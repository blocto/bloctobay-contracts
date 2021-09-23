import Marketplace from "../../../contracts/Marketplace.cdc"
import DarkCountry from "../../../contracts/NFTs/DarkCountry.cdc"

pub fun main(): [UInt64] {
    return Marketplace.getCollectionListingIDsByPrice(nftType: Type<@DarkCountry.NFT>())
}