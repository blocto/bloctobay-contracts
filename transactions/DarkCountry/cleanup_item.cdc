import NFTStorefront from 0x009c6a4e1c04b3af

transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}

    prepare(acct: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")
    }

    execute {
        // Be kind and recycle
        self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID)
    }
}
