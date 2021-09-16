import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import Evolution from "../../../contracts/NFTs/Evolution.cdc"

transaction {

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&Evolution.Collection>(from: /storage/f4264ac8f3256818_Evolution_Collection) == nil {
            let collection <- Evolution.createEmptyCollection() as! @Evolution.Collection

            signer.save(<-collection, to: /storage/f4264ac8f3256818_Evolution_Collection)

            signer.link<&{Evolution.EvolutionCollectionPublic, NonFungibleToken.CollectionPublic}>(
                /public/f4264ac8f3256818_Evolution_Collection,
                target: /storage/f4264ac8f3256818_Evolution_Collection)
        }
    }
}