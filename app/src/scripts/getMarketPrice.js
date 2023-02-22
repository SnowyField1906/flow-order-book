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
import OrderBookV16 from 0xOrderBookV16
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(quantity: UFix64, isBid: Bool): UFix64 {
    var _quantity: UFix64 = quantity
    var amount: UFix64 = 0.0
    
    if isBid {
        var price: UFix64 = OrderBookV16.askTree.treeMinimum(key: OrderBookV16.askTree.root)
        while _quantity > 0.0 && price != 0.0 {
            if OrderBookV16.askOffers[price]?.amount != nil && OrderBookV16.askOffers[price]!.amount <= _quantity {
                amount = amount + OrderBookV16.askOffers[price]!.amount * price
                _quantity = _quantity - OrderBookV16.askOffers[price]!.amount
                price = OrderBookV16.askTree.next(target: price)
            } else {
                amount = amount + _quantity * price
                break
            }
        }
    }
    else {
        var price: UFix64 = OrderBookV16.bidTree.treeMaximum(key: OrderBookV16.bidTree.root)
        while _quantity > 0.0 && price != 0.0 {
            if OrderBookV16.bidOffers[price]?.amount != nil && OrderBookV16.bidOffers[price]!.amount <= _quantity {
                amount = amount + OrderBookV16.bidOffers[price]!.amount * price
                _quantity = _quantity - OrderBookV16.bidOffers[price]!.amount
                price = OrderBookV16.bidTree.prev(target: price)
            } else {
                amount = amount + _quantity * price
                break
            }
        }
    }
    return amount
}
`