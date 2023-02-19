import OrderBookV11 from 0xOrderBookV11

pub fun main(price: UFix64, isBid: Bool): OrderBookV11.Offer? {
    if isBid {
        return OrderBookV11.bidOffers[price]
    }
    return OrderBookV11.askOffers[price]
}