import { ethers } from "hardhat";
import { StakingReward } from "../types/StakingReward";

const REWARD_CONTRACT_ADDRESS = process.env.REWARD_CONTRACT_ADDRESS ?? "";

async function main() {
  const [account] = await ethers.getSigners();

  console.log(
    `Register StakingReward: address=${REWARD_CONTRACT_ADDRESS}, account=${account.address}`
  );
  console.log(`Account balance: ${(await account.getBalance()).toString()}`);

  const rewardContract = (await ethers.getContractAt(
    "StakingReward",
    REWARD_CONTRACT_ADDRESS,
    account
  )) as StakingReward;

  const tx = await rewardContract.registerRewardProgram();
  const receipt = await tx.wait();

  console.log("Registered", tx.hash, receipt);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
