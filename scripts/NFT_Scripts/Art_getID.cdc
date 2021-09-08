// import NonFungibleToken from 0x1d7e57aa55817448
// import Art from 0xd796ff17107bbff6

// // This script returns an array of all the NFT IDs in an account's collection.

// pub fun main(address: Address): [UInt64] {
//     let account = getAccount(address)

//     let collectionRef = account.getCapability(Art.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()
//         ?? panic("Could not borrow capability from public collection")
    
//     return collectionRef.getIDs()
// }


// 0x4e1d3888f573508d

//testnet
//import FungibleToken from 0x9a0766d93b6608b7
//import NonFungibleToken from 0x631e88ae7f1d7c20
//import Art from 0x1ff7e32d71183db0

//emulator
// import FungibleToken from 0xee82856bf20e2aa6
// import NonFungibleToken, Content, Art, Auction, Versus from 0xf8d6e0586b0a20c7

import NonFungibleToken from 0x1d7e57aa55817448
import Art from 0xd796ff17107bbff6
import FungibleToken from 0xf233dcee88fe0abe

pub struct AddressStatus {

  pub(set) var address:Address
  pub(set) var balance: UFix64
  pub(set) var art: [Art.ArtData]
  init (_ address:Address) {
    self.address=address
    self.balance= 0.0
    self.art= []
  }
}

/*
  This script will check an address and print out its FT, NFT and Versus resources
 */
pub fun main(address:Address) : AddressStatus {
    // get the accounts' public address objects
    let account = getAccount(address)
    let status= AddressStatus(address)
    
    if let vault= account.getCapability(/public/flowTokenBalance).borrow<&{FungibleToken.Balance}>() {
       status.balance=vault.balance
    }

    status.art= Art.getArt(address: address)
    
    return status

}