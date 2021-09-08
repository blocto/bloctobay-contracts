import FungibleToken from 0xf8d6e0586b0a20c7
import FlowToken from 0xf8d6e0586b0a20c7

// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the FlowToken

transaction {

    prepare(signer: AuthAccount) {

        if signer.borrow<&FlowToken.Vault>(from: FlowToken.VaultStoragePath) == nil {
            // Create a new FlowToken Vault and put it in storage
            signer.save(<-FlowToken.createEmptyVault(), to: FlowToken.VaultStoragePath)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(
                FlowToken.ReceiverPublicPath,
                target: FlowToken.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&FlowToken.Vault{FungibleToken.Balance}>(
                FlowToken.BalancePublicPath,
                target: FlowToken.VaultStoragePath
            )
        }
    }
}