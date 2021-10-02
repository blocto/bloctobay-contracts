import FungibleToken from "../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../contracts/Marketplace.cdc"
import FUSD from "../../../contracts/FTs/FUSD.cdc"
import Evolution from "../../../contracts/NFTs/Evolution.cdc"

transaction(listingResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FungibleToken.Vault
    let evolutionCollection: &Evolution.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&Evolution.Collection>(from: /storage/f4264ac8f3256818_Evolution_Collection) == nil {
            let collection <- Evolution.createEmptyCollection() as! @Evolution.Collection
            signer.save(<-collection, to: /storage/f4264ac8f3256818_Evolution_Collection)
            signer.link<&{Evolution.EvolutionCollectionPublic, NonFungibleToken.CollectionPublic}>(/public/f4264ac8f3256818_Evolution_Collection, target: /storage/f4264ac8f3256818_Evolution_Collection)
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

        self.evolutionCollection = signer.borrow<&Evolution.Collection{NonFungibleToken.Receiver}>(from: /storage/f4264ac8f3256818_Evolution_Collection)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)

        self.evolutionCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}
