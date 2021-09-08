//Sort by time latest 10
import NFTStorefront from 0x14b020f26aebc983
 
//Script to get 10 latest listed NFTs in sets
pub fun main(set : UInt64) : { UInt64 : UFix64 }{
    var end = UInt64(0)
    var n = UInt64(NFTStorefront.allIdsForTimeStamps.length - 1)
    var start = n - ((set-1) * 10)
    if n >= set*10 {
        end = n - (set *10) + 1
    } else {
        end = start - n%10
    }

    let dict : { UInt64 : UFix64 } = {}
    
    while start >= end {
        let old = dict.insert(key: NFTStorefront.allIdsForTimeStamps[start],
                                    NFTStorefront.allPricesForTime[start])
        if start == 0 {
            break
        }
        start = start - 1 
    }

    return dict;
    
}