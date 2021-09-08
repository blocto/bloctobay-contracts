import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import MotoGPCard from 0xa49cc0ee46c54bfb
import MotoGPPack from 0xa49cc0ee46c54bfb
import NFTStorefront from 0xf8d6e0586b0a20c7

transaction(itemID: UInt64, saleItemPrice: UFix64) {
    let flowReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let MotoGPCardProvider: Capability<&MotoGPCard.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(acct: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let MotoGPCardCollectionProviderPrivatePath = /private/MotoGPCardCollectionProviderForNFTStorefront
        if(signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil) {
            signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }

        self.flowReceiver = acct.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(from: /public/fusdMinterProxy)!
        assert(self.flowReceiver.borrow() != nil, message: "Missing or mis-typed FUSD receiver")

        if !acct.getCapability<&MotoGPCard.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MotoGPCardCollectionProviderPrivatePath)!.check() {
            acct.link<&MotoGPCard.Collection{NonFungibleToken.Provider,  NonFungibleToken.CollectionPublic}>(MotoGPCardCollectionProviderPrivatePath, target: /storage/motogpCardCollection)
        }

        self.MotoGPCardProvider = acct.getCapability<&MotoGPCard.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(MotoGPCardCollectionProviderPrivatePath)!
        assert(self.MotoGPCardProvider.borrow() != nil, message: "Missing or mis-typed MotoGPCard.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.flowReceiver,
            amount: saleItemPrice
        )
        self.storefront.createSaleOffer(
            nftProviderCapability: self.MotoGPCardProvider,
            nftType: Type<@MotoGPCard.NFT>(),
            nftID: itemID,
            salePaymentVaultType: Type<@FUSD.Vault>(),
            saleCuts: [saleCut]
        )
    }
}
