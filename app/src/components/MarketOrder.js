import { useEffect, useState } from "react";
import marketOrder from "../transactions/maketOrder";
import getMarketPrice from "../scripts/getMarketPrice";

function MarketOrder({ currentBid, currentAsk }) {
    const [marketAmount, setMarketAmount] = useState(0);
    const [amount, setAmount] = useState("");
    const [isBid, setIsBid] = useState(true);

    useEffect(() => {
        async function fetchMarketPrice() {
            await getMarketPrice(amount, isBid).then(setMarketAmount)
        }
        fetchMarketPrice();
    }, [amount, isBid])


    return (
        <>
            <div className="translate-y-4 bg-blue-50 text-2xl font-bold text-blue-800 px-2">Market Order</div>
            <div className='gris place-content-center border-2 p-3 rounded-xl border-blue-800 w-96'>
                <div className="text-center my-5 font-semibold text-xl w-[90%] mx-auto">
                    <button onClick={() => setIsBid(true)}
                        className={`rounded-l-xl border-2 border-blue-800 p-1 w-1/2 ${isBid ? "bg-blue-800 text-white" : "bg-white text-blue-800"}`}>
                        Buy FUSD
                    </button>
                    <button onClick={() => setIsBid(false)}
                        className={`rounded-r-xl border-2 border-blue-800 p-1 w-1/2 ${isBid ? "bg-white text-blue-800" : "bg-blue-800 text-white"}`}>
                        Sell FUSD
                    </button>
                </div>
                <div className="grid gap-2 w-full">
                    <div className="flex w-full">
                        <div className='rounded-l-xl border-2 bg-gray-200 border-gray-300 p-2 w-4/5' >
                            <p className="text-gray-400">Current price: {isBid ? currentAsk : currentBid}</p>
                        </div>
                        <div className="grid rounded-r-xl w-1/5 bg-blue-800">
                            <p className="self-center text-center text-white">Flow</p>
                        </div>
                    </div>
                    <div className="flex w-full">
                        <input onChange={(e) => setAmount(e.target.value)}
                            type='text' placeholder='amount' className='rounded-l-xl border-2 border-blue-800 p-2 w-4/5' />
                        <div className="grid rounded-r-xl w-1/5 bg-blue-800">
                            <p className="self-center text-center text-white">FUSD</p>
                        </div>
                    </div>
                </div>
                {
                    amount === "" ?
                        <div className="bg-blue-200 cursor-not-allowed mx-auto rounded-xl text-white font-medium
                 py-2 w-[90%] text-center mt-4" disabled>
                            Input all fields
                        </div>
                        :
                        isBid ?
                            <div onClick={() => marketOrder(amount, true)}
                                className="bg-blue-800 hover:bg-blue-900 cursor-pointer mx-auto rounded-xl text-white font-medium
                 py-2 w-[90%] text-center mt-4">
                                Pay {parseFloat(marketAmount)} Flow
                            </div>
                            :
                            <div onClick={() => marketOrder(amount, false)}
                                className="bg-blue-800 hover:bg-blue-900 cursor-pointer mx-auto rounded-xl text-white font-medium
                 py-2 w-[90%] text-center mt-4">
                                Receive {parseFloat(marketAmount)} Flow
                            </div>
                }
            </div>
        </>

    )
}

export default MarketOrder
