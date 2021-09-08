import NFTStorefront from 0x47d3edb601d7b478
import NonFungibleToken from 0x631e88ae7f1d7c20
import DarkCountry from 0x47d3edb601d7b478
import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import StorefrontData from 0x47d3edb601d7b478

transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let exampleNFTCollection: &DarkCountry.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let saleOffer: &NFTStorefront.SaleOffer{NFTStorefront.SaleOfferPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&DarkCountry.Collection>(from: DarkCountry.CollectionStoragePath) == nil {
            // create a new empty collection
            let collection <- DarkCountry.createEmptyCollection()
    
                // save it to the account
            signer.save(<-collection, to: DarkCountry.CollectionStoragePath)
    
                // create a public capability for the collection
            signer.link<&DarkCountry.Collection{NonFungibleToken.CollectionPublic, DarkCountry.DarkCountryCollectionPublic}>(DarkCountry.CollectionPublicPath, target: DarkCountry.CollectionStoragePath)
        }
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.saleOffer = self.storefront.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID)
                    ?? panic("No Offer with that ID in Storefront")
        let price = self.saleOffer.getDetails().salePrice

        let mainFUSDVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Could not borrow reference to the owner's Vault!")
        self.paymentVault <- mainFUSDVault.withdraw(amount: price)

        self.exampleNFTCollection = signer.borrow<&DarkCountry.Collection{NonFungibleToken.Receiver}>(
            from: DarkCountry.CollectionStoragePath
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.saleOffer.accept(
            payment: <-self.paymentVault
        )

        self.exampleNFTCollection.deposit(token: <-item)
        StorefrontData.remove(nftID: self.saleOffer.getDetails().nftID)
        self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID)

    }

}
