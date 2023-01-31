import { ethers } from "hardhat";
import { StakingReward } from "../types/StakingReward";

const REWARD_CONTRACT_ADDRESS = process.env.REWARD_CONTRACT_ADDRESS ?? "";
const CLAIM_SLOT_NUMBER = process.env.CLAIM_SLOT_NUMBER ?? ""; //

async function main() {
  const [account] = await ethers.getSigners();

  console.log(
    `Claim: contract=${REWARD_CONTRACT_ADDRESS}, account=${account.address}, slot=${CLAIM_SLOT_NUMBER}`
  );
  console.log("Account balance", (await account.getBalance()).toString());

  const rewardContract = (await ethers.getContractAt(
    "StakingReward",
    REWARD_CONTRACT_ADDRESS,
    account
  )) as StakingReward;

  const tx = await rewardContract.claimReward(CLAIM_SLOT_NUMBER);
  const receipt = await tx.wait();

  console.log("Claimed", tx.hash, receipt);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
