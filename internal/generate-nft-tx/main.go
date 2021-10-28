package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"unicode"
)

func LcFirst(str string) string {
	for i, v := range str {
		return string(unicode.ToLower(v)) + str[i+1:]
	}
	return ""
}

func main() {
	projectRef := flag.String("project", "", "project name")
	nftNameRef := flag.String("nftName", "", "NFT name")
	nftPathRef := flag.String("nftPath", "", "NFT path")
	nftRecipientRef := flag.String("nftRecipient", "", "NFT sale-cut recipient")
	nftRatioRef := flag.String("nftRatio", "", "NFT ratio")
	nftStoragePathRef := flag.String("nftStoragePath", "", "NFT storage path")
	nftPublicPathRef := flag.String("nftPublicPath", "", "NFT public path")
	nftPrivatePathRef := flag.String("nftPrivatePath", "", "NFT private path")

	flag.Parse()

	project := *projectRef
	nftName := *nftNameRef
	nftPath := *nftPathRef
	nftRecipient := *nftRecipientRef
	nftRatio := *nftRatioRef
	nftStoragePath := *nftStoragePathRef
	nftPublicPath := *nftPublicPathRef
	nftPrivatePath := *nftPrivatePathRef

	if project == "" {
		log.Fatal("project is empty")
	}
	if nftName == "" {
		log.Fatal("nftName is empty")
	}
	if nftPath == "" {
		log.Fatal("nftPath is empty")
	}
	if nftRecipient == "" {
		log.Fatal("nftRecipient is empty")
	}
	if nftRatio == "" {
		log.Fatal("nftRatio is empty")
	}
	if nftStoragePath == "" {
		nftStoragePath = fmt.Sprintf("%s.CollectionStoragePath", nftName)
	}
	if nftPublicPath == "" {
		nftPublicPath = fmt.Sprintf("%s.CollectionPublicPath", nftName)
	}
	if nftPrivatePath == "" {
		var privatePathPrefix string
		if project == nftName {
			privatePathPrefix = LcFirst(nftName)
		} else {
			privatePathPrefix = fmt.Sprintf("%s%s", LcFirst(project), nftName)
		}
		nftPrivatePath = fmt.Sprintf("/private/%sNFTCollectionProviderForNFTStorefront", privatePathPrefix)
	}

	// Generate Marketplace updateSaleCut tx
	updateSaleCutTx := fmt.Sprintf(updateSaleCutTxFormat,
		nftName, nftPath,
		nftRecipient, nftRatio,
		nftName)
	var updateSaleCutFileName string
	if project == nftName {
		updateSaleCutFileName = fmt.Sprintf("./transactions/Marketplace/updateSaleCut%s.cdc", nftName)
	} else {
		updateSaleCutFileName = fmt.Sprintf("./transactions/Marketplace/updateSaleCut%s%s.cdc", project, nftName)
	}
	err := os.WriteFile(updateSaleCutFileName, []byte(updateSaleCutTx), 0644)
	if err != nil {
		log.Fatal(err)
	}

	var buyItemFileName string
	var sellItemFileName string
	if project == nftName {
		buyItemFileName = fmt.Sprintf("./transactions/NFTs/%s/buyItem.cdc", nftName)
		sellItemFileName = fmt.Sprintf("./transactions/NFTs/%s/sellItem.cdc", nftName)

		err = os.MkdirAll(fmt.Sprintf("./transactions/NFTs/%s", project), os.ModePerm)
		if err != nil && os.IsNotExist(err) {
			log.Fatal(err)
		}
	} else {
		buyItemFileName = fmt.Sprintf("./transactions/NFTs/%s/%s/buyItem.cdc", project, nftName)
		sellItemFileName = fmt.Sprintf("./transactions/NFTs/%s/%s/sellItem.cdc", project, nftName)

		err = os.MkdirAll(fmt.Sprintf("./transactions/NFTs/%s/%s", project, nftName), os.ModePerm)
		if err != nil && os.IsNotExist(err) {
			log.Fatal(err)
		}
	}

	// Generate buyItem tx
	buyItemTx := fmt.Sprintf(buyItemFormat,
		nftName, nftPath,
		nftName,
		nftName, nftStoragePath, nftName, nftStoragePath, nftName, nftName, nftPublicPath, nftStoragePath,
		nftName, nftStoragePath)
	err = os.WriteFile(buyItemFileName, []byte(buyItemTx), 0644)
	if err != nil {
		log.Fatal(err)
	}

	// Generate sellItem tx
	sellItemTx := fmt.Sprintf(
		sellItemFormat, nftName, nftPath, nftName,
		nftPrivatePath, nftName, nftName, nftStoragePath, nftName, nftName, nftName, nftName, nftName)
	err = os.WriteFile(sellItemFileName, []byte(sellItemTx), 0644)
	if err != nil {
		log.Fatal(err)
	}
}

