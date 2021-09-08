import NFTStorefront from 0x47d3edb601d7b478
import StorefrontData from 0x47d3edb601d7b478

transaction(saleOfferResourceID: UInt64, account:Address) {
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontManager}

    prepare(acct: AuthAccount) {
        self.storefront = acct.borrow<&NFTStorefront.Storefront{NFTStorefront.StorefrontManager}>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront.Storefront")
    }

    execute {
        let storefrontRef = getAccount(account)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath)
                .borrow()
                ?? panic("Could not borrow public storefront from address")
        let saleOffer = storefrontRef.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID)
            ?? panic("No item with that ID")
        StorefrontData.remove(nftID: saleOffer.getDetails().nftID)
        self.storefront.removeSaleOffer(saleOfferResourceID: saleOfferResourceID)
    }
}

//QmWJ2MdKYTByYsXYGZQmuXkmPzUv9SwbVxgUQkAhifRLdn