import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import MotoGPCard from "../../../contracts/NFTs/MotoGP/MotoGPCard.cdc"
import MotoGPPack from "../../../contracts/NFTs/MotoGP/MotoGPPack.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&MotoGPPack.Collection>(from: /storage/motogpPackCollection) == nil {
		    let packCollection <- MotoGPPack.createEmptyCollection()
		    signer.save(<-packCollection, to: /storage/motogpPackCollection)
		    signer.link<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic, MotoGPPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>(/public/motogpPackCollection, target: /storage/motogpPackCollection)
	    }

	    if signer.getCapability(/public/motogpPackCollection)!
            .borrow<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic, MotoGPPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>() == nil {
            signer.unlink(/public/motogpPackCollection)
            signer.link<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic, MotoGPPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>(
                /public/motogpPackCollection,
                target: /storage/motogpPackCollection
            )
        }

	    if signer.borrow<&MotoGPCard.Collection>(from: /storage/motogpCardCollection) == nil {
		    let cardCollection <- MotoGPCard.createEmptyCollection()
		    signer.save(<-cardCollection, to: /storage/motogpCardCollection)
		    signer.link<&MotoGPCard.Collection{MotoGPCard.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/motogpCardCollection, target: /storage/motogpCardCollection)
	    }

	    if signer.getCapability(/public/motogpCardCollection)!
            .borrow<&MotoGPCard.Collection{MotoGPCard.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>() == nil {
            signer.unlink(/public/motogpCardCollection)
            signer.link<&MotoGPCard.Collection{MotoGPCard.ICardCollectionPublic, NonFungibleToken.CollectionPublic}>(
                /public/motogpCardCollection,
                target: /storage/motogpCardCollection
            )
        }
    }
}
