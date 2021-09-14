import FungibleToken from "./FungibleToken.cdc"
import NFTStorefront from "./NFTStorefront.cdc"

pub contract Marketplace {

    pub struct Item {
        pub let storefrontPublicCapability: Capability<&{NFTStorefront.StorefrontPublic}>

        // NFTStoreFront.Listing resource uuid
        pub let listingID: UInt64

        // Store listingDetails to prevent vanishing from storefrontPublicCapability
        pub let listingDetails: NFTStorefront.ListingDetails

        // When to add this item to marketplace
        pub let timestamp: UFix64

        init(storefrontPublicCapability: Capability<&{NFTStorefront.StorefrontPublic}>, listingID: UInt64) {
            self.storefrontPublicCapability = storefrontPublicCapability
            self.listingID = listingID
            let storefrontPublic = storefrontPublicCapability.borrow() ?? panic("Could not borrow public storefront from capability")
            let listingPublic = storefrontPublic.borrowListing(listingResourceID: listingID) ?? panic("no listing id")
            self.listingDetails = listingPublic.getDetails()
            self.timestamp = getCurrentBlock().timestamp
        }
    }

    pub struct SaleCutRequirement {
        pub let receiver: Capability<&{FungibleToken.Receiver}>

        pub let ratio: UFix64

        init(receiver: Capability<&{FungibleToken.Receiver}>, ratio: UFix64) {
            self.receiver = receiver
            assert(ratio <= 1.0, message: "ratio must be less than or equal to 1.0")
            self.ratio = ratio
        }
    }

    pub let MarketplaceAdminStoragePath: StoragePath

    // listingID order by time, listingID asc
    pub let listingIDsByTime: [UInt64]

    // listingID order by price, listingID asc
    pub let listingIDsByPrice: [UInt64]

    // collection identifier => listingIDs order by time, listingID asc
    pub let collectionListingIDsByTime: {String: [UInt64]}

    // collection identifier => listingIDs order by price, listingID asc
    pub let collectionListingIDsByPrice: {String: [UInt64]}

    // listingID => item
    pub let listingIDItems: {UInt64: Item}

    // collection identifier => (NFT id => listingID)
    pub let collectionNFTListingIDs: {String: {UInt64: UInt64}}

    // collection identifier => SaleCutRequirements
    pub let saleCutRequirements: {String: [SaleCutRequirement]}

    // Administrator
    //
    pub resource Administrator {

        pub fun updateSaleCutRequirements(_ requirements: [SaleCutRequirement], nftType: Type) {
            Marketplace.saleCutRequirements[nftType.identifier] = requirements
        }

        pub fun forceRemoveListing(id: UInt64) {
            if let item = Marketplace.listingIDItems[id] {
                Marketplace.removeItem(item)
            }
        }
    }

    pub fun addListing(id: UInt64, storefrontPublicCapability: Capability<&{NFTStorefront.StorefrontPublic}>) {
        pre {
            self.listingIDItems[id] == nil: "could not add duplicate listing"
        }

        let item = Item(storefrontPublicCapability: storefrontPublicCapability, listingID: id)

        // check the item hasn't been purchased
        if item.listingDetails.purchased == true {
            return
        }

        // check duplicate NFT
        let nftListingIDs = self.collectionNFTListingIDs[item.listingDetails.nftType.identifier] ?? {}
        assert(nftListingIDs[item.listingDetails.nftID] == nil, message: "could not add duplicate NFT")

        // check sale cut
        let requirements = self.saleCutRequirements[item.listingDetails.nftType.identifier] ?? []
        for requirement in requirements {
            let salePrice = item.listingDetails.salePrice * requirement.ratio

            var match = false
            for saleCut in item.listingDetails.saleCuts {
                if saleCut.receiver.address == requirement.receiver.address {
                    if saleCut.amount == salePrice {
                        match = true
                    }
                    break
                }
            }

            assert(match == true, message: "saleCut must be follow requirements")
        }

        // all by time
        var index = self.getIndexToAddlistingIDsByTime(item: item, items: self.listingIDsByTime)
        self.listingIDsByTime.insert(at: index, id)

        // all by price
        index = self.getIndexToAddlistingIDsByPrice(item: item, items: self.listingIDsByPrice)
        self.listingIDsByPrice.insert(at: index, id)

        // collection by time
        var items = self.collectionListingIDsByTime[item.listingDetails.nftType.identifier] ?? []
        index = self.getIndexToAddlistingIDsByTime(item: item, items: items)
        items.insert(at: index, id)
        self.collectionListingIDsByTime[item.listingDetails.nftType.identifier] = items

        // collection by price
        items = self.collectionListingIDsByPrice[item.listingDetails.nftType.identifier] ?? []
        index = self.getIndexToAddlistingIDsByPrice(item: item, items: items)
        items.insert(at: index, id)
        self.collectionListingIDsByPrice[item.listingDetails.nftType.identifier] = items

        // update index data
        self.listingIDItems[id] = item
        nftListingIDs[item.listingDetails.nftID] = id
        self.collectionNFTListingIDs[item.listingDetails.nftType.identifier] = nftListingIDs
    }

    // Anyone can remove it if the listing item has been removed or purchased.
    pub fun removeListing(id: UInt64) {
        if let item = self.listingIDItems[id] {
            // Skip if the listing item haven't been purchased
            if let storefrontPublic = item.storefrontPublicCapability.borrow() {
                if let listingItem = storefrontPublic.borrowListing(listingResourceID: id) {
                    let listingDetails = listingItem.getDetails()
                    if listingDetails.purchased == false {
                        return
                    }
                }
            }

            self.removeItem(item)
        }
    }

    access(contract) fun removeItem(_ item: Item) {
        // remove from listingIDsByPrice
        if let index = self.getIndexToRemovelistingIDsByPrice(item: item, items: self.listingIDsByPrice) {
            self.listingIDsByPrice.remove(at: index)
        }

        // remove from listingIDsByTime
        if let index = self.getIndexToRemovelistingIDsByTime(item: item, items: self.listingIDsByTime) {
            self.listingIDsByTime.remove(at: index)
        }

        // remove from collectionListingIDsByPrice
        var items = self.collectionListingIDsByPrice[item.listingDetails.nftType.identifier] ?? []
        if let index = self.getIndexToRemovelistingIDsByPrice(item: item, items: items) {
            items.remove(at: index)
            self.collectionListingIDsByPrice[item.listingDetails.nftType.identifier] = items
        }
        // remove from collectionListingIDsByTime
        items = self.collectionListingIDsByTime[item.listingDetails.nftType.identifier] ?? []
        if let index = self.getIndexToRemovelistingIDsByTime(item: item, items: items) {
            items.remove(at: index)
            self.collectionListingIDsByTime[item.listingDetails.nftType.identifier] = items
        }

        self.listingIDItems.remove(key: item.listingID)
        let nftListingIDs = self.collectionNFTListingIDs[item.listingDetails.nftType.identifier] ?? {}
        nftListingIDs.remove(key: item.listingDetails.nftID)
        self.collectionNFTListingIDs[item.listingDetails.nftType.identifier] = nftListingIDs
    }

    // Run binary search to find out the index to insert
    access(contract) fun getIndexToAddlistingIDsByPrice(item: Item, items: [UInt64]): Int {
        var startIndex = 0
        var endIndex = items.length

        while startIndex < endIndex {
            var midIndex = startIndex + (endIndex - startIndex) / 2
            var midListingID = items[midIndex]!
            var midItem = self.listingIDItems[midListingID]!

            if item.listingDetails.salePrice > midItem.listingDetails.salePrice {
                startIndex = midIndex + 1
            } else if item.listingDetails.salePrice < midItem.listingDetails.salePrice {
                endIndex = midIndex
            } else {
                if item.listingID > midListingID {
                    startIndex = midIndex + 1
                }  else if item.listingID < midListingID {
                    endIndex = midIndex
                } else {
                    panic("could not add duplicate listing")
                }
            }
        }
        return startIndex
    }

    // Run reverse for loop to find out the index to insert
    access(contract) fun getIndexToAddlistingIDsByTime(item: Item, items: [UInt64]): Int {
        var index = items.length - 1
        while index >= 0 {
            let currentListingID = items[index]
            let currentItem = self.listingIDItems[currentListingID]!

            if item.timestamp == currentItem.timestamp {
                if item.listingID > currentListingID {
                    break
                }
                index = index - 1
            } else {
                break
            }
        }
        return index + 1
    }

    // Run binary search to find the listing ID
    access(contract) fun getIndexToRemovelistingIDsByTime(item: Item, items: [UInt64]): Int? {
        var startIndex = 0
        var endIndex = items.length

        while startIndex < endIndex {
            var midIndex = startIndex + (endIndex - startIndex) / 2
            var midListingID = items[midIndex]!
            var midItem = self.listingIDItems[midListingID]!

            if item.timestamp > midItem.timestamp {
                startIndex = midIndex + 1
            } else if item.timestamp < midItem.timestamp {
                endIndex = midIndex
            } else {
                if item.listingID > midListingID {
                    startIndex = midIndex + 1
                }  else if item.listingID < midListingID {
                    endIndex = midIndex
                } else {
                    return midIndex
                }
            }
        }
        return nil
    }

    // Run binary search to find the listing ID
    access(contract) fun getIndexToRemovelistingIDsByPrice(item: Item, items: [UInt64]): Int? {
        var startIndex = 0
        var endIndex = items.length

        while startIndex < endIndex {
            var midIndex = startIndex + (endIndex - startIndex) / 2
            var midListingID = items[midIndex]!
            var midItem = self.listingIDItems[midListingID]!

            if item.listingDetails.salePrice > midItem.listingDetails.salePrice {
                startIndex = midIndex + 1
            } else if item.listingDetails.salePrice < midItem.listingDetails.salePrice {
                endIndex = midIndex
            } else {
                if item.listingID > midListingID {
                    startIndex = midIndex + 1
                }  else if item.listingID < midListingID {
                    endIndex = midIndex
                } else {
                    return midIndex
                }
            }
        }
        return nil
    }

    init () {
        self.MarketplaceAdminStoragePath = /storage/marketplaceAdmin

        self.listingIDsByTime = []
        self.listingIDsByPrice = []
        self.collectionListingIDsByTime = {}
        self.collectionListingIDsByPrice = {}
        self.listingIDItems = {}
        self.collectionNFTListingIDs = {}
        self.saleCutRequirements = {}

        let admin <- create Administrator()
        self.account.save(<-admin, to: self.MarketplaceAdminStoragePath)
    }
}