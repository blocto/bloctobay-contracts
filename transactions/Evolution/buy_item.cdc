import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import FUSD from 0x3c5959b568896393
import Evolution from 0xf4264ac8f3256818
import NFTStorefront from 0xf8d6e0586b0a20c7

transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {
    let paymentVault: @FUSD.Vault
    let exampleNFTCollection: &Evolution.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let saleOffer: &NFTStorefront.SaleOffer{NFTStorefront.SaleOfferPublic}

    prepare(acct: AuthAccount) {
        if(signer.borrow<&FUSD.Vault>(from: /storage/fusdVault) != nil) {
            signer.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver, target: /storage/fusdVault)
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance, target: /storage/fusdVault)
        }    
        // Create a collection to store the purchase if none present
        if acct.borrow<&Evolution.Collection>(from: /storage/f8d6e0586b0a20c7_Evolution_Collection) == nil {
            let collection <- Evolution.createEmptyCollection() as! @Evolution.Collection

            acct.save(<-collection, to: /storage/f8d6e0586b0a20c7_Evolution_Collection)

            acct.link<&{Evolution.EvolutionCollectionPublic}>(/public/f8d6e0586b0a20c7_Evolution_Collection, target: /storage/f8d6e0586b0a20c7_Evolution_Collection)
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

        let mainFlowVault = acct.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: /storage/fusdMinterProxy)
            ?? panic("Cannot borrow FUSD vault from acct storage")
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        self.exampleNFTCollection = acct.borrow<&Evolution.Collection{NonFungibleToken.Receiver}>(
            from: /storage/f8d6e0586b0a20c7_Evolution_Collection
        ) ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.saleOffer.accept(
            payment: <-self.paymentVault
        )

        self.exampleNFTCollection.deposit(token: <-item)

        /* //-
        error: Execution failed:
        computation limited exceeded: 100
        */
        // Be kind and recycle
        //self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID)
    }

    //- Post to check item is in collection?
}
