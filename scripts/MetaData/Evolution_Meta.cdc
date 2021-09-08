import Evolution from 0xf4264ac8f3256818
    
pub fun main (itemId: UInt32) : {String: String}? {
    let meta = Evolution.getItemMetadata(itemId: itemId)
    return meta
}