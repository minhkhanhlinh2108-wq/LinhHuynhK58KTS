import "dotenv/config";
import {
  JsonRpcProvider,
  Wallet,
  ContractFactory,
  formatEther
} from "ethers";
import { readFile } from "node:fs/promises";

async function main() {
  console.log("=== TrustScholar: Deploy ProjectCore ===");

  const rpcUrl =
    process.env.SEPOLIA_RPC_URL ||
    "https://ethereum-sepolia-rpc.publicnode.com";

  const rawKey = process.env.PRIVATE_KEY || "";
  const privateKey = rawKey
    ? rawKey.startsWith("0x")
      ? rawKey
      : `0x${rawKey}`
    : "";

  if (!privateKey) {
    throw new Error("Thieu PRIVATE_KEY trong file .env");
  }

  const provider = new JsonRpcProvider(rpcUrl);
  const network = await provider.getNetwork();

  if (network.chainId !== 11155111n) {
    throw new Error(`Sai chainId: ${network.chainId}; yeu cau Sepolia.`);
  }

  const wallet = new Wallet(privateKey, provider);
  const balance = await provider.getBalance(wallet.address);

  console.log("Deployer:", wallet.address);
  console.log("So du:", formatEther(balance), "ETH");

  if (balance === 0n) {
    throw new Error("Vi deployer khong co Sepolia ETH.");
  }

  const artifactPath = new URL(
    "../artifacts/contracts/project/ProjectCore.sol/ProjectCore.json",
    import.meta.url
  );

  const artifact = JSON.parse(await readFile(artifactPath, "utf8"));

  if (!artifact.abi || !artifact.bytecode || artifact.bytecode === "0x") {
    throw new Error("Artifact thieu ABI hoac bytecode.");
  }

  const factory = new ContractFactory(
    artifact.abi,
    artifact.bytecode,
    wallet
  );

  console.log("Dang trien khai ProjectCore...");
  const contract = await factory.deploy();
  const tx = contract.deploymentTransaction();

  console.log("TX hash:", tx?.hash || "(unknown)");

  await contract.waitForDeployment();

  const address = await contract.getAddress();
  const code = await provider.getCode(address);

  if (!code || code === "0x" || code.length <= 2) {
    throw new Error("Khong tim thay bytecode tai dia chi vua deploy.");
  }

  console.log("DEPLOY THANH CONG!");
  console.log("Contract address:", address);
  console.log("Bytecode length:", code.length);
  console.log("Etherscan:", `https://sepolia.etherscan.io/address/${address}`);
}

main().catch((error) => {
  console.error("DEPLOY THAT BAI:", error.shortMessage || error.message || error);
  process.exitCode = 1;
});
