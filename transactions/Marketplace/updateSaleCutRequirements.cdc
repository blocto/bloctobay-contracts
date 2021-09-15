import FungibleToken from "../../contracts/FungibleToken.cdc"
import Marketplace from "../../contracts/Marketplace.cdc"
import FUSD from "../../contracts/FTs/FUSD.cdc"
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
            let bloctoFUSDReceiver = getAccount(bloctoRecipient).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)
            assert(bloctoFUSDReceiver.borrow() != nil, message: "Missing or mis-typed blocto FUSD receiver")
            requirements.append(Marketplace.SaleCutRequirement(receiver: bloctoFUSDReceiver, ratio: bloctoRatio))
        }

        // NFT SaleCut
        if nftRatio > 0.0 {
            let nftFUSDReceiver = getAccount(nftRecipient).getCapability<&FUSD.Vault{FungibleToken.Receiver}>(/public/fusdReceiver)
            assert(nftFUSDReceiver.borrow() != nil, message: "Missing or mis-typed NFT FUSD receiver")
            requirements.append(Marketplace.SaleCutRequirement(receiver: nftFUSDReceiver, ratio: nftRatio))
        }

        admin.updateSaleCutRequirements(requirements, nftType: Type<@ExampleNFT.NFT>())
    }
}