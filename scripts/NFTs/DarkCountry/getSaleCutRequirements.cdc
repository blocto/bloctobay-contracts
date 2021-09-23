import Marketplace from "../../../contracts/Marketplace.cdc"
import DarkCountry from "../../../contracts/NFTs/DarkCountry.cdc"

pub fun main(): [Marketplace.SaleCutRequirement] {
    return Marketplace.getSaleCutRequirements(nftType: Type<@DarkCountry.NFT>())
}