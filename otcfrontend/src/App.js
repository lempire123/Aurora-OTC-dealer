import { useState } from 'react'
import { ethers } from 'ethers'
import './App.css'
import OTC from './AuroraOTC.json'

// NOTE: Make sure to change this to the contract address you deployed
const contractAddress = "0xea4B484756B4fbA56e02d482DCb33fF4C79E0a42"



function App() {
  // store greeting in local state
 const [token0, setToken0] = useState()
 const [token1, setToken1] = useState()
 const [amount0, setAmount0] = useState()
 const [amount1, setAmount1] = useState()
 const [index, setIndex] = useState()

  window.onload = async function getChainId() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const { chainId } = await provider.getNetwork()
    if(chainId !== 1313161554) {
        alert("Incorrect Network, please switch to Aurora Network");
    } 
  }
 
  // request access to the user's MetaMask account
  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  }

  async function setupDeal() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner()
      const contract = new ethers.Contract(contractAddress, OTC.abi, signer)
      const transaction = await contract.createDeal(token0, token1, amount0, amount1);
      await transaction.wait();
      console.log('transaction successful!');
    }
  }

  async function deleteDeal() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner()
      const contract = new ethers.Contract(contractAddress, OTC.abi, signer)
      const transaction = await contract.removeDeal(index);
      await transaction.wait();
      console.log('transaction successful!');
    }
  }

  async function takeDeal() {
    if (typeof window.ethereum !== 'undefined') {
      await requestAccount()
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner()
      const contract = new ethers.Contract(contractAddress, OTC.abi, signer)
      const transaction = await contract.acceptDeal(index);
      await transaction.wait();
      console.log('transaction successful!');
    }
  }

  return (
    <div className="App">
      
      <h1>Aurora OTC dealer</h1>
      <header className="App-header">
      <br></br>
      <p className="p">Create an OTC deal!
      </p>
      <button className="button"  onClick={setupDeal}>Create deal</button>
      <input className="input" onChange={e => setToken0(e.target.value)} placeholder="token 0 (token provided)" />
      <input className="input" onChange={e => setToken1(e.target.value)} placeholder="token 1 (token received)" />
      <input className="input" onChange={e => setAmount0(e.target.value)} placeholder="amount 0" />
      <input className="input" onChange={e => setAmount1(e.target.value)} placeholder="amount 1" />

      <p className="p">Available OTC deals</p>
      <button className="button" onClick={takeDeal}>Accept deal</button>
      <input className="input" onChange={e => setIndex(e.target.value)} placeholder="Deal index" />

        <p className="p">Delete outstanding deal</p>
      <button className="button" onClick={deleteDeal}>Remove deal</button>
      	<input className="input" onChange={e => setIndex(e.target.value)} placeholder="Deal index" />
  
      <br></br>
      <br></br>

      </header>
      
    </div>
  );
}

export default App