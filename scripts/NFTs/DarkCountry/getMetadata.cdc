import DarkCountry from "../../../contracts/NFTs/DarkCountry.cdc"

pub fun main(id: UInt64) : {String: String}? {
    let meta = DarkCountry.getItemTemplateMetaData(itemTemplateID: id)
    return meta
}