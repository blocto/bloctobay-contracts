import FungibleToken from "../../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../../contracts/Marketplace.cdc"
import FlowToken from "../../../contracts/FTs/FlowToken.cdc"
import MotoGPPack from "../../../../contracts/NFTs/MotoGP/MotoGPPack.cdc"

transaction(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let motoGPPackCollection: &MotoGPPack.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&MotoGPPack.Collection>(from: /storage/motogpPackCollection) == nil {
            signer.save(<- MotoGPPack.createEmptyCollection(), to: /storage/motogpPackCollection)
            signer.link<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic, MotoGPPack.IPackCollectionAdminAccessible, NonFungibleToken.CollectionPublic}>(/public/motogpPackCollection, target: /storage/motogpPackCollection)
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        assert(buyPrice == price, message: "buyPrice is NOT same with salePrice")

        let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from signer storage")
        self.paymentVault <- flowTokenVault.withdraw(amount: price)

        self.motoGPPackCollection = signer.borrow<&MotoGPPack.Collection{NonFungibleToken.Receiver}>(from: /storage/motogpPackCollection)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)

        self.motoGPPackCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}
