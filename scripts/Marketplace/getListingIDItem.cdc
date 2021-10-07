import Marketplace from "../../contracts/Marketplace.cdc"

pub fun main(listingID: UInt64): Marketplace.Item? {
    return Marketplace.getListingIDItem(listingID: listingID)
}
