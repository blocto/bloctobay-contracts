import FungibleToken from "../../contracts/FungibleToken.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"
import FlowToken from "../../contracts/FTs/FlowToken.cdc"
import ExampleNFT from "../../contracts/NFTs/ExampleNFT.cdc"

// This transaction creates SaleCutRequirements of Marketplace for NFT & Blocto

transaction(bloctoRecipient: Address, bloctoRatio: UFix64, nftRecipient: Address, nftRatio: UFix64) {

    prepare(signer: AuthAccount) {
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

        admin.updateSaleCutRequirements(requirements, nftType: Type<@ExampleNFT.NFT>())
    }
}