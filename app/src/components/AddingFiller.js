import { useState } from "react";
import limitOrder from "../transactions/limitOrder";

function AddingFiller() {
    const [price, setPrice] = useState(0);
    const [amount, setAmount] = useState(0);
    const [isBid, setIsBid] = useState(true);


    return (
        <div className='grid gird-cols-2 grid-rows-3 w-full h-full '>
            <input onChange={(e) => setPrice(e.target.value)}
                type='text' placeholder='price' className='rounded-xl border-2 border-blue-800 p-2 my-2' />
            <input onChange={(e) => setAmount(e.target.value)}
                type='text' placeholder='amount' className='rounded-xl border-2 border-blue-800 p-2 my-2' />
            <div className="flex justify-evenly w-full">
                <div className='flex place-items-center w-min'>
                    <input onChange={() => setIsBid(true)}
                        type='radio' name='isBid' className='w-full' defaultChecked />
                    <p className='w-full ml-3'>Bid</p>
                </div>
                <div className='flex place-items-center w-min'>
                    <input onChange={() => setIsBid(false)}
                        type='radio' name='isBid' className='w-full ' />
                    <p className='w-full ml-3'>Ask</p>
                </div>
            </div>
            <div onClick={() => limitOrder(price, amount, isBid)} disabled={amount === 0 || price === 0}
                className="place-self-center w-auto bg-blue-500 hover:bg-blue-800 p-2 rounded-xl text-white font-medium cursor-pointer
                disabled:cursor-not-allowed">
                Add Offer
            </div>
        </div>
    )
}

export default AddingFiller
