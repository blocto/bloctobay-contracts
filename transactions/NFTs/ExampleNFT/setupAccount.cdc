import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../../../contracts/NFTs/ExampleNFT.cdc"

transaction {

    prepare(account: AuthAccount) {
        // Create a collection to store the purchase if none present
        if account.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection) == nil {
            // Create a Collection resource and save it to storage
            let collection <- ExampleNFT.createEmptyCollection()
            account.save(<-collection, to: /storage/NFTCollection)

            // create a public capability for the collection
            account.link<&{NonFungibleToken.CollectionPublic}>(
                /public/NFTCollection,
                target: /storage/NFTCollection
            )
        }
    }
}