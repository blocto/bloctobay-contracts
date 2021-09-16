import Art from "../../../contracts/NFTs/Versus/Art.cdc"
    
pub fun main (address: Address, itemId: UInt64): String? {
    let meta = Art.getContentForArt(address: address, artId: itemId)
    return meta
}