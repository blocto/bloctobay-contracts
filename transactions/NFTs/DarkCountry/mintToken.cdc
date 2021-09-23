import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import DarkCountry from "../../../contracts/NFTs/DarkCountry.cdc"

transaction(address: Address, itemID: UInt64) {

    // local variable for storing the DarkCountry Minter reference
    let minter: &DarkCountry.NFTMinter
    let recipient: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.minter = signer.borrow<&DarkCountry.NFTMinter>(from: /storage/DarkCountryMinter)
            ?? panic("Could not borrow a reference to the NFT Minter")

        self.recipient = getAccount(address)
            .getCapability(DarkCountry.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
    }

    execute {
        self.minter.createItemTemplate(metadata: {"QQ": "AA"})
        self.minter.mintNFT(recipient: self.recipient, itemTemplateID: itemID)
    }
}
