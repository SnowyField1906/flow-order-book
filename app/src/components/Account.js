import "../flow.config";
import { useState, useEffect } from "react";
import getUserBalance from "../scripts/getUserBalance";
import setupAccount from "../transactions/setupAccount";
import * as fcl from "@onflow/fcl";

export default function Account() {

    const [user, setUser] = useState({ loggedIn: null })
    const [balance, setBalance] = useState({ Flow: 0, FUSD: 0 })

    useEffect(() => {
        fcl.currentUser().subscribe(setUser)
        if (user.loggedIn) {
            getUserBalance(user?.addr).then(setBalance)
        }
    }, [user.loggedIn])

    return (
        <div className="bg-slate-200 flex justify-evenly w-full">
            {user.loggedIn && <div className="flex place-content-center">
                <div className="self-center mx-3">Flow: {balance.Flow}</div>
                <div className="self-center mx-3">FUSD: {balance.FUSD}</div>
                <div className="self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-blue-600 hover:bg-blue-800" onClick={() => setupAccount(user?.addr)}>Setup Account</div>
            </div>
            }
            {user.loggedIn ?
                <div className="flex place-content-center">
                    <div className="self-center mx-3">Address: {user?.addr ?? "No Address"}</div>
                    <div>
                        <div className="place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-red-600 hover:bg-red-800 " onClick={fcl.unauthenticate}>Log Out</div>
                    </div>
                </div>
                :
                <div className="flex place-content-center">
                    <div className="place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-green-600 hover:bg-green-800" onClick={fcl.logIn}>Log In</div>
                    <div className="place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-blue-600 hover:bg-blue-800" onClick={fcl.signUp}>Sign Up</div>
                </div>
            }
        </div>
    );
}