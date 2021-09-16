import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"
import CNN_NFT from "../../../contracts/NFTs/CNN_NFT.cdc"

// This script uses the Admin resource to add a new Series 
// It must be run with the account that has the Admin resource
// stored in /storage/CNN_NFTAdmin

transaction(seriesId: UInt32, recipient: Address, setId: UInt32, tokenId: UInt64) {

    // local variable for storing the CNN_NFT admin reference
    let admin: &CNN_NFT.Admin

    prepare(signer: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.admin = signer.borrow<&CNN_NFT.Admin>(from: CNN_NFT.AdminStoragePath)
            ?? panic("Could not borrow a reference to the NFT Admin")
    }

    execute {
        // Create the new Series resource
        self.admin.addSeries(
            seriesId: seriesId,
            metadata: {}
        )

        // Borrow a reference to the specified Series
        let series = self.admin.borrowSeries(seriesId: seriesId)

        // Get the public account object for the recipient
        let recipientAccount = getAccount(recipient)

        // Borrow the recipient''s public NFT collection reference
        let receiver = recipientAccount
            .getCapability(CNN_NFT.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        series.addNftSet(
            setId: setId,
            maxEditions: 10,
            ipfsMetadataHashes: {},
            metadata: {}
        )
        
        // Mint all NFTs
        series.mintCNN_NFT(
            recipient: receiver,
            tokenId: tokenId,
            setId: setId
        )
    }
}
