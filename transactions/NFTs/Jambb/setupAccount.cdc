import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import Vouchers from "../../../contracts/NFTs/Jambb/Vouchers.cdc"

transaction() {
    prepare(signer: AuthAccount) {
	    // If the account doesn't already have a collection
	    if signer.borrow<&Vouchers.Collection>(from: Vouchers.CollectionStoragePath) == nil {
		    // Create a new empty collection and save it to the account
		    signer.save(<-Vouchers.createEmptyCollection(), to: Vouchers.CollectionStoragePath)
		    // Create a public capability to the collection that exposes the Collection interface
		    signer.link<&Vouchers.Collection{NonFungibleToken.CollectionPublic, Vouchers.CollectionPublic}>(Vouchers.CollectionPublicPath, target: Vouchers.CollectionStoragePath)
	    }
    }
}