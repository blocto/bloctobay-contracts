import MotoGPCardMetadata from "../../../../contracts/NFTs/MotoGP/MotoGPCardMetadata.cdc"
import MotoGPCard from "../../../../contracts/NFTs/MotoGP/MotoGPCard.cdc"

pub fun main (cardID: UInt64) : MotoGPCardMetadata.Metadata? {  
    let meta = MotoGPCardMetadata.getMetadataForCardID(cardID: cardID)
    return meta
}