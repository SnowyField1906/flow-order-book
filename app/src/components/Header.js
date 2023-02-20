import "../flow.config";
import { useState, useEffect } from "react";
import getContractBalance from "../scripts/getContractBalance";
import getUserBalance from "../scripts/getUserBalance";
import getDepositedAmount from "../scripts/getDepositedAmount";
import setupAccount from "../transactions/setupAccount";
import checkSetup from "../scripts/checkSetup";
import * as fcl from "@onflow/fcl";

export default function Header({ setAddress }) {

    const [user, setUser] = useState({ loggedIn: null })
    const [userBalance, setBalance] = useState({ Flow: null, FUSD: null })
    const [contractBalance, setContractBalance] = useState({ Flow: null, FUSD: null })
    const [userDeposited, setUserDeposited] = useState({ Flow: null, FUSD: null })

    useEffect(() => {
        getContractBalance().then(setContractBalance)
        fcl.currentUser().subscribe(setUser)
        user.loggedIn && checkSetup(user?.addr)
            .then(setup => setup &&
                getUserBalance(user?.addr).then(setBalance) &&
                getDepositedAmount(user?.addr).then(setUserDeposited)
            )
        setAddress(user?.addr)
    }, [user.loggedIn])


    return (
        <div className="bg-blue-800 grid grid-cols-3 w-full h-16 fixed z-50">
            <div className="grid grid-cols-2 h-full border-r-2 place-content-center">
                <div className="text-4xl font-bold text-white self-center text-center">Flow-FUSD</div>
                <div className="grid">
                    <div className="text-center self-center mx-3 font-bold text-xl text-white">Total Supply</div>
                    <div className="flex place-content-center">
                        <div className="self-center mx-3 font-semibold text-white">Flow: {contractBalance.Flow}</div>
                        <div className="self-center mx-3 font-semibold text-white">FUSD: {contractBalance.FUSD}</div>
                    </div>
                </div>
            </div>
            {user.loggedIn ?
                userDeposited.Flow && userDeposited.FUSD && userBalance.Flow && userBalance.FUSD ?
                    <div className="grid grid-cols-7 col-span-2 place-content-center">
                        <div className="flex text-2xl font-bold text-white self-center col-span-2 justify-center">{user?.addr}</div>
                        <div className="grid col-span-2">
                            <div className="text-center self-center mx-3 font-bold text-xl text-white">Your Balance</div>
                            <div className="flex place-content-center">
                                <div className="flex place-content-center">
                                    <div className="self-center mx-3 font-semibold text-white">Flow: {userBalance.Flow}</div>
                                    <div className="self-center mx-3 font-semibold text-white">FUSD: {userBalance.FUSD}</div>
                                </div>
                            </div>
                        </div>
                        <div className="grid col-span-2">
                            <div className="text-center self-center mx-3 font-bold text-xl text-white">You Deposited</div>
                            <div className="flex place-content-center">
                                <div className="flex place-content-center">
                                    <div className="self-center mx-3 font-semibold text-white">Flow: {userDeposited.Flow}</div>
                                    <div className="self-center mx-3 font-semibold text-white">FUSD: {userDeposited.FUSD}</div>
                                </div>
                            </div>
                        </div>
                        <div className="w-20 text-center place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer rounded-lg bg-red-600 hover:bg-red-800" onClick={fcl.unauthenticate}>Log Out</div>
                    </div>
                    :
                    <div className="flex place-content-center col-span-2">
                        <div className="w-20 text-center place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer rounded-lg bg-green-600 hover:bg-green-800" onClick={setupAccount}>Setup</div>
                        <div className="w-20 text-center place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer rounded-lg bg-red-600 hover:bg-red-800" onClick={fcl.unauthenticate}>Log Out</div>
                    </div>
                :
                <div className="flex place-content-center col-span-2">
                    <div className="w-20 text-center place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer rounded-lg bg-green-600 hover:bg-green-800" onClick={fcl.logIn}>Log In</div>
                    <div className="w-20 text-center place-self-center mx-3 py-2 px-2 text-white font-medium cursor-pointer rounded-lg bg-yellow-600 hover:bg-yellow-800" onClick={fcl.signUp}>Sign Up</div>
                </div>
            }
        </div>
    );
}