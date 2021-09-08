//Sort by price Ascending
import NFTStorefront from 0x14b020f26aebc983
 
 //returns 10 NFTs in increasing order of price
pub fun main(set : UInt64) : { UInt64 : UFix64 } {
    var end = UInt64(0)
    var n = UInt64(NFTStorefront.allIdsForPrices.length)
    var start = (set-1) * 10
    if n >= set*10 {
        end = set *10 
    } else {
        end = start + n%10
    }


  
    var dict : {UInt64 : UFix64} = {}

    while start < end{
        let old = dict.insert(key: NFTStorefront.allIdsForPrices[start],
                              NFTStorefront.allPrices[start])
        //pricearr.append(NFTStorefront.allIdsForPrices[start])
        start = start + 1
    }
    
    return dict;
}