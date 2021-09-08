import Art from 0xd796ff17107bbff6
    
pub fun main (address:Address, itemId: UInt64) : String?? {
    let meta = Art.getContentForArt(address: address, artId: itemId)
    return meta
}