import { useState, useEffect } from "react";
import * as fcl from "@onflow/fcl";
import "./flow.config";

import getSortedIDs from "./scripts/getSortedIDs";

import LimitOrder from "./components/LimitOrder";
import Header from "./components/Header";
import Order from "./components/Order";

function App() {
  const [bidIDs, setBidISs] = useState([]);
  const [askIDs, setAskIDs] = useState([]);

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
    <div className="grid">
      <Header setAddress={setAddress} />
      <div className="flex mx-20">
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
        </div>
      </div>
    </div>
  );
}

export default App;
