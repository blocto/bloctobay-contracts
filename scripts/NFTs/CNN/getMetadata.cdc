import CNN_NFT from "../../../contracts/NFTs/CNN_NFT.cdc"

pub fun main(id: UInt32): {String: String}? {
    let meta = CNN_NFT.getSetMetadata(setId: id)
    return meta
}
