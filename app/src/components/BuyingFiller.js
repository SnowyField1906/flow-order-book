import React from 'react'

function LimitOrder() {
    return (
        <div className='grid gird-cols-2 grid-rows-2 w-full h-full '>
            <input type='text' placeholder='payAmount' className='rounded-xl border-2 border-blue-800 p-2 my-2' />
            <input type='text' placeholder='buyAmount' className='rounded-xl border-2 border-blue-800 p-2 my-2' />
            <div className="place-self-center w-auto bg-blue-500 hover:bg-blue-800 p-2 rounded-xl text-white font-medium cursor-pointer">Add Offer</div>
        </div>
    )
}

export default LimitOrder
