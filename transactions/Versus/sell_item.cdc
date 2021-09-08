import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import Art from 0xd796ff17107bbff6
import NFTStorefront from 0xf8d6e0586b0a20c7

transaction(itemID: UInt64, saleItemPrice: UFix64) {
    let flowReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let ArtProvider: Capability<&Art.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(acct: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let ArtCollectionProviderPrivatePath = /private/ArtCollectionProviderForNFTStorefront
        if(signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil) {
            signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }

        self.flowReceiver = acct.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(from: /public/fusdMinterProxy)!
        assert(self.flowReceiver.borrow() != nil, message: "Missing or mis-typed FUSD receiver")

        if !acct.getCapability<&Art.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ArtCollectionProviderPrivatePath)!.check() {
            acct.link<&Art.Collection{NonFungibleToken.Provider,  NonFungibleToken.CollectionPublic}>(ArtCollectionProviderPrivatePath, target: /storage/versusArtCollection)
        }

        self.ArtProvider = acct.getCapability<&Art.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ArtCollectionProviderPrivatePath)!
        assert(self.ArtProvider.borrow() != nil, message: "Missing or mis-typed Art.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.flowReceiver,
            amount: saleItemPrice
        )
        self.storefront.createSaleOffer(
            nftProviderCapability: self.ArtProvider,
            nftType: Type<@Art.NFT>(),
            nftID: itemID,
            salePaymentVaultType: Type<@FUSD.Vault>(),
            saleCuts: [saleCut]
        )
    }
}
