import NFTStorefront from 0x47d3edb601d7b478
import NonFungibleToken from 0x631e88ae7f1d7c20
import DarkCountry from 0x47d3edb601d7b478
import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import StorefrontData from 0x47d3edb601d7b478

transaction(itemID: UInt64, saleItemPrice: UFix64, account: Address) {
    let FUSDReceiver: Capability<&FUSD.Vault{FungibleToken.Receiver}>
    let DarkCountryProvider: Capability<&DarkCountry.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(acct: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let DarkCountryCollectionProviderPrivatePath = /private/DarkCountryCollectionProviderForNFTStorefront

        self.FUSDReceiver = acct.getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)!
        assert(self.FUSDReceiver.borrow()!= nil, message: "Missing or mis-typed FUSD receiver")

        if !acct.getCapability<&DarkCountry.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(DarkCountryCollectionProviderPrivatePath)!.check() {
            acct.link<&DarkCountry.Collection{NonFungibleToken.Provider,  NonFungibleToken.CollectionPublic}>(DarkCountryCollectionProviderPrivatePath, target: /storage/DarkCountryCollection)
        }

        self.DarkCountryProvider = acct.getCapability<&DarkCountry.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(DarkCountryCollectionProviderPrivatePath)!
        assert(self.DarkCountryProvider.borrow() != nil, message: "Missing or mis-typed DarkCountry.Collection provider")

        self.storefront = acct.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")    
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.FUSDReceiver,
            amount: saleItemPrice
        )
        let sale = self.storefront.createSaleOffer(
            nftProviderCapability: self.DarkCountryProvider,
            nftType: Type<@DarkCountry.NFT>(),
            nftID: itemID,
            salePaymentVaultType: Type<@FUSD.Vault>(),
            saleCuts: [saleCut]
        )
        let storefrontRef = getAccount(account)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath)
                .borrow()
                ?? panic("Could not borrow public storefront from address")
        let saleOffer = storefrontRef.borrowSaleOffer(saleOfferResourceID: sale)
            ?? panic("No item with that ID")
        StorefrontData.StoreData(id : saleOffer.getDetails().nftID, price : saleOffer.getDetails().salePrice, nftType : saleOffer.getDetails().nftType, resourceID: sale)
    }
}
