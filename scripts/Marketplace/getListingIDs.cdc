import NFTStorefront from "../../contracts/NFTStorefront.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"

pub fun main(): [UInt64] {
    return Marketplace.getListingIDs()
}
