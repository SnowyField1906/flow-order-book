import OrderBookUtility from 0x9d380238fdd484d7
import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68
import FlowToken from 0x7e60df042a9c0868


pub contract OrderBookV18 {
    pub let AdminStoragePath: StoragePath
    pub let AdminCapabilityPath: CapabilityPath
    pub let AdminPublicPath: PublicPath
    pub let ListingPublicPath: PublicPath
    pub let ListingStoragePath: StoragePath

    pub var flowSupply: UFix64
    pub var fusdSupply: UFix64

    pub resource interface ListingPublic {
        pub let bidTree: OrderBookUtility.Tree
        pub let askTree: OrderBookUtility.Tree
        
        pub fun orderDetails(price: UFix64, isBid: Bool): OrderDetails
        pub fun limitOrder(addr: Address, price: UFix64, amount: UFix64, isBid: Bool,  storageCapability: Capability<&Admin{AdminPrivate}>, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault)
        pub fun marketOrder(addr: Address, quantity: UFix64, isBid: Bool, storageCapability: Capability<&Admin{AdminPrivate}>, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault)
        pub fun cancelOrder(price: UFix64, isBid: Bool, storageCapability: Capability<&Admin{AdminPrivate}>)
    }

    pub resource Listing: ListingPublic {
        pub let bidTree: OrderBookUtility.Tree
        pub let askTree: OrderBookUtility.Tree

        access(contract) var bidOrders: @{UFix64: Order}
        access(contract) var askOrders: @{UFix64: Order}

        pub fun orderDetails(price: UFix64, isBid: Bool): OrderDetails {
            if isBid {
                let order: &Order? = &self.bidOrders[price] as &Order?
                return order!._details()
            } else {
                let order: &Order? = &self.askOrders[price] as &Order?
                return order!._details()
            }
        }

        pub fun limitOrder(addr: Address, price: UFix64, amount: UFix64, isBid: Bool, storageCapability: Capability<&Admin{AdminPrivate}>, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault) {

            /* is buying - bid */
            if isBid {

                /* doesn't exist a matching ask order */
                if !self.askTree.exists(key: price) {

                    // (1): add this order with full amount
                    self.bidOrders[price] <-! create Order(amount: amount, addr: addr, storageCapability: storageCapability)
                    self.bidTree.insert(key: price)

                    // (2): deposit Flow to contract
                    storageCapability.borrow()!._depositAdminFlow(from: <- flowVaultRef.withdraw(amount: price * amount))
                }

                /* exists a matching ask order */
                else {
                    let askOffer: &Order? = &self.askOrders[price] as &Order?
                    let askReceiver: &{AdminPublic} = getAccount(askOffer!.admin.addr).getCapability(OrderBookV18.AdminPublicPath).borrow<&{AdminPublic}>()!
                    
                    /* ask order has enough FUSD amount for this order */
                    if askOffer!.amount > amount {

                        // (1): decrease ask order's FUSD amount
                        askOffer!._changeAmount(amount: askOffer!.amount - amount)

                        // (3): transfer Flow to ask
                        askReceiver.transferredFlow(from: <- flowVaultRef.withdraw(amount: price * amount))

                        // (4): receive FUSD from ask's
                        storageCapability.borrow()!._receiveAdminFusd(from: <- askOffer!.admin.storageCapability.borrow()!._withdrawAdminFusd(amount: amount))
                    }

                    else {

                        /* ask order doesn't have enough FUSD amount for this order */
                        if askOffer!.amount < amount {

                            // (1): add this order with decreased amount
                            self.bidOrders[price] <-! create Order(amount: amount - askOffer!.amount, addr: addr, storageCapability: storageCapability)
                            self.bidTree.insert(key: price)

                            // (2): deposit Flow to contract
                            storageCapability.borrow()!._depositAdminFlow(from: <- flowVaultRef.withdraw(amount: price * (amount - askOffer!.amount)))

                            // (3): transfer Flow to ask
                            askReceiver.transferredFlow(from: <- flowVaultRef.withdraw(amount: price * askOffer!.amount))

                            // (4): receive FUSD from ask's
                            storageCapability.borrow()!._receiveAdminFusd(from: <- askOffer!.admin.storageCapability.borrow()!._withdrawAdminFusd(amount: askOffer!.amount))
                        }

                        /* ask order has equal FUSD amount for this order */
                        else {
                            
                            // (3): transfer Flow to ask
                            askReceiver.transferredFlow(from: <- flowVaultRef.withdraw(amount: price * amount))

                            // (4): receive FUSD from ask's
                            storageCapability.borrow()!._receiveAdminFusd(from: <- askOffer!.admin.storageCapability.borrow()!._withdrawAdminFusd(amount: amount))
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

                    // (2): deposit FUSD to contract
                    storageCapability.borrow()!._depositAdminFusd(from: <- fusdVaultRef.withdraw(amount: amount))
                }

                /* exists a matching bid order */ 
                else {
                    let bidOrder: &Order? = &self.bidOrders[price] as &Order?
                    let bidReceiver: &{AdminPublic} = getAccount(bidOrder!.admin.addr).getCapability(OrderBookV18.AdminPublicPath).borrow<&{AdminPublic}>()!

                    /* bid order has enough Flow amount for this order */
                    if bidOrder!.amount > amount {
                        
                        // (1): decrease bid order's FUSD amount
                        bidOrder!._changeAmount(amount: bidOrder!.amount - amount)

                        // (3): transfer FUSD to bid
                        bidReceiver.transferredFusd(from: <- fusdVaultRef.withdraw(amount: amount))

                        // (4): receive Flow from bid's
                        storageCapability.borrow()!._receiveAdminFlow(from: <- bidOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: price * amount))
                    }

                    else {

                        /* bid order doesn't have enough FUSD amount for this order */
                        if bidOrder!.amount < amount {

                            // (1): add this order with decreased amount
                            self.bidOrders[price] <-! create Order(amount: amount - bidOrder!.amount, addr: addr, storageCapability: storageCapability)
                            self.bidTree.insert(key: price)

                            // (2): deposit FUSD to contract
                            storageCapability.borrow()!._depositAdminFusd(from: <- fusdVaultRef.withdraw(amount: amount - bidOrder!.amount))

                            // (3): transfer FUSD to bid
                            bidReceiver.transferredFusd(from: <- fusdVaultRef.withdraw(amount: bidOrder!.amount))

                            // (4): receive Flow from bid's
                            storageCapability.borrow()!._receiveAdminFlow(from: <- bidOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: price * bidOrder!.amount))
                        }

                        /* bid order has equal FUSD amount for this order */
                        else {
                            
                            // (3): transfer FUSD to bid
                            bidReceiver.transferredFusd(from: <- fusdVaultRef.withdraw(amount: amount))

                            // (4): receive Flow from bid's
                            storageCapability.borrow()!._receiveAdminFlow(from: <- bidOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: price * amount))
                        }
                        
                        // (5): remove bid order
                        self.bidTree.remove(key: price)
                        destroy self.bidOrders.remove(key: price)
                    }
                }
            }
        }

        pub fun marketOrder(addr: Address, quantity: UFix64, isBid: Bool, storageCapability: Capability<&Admin{AdminPrivate}>, flowVaultRef: &FlowToken.Vault, fusdVaultRef: &FUSD.Vault) {
            var _quantity: UFix64 = quantity

            if isBid {
                var price: UFix64 = self.askTree.treeMinimum(key: self.askTree.root)

                while _quantity > 0.0 && price != 0.0 {
                    let askOrder: &Order? = &self.askOrders[price] as &Order?
                    let askReceiver: &{AdminPublic} = getAccount(askOrder!.admin.addr).getCapability(OrderBookV18.AdminPublicPath).borrow<&{AdminPublic}>()!

                    if askOrder?.amount != nil && askOrder!.amount <= _quantity {

                        _quantity = _quantity - askOrder!.amount
                        price = self.askTree.next(target: price)

                        askReceiver.transferredFlow(from: <- flowVaultRef.withdraw(amount: price * askOrder!.amount))
                        storageCapability.borrow()!._receiveAdminFusd(from: <- askOrder!.admin.storageCapability.borrow()!._withdrawAdminFusd(amount: askOrder!.amount))

                        self.askTree.remove(key: price)
                        destroy self.askOrders.remove(key: price)
                    }
                    
                    else {
                        askOrder!._changeAmount(amount: askOrder!.amount - _quantity)

                        askReceiver.transferredFlow(from: <- flowVaultRef.withdraw(amount: price * _quantity))
                        storageCapability.borrow()!._receiveAdminFusd(from: <- askOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: _quantity))

                        break
                    }
                }
            }
            else {
                var price: UFix64 = self.bidTree.treeMaximum(key: self.bidTree.root)

                while _quantity > 0.0 && price != 0.0 {
                    let bidOrder: &Order? = &self.bidOrders[price] as &Order?
                    let bidReceiver: &{AdminPublic} = getAccount(bidOrder!.admin.addr).getCapability(OrderBookV18.AdminPublicPath).borrow<&{AdminPublic}>()!

                    if bidOrder?.amount != nil && bidOrder!.amount <= _quantity {
                        _quantity = _quantity - bidOrder!.amount
                        price = self.bidTree.prev(target: price)

                        bidReceiver.transferredFusd(from: <- fusdVaultRef.withdraw(amount: bidOrder!.amount))
                        storageCapability.borrow()!._receiveAdminFlow(from: <- bidOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: price * bidOrder!.amount))

                        self.bidTree.remove(key: price)
                        destroy self.bidOrders.remove(key: price)
                    }
                    
                    else {
                        bidOrder!._changeAmount(amount: bidOrder!.amount - _quantity)

                        bidReceiver.transferredFusd(from: <- fusdVaultRef.withdraw(amount: _quantity))
                        storageCapability.borrow()!._receiveAdminFlow(from: <- bidOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: price * _quantity))

                        break
                    }
                }
            }
        }

        pub fun cancelOrder(price: UFix64, isBid: Bool, storageCapability: Capability<&Admin{AdminPrivate}>) {
            if isBid {
                let bidOrder: &Order? = &self.bidOrders[price] as &Order?
                
                self.bidTree.remove(key: price)
                destroy self.bidOrders.remove(key: price)

                storageCapability.borrow()!._receiveAdminFlow(from: <- bidOrder!.admin.storageCapability.borrow()!._withdrawAdminFlow(amount: price * bidOrder!.amount))
            }
            
            else {
                let askOrder: &Order? = &self.askOrders[price] as &Order?

                self.askTree.remove(key: price)
                destroy self.askOrders.remove(key: price)

                storageCapability.borrow()!._receiveAdminFusd(from: <- askOrder!.admin.storageCapability.borrow()!._withdrawAdminFusd(amount: askOrder!.amount))
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

    pub struct OrderDetails {
        pub let addr: Address
        pub let amount: UFix64

        init(addr: Address, amount: UFix64) {
            self.addr = addr
            self.amount = amount
        }
    }

    pub resource Order {
        access(contract) let admin: AdminDetail
        access(contract) var amount: UFix64

        init(amount: UFix64, addr: Address, storageCapability: Capability<&Admin{AdminPrivate}>) {
            self.amount = amount
            self.admin = AdminDetail(addr: addr, storageCapability: storageCapability)
        }

        access(contract) fun _changeAmount(amount: UFix64) {
            self.amount = amount
        }

        access(contract) fun _details(): OrderDetails {
            return OrderDetails(addr: self.admin.addr, amount: self.amount)
        }
    }

    pub struct AdminDetail {
        access(contract) let addr: Address
        access(contract) let storageCapability: Capability<&Admin{AdminPrivate}>

        init(addr: Address, storageCapability: Capability<&Admin{AdminPrivate}>) {
            self.addr = addr
            self.storageCapability = storageCapability
        }
    }

    pub resource interface AdminPublic {
        pub fun transferredFlow(from: @FungibleToken.Vault)
        pub fun transferredFusd(from: @FungibleToken.Vault)
        pub fun flowDeposited(): UFix64
        pub fun fusdDeposited(): UFix64
    }

    pub resource interface AdminPrivate {
        access(contract) fun _receiveAdminFlow(from: @FungibleToken.Vault)
        access(contract) fun _receiveAdminFusd(from: @FungibleToken.Vault)
        access(contract) fun _depositAdminFlow(from: @FungibleToken.Vault)
        access(contract) fun _depositAdminFusd(from: @FungibleToken.Vault)
        access(contract) fun _withdrawAdminFlow(amount: UFix64): @FungibleToken.Vault
        access(contract) fun _withdrawAdminFusd(amount: UFix64): @FungibleToken.Vault
    }

    pub resource Admin: AdminPublic, AdminPrivate {
        access(self) let flowReceiverCapability: Capability<&{FungibleToken.Receiver}>
        access(self) let fusdReceiverCapability: Capability<&{FungibleToken.Receiver}>

        access(self) let flowVault: @FlowToken.Vault
        access(self) let fusdVault: @FUSD.Vault

        pub fun transferredFlow(from: @FungibleToken.Vault) {
            self.flowReceiverCapability.borrow()!.deposit(from: <-from)
        }
        pub fun transferredFusd(from: @FungibleToken.Vault) {
            self.fusdReceiverCapability.borrow()!.deposit(from: <-from)
        }
        pub fun flowDeposited(): UFix64 {
            return self.flowVault.balance
        }
        pub fun fusdDeposited(): UFix64 {
            return self.fusdVault.balance
        }

        access(contract) fun _receiveAdminFlow(from: @FungibleToken.Vault) {
            OrderBookV18.flowSupply = OrderBookV18.flowSupply - from.balance
            self.flowReceiverCapability.borrow()!.deposit(from: <-from)
        }
        access(contract) fun _receiveAdminFusd(from: @FungibleToken.Vault) {
            OrderBookV18.fusdSupply = OrderBookV18.fusdSupply - from.balance
            self.fusdReceiverCapability.borrow()!.deposit(from: <-from)
        }
        access(contract) fun _depositAdminFlow(from: @FungibleToken.Vault) {
            OrderBookV18.flowSupply = OrderBookV18.flowSupply + from.balance
            self.flowVault.deposit(from: <-from)
        }
        access(contract) fun _depositAdminFusd(from: @FungibleToken.Vault) {
            OrderBookV18.fusdSupply = OrderBookV18.fusdSupply + from.balance
            self.fusdVault.deposit(from: <-from)
        }
        access(contract) fun _withdrawAdminFlow(amount: UFix64): @FungibleToken.Vault {
            return <-self.flowVault.withdraw(amount: amount)
        }
        access(contract) fun _withdrawAdminFusd(amount: UFix64): @FungibleToken.Vault {
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

    pub fun createAdmin(flowReceiverCapability: Capability<&{FungibleToken.Receiver}>, fusdReceiverCapability: Capability<&{FungibleToken.Receiver}>): @Admin {
        return <-create Admin(flowReceiverCapability: flowReceiverCapability, fusdReceiverCapability: fusdReceiverCapability)
    }

    init() {
        self.AdminStoragePath = /storage/OrderBookV18Admin
        self.AdminCapabilityPath = /private/OrderBookV18Admin
        self.AdminPublicPath = /public/OrderBookV18Amin
        self.ListingStoragePath = /storage/OrderBookV18Listing
        self.ListingPublicPath = /public/OrderBookV18Listing

        self.account.save(<- create Listing(), to: self.ListingStoragePath)
        self.account.link<&Listing{ListingPublic}>(self.ListingPublicPath, target: self.ListingStoragePath)
        
        self.flowSupply = 0.0
        self.fusdSupply = 0.0
    }
}