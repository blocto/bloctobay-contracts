//Show Sorted price by price descending
import NFTStorefront from 0x14b020f26aebc983
 
//Script to get 10 NFTs in Decreasing price order
pub fun main(set : UInt64) : { UInt64 : UFix64 }{
    
    var end = UInt64(0)
    var n = UInt64(NFTStorefront.allIdsForPrices.length - 1)
    var start = n - ((set-1) * 10)
    if n >= set*10 {
        end = n - (set *10)
    } else {
        end = start - n%10
    }

    let dict : {UInt64 : UFix64} = {}
    
    while start >= end {
        let old = dict.insert(key: NFTStorefront.allIdsForPrices[start],
                              NFTStorefront.allPrices[start])
        //pricearr.append(NFTStorefront.allIdsForPrices[start])
        if start == 0 {
            break
        }
        start = start - 1 
    }
    
    return dict;
}