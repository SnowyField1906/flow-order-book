import OrderBookV10 from 0xOrderBookV10

pub fun main(price: UFix64, isBid: Bool): OrderBookV10.Offer? {
    if isBid {
        return OrderBookV10.bidOffers[price]
    }
    return OrderBookV10.askOffers[price]
}