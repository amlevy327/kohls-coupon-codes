const hre = require('hardhat');
require("dotenv").config();

async function main() {
  const subscriptionId = "5686";
  // mumbai
  const vrfCoordinator = '0x7a1bac17ccc5b313516c5e16fb24f7659aa5ebed';
  const keyHash = '0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f';

  const CouponCodes = await hre.ethers.getContractFactory(
    'CouponCodes',
  );

  const couponCodes = await CouponCodes.deploy(
    subscriptionId,
    vrfCoordinator,
    keyHash
  );

  await couponCodes.waitForDeployment();

  console.log(`couponCodes deployed to ${await couponCodes.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});