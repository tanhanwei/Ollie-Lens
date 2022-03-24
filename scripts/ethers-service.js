import { ethers, Contract } from 'ethers';

// This code will assume you are using MetaMask.
// It will also assume that you have already done all the connecting to metamask
// this is purely here to show you how the public API hooks together
//export const ethersProvider = new ethers.providers.Web3Provider(window.ethereum);

export const ethersProvider = typeof window !== "undefined" && new ethers.providers.Web3Provider(window?.ethereum, "any");

export const getAddress = async() => {
  const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
  return accounts[0];
}

export const signText = (text) => {
  const signer = ethersProvider.getSigner();
  return signer.signMessage(text);
}

export const checkLPPTokenBalance = async (address) => {
  const lppTokenAddress = '0xd7b3481de00995046c7850bce9a5196b7605c367';
  const apiToken = "1EUKR4GM3GS2TSSV1IARBSZSDWVC8H3Q5W"

  const requestURL = `https://api-testnet.polygonscan.com/api?module=account&action=tokennfttx&contractaddress=${lppTokenAddress}&address=${await getAddress()}&page=1&offset=100&sort=asc&apikey=${apiToken}`;
    
  const response = await fetch(requestURL);
  
  const data = await response.json();

  return data?.result;
}