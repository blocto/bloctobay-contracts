import NonFungibleToken from "../../../../contracts/NonFungibleToken.cdc"
import MotoGPPack from "../../../../contracts/NFTs/MotoGP/MotoGPPack.cdc"

// This script returns an array of all the NFT IDs in an account's collection.

pub fun main(address: Address): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account.getCapability(/public/motogpPackCollection)!.borrow<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs()
}