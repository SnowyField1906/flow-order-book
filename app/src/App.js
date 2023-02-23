import { useState, useEffect } from "react";
import * as fcl from "@onflow/fcl";
import "./flow.config";

import getSortedIDs from "./scripts/getSortedIDs";

import LimitOrder from "./components/LimitOrder";
import MarketOrder from "./components/MarketOrder";
import Header from "./components/Header";
import Order from "./components/Order";

function App() {
  const [bidIDs, setBidISs] = useState([]);
  const [askIDs, setAskIDs] = useState([]);

  fcl.query({
    cadence: `
      import OrderBookV21 from 0xOrderBookV21
      
      pub fun main(): [UFix64] {
          let listing = getAccount(0xOrderBookV21).getCapability<&OrderBookV21.Listing{OrderBookV21.ListingPublic}>(OrderBookV21.ListingPublicPath).borrow()
          return [listing!.askTree.treeMinimum(key: listing!.askTree.root), listing!.bidTree.treeMaximum(key: listing!.bidTree.root)]
      }
      `,
  }).then((res) => {
    console.log(res);
  });

  const [address, setAddress] = useState("");

  useEffect(() => {
    async function fetchBidIDs() {
      const bidIDs = await getSortedIDs(true);
      setBidISs(bidIDs);
    }

    async function fetchAskIDs() {
      const askIDs = await getSortedIDs(false);
      setAskIDs(askIDs);
    }

    fetchBidIDs();
    fetchAskIDs();
  }, []);

  return (
    <div className="h-full w-screen bg-blue-50">
      <Header setAddress={setAddress} />
      <div className="flex mx-20 pt-20">
        <div className="grid w-1/2">
          {
            askIDs.length !== 0
              ? askIDs.map((id) => {
                return <Order id={id} isBid={false} address={address} />;
              })
              : <div>Loading...</div>
          }
          {
            bidIDs.length !== 0
              ? bidIDs.map((id) => {
                return <Order id={id} isBid={true} address={address} />;
              })
              : <div>Loading...</div>
          }
        </div>
        <div className="grid w-1/2 place-items-center">
          <LimitOrder />
          <MarketOrder currentBid={bidIDs[0]} currentAsk={askIDs[askIDs.length - 1]} />
        </div>
      </div>
    </div>
  );
}

export default App;
