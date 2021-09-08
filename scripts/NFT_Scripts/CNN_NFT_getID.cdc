import NonFungibleToken from 0xf8d6e0586b0a20c7
import CNN_NFT from 0xf8d6e0586b0a20c7

// This script returns an array of all the NFT IDs in an account's collection.

pub fun main(address: Address): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account.getCapability(/public/CNN_NFTCollection)!.borrow<&{CNN_NFT.CNN_NFTCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
