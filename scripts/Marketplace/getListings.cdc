import NFTStorefront from "../../contracts/NFTStorefront.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"

pub fun main(offset: Int, limit: Int): DipslayResult {
    var listingIds: [UInt64] = Marketplace.getListingIDs()

    var displayItems: [ListingDisplayItem] = []
    var limit = limit
    var skipCount = 0
    var index = offset
    while index < listingIds.length && limit >= 0 {
        let listingID = listingIds[index]
        if let item = getListingDisplayItem(listingID: listingID) {
            displayItems.append(item)
            limit = limit - 1
        } else {
            skipCount = skipCount + 1
        }
        index = index + 1
    }

    return DipslayResult(displayItems: displayItems, skipCount: skipCount)
}

pub struct ListingDisplayItem {

    pub let listingID: UInt64

    pub var address: Address

    // The identifier of type of the NonFungibleToken.NFT that is being listed.
    pub let nftType: String
    // The ID of the NFT within that type.
    pub let nftID: UInt64
    // The identifier of type of the FungibleToken that payments must be made in.
    pub let salePaymentVaultType: String
    // The amount that must be paid in the specified FungibleToken.
    pub let salePrice: UFix64
    // This specifies the division of payment between recipients.
    pub let saleCuts: [NFTStorefront.SaleCut]

    pub let timestamp: UFix64

    init (
        listingID: UInt64,
        address: Address,
        nftType: String,
        nftID: UInt64,
        salePaymentVaultType: String,
        salePrice: UFix64,
        saleCuts: [NFTStorefront.SaleCut],
        timestamp: UFix64
    ) {
        self.listingID = listingID
        self.address = address
        self.nftType = nftType
        self.nftID = nftID
        self.salePaymentVaultType = salePaymentVaultType
        self.salePrice = salePrice
        self.saleCuts = saleCuts
        self.timestamp = timestamp
    }
}

pub struct DipslayResult {
    pub let displayItems: [ListingDisplayItem]
    pub let skipCount: Int

    init(displayItems: [ListingDisplayItem], skipCount: Int) {
        self.displayItems = displayItems
        self.skipCount = skipCount
    }
}

pub fun getListingDisplayItem(listingID: UInt64): ListingDisplayItem? {
    if let item = Marketplace.getListingIDItem(listingID: listingID) {
        if let storefrontPublic = item.storefrontPublicCapability.borrow() {
            if let listingPublic = storefrontPublic.borrowListing(listingResourceID: listingID) {
                let listingDetails = listingPublic.getDetails()

                if listingDetails.purchased == false {
                    return ListingDisplayItem(
                        listingID: listingID,
                        address: item.storefrontPublicCapability.address,
                        nftType: listingDetails.nftType.identifier,
                        nftID: listingDetails.nftID,
                        salePaymentVaultType: listingDetails.salePaymentVaultType.identifier,
                        salePrice: listingDetails.salePrice,
                        saleCuts: listingDetails.saleCuts,
                        timestamp: item.timestamp
                    )
                }
            }
        }
    }

    return nil
}