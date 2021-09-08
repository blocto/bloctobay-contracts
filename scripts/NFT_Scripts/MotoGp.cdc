import NonFungibleToken from 0x1d7e57aa55817448
import MotoGPCard from 0xa49cc0ee46c54bfb
import MotoGPPack from 0xa49cc0ee46c54bfb

// This script returns an array of all the NFT IDs in an account's collection.

pub fun main(address: Address): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account.getCapability(/public/motogpCardCollection)!.borrow<&{MotoGPCard.ICardCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
