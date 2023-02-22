import OrderBookV16 from 0xOrderBookV16

pub fun main(price: UFix64, isBid: Bool): OrderBookV16.Offer? {
    if isBid {
        return OrderBookV16.bidOffers[price]
    }
    return OrderBookV16.askOffers[price]
}