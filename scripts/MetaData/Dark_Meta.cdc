import DarkCountry from 0xc8c340cebd11f690
    
pub fun main (itemId: UInt64) : {String: String}? {
    let meta = DarkCountry.getItemTemplateMetaData(itemTemplateID: itemId)
    return meta
}