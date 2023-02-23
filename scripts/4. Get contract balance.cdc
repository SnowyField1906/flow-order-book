import OrderBookV18 from 0xOrderBookV18

pub fun main() : {String: UFix64} {
    return {"Flow": OrderBookV18.flowSupply, "FUSD": OrderBookV18.fusdSupply}
}