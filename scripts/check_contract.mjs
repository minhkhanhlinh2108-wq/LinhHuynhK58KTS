import { ethers } from 'ethers';
const addr = '0x71c8360f089f24e1f034c7f6424E86a51D45C522';
const rpc = 'https://ethereum-sepolia-rpc.publicnode.com';
console.log('Checking:', addr, 'on Sepolia');
const provider = new ethers.JsonRpcProvider(rpc);
try {
  const network = await provider.getNetwork();
  console.log('Chain ID:', network.chainId.toString());
  const code = await provider.getCode(addr);
  console.log('Bytecode length:', code.length);
  if (code === '0x') {
    console.log('RESULT: EOA (no bytecode) - Contract NOT deployed here!');
  } else {
    console.log('RESULT: Contract found! First bytes:', code.slice(0,20));
    const abi = ['function scholarshipCount() external view returns (uint256)'];
    const c = new ethers.Contract(addr, abi, provider);
    const count = await c.scholarshipCount();
    console.log('scholarshipCount:', count.toString());
  }
} catch(e) { console.error('ERROR:', e.message); }
