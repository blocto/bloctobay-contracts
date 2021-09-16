import FungibleToken from "../../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../../contracts/Marketplace.cdc"
import FUSD from "../../../../contracts/FTs/FUSD.cdc"
import MotoGPCard from "../../../../contracts/NFTs/MotoGP/MotoGPCard.cdc"

transaction(listingResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let MotoGPCardCollection: &MotoGPCard.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&MotoGPCard.Collection>(from: /storage/motogpCardCollection) == nil {
            signer.save(<- MotoGPCard.createEmptyCollection(), to: /storage/motogpCardCollection)
            signer.link<&{NonFungibleToken.CollectionPublic}>(/public/NFTCollection, target: /storage/motogpCardCollection)
        }

        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")

        self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
            ?? panic("No Offer with that ID in Storefront")
        let price = self.listing.getDetails().salePrice

        let fusdVault = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
            ?? panic("Cannot borrow FUSD vault from signer storage")
        self.paymentVault <- fusdVault.withdraw(amount: price)

        self.MotoGPCardCollection = signer.borrow<&MotoGPCard.Collection{NonFungibleToken.Receiver}>(from: /storage/motogpCardCollection)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)

        self.MotoGPCardCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}
