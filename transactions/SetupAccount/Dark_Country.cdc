import NonFungibleToken from 0xf8d6e0586b0a20c7
import DarkCountry from 0xf8d6e0586b0a20c7

transaction {
    //let vault: @FlowToken.Vault
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&DarkCountry.Collection>(from: DarkCountry.CollectionStoragePath) == nil {
    
            // create a new empty collection
            let collection <- DarkCountry.createEmptyCollection()
    
                // save it to the account
            signer.save(<-collection, to: DarkCountry.CollectionStoragePath)
    
                // create a public capability for the collection
            signer.link<&DarkCountry.Collection{NonFungibleToken.CollectionPublic, DarkCountry.DarkCountryCollectionPublic}>(DarkCountry.CollectionPublicPath, target: DarkCountry.CollectionStoragePath)
        }
    }    
}    