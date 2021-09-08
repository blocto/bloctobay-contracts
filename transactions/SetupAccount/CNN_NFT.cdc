
import NonFungibleToken from 0xf8d6e0586b0a20c7
import CNN_NFT from 0xf8d6e0586b0a20c7

transaction {
    //let vault: @FlowToken.Vault

    prepare(acct: AuthAccount) {
        // Create a collection to store the purchase if none present
        if acct.borrow<&CNN_NFT.Collection>(from: /storage/CNN_NFTCollection) == nil {
            let collection <- CNN_NFT.createEmptyCollection() as! @CNN_NFT.Collection

            acct.save(<-collection, to: /storage/CNN_NFTCollection)

            acct.link<&{CNN_NFT.CNN_NFTCollectionPublic}>(/public/CNN_NFTCollection, target: /storage/CNN_NFTCollection)
        }
    }    
}    