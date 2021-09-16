import Evolution from "../../../contracts/NFTs/Evolution.cdc"

pub fun main (itemId: UInt32) : {String: String}? {
    let meta = Evolution.getItemMetadata(itemId: itemId)
    return meta
}