import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../contracts/NFTStorefront.cdc"
import Marketplace from "../contracts/Marketplace.cdc"
import CNN_NFT from "../contracts/NFTs/CNN_NFT.cdc"
import DarkCountry from "../contracts/NFTs/DarkCountry.cdc"
import Evolution from "../contracts/NFTs/Evolution.cdc"
import MotoGPCard from "../contracts/NFTs/MotoGP/MotoGPCard.cdc"
import MotoGPPack from "../contracts/NFTs/MotoGP/MotoGPPack.cdc"
import Art from "../contracts/NFTs/Versus/Art.cdc"

// This script returns an array of all the NFT IDs in an account's collection.

pub fun main(address: Address): Result {
    let account = getAccount(address)

    var nfts: [NFT] = []
    var displayItems: [ListingDisplayItem] = []
    if let collectionRef = account.getCapability(CNN_NFT.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>() {
        let type = Type<@CNN_NFT.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        let items = getDisplayItems(nftType: type, nftIDs: ids)
        displayItems.appendAll(items)
    }

    if let collectionRef = account.getCapability(DarkCountry.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>() {
        let type = Type<@DarkCountry.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        let items = getDisplayItems(nftType: type, nftIDs: ids)
        displayItems.appendAll(items)
    }

    if let collectionRef = account.getCapability(/public/f4264ac8f3256818_Evolution_Collection).borrow<&{Evolution.EvolutionCollectionPublic}>() {
        let type = Type<@Evolution.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        let items = getDisplayItems(nftType: type, nftIDs: ids)
        displayItems.appendAll(items)
    }

    if let collectionRef = account.getCapability(/public/motogpCardCollection)!.borrow<&{MotoGPCard.ICardCollectionPublic}>() {
        let type = Type<@MotoGPCard.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        let items = getDisplayItems(nftType: type, nftIDs: ids)
        displayItems.appendAll(items)
    }

    if let collectionRef = account.getCapability(/public/motogpPackCollection)!.borrow<&MotoGPPack.Collection{MotoGPPack.IPackCollectionPublic}>() {
        let type = Type<@MotoGPPack.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        let items = getDisplayItems(nftType: type, nftIDs: ids)
        displayItems.appendAll(items)
    }

    if let collectionRef = account.getCapability(Art.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>() {
        let type = Type<@Art.NFT>()
        let ids = collectionRef.getIDs()
        nfts.appendAll(getNFTs(nftType: type, nftIDs: ids))
        let items = getDisplayItems(nftType: type, nftIDs: ids)
        displayItems.appendAll(items)
    }

    return Result(
        nfts: nfts,
        displayItems: displayItems
    )
}

pub fun getNFTs(nftType: Type, nftIDs: [UInt64]): [NFT] {
    var nfts: [NFT] = []
    for id in nftIDs {
        nfts.append(NFT(
            nftType: nftType,
            nftID: id
        ))
    }
    return nfts
}

pub fun getDisplayItems(nftType: Type, nftIDs: [UInt64]): [ListingDisplayItem] {
    var displayItems: [ListingDisplayItem] = []
    for id in nftIDs {
        if let listingID = Marketplace.getListingID(nftType: nftType, nftID: id) {
            if let item = Marketplace.getListingIDItem(listingID: listingID) {
                let listingDetails = item.listingDetails

                displayItems.append(ListingDisplayItem(
                    listingID: listingID,
                    address: item.storefrontPublicCapability.address,
                    nftType: listingDetails.nftType.identifier,
                    nftID: listingDetails.nftID,
                    salePaymentVaultType: listingDetails.salePaymentVaultType.identifier,
                    salePrice: listingDetails.salePrice,
                    saleCuts: listingDetails.saleCuts,
                    timestamp: item.timestamp
                ))
            }
        }
    }
    return displayItems
}

pub struct Result {
    pub let nfts: [NFT]
    pub let displayItems: [ListingDisplayItem]

    init(nfts: [NFT], displayItems: [ListingDisplayItem]) {
        self.nfts = nfts
        self.displayItems = displayItems
    }
}

pub struct NFT {
    pub let nftType: Type
    pub let nftID: UInt64

    init(nftType: Type, nftID: UInt64) {
        self.nftType = nftType
        self.nftID = nftID
    }
}

pub struct ListingDisplayItem {

    pub let listingID: UInt64

    pub var address: Address

    // The identifier of type of the NonFungibleToken.NFT that is being listed.
    pub let nftType: String
    // The ID of the NFT within that type.
    pub let nftID: UInt64
    // The identifier of type of the FungibleToken that payments must be made in.
    pub let salePaymentVaultType: String
    // The amount that must be paid in the specified FungibleToken.
    pub let salePrice: UFix64
    // This specifies the division of payment between recipients.
    pub let saleCuts: [NFTStorefront.SaleCut]

    pub let timestamp: UFix64

    init (
        listingID: UInt64,
        address: Address,
        nftType: String,
        nftID: UInt64,
        salePaymentVaultType: String,
        salePrice: UFix64,
        saleCuts: [NFTStorefront.SaleCut],
        timestamp: UFix64
    ) {
        self.listingID = listingID
        self.address = address
        self.nftType = nftType
        self.nftID = nftID
        self.salePaymentVaultType = salePaymentVaultType
        self.salePrice = salePrice
        self.saleCuts = saleCuts
        self.timestamp = timestamp
    }
}