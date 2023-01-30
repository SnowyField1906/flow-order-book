import SimpleMarket from 0x01

transaction {
    prepare(acct: AuthAccount) {
        let newUser <- SimpleMarket.createUser()
        acct.save<@SimpleMarket.User>(<-newUser, to: /storage/User)

        let capability = acct.link<&SimpleMarket.User>(/public/User, target: /storage/User)
        let userRef = capability!.borrow()
    }

    execute {
        log("Capability and Link created")
    }
}