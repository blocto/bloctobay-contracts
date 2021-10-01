import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import Collectible from "../../../contracts/NFTs/xtingles/Collectible.cdc"

transaction() {
  prepare(signer: AuthAccount) {
	  // If the account doesn''t already have a collection
	  if signer.borrow<&Collectible.Collection>(from: Collectible.CollectionStoragePath) == nil {

		  // Create a new empty collection and save it to the account
		  signer.save(<-Collectible.createEmptyCollection(), to: Collectible.CollectionStoragePath)

		  // Create a public capability to the _GENERAL_NFT collection
		  // that exposes the Collection interface
		  signer.link<&Collectible.Collection{NonFungibleToken.CollectionPublic,Collectible.CollectionPublic}>(
			Collectible.CollectionPublicPath,
			  target: Collectible.CollectionStoragePath
		  )
	  }
  }
}