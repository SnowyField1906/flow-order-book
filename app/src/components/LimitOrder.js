import { useEffect, useState } from "react";
import limitOrder from "../transactions/limitOrder";

function LimitOrder() {
    const [price, setPrice] = useState("");
    const [amount, setAmount] = useState("");
    const [isBid, setIsBid] = useState(true);

    console.log(typeof price, typeof amount)

    return (
        <div className='gris place-content-center w-full h-full'>
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
                    <input onChange={(e) => setPrice(e.target.value)}
                        type='text' placeholder='price' className='rounded-l-xl border-2 border-blue-800 p-2 w-4/5' />
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
                amount === "" || price === "" ?
                    <div className="bg-blue-200 cursor-not-allowed mx-auto rounded-xl text-white font-medium
                 py-2 w-[90%] text-center mt-4" disabled>
                        Input all fields
                    </div>
                    :
                    isBid ?
                        <div onClick={() => limitOrder(price, amount, true)}
                            className="bg-blue-800 hover:bg-blue-900 cursor-pointer mx-auto rounded-xl text-white font-medium
                 py-2 w-[90%] text-center mt-4">
                            Pay {+price * +amount} Flow
                        </div>
                        :
                        <div onClick={() => limitOrder(price, amount, false)}
                            className="bg-blue-800 hover:bg-blue-900 cursor-pointer mx-auto rounded-xl text-white font-medium
                 py-2 w-[90%] text-center mt-4">
                            Pay {amount} FUSD
                        </div>
            }
        </div>

    )
}

export default LimitOrder
