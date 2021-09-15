import NFTStorefront from "../contracts/NFTStorefront.cdc"
import Marketplace from "../contracts/Marketplace.cdc"

transaction(listingResourceID: UInt64, storefrontAddress: Address) {
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}

    prepare(signer: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")
    }

    execute {
        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }
}
