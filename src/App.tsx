import React from "react";
import Web3Modal from "web3modal";
import WalletConnectProvider from "@walletconnect/ethereum-provider";
import { Contract, providers, utils } from "ethers";
import { NftGallery } from 'react-nft-gallery';

// @ts-ignore
import logo from "./logo.png";
import "./App.css";
import { formatAuthMessage } from "./utils";
import { DAI, NFTransport } from "./constants";

function App() {
  const web3Modal = new Web3Modal({
    network: "rinkeby",
    cacheProvider: true,
    providerOptions: {
      walletconnect: {
        package: WalletConnectProvider,
        options: {
          infuraId: "07a97e3a0c9f47cab7b6bbf61dc6df47",
        },
      },
    },
  });

  const [chainId, setChainId] = React.useState<number>(1);
  const [address, setAddress] = React.useState<string>("");
  const [provider, setProvider] = React.useState<providers.Web3Provider>();

  function reset() {
    console.log("reset");
    setAddress("");
    setProvider(undefined);
    web3Modal.clearCachedProvider();
  }

  async function connect() {
    if (!"07a97e3a0c9f47cab7b6bbf61dc6df47") {
      throw new Error("Missing Infura Id");
    }
    const web3Provider = await web3Modal.connect();

    web3Provider.on("disconnect", reset);

    const accounts = (await web3Provider.enable()) as string[];
    setAddress(accounts[0]);
    setChainId(web3Provider.chainId);

    const provider = new providers.Web3Provider(web3Provider);
    setProvider(provider);
  }

  async function signMessage() {
    if (!provider) {
      throw new Error("Provider not connected");
    }
    const msg = formatAuthMessage(address, chainId);
    const sig = await provider.send("personal_sign", [msg, address]);
    console.log("Signature", sig);
    console.log("isValid", utils.verifyMessage(msg, sig) === address);
  }
  //async function mint
  async function redeem() {
    if (!provider) {
      throw new Error("Provider not connected");
    }
    const contract = new Contract(NFTransport.address, NFTransport.abi, provider.getSigner());
    const res = await contract.redeem(1);
    console.log("res", res);
  }
  //async function redeem
  async function safeMint() {
    if (!provider) {
      throw new Error("Provider not connected");
    }
    const contract = new Contract(NFTransport.address, NFTransport.abi, provider.getSigner());
    const res = await contract.safeMint();
    console.log("res", res);
  }
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />

        <div>{provider ? "Connected!" : "Not connected"}</div>
        {address ? (
          <>
            <div>{address}</div>
            <button onClick={safeMint}>Mint</button>
            <button onClick={redeem}>Redeem</button>
          </>
        ) : (
          <button onClick={connect}>Connect</button>
        )}
      </header>
      {address ? (
        <>
      <NftGallery
        ownerAddress={address}
        apiUrl="https://testnets-api.opensea.io" />
        </>
      ) : (<></>)}
    </div>
  );
}

export default App;
