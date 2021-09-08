import NFTStorefront from 0x14b020f26aebc983
 
 //returns oldest 10 NFTs in sets
pub fun main(set : UInt64) : { UInt64 : Type } {
    
    var end = UInt64(0)
    var n = UInt64(NFTStorefront.allIdsForTimeStamps.length - 1)
    var start = (set-1) * 10
    if n >= set*10 {
        end = set *10 - 1
    } else {
        end = start + n%10
    }

  
    let dict : { UInt64 : Type } = {}

    while start <= end{
        let old = dict.insert(key: NFTStorefront.allIdsForTimeStamps[start],
                        NFTStorefront.allType[start])
        start = start + 1
    }
    
    return dict;
}