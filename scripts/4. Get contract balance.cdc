import OrderBookV21 from 0xOrderBookV21

pub fun main() : {String: UFix64} {
    return {"Flow": OrderBookV21.flowSupply, "FUSD": OrderBookV21.fusdSupply}
}