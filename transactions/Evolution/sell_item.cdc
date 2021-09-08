import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import Evolution from 0xf4264ac8f3256818
import NFTStorefront from 0xf8d6e0586b0a20c7

transaction(itemID: UInt64, saleItemPrice: UFix64) {
    let flowReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let EvolutionProvider: Capability<&Evolution.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(acct: AuthAccount) {
        if(signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil) {
            signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let EvolutionCollectionProviderPrivatePath = /private/EvolutionCollectionProviderForNFTStorefront

        self.flowReceiver = acct.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(from: /public/fusdMinterProxy)!
        assert(self.flowReceiver.borrow() != nil, message: "Missing or mis-typed FUSD receiver")

        if !acct.getCapability<&Evolution.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(EvolutionCollectionProviderPrivatePath)!.check() {
            acct.link<&Evolution.Collection{NonFungibleToken.Provider,  NonFungibleToken.CollectionPublic}>(EvolutionCollectionProviderPrivatePath, target: /storage/f8d6e0586b0a20c7_Evolution_Collection)
        }

        self.EvolutionProvider = acct.getCapability<&Evolution.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(EvolutionCollectionProviderPrivatePath)!
        assert(self.EvolutionProvider.borrow() != nil, message: "Missing or mis-typed Evolution.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.flowReceiver,
            amount: saleItemPrice
        )
        self.storefront.createSaleOffer(
            nftProviderCapability: self.EvolutionProvider,
            nftType: Type<@Evolution.NFT>(),
            nftID: itemID,
            salePaymentVaultType: Type<@FUSD.Vault>(),
            saleCuts: [saleCut]
        )
    }
}
