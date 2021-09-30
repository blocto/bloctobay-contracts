import Marketplace from "../../contracts/Marketplace.cdc"
import ExampleNFT from "../../contracts/NFTs/ExampleNFT.cdc"

pub fun main() {
    log({"saleCutRequirements": Marketplace.getSaleCutRequirements(nftType: Type<@ExampleNFT.NFT>())})

    for listingID in Marketplace.getListingIDs() {
        let item = Marketplace.getListingIDItem(listingID: listingID)!
        logItem(item, listingID: listingID)
    }
}

pub fun logItem(_ item: Marketplace.Item, listingID: UInt64) {
    let storefrontPublic = item.storefrontPublicCapability.borrow() ?? panic("Could not borrow public storefront from capability")
    let listingPublic = storefrontPublic.borrowListing(listingResourceID: listingID) ?? panic("no listing id")
    let listingDetails = listingPublic.getDetails()
    log({"id": listingID, "nftID": listingDetails.nftID})
    log({"price": listingDetails.salePrice, "tiemstamp": item.timestamp})
}
