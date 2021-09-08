
import KittyItems from 0xf56067d705179c82

transactions (signer : Address, id :UInt64, newPrice : UFix64 ) {

    execute()
    {
        signer = getAccount(signer)

        let owner = signer
            .getCapability(KittyItems.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")    
            
        owner.ownedNFTs[id].price = newPrice    
    }
}