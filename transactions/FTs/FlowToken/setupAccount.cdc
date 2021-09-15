import FungibleToken from "../../../contracts/FungibleToken.cdc"
import FlowToken from "../../../contracts/FTs/FlowToken.cdc"

transaction {

    prepare(signer: AuthAccount) {

        let VaultStoragePath = /storage/flowTokenVault
        if signer.borrow<&FlowToken.Vault>(from: VaultStoragePath) == nil {
            // Create a new FlowToken Vault and put it in storage
            signer.save(<-FlowToken.createEmptyVault(), to: VaultStoragePath)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(
                /public/flowTokenReceiver,
                target: VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&FlowToken.Vault{FungibleToken.Balance}>(
                /public/flowTokenBalance,
                target: VaultStoragePath
            )
        }
    }
}