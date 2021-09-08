import CNN_NFT from 0x329feb3ab062d289

pub fun main (setId: UInt32): {String: String}? {
 let meta = CNN_NFT.getSetMetadata(setId: setId)
 return meta
}
