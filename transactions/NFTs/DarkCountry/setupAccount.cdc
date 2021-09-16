import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import DarkCountry from "../../../contracts/NFTs/DarkCountry.cdc"

transaction() {

    prepare(signer: AuthAccount) {
	    if signer.borrow<&DarkCountry.Collection>(from: DarkCountry.CollectionStoragePath) == nil {
            signer.save(<-DarkCountry.createEmptyCollection(), to: DarkCountry.CollectionStoragePath)
            signer.link<&DarkCountry.Collection{DarkCountry.DarkCountryCollectionPublic, NonFungibleToken.CollectionPublic}>(
                DarkCountry.CollectionPublicPath,
                target: DarkCountry.CollectionStoragePath
            )
        }

        if signer.getCapability(DarkCountry.CollectionPublicPath)!
            .borrow<&DarkCountry.Collection{DarkCountry.DarkCountryCollectionPublic, NonFungibleToken.CollectionPublic}>() == nil {
            signer.unlink(DarkCountry.CollectionPublicPath)
            signer.link<&DarkCountry.Collection{DarkCountry.DarkCountryCollectionPublic, NonFungibleToken.CollectionPublic}>(
                DarkCountry.CollectionPublicPath,
                target: DarkCountry.CollectionStoragePath
            )
        }
    }
}