Flow -> FUSD
12 -> 5

ask(price 4 Flow: sell 3 FUSD) pay(3 FUSD) receive(12 Flow)

bid(price 4 Flow: buy 5 FUSD) pay(20 Flow) receive(5 FUSD)


edit: bid(price 4 Flow: buy 2 FUSD) pay(8 Flow) receive(2 FUSD)


withdraw: bid(12 Flow)
deposit: ask(12 Flow)

withdraw: contract(3 FUSD)
deposit: bid(3 FUSD)
