import OrderBookV14 from 0xOrderBookV14

pub fun main(price: UFix64, isBid: Bool): OrderBookV14.Offer? {
    if isBid {
        return OrderBookV14.bidOffers[price]
    }
    return OrderBookV14.askOffers[price]
}