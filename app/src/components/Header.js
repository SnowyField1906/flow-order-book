import "../flow.config";
import { useState, useEffect } from "react";
import getContractBalance from "../scripts/getContractBalance";
import getUserBalance from "../scripts/getUserBalance";
import setupAccount from "../transactions/setupAccount";
import checkSetup from "../scripts/checkSetup";
import * as fcl from "@onflow/fcl";

export default function Header() {

    const [user, setUser] = useState({ loggedIn: null })
    const [userBalance, setBalance] = useState({ Flow: null, FUSD: null })
    const [contractBalance, setContractBalance] = useState({ Flow: null, FUSD: null })

    useEffect(() => {
        getContractBalance().then(setContractBalance)
        fcl.currentUser().subscribe(setUser)
        user.loggedIn && checkSetup(user?.addr)
            .then(setup => setup
                ? getUserBalance(user?.addr).then(setBalance)
                : setBalance({ Flow: null, FUSD: null })
            )
    }, [user.loggedIn])


    return (
        <div className="bg-slate-200 grid grid-cols-2 w-full h-16">
            <div className="flex justify-evenly place-content-center h-full">
                <div className="text-3xl font-bold text-black self-center">Flow-FUSD</div>
                <div className="grid">
                    <div className="text-center self-center mx-3">Total Supply</div>
                    <div className="flex place-content-center">
                        <div className="self-center mx-3">Flow: {contractBalance.Flow}</div>
                        <div className="self-center mx-3">FUSD: {contractBalance.FUSD}</div>
                    </div>
                </div>
            </div>
            <div className="flex justify-evenly">
                {user.loggedIn ?
                    <>
                        <div className="flex place-content-center">
                            <div className="grid">
                                <div className="text-center self-center mx-3">Address: {user?.addr ?? "No Address"}</div>
                                <div className="flex place-content-center">
                                    {userBalance.FUSD === null ?
                                        <div className="self-center mx-3 py-1 px-2 text-white font-medium cursor-pointer border rounded-lg bg-blue-600 hover:bg-blue-800" onClick={setupAccount}>
                                            Setup Account
                                        </div>
                                        :
                                        <div className="flex place-content-center">
                                            <div className="self-center mx-3">Flow: {userBalance.Flow}</div>
                                            <div className="self-center mx-3">FUSD: {userBalance.FUSD}</div>
                                        </div>
                                    }
                                </div>
                            </div>
                            <div className="place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-red-600 hover:bg-red-800 " onClick={fcl.unauthenticate}>Log Out</div>
                        </div>
                    </>
                    :
                    <div className="flex place-content-center">
                        <div className="place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-green-600 hover:bg-green-800" onClick={fcl.logIn}>Log In</div>
                        <div className="place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-blue-600 hover:bg-blue-800" onClick={fcl.signUp}>Sign Up</div>
                    </div>
                }
            </div>
        </div>
    );
}