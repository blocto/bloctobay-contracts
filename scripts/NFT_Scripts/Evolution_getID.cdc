
import NonFungibleToken from 0xf8d6e0586b0a20c7
import Evolution from 0xf8d6e0586b0a20c7

// This script returns an array of all the NFT IDs in an account's collection.

pub fun main(address: Address): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account.getCapability(/public/f8d6e0586b0a20c7_Evolution_Collection)!.borrow<&{Evolution.EvolutionCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
