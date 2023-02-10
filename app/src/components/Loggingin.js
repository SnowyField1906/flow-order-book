import "../flow.config";
import { useState, useEffect } from "react";
import * as fcl from "@onflow/fcl";

export default function Loggingin() {

    const [user, setUser] = useState({ loggedIn: null })

    useEffect(() => fcl.currentUser.subscribe(setUser), [])

    const AuthedState = () => {
        return (
            <div className="flex place-content-center">
                <div>Address: {user?.addr ?? "No Address"}</div>
                <div>
                    <div className="place-self-center py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-red-600 hover:bg-red-800 " onClick={fcl.unauthenticate}>Log Out</div>
                </div>
            </div >
        )
    }

    const UnauthenticatedState = () => {
        return (
            <div className="flex place-content-center">
                <div className="place-self-center py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-green-600 hover:bg-green-800" onClick={fcl.logIn}>Log In</div>
                <div className="place-self-center py-2 px-2 text-white font-medium cursor-pointer border rounded-lg bg-blue-600 hover:bg-blue-800" onClick={fcl.signUp}>Sign Up</div>
            </div>
        )
    }

    return (
        <>
            {user.loggedIn
                ? <AuthedState />
                : <UnauthenticatedState />
            }
        </>
    );
}