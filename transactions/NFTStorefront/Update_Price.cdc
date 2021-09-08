//Update price arrray
//To be calle after updatePrice transaction on KittyItems
import NFTStorefront from 0xf8d6e0586b0a20c7

transaction(id : UInt64 , price : UFix64) { 
    prepare(acct: AuthAccount) {
        NFTStorefront.updatePriceArray(id:id , newPrice:price )
    }

}