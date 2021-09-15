import FungibleToken from "../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../contracts/Marketplace.cdc"
import FUSD from "../../../contracts/FTs/FUSD.cdc"
import ExampleNFT from "../../../contracts/NFTs/ExampleNFT.cdc"

transaction(saleItemID: UInt64, saleItemPrice: UFix64) {
    let fusdReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let exampleNFTProvider: Capability<&ExampleNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let storefrontPublic: Capability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>

    prepare(signer: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let exampleNFTCollectionProviderPrivatePath = /private/exampleNFTCollectionProviderForNFTStorefront

        self.fusdReceiver = signer.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.fusdReceiver.borrow() != nil, message: "Missing or mis-typed FUSD receiver")

        if !signer.getCapability<&ExampleNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(exampleNFTCollectionProviderPrivatePath)!.check() {
            signer.link<&ExampleNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(exampleNFTCollectionProviderPrivatePath, target: /storage/NFTCollection)
        }

        self.exampleNFTProvider = signer.getCapability<&ExampleNFT.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(exampleNFTCollectionProviderPrivatePath)!
        assert(self.exampleNFTProvider.borrow() != nil, message: "Missing or mis-typed ExampleNFT.Collection provider")

        self.storefront = signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        self.storefrontPublic = signer.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        assert(self.storefrontPublic.borrow() != nil, message: "Could not borrow public storefront from address")
    }

    execute {
        let requirements = Marketplace.getSaleCutRequirements(nftType: Type<@ExampleNFT.NFT>())
        var remainingPrice = saleItemPrice

        var saleCuts: [NFTStorefront.SaleCut] = []
        for requirement in requirements {
            let price = saleItemPrice * requirement.ratio
            saleCuts.append(NFTStorefront.SaleCut(
                receiver: requirement.receiver,
                amount: price
            ))
            remainingPrice = remainingPrice - price
        }
        saleCuts.append(NFTStorefront.SaleCut(
            receiver: self.fusdReceiver,
            amount: remainingPrice
        ))

        let id = self.storefront.createListing(
            nftProviderCapability: self.exampleNFTProvider,
            nftType: Type<@ExampleNFT.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FUSD.Vault>(),
            saleCuts: saleCuts
        )
        Marketplace.addListing(id: id, storefrontPublicCapability: self.storefrontPublic)
    }
}