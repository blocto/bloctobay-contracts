import MotoGPCardMetadata from 0xa49cc0ee46c54bfb
import MotoGPCard from 0xa49cc0ee46c54bfb

pub fun main (cardID: UInt64) : MotoGPCardMetadata.Metadata? {  
   //let a: MotoGPCard.NFT
   let meta = MotoGPCardMetadata.getMetadataForCardID(cardID: cardID)

    return meta
}