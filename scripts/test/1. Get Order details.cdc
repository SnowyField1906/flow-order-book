import OrderBookV21 from 0xOrderBookV21

pub fun main(price: UFix64, isBid: Bool): OrderBookV21.Offer? {
    if isBid {
        return OrderBookV21.bidOffers[price]
    }
    return OrderBookV21.askOffers[price]
}