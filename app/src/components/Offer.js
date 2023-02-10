import { useState, useEffect } from "react";
import getOfferDetail from "../scripts/getOfferDetail";
import * as fcl from "@onflow/fcl";

function Offer({ id, isBid }) {
    const [detail, setDetail] = useState({});

    useEffect(() => {
        getOfferDetail(id, isBid).then((res) => {
            setDetail(res);
        });
    }, []);


    const detailcolor = isBid ? "bg-red-600 " : "bg-green-600";

    return (
        <div className="flex place-items-center">
            <div className={`${detailcolor} w-1/3 h-min grid p-2 my-2`}>
                <p className="w-full my-auto text-white text-center font-bold">{id}</p>
                <div className="w-full h-full flex justify-center">
                    <p className="w-full my-auto text-white text-center text-sm">{detail.payAmount}</p>
                    <p className="w-full my-auto text-white text-center text-sm">for</p>
                    <p className="w-full my-auto text-white text-center text-sm">{detail.buyAmount}</p>
                </div>
            </div>
            <div className='pl-5'>Cancel</div>
        </div>
    )
}

export default Offer
