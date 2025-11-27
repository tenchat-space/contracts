import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // 1. Deploy TenchatToken
  const TenchatToken = await ethers.getContractFactory("TenchatToken");
  const tenchatToken = await TenchatToken.deploy();
  await tenchatToken.waitForDeployment();
  const tokenAddress = await tenchatToken.getAddress();
  console.log("TenchatToken deployed to:", tokenAddress);

  // 2. Deploy TenchatIdentity
  const TenchatIdentity = await ethers.getContractFactory("TenchatIdentity");
  const tenchatIdentity = await TenchatIdentity.deploy();
  await tenchatIdentity.waitForDeployment();
  console.log("TenchatIdentity deployed to:", await tenchatIdentity.getAddress());

  // 3. Deploy TenchatSignaling
  const TenchatSignaling = await ethers.getContractFactory("TenchatSignaling");
  const tenchatSignaling = await TenchatSignaling.deploy();
  await tenchatSignaling.waitForDeployment();
  console.log("TenchatSignaling deployed to:", await tenchatSignaling.getAddress());

  // 4. Deploy TenchatMiniAppRegistry
  const TenchatMiniAppRegistry = await ethers.getContractFactory("TenchatMiniAppRegistry");
  const tenchatMiniAppRegistry = await TenchatMiniAppRegistry.deploy();
  await tenchatMiniAppRegistry.waitForDeployment();
  console.log("TenchatMiniAppRegistry deployed to:", await tenchatMiniAppRegistry.getAddress());

  // 5. Deploy TenchatPrediction
  const TenchatPrediction = await ethers.getContractFactory("TenchatPrediction");
  const tenchatPrediction = await TenchatPrediction.deploy(tokenAddress);
  await tenchatPrediction.waitForDeployment();
  console.log("TenchatPrediction deployed to:", await tenchatPrediction.getAddress());

  // 6. Deploy TenchatSubscription
  const TenchatSubscription = await ethers.getContractFactory("TenchatSubscription");
  const tenchatSubscription = await TenchatSubscription.deploy(tokenAddress);
  await tenchatSubscription.waitForDeployment();
  console.log("TenchatSubscription deployed to:", await tenchatSubscription.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

