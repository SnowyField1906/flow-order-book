import OrderBookV13 from 0xOrderBookV13

pub fun main(price: UFix64, isBid: Bool): OrderBookV13.Offer? {
    if isBid {
        return OrderBookV13.bidOffers[price]
    }
    return OrderBookV13.askOffers[price]
}