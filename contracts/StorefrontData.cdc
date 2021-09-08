pub contract StorefrontData {

    pub let allIdsForPrices : [UInt64]
    pub let allPrices : [UFix64]
    pub let allIdsForTimeStamps : [UInt64]
    pub let allTimeStamps : [UFix64]
    pub let allType : [Type]
    pub let allPricesForTime : [UFix64]
    pub let allPricesForTimeResourceID : [UInt64]
    pub let allAccountForTIme: [Address]

    pub fun sortByPrice (id : UInt64, price : UFix64, type : Type) {        
        
        // If array was empty earlier
        if (self.allPrices.length == 0 && self.allIdsForPrices.length == 0) || 
        (self.allPrices[self.allPrices.length - 1] <= price) {
            self.allIdsForPrices.append(id)
            self.allPrices.append(price)
            self.allType.append(type)
        }    

        // If price is less than or equal to the first NFT's price
        else if(self.allPrices[0] >= price) {
            self.allPrices.insert (at: 0, price)
            self.allIdsForPrices.insert (at : 0, id)
            self.allType.insert (at : 0, type)

        }

        else {

            var start = 0
            var end = self.allPrices.length - 2

            while start <= end {
                var mid = start + (end - start)/2

                if (self.allPrices[mid] <= price && price < self.allPrices[mid+1]) {
                    self.allPrices.insert (at: mid + 1, price)
                    self.allIdsForPrices.insert (at : mid + 1, id)
                    self.allType.insert (at : mid + 1, type)
                    return
                }

                else if(self.allPrices[mid] > price) {
                    end = mid - 1
                }

                else {
                    start = mid + 1
                }
            }
        }
    }

    
    pub fun removeArrUInt64(arr : [UInt64] , ele : UInt64): UInt64 {

        var start = UInt64(0)
        var end = UInt64(arr.length) - UInt64(1)
        var mid = UInt64(0)
        while start <= end {
            mid = start + (end - start)/2

            if (arr[mid] == ele) {
                return mid;
            }

            else if(arr[mid] > ele) {
                if (mid == 0) {
                    break
                }else {
                    end = mid - UInt64(1)
                }

            }

            else {
                start = mid + UInt64(1)
            }
        }
        return mid;
    }

    pub fun remove(nftID: UInt64) {
            // allIdsForPrices
            // allPrices
            // allType
            var a = self.removeArrUInt64(arr: StorefrontData.allIdsForPrices, ele: nftID)
            var b = self.allIdsForPrices.remove(at : a)  
            var c = self.allPrices.remove(at : a)
            var d = self.allType.remove(at : a) 

            // allIdsForTimeStamps
            // allTimeStamps
            // allPricesForTime
            a = self.removeArrUInt64(arr: StorefrontData.allIdsForTimeStamps, ele: nftID)
            b = self.allIdsForTimeStamps.remove(at : a) 
            c = self.allTimeStamps.remove(at : a) 
            c = self.allPricesForTime.remove(at : a) 
            b = self.allPricesForTimeResourceID.remove(at : a)
            var e = self.allAccountForTIme.remove(at : a)


    }

    pub fun StoreData(id : UInt64, price : UFix64, nftType : Type, resourceID: UInt64, account:Address) {
        self.sortByPrice(id : id, price : price, type : nftType)
        self.allTimeStamps.append(getCurrentBlock().timestamp)
        self.allIdsForTimeStamps.append(id)
        self.allPricesForTime.append(price)
        self.allPricesForTimeResourceID.append(resourceID)
        self.allAccountForTIme.append(account)
    }






    init () {

        self.allPrices = []
        self.allIdsForPrices = []
        self.allTimeStamps = []
        self.allIdsForTimeStamps = []
        self.allType = []
        self.allPricesForTime = []
        self.allPricesForTimeResourceID = []
        self.allAccountForTIme = []
    }
}
