import { useState, useEffect } from "react";
import getOrderDetail from "../scripts/getOrderDetail";
import cancelOrder from "../transactions/cancelOrder";
import * as fcl from "@onflow/fcl";

function Order({ id, isBid, address }) {
    const [detail, setDetail] = useState({});
    useEffect(() => {
        getOrderDetail(id, isBid).then((res) => {
            setDetail(res);
        });
    }, []);


    const detailcolor = isBid ? "bg-green-600 " : "bg-red-600";


    return (
        <div className="flex place-items-center">
            <div className={`${detailcolor} grid grid-cols-2 w-1/3 h-min p-2 my-2 px-4 cursor-pointer`}>
                <p className="w-full my-auto text-white text-left font-bold text-lg">{id}</p>
                <p className="w-full my-auto text-white text-right text-sm">{parseFloat(detail.amount)}</p>
            </div>
            {detail.addr === address && <div onClick={() => cancelOrder(id, isBid)} className='pl-5 cursor-pointer'>Cancel</div>}
        </div>
    )

}

export default Order
