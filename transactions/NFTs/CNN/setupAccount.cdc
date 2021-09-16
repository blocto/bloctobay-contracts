import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import CNN_NFT from "../../../contracts/NFTs/CNN_NFT.cdc"

transaction {

    prepare(signer: AuthAccount) {
	    // If the account doesn''t already have a collection
	    if signer.borrow<&CNN_NFT.Collection>(from: CNN_NFT.CollectionStoragePath) == nil {

		    // Create a new empty collection and save it to the account
		    signer.save(<-CNN_NFT.createEmptyCollection(), to: CNN_NFT.CollectionStoragePath)

		    // Create a public capability to the _GENERAL_NFT collection
		    // that exposes the Collection interface
		    signer.link<&CNN_NFT.Collection{NonFungibleToken.CollectionPublic, CNN_NFT.CNN_NFTCollectionPublic}>(
			    CNN_NFT.CollectionPublicPath,
			    target: CNN_NFT.CollectionStoragePath
		    )
	    }
    }
}