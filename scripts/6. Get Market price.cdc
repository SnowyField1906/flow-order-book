import OrderBookV14 from 0xOrderBookV14
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import FUSD from 0xFUSD

pub fun main(quantity: UFix64, isBid: Bool): UFix64 {
    var _quantity: UFix64 = quantity
    var amount: UFix64 = 0.0
    
    if isBid {
        var price: UFix64 = OrderBookV14.askTree.treeMinimum(key: OrderBookV14.askTree.root)
        while _quantity > 0.0 && price != 0.0 {
            if OrderBookV14.askOffers[price]?.amount != nil && OrderBookV14.askOffers[price]!.amount <= _quantity {
                amount = amount + OrderBookV14.askOffers[price]!.amount * price
                _quantity = _quantity - OrderBookV14.askOffers[price]!.amount
                price = OrderBookV14.askTree.next(target: price)
            } else {
                amount = amount + _quantity * price
                break
            }
        }
    }
    else {
        var price: UFix64 = OrderBookV14.bidTree.treeMaximum(key: OrderBookV14.bidTree.root)
        while _quantity > 0.0 && price != 0.0 {
            if OrderBookV14.bidOffers[price]?.amount != nil && OrderBookV14.bidOffers[price]!.amount <= _quantity {
                amount = amount + OrderBookV14.bidOffers[price]!.amount * price
                _quantity = _quantity - OrderBookV14.bidOffers[price]!.amount
                price = OrderBookV14.bidTree.prev(target: price)
            } else {
                amount = amount + _quantity * price
                break
            }
        }
    }
    return amount
}