const updateSaleCutTxFormat = `import FungibleToken from "../../contracts/FungibleToken.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"
import FlowToken from "../../contracts/FTs/FlowToken.cdc"
import %s from "../.%s"

// This transaction creates SaleCutRequirements of Marketplace for NFT & Blocto

transaction {

    prepare(signer: AuthAccount) {
        let bloctoRecipient: Address = 0x77e38c96fda5c5c5
        let bloctoRatio = 0.025 // 2.5%%
        let nftRecipient: Address = %s
        let nftRatio = %s

        assert(nftRatio + bloctoRatio <= 1.0, message: "total of ratio must be less than or equal to 1.0")

        let admin = signer.borrow<&Marketplace.Administrator>(from: Marketplace.MarketplaceAdminStoragePath)
            ?? panic("Cannot borrow marketplace admin")

        let requirements: [Marketplace.SaleCutRequirement] = []

        // Blocto SaleCut
        if bloctoRatio > 0.0 {
            let bloctoFlowTokenReceiver = getAccount(bloctoRecipient).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            assert(bloctoFlowTokenReceiver.borrow() != nil, message: "Missing or mis-typed blocto FlowToken receiver")
            requirements.append(Marketplace.SaleCutRequirement(receiver: bloctoFlowTokenReceiver, ratio: bloctoRatio))
        }

        // NFT SaleCut
        if nftRatio > 0.0 {
            let nftFlowTokenReceiver = getAccount(nftRecipient).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            assert(nftFlowTokenReceiver.borrow() != nil, message: "Missing or mis-typed NFT FlowToken receiver")
            requirements.append(Marketplace.SaleCutRequirement(receiver: nftFlowTokenReceiver, ratio: nftRatio))
        }

        admin.updateSaleCutRequirements(requirements, nftType: Type<@%s.NFT>())
    }
}`

const buyItemFormat = `import FungibleToken from "../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../contracts/Marketplace.cdc"
import FlowToken from "../../../contracts/FTs/FlowToken.cdc"
import %s from "../../.%s"

transaction(listingResourceID: UInt64, storefrontAddress: Address, buyPrice: UFix64) {
    let paymentVault: @FungibleToken.Vault
    let nftCollection: &%s.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}

    prepare(signer: AuthAccount) {
        // Create a collection to store the purchase if none present
        if signer.borrow<&%s.Collection>(from: %s) == nil {
            signer.save(<-%s.createEmptyCollection(), to: %s)
            signer.link<&%s.Collection{NonFungibleToken.CollectionPublic, %s.CollectionPublic}>(
                %s,
                target: %s)
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

        self.nftCollection = signer.borrow<&%s.Collection{NonFungibleToken.Receiver}>(from: %s)
            ?? panic("Cannot borrow NFT collection receiver from account")
    }

    execute {
        let item <- self.listing.purchase(payment: <-self.paymentVault)

        self.nftCollection.deposit(token: <-item)

        // Be kind and recycle
        self.storefront.cleanup(listingResourceID: listingResourceID)
        Marketplace.removeListing(id: listingResourceID)
    }

}`

const sellItemFormat = `import FungibleToken from "../../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../../contracts/NFTStorefront.cdc"
import Marketplace from "../../../contracts/Marketplace.cdc"
import FlowToken from "../../../contracts/FTs/FlowToken.cdc"
import %s from "../../.%s"

transaction(saleItemID: UInt64, saleItemPrice: UFix64) {
    let flowTokenReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let nftProvider: Capability<&%s.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let storefrontPublic: Capability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>

    prepare(signer: AuthAccount) {
        // Create Storefront if it doesn't exist
        if signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            let storefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront
            signer.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)
            signer.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath,
                target: NFTStorefront.StorefrontStoragePath)
        }

        // We need a provider capability, but one is not provided by default so we create one if needed.
        let nftCollectionProviderPrivatePath = %s
        if !signer.getCapability<&%s.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath)!.check() {
            signer.link<&%s.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath, target: %s)
        }

        self.flowTokenReceiver = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
        assert(self.flowTokenReceiver.borrow() != nil, message: "Missing or mis-typed FlowToken receiver")

        self.nftProvider = signer.getCapability<&%s.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(nftCollectionProviderPrivatePath)!
        assert(self.nftProvider.borrow() != nil, message: "Missing or mis-typed %s.Collection provider")

        self.storefront = signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        self.storefrontPublic = signer.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
        assert(self.storefrontPublic.borrow() != nil, message: "Could not borrow public storefront from address")
    }

    execute {
        // Remove old listing
        if let listingID = Marketplace.getListingID(nftType: Type<@%s.NFT>(), nftID: saleItemID) {
            let listingIDs = self.storefront.getListingIDs()
            if listingIDs.contains(listingID) {
                self.storefront.removeListing(listingResourceID: listingID)
            }
            Marketplace.removeListing(id: listingID)
        }

        // Create SaleCuts
        var saleCuts: [NFTStorefront.SaleCut] = []
        let requirements = Marketplace.getSaleCutRequirements(nftType: Type<@%s.NFT>())
        var remainingPrice = saleItemPrice
        for requirement in requirements {
            let price = saleItemPrice * requirement.ratio
            saleCuts.append(NFTStorefront.SaleCut(
                receiver: requirement.receiver,
                amount: price
            ))
            remainingPrice = remainingPrice - price
        }
        saleCuts.append(NFTStorefront.SaleCut(
            receiver: self.flowTokenReceiver,
            amount: remainingPrice
        ))

        // Add listing
        let id = self.storefront.createListing(
            nftProviderCapability: self.nftProvider,
            nftType: Type<@%s.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: saleCuts
        )
        Marketplace.addListing(id: id, storefrontPublicCapability: self.storefrontPublic)
    }
}`
