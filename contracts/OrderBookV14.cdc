import OrderBookUtility from 0x01
import FUSD from 0x03
import FlowToken from 0x04
import FungibleToken from 0x05

pub contract OrderBookV14 {
    pub let AdminPrivatePath: StoragePath
    pub let AdminPublicPath: PublicPath

    access(self) let flowVault: @FlowToken.Vault
    access(self) let fusdVault: @FUSD.Vault

    pub let bidTree: OrderBookUtility.Tree
    pub let askTree: OrderBookUtility.Tree
    pub(set) var bidOrders: @{UFix64: Order}
    pub(set) var askOrders: @{UFix64: Order}


    pub struct AdminDetail {
        pub let addr: Address
        access(contract) let storageCapability: Capability<&Admin{AdminPrivate}>

        init(addr: Address, storageCapability: Capability<&Admin{AdminPrivate}>) {
            self.addr = addr
            self.storageCapability = storageCapability
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
            self.flowVault.deposit(from: <-from)
        }
        pub fun depositFusd(from: @FungibleToken.Vault) {
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

            self.flowVault <- FlowToken.createEmptyVault()
            self.fusdVault <- FUSD.createEmptyVault()
        }

        destroy () {
            destroy self.flowVault
            destroy self.fusdVault
        }
    }


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
                let askReceiver: &{AdminPublic} = getAccount(askOffer!.admin.addr).getCapability(self.AdminPublicPath).borrow<&{AdminPublic}>()!
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
                let bidReceiver: &{AdminPublic} = getAccount(bidOrder!.admin.addr).getCapability(self.AdminPublicPath).borrow<&{AdminPublic}>()!
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
                let askReceiver: &{AdminPublic} = getAccount(askOrder!.admin.addr).getCapability(self.AdminPublicPath).borrow<&{AdminPublic}>()!

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
                let bidReceiver: &{AdminPublic} = getAccount(bidOrder!.admin.addr).getCapability(self.AdminPublicPath).borrow<&{AdminPublic}>()!

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
            self.bidTree.remove(key: price)
            destroy self.bidOrders.remove(key: price)

            return price * bidOrder!.amount
        }
        
        else {
            let askOrder: &Order? = &self.askOrders[price] as &Order?

            self.askTree.remove(key: price)
            destroy self.askOrders.remove(key: price)

            return askOrder!.amount
        }
    }


    init() {
        self.AdminPrivatePath = /storage/OrderBookAdmin
        self.AdminPublicPath = /public/OrderBookAmin
        
        self.flowVault <- FlowToken.createEmptyVault()
        self.fusdVault <- FUSD.createEmptyVault()

        self.bidTree = OrderBookUtility.Tree()
        self.askTree = OrderBookUtility.Tree()
        self.bidOrders <- {}
        self.askOrders <- {}
    }
}
 