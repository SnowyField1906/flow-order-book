pub contract Token0 {

    pub var totalSupply: UFix64

    pub resource interface Provider {

        pub fun withdraw(amount: UFix64): @Vault {
            post {
                result.balance == UFix64(amount):
                    "Withdrawal amount must be the same as the balance of the withdrawn Vault"
            }
        }
    }

	pub resource interface Receiver {
        pub fun deposit(from: @Vault) {
            pre {
                from.balance > 0.0:
                    "Deposit balance must be positive"
            }
        }
    }

    pub resource interface Balance {
        pub var balance: UFix64
    }

    pub resource Vault: Provider, Receiver, Balance {

        pub var balance: UFix64

        init(balance: UFix64) {
            self.balance = balance
        }

        pub fun withdraw(amount: UFix64): @Vault {
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

        pub fun deposit(from: @Vault) {
            self.balance = self.balance + from.balance
            destroy from
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 10.0)
    }

    pub resource VaultMinter {

        pub fun mintTokens(amount: UFix64, recipient: Capability<&AnyResource{Receiver}>) {
            let recipientRef = recipient.borrow()
                ?? panic("Could not borrow a receiver reference to the vault")

            Token0.totalSupply = Token0.totalSupply + UFix64(amount)
            recipientRef.deposit(from: <-create Vault(balance: amount))
        }
    }

    init() {
        self.totalSupply = 100.0

        let vault <- create Vault(balance: self.totalSupply)
        self.account.save(<-vault, to: /storage/Vault0)

        self.account.save(<-create VaultMinter(), to: /storage/Minter0)

        self.account.link<&VaultMinter>(/private/Minter, target: /storage/Minter0)
    }
}

