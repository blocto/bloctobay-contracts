//import FungibleToken from 0xf233dcee88fe0abe 
//import NonFungibleToken from 0x1d7e57aa55817448
//import FlowToken from 0x1654653399040a61
//import VIV3 from 0xc2d564119d2e5c3d
import Evolution from 0xf8d6e0586b0a20c7

transaction {
    //let vault: @FlowToken.Vault

    prepare(acct: AuthAccount) {
        // Create a collection to store the purchase if none present
        if acct.borrow<&Evolution.Collection>(from: /storage/f8d6e0586b0a20c7_Evolution_Collection) == nil {
            let collection <- Evolution.createEmptyCollection() as! @Evolution.Collection

            acct.save(<-collection, to: /storage/f8d6e0586b0a20c7_Evolution_Collection)

            acct.link<&{Evolution.EvolutionCollectionPublic}>(/public/f8d6e0586b0a20c7_Evolution_Collection, target: /storage/f8d6e0586b0a20c7_Evolution_Collection)
        }
    }    
}    