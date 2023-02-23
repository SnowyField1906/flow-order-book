import * as fcl from "@onflow/fcl";

export default async function getMarketPrice(quantity, isBid) {
    return fcl.query({
        cadence: AMOUNT,
        args: (arg, t) => [
            arg(quantity, t.UFix64),
            arg(isBid, t.Bool),
        ],
    });
}

const AMOUNT = `
import OrderBookV18 from 0xOrderBookV18
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(quantity: UFix64, isBid: Bool): UFix64 {
    var _quantity: UFix64 = quantity
    var amount: UFix64 = 0.0
    
    if isBid {
        var price: UFix64 = OrderBookV18.askTree.treeMinimum(key: OrderBookV18.askTree.root)
        while _quantity > 0.0 && price != 0.0 {
            if OrderBookV18.askOffers[price]?.amount != nil && OrderBookV18.askOffers[price]!.amount <= _quantity {
                amount = amount + OrderBookV18.askOffers[price]!.amount * price
                _quantity = _quantity - OrderBookV18.askOffers[price]!.amount
                price = OrderBookV18.askTree.next(target: price)
            } else {
                amount = amount + _quantity * price
                break
            }
        }
    }
    else {
        var price: UFix64 = OrderBookV18.bidTree.treeMaximum(key: OrderBookV18.bidTree.root)
        while _quantity > 0.0 && price != 0.0 {
            if OrderBookV18.bidOffers[price]?.amount != nil && OrderBookV18.bidOffers[price]!.amount <= _quantity {
                amount = amount + OrderBookV18.bidOffers[price]!.amount * price
                _quantity = _quantity - OrderBookV18.bidOffers[price]!.amount
                price = OrderBookV18.bidTree.prev(target: price)
            } else {
                amount = amount + _quantity * price
                break
            }
        }
    }
    return amount
}
`