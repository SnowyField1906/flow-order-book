import OrderBookUtility from 0x9d380238fdd484d7
import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868


pub contract OrderBookV16 {
    pub let AdminPrivatePath: StoragePath
    pub let AdminPublicPath: PublicPath
    pub let ListingPublicPath: PublicPath
    pub let ListingStoragePath: StoragePath

    pub var flowSupply: UFix64
    pub var fusdSupply: UFix64


    pub struct AdminDetail {
        pub let addr: Address
        access(contract) let storageCapability: Capability<&Admin{AdminPrivate}>

        init(addr: Address, storageCapability: Capability<&Admin{AdminPrivate}>) {
            self.addr = addr
            self.storageCapability = storageCapability
        }
    }

    pub resource interface ListingPublic {
        pub let bidTree: OrderBookUtility.Tree
        pub let askTree: OrderBookUtility.Tree
        
        pub fun limitOrder(addr: Address, price: UFix64, amount: UFix64, isBid: Bool,  storageCapability: Capability<&Admin{AdminPrivate}>, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault)
        pub fun marketOrder(addr: Address, quantity: UFix64, isBid: Bool, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault)
        pub fun cancelOrder(price: UFix64, isBid: Bool): UFix64
    }

    pub resource Listing: ListingPublic {
        pub let bidTree: OrderBookUtility.Tree
        pub let askTree: OrderBookUtility.Tree

        access(contract) var bidOrders: @{UFix64: Order}
        access(contract) var askOrders: @{UFix64: Order}

        pub fun limitOrder(addr: Address, price: UFix64, amount: UFix64, isBid: Bool,  storageCapability: Capability<&Admin{AdminPrivate}>, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault) {

            /* is buying - bid */
            if isBid {

                /* doesn't exist a matching ask order */
                if !self.askTree.exists(key: price) {

                    // (1): add this order with full amount
                    self.bidOrders[price] <-! create Order(amount: amount, addr: addr, storageCapability: storageCapability)
                    self.bidTree.insert(key: price)

                    // (2): transfer Flow from this order's to contract
                    storageCapability.borrow()!.depositFlow(from: <- flowVaultRef.withdraw(amount: price * amount))
                }

                /* exists a matching ask order */
                else {
                    let askOffer: &Order? = &self.askOrders[price] as &Order?
                    let askReceiver: &{AdminPublic} = getAccount(askOffer!.admin.addr).getCapability(OrderBookV16.AdminPublicPath).borrow<&{AdminPublic}>()!
                    let thisReceiver: &{FungibleToken.Receiver} = getAccount(addr).getCapability(/public/fusdReceiver).borrow<&{FungibleToken.Receiver}>()!
                    
                    /* ask order has enough FUSD amount for this order */
                    if askOffer!.amount > amount {

                        // (1): decrease ask order's FUSD amount
                        askOffer!.changeAmount(amount: askOffer!.amount - amount)

                        // (3): transfer Flow from this order's to ask
                        
                        askReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: price * amount))

                        // (4): transfer FUSD from contract's to this order
                        thisReceiver.deposit(from: <- askOffer!.admin.storageCapability.borrow()!.withdrawFUSD(amount: amount))
                    }

                    else {

                        /* ask order doesn't have enough FUSD amount for this order */
                        if askOffer!.amount < amount {

                            // (1): add this order with decreased amount
                            self.bidOrders[price] <-! create Order(amount: amount - askOffer!.amount, addr: addr, storageCapability: storageCapability)
                            self.bidTree.insert(key: price)

                            // (2): transfer Flow from this order's to contract
                            storageCapability.borrow()!.depositFlow(from: <- flowVaultRef.withdraw(amount: price * (amount - askOffer!.amount)))

                            // (3): transfer Flow from this order's to ask
                            askReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: price * askOffer!.amount))

                            // (4): transfer FUSD from contract's to this order
                            thisReceiver.deposit(from: <- askOffer!.admin.storageCapability.borrow()!.withdrawFUSD(amount: askOffer!.amount))
                        }

                        /* ask order has equal FUSD amount for this order */
                        else {
                            
                            // (3): transfer Flow from this order's to ask
                            askReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: price * amount))

                            // (4): transfer FUSD from contract's to this order
                            thisReceiver.deposit(from: <- askOffer!.admin.storageCapability.borrow()!.withdrawFUSD(amount: amount))
                        }

                        // (5): remove ask order
                        self.askTree.remove(key: price)
                        destroy self.askOrders.remove(key: price)
                    }
                }

            }

            /* is selling - ask */ 
            else {

                /* doesn't exist a matching bid order */ 
                if !self.bidTree.exists(key: price) {

                    // (1): add this order with full amount
                    self.askOrders[price] <-! create Order(amount: amount, addr: addr, storageCapability: storageCapability)
                    self.askTree.insert(key: price)

                    // (2): transfer FUSD from this order's to contract
                    storageCapability.borrow()!.depositFusd(from: <- fusdVaultRef.withdraw(amount: amount))
                }

                /* exists a matching bid order */ 
                else {
                    let bidOrder: &Order? = &self.bidOrders[price] as &Order?
                    let bidReceiver: &{AdminPublic} = getAccount(bidOrder!.admin.addr).getCapability(OrderBookV16.AdminPublicPath).borrow<&{AdminPublic}>()!
                    let thisReceiver: &{FungibleToken.Receiver} = getAccount(addr).getCapability(/public/flowTokenReceiver).borrow<&{FungibleToken.Receiver}>()!

                    /* bid order has enough Flow amount for this order */
                    if bidOrder!.amount > amount {
                        
                        // (1): decrease bid order's FUSD amount
                        bidOrder!.changeAmount(amount: bidOrder!.amount - amount)

                        // (3): transfer FUSD from this order's to bid
                        bidReceiver.transferFusd(from: <- flowVaultRef.withdraw(amount: amount))

                        // (4): transfer Flow from contract's to this order
                        thisReceiver.deposit(from: <- bidOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: price * amount))
                    }

                    else {

                        /* bid order doesn't have enough FUSD amount for this order */
                        if bidOrder!.amount < amount {

                            // (1): add this order with decreased amount
                            self.bidOrders[price] <-! create Order(amount: amount - bidOrder!.amount, addr: addr, storageCapability: storageCapability)
                            self.bidTree.insert(key: price)

                            // (2): transfer FUSD from this order's to contract
                            storageCapability.borrow()!.depositFusd(from: <- fusdVaultRef.withdraw(amount: amount - bidOrder!.amount))

                            // (3): transfer FUSD from this order's to bid
                            bidReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: bidOrder!.amount))

                            // (4): transfer Flow from contract's to this order
                            thisReceiver.deposit(from: <- bidOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: price * bidOrder!.amount))
                        }

                        /* bid order has equal FUSD amount for this order */
                        else {
                            
                            // (3): transfer FUSD from this order's to bid
                            bidReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: amount))

                            // (4): transfer Flow from contract's to this order
                            thisReceiver.deposit(from: <- bidOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: price * amount))
                        }
                        
                        // (5): remove bid order
                        self.bidTree.remove(key: price)
                        destroy self.bidOrders.remove(key: price)
                    }
                }
            }
        }

        pub fun marketOrder(addr: Address, quantity: UFix64, isBid: Bool, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault) {
            var _quantity: UFix64 = quantity

            if isBid {
                var price: UFix64 = self.askTree.treeMinimum(key: self.askTree.root)
                let thisReceiver: &{FungibleToken.Receiver} = getAccount(addr).getCapability(/public/fusdReceiver).borrow<&{FungibleToken.Receiver}>()!

                while _quantity > 0.0 && price != 0.0 {
                    let askOrder: &Order? = &self.askOrders[price] as &Order?
                    let askReceiver: &{AdminPublic} = getAccount(askOrder!.admin.addr).getCapability(OrderBookV16.AdminPublicPath).borrow<&{AdminPublic}>()!

                    if askOrder?.amount != nil && askOrder!.amount <= _quantity {

                        _quantity = _quantity - askOrder!.amount
                        price = self.askTree.next(target: price)

                        askReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: price * askOrder!.amount))
                        thisReceiver.deposit(from: <- askOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: askOrder!.amount))

                        self.askTree.remove(key: price)
                        destroy self.askOrders.remove(key: price)
                    }
                    
                    else {
                        askOrder!.changeAmount(amount: askOrder!.amount - _quantity)

                        askReceiver.transferFlow(from: <- flowVaultRef.withdraw(amount: price * _quantity))
                        thisReceiver.deposit(from: <- askOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: _quantity))

                        break
                    }
                }
            }
            else {
                var price: UFix64 = self.bidTree.treeMaximum(key: self.bidTree.root)
                let thisReceiver: &{FungibleToken.Receiver} = getAccount(addr).getCapability(/public/flowTokenReceiver).borrow<&{FungibleToken.Receiver}>()!

                while _quantity > 0.0 && price != 0.0 {
                    let bidOrder: &Order? = &self.bidOrders[price] as &Order?
                    let bidReceiver: &{AdminPublic} = getAccount(bidOrder!.admin.addr).getCapability(OrderBookV16.AdminPublicPath).borrow<&{AdminPublic}>()!

                    if bidOrder?.amount != nil && bidOrder!.amount <= _quantity {
                        _quantity = _quantity - bidOrder!.amount
                        price = self.bidTree.prev(target: price)

                        bidReceiver.transferFusd(from: <- fusdVaultRef.withdraw(amount: bidOrder!.amount))
                        thisReceiver.deposit(from: <- bidOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: price * bidOrder!.amount))

                        self.bidTree.remove(key: price)
                        destroy self.bidOrders.remove(key: price)
                    }
                    
                    else {
                        bidOrder!.changeAmount(amount: bidOrder!.amount - _quantity)

                        bidReceiver.transferFusd(from: <- fusdVaultRef.withdraw(amount: _quantity))
                        thisReceiver.deposit(from: <- bidOrder!.admin.storageCapability.borrow()!.withdrawFUSD(amount: price * _quantity))

                        break
                    }
                }
            }
        }

        pub fun cancelOrder(price: UFix64, isBid: Bool): UFix64 {
            if isBid {
                let bidOrder: &Order? = &self.bidOrders[price] as &Order?
                
                OrderBookV16.flowSupply = OrderBookV16.flowSupply - price * bidOrder!.amount
                self.bidTree.remove(key: price)
                destroy self.bidOrders.remove(key: price)

                return price * bidOrder!.amount
            }
            
            else {
                let askOrder: &Order? = &self.askOrders[price] as &Order?

                OrderBookV16.fusdSupply = OrderBookV16.fusdSupply - askOrder!.amount
                self.askTree.remove(key: price)
                destroy self.askOrders.remove(key: price)

                return askOrder!.amount
            }
        }

        init() {
            self.bidTree = OrderBookUtility.Tree()
            self.askTree = OrderBookUtility.Tree()
            self.bidOrders <- {}
            self.askOrders <- {}
        }

        destroy () {
            destroy self.bidOrders
            destroy self.askOrders
        }
    }

    pub resource Order {
        pub let admin: AdminDetail
        pub var amount: UFix64

        init(amount: UFix64, addr: Address, storageCapability: Capability<&Admin{AdminPrivate}>) {
            self.amount = amount
            self.admin = AdminDetail(addr: addr, storageCapability: storageCapability)
        }

        pub fun changeAmount(amount: UFix64) {
            self.amount = amount
        }
    }

    pub resource interface AdminPublic {
        pub fun transferFlow(from: @FungibleToken.Vault)
        pub fun transferFusd(from: @FungibleToken.Vault)
        pub fun flowDeposited(): UFix64
        pub fun fusdDeposited(): UFix64
    }

    pub resource interface AdminPrivate {
        pub fun depositFlow(from: @FungibleToken.Vault)
        pub fun depositFusd(from: @FungibleToken.Vault)
        pub fun withdrawFlow(amount: UFix64): @FungibleToken.Vault
        pub fun withdrawFUSD(amount: UFix64): @FungibleToken.Vault
    }


    pub resource Admin: AdminPublic, AdminPrivate {
        access(self) let flowReceiverCapability: Capability<&{FungibleToken.Receiver}>
        access(self) let fusdReceiverCapability: Capability<&{FungibleToken.Receiver}>

        access(self) let flowVault: @FlowToken.Vault
        access(self) let fusdVault: @FUSD.Vault

        pub fun transferFlow(from: @FungibleToken.Vault) {
            self.flowReceiverCapability.borrow()!.deposit(from: <-from)
        }
        pub fun transferFusd(from: @FungibleToken.Vault) {
            self.fusdReceiverCapability.borrow()!.deposit(from: <-from)
        }
        pub fun flowDeposited(): UFix64 {
            return self.flowVault.balance
        }
        pub fun fusdDeposited(): UFix64 {
            return self.fusdVault.balance
        }

        pub fun depositFlow(from: @FungibleToken.Vault) {
            OrderBookV16.flowSupply = OrderBookV16.flowSupply + from.balance
            self.flowVault.deposit(from: <-from)
        }
        pub fun depositFusd(from: @FungibleToken.Vault) {
            OrderBookV16.fusdSupply = OrderBookV16.fusdSupply + from.balance
            self.fusdVault.deposit(from: <-from)
        }
        pub fun withdrawFlow(amount: UFix64): @FungibleToken.Vault {
            return <-self.flowVault.withdraw(amount: amount)
        }
        pub fun withdrawFUSD(amount: UFix64): @FungibleToken.Vault {
            return <-self.fusdVault.withdraw(amount: amount)
        }

        init(flowReceiverCapability: Capability<&{FungibleToken.Receiver}>, fusdReceiverCapability: Capability<&{FungibleToken.Receiver}>) {
            self.flowReceiverCapability = flowReceiverCapability
            self.fusdReceiverCapability = fusdReceiverCapability

            self.flowVault <- FlowToken.createEmptyVault() as! @FlowToken.Vault
            self.fusdVault <- FUSD.createEmptyVault() as! @FUSD.Vault
        }

        destroy () {
            destroy self.flowVault
            destroy self.fusdVault
        }
    }

    


    init() {
        self.AdminPrivatePath = /storage/OrderBookAdmin
        self.AdminPublicPath = /public/OrderBookAmin
        self.ListingStoragePath = /storage/OrderBookListing
        self.ListingPublicPath = /public/OrderBookListing

        self.account.save(<- create Listing(), to: self.ListingStoragePath)
        self.account.link<&Listing{ListingPublic}>(self.ListingPublicPath, target: self.ListingStoragePath)
        
        self.flowSupply = 0.0
        self.fusdSupply = 0.0
    }
}