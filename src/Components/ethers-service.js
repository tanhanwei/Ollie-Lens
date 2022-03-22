import { ethers } from 'ethers';

// This code will assume you are using MetaMask.
// It will also assume that you have already done all the connecting to metamask
// this is purely here to show you how the public API hooks together
//export const ethersProvider = new ethers.providers.Web3Provider(window.ethereum);
export const ethersProvider = new ethers.providers.Web3Provider(window.ethereum, "any");

export const getAddress = async() => {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
  return accounts[0];
}

export const signText = (text) => {
  const signer = ethersProvider.getSigner();
  return signer.signMessage(text);
}





// const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
// // Prompt user for account connections
// await provider.send("eth_requestAccounts", []);
// const signer = provider.getSigner();
// console.log("Account:", await signer.getAddress());