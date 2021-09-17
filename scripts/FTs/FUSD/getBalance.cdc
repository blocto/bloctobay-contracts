import "../../../contracts/FungibleToken.cdc"
import "../../../contracts/FTs/FUSD.cdc"

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)
    let balanceRef = account.getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()

    if let balanceRef = balanceRef {
        return balanceRef.balance
    } else {
        return 0.0
    }
}
