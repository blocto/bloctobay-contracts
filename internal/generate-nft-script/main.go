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
	nftRecipientRef := flag.String("nftRecipient", "", "NFT sale-cut recipient")
	nftRatioRef := flag.String("nftRatio", "", "NFT ratio")

	flag.Parse()

	project := *projectRef
	nftName := *nftNameRef
	nftRecipient := *nftRecipientRef
	nftRatio := *nftRatioRef

	if project == "" {
		log.Fatal("project is empty")
	}
	if nftName == "" {
		log.Fatal("nftName is empty")
	}
	if nftRecipient == "" {
		log.Fatal("nftRecipient is empty")
	}
	if nftRatio == "" {
		log.Fatal("nftRatio is empty")
	}

	// Generate Marketplace updateSaleCut tx
	updateSaleCutTx := fmt.Sprintf(updateSaleCutTxFormat,
		nftName, project, nftName,
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
}

const updateSaleCutTxFormat = `import FungibleToken from "../../contracts/FungibleToken.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"
import FlowToken from "../../contracts/FTs/FlowToken.cdc"
import %s from "../../contracts/NFTs/%s/%s.cdc"

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
