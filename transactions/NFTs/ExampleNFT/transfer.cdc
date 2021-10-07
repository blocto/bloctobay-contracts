import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../../../contracts/NFTs/ExampleNFT.cdc"

transaction(id: UInt64, to: Address) {
  let sentNFT: @NonFungibleToken.NFT

  prepare(signer: AuthAccount) {
    let collectionRef = signer.borrow<&NonFungibleToken.Collection>(from: /storage/NFTCollection)
      ?? panic("Could not borrow reference collection")

    self.sentNFT <- collectionRef.withdraw(withdrawID: id)
  }

  execute {
    let recipient = getAccount(to)

    let receiverRef = recipient.getCapability(/public/NFTCollection).borrow<&{NonFungibleToken.CollectionPublic}>()
      ?? panic("Could not borrow receiver reference to the recipient's Vault")

    receiverRef.deposit(token: <-self.sentNFT)
  }
}