import Marketplace from "../../contracts/Marketplace.cdc"

pub fun main(): {String: [Marketplace.SaleCutRequirement]} {
    return Marketplace.getAllSaleCutRequirements()
}
