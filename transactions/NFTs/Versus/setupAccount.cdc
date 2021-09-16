import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import Art from "../../../contracts/NFTs/Versus/Art.cdc"

transaction {

    prepare(signer: AuthAccount) {
        if signer.borrow<&Art.Collection>(from: Art.CollectionStoragePath) == nil {
            signer.save(<-Art.createEmptyCollection(), to: Art.CollectionStoragePath)
            signer.link<&Art.Collection{Art.CollectionPublic, NonFungibleToken.CollectionPublic}>(
                Art.CollectionPublicPath,
                target: Art.CollectionStoragePath
            )
        }
        
        if signer.getCapability(Art.CollectionPublicPath)!
            .borrow<&Art.Collection{Art.CollectionPublic, NonFungibleToken.CollectionPublic}>() == nil {
                signer.unlink(Art.CollectionPublicPath)
                signer.link<&Art.Collection{Art.CollectionPublic, NonFungibleToken.CollectionPublic}>(
                    Art.CollectionPublicPath,
                    target: Art.CollectionStoragePath
                )
        }
    }
}