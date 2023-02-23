import OrderBookV18 from 0xOrderBookV18

pub fun main(price: UFix64, isBid: Bool): OrderBookV18.Offer? {
    if isBid {
        return OrderBookV18.bidOffers[price]
    }
    return OrderBookV18.askOffers[price]
}