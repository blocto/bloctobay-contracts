import FungibleToken from "../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../contracts/Marketplace.cdc"
import FUSD from "../../../contracts/FTs/FUSD.cdc"
import ExampleNFT from "../../../contracts/NFTs/ExampleNFT.cdc"

transaction(listingResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let exampleNFTCollection: &ExampleNFT.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        let mainFlowVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from signer storage")
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        self.exampleNFTCollection = signer.borrow<&ExampleNFT.Collection{NonFungibleToken.Receiver}>(
            from: /storage/NFTCollection
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(
            payment: <-self.paymentVault
        )

        self.exampleNFTCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}
