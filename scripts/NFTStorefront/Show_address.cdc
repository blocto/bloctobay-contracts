import StorefrontData from 0x47d3edb601d7b478
 
//Script to get 10 latest listed NFTs in sets
pub fun main() : { UInt64 : Address }{
    var end = UInt64(0)
    var start = UInt64(StorefrontData.allIdsForTimeStamps.length - 1)

    let dict : { UInt64 : Address } = {}
    
    while start >= end {
        let old = dict.insert(key: StorefrontData.allIdsForTimeStamps[start],
                                    StorefrontData.allAccountForTIme[start])
        if start == 0 {
            break
        }
        start = start - 1 
    }

    return dict;
    
}