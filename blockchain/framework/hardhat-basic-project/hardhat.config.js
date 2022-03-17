require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const ALCHEMY_API_KEY = "https://speedy-nodes-nyc.moralis.io/b897c330c1dca3a8bfb173b4/eth/ropsten";
const ROPSTEN_PRIVATE_KEY = "0x55227954ea3c5a1dcb192843bb78369519fed30922d6be59ceb0792d83a9bdbc";

module.exports = {
  solidity: "0.8.4",
  networks: {
    ropsten: {
      url: `${ALCHEMY_API_KEY}`,
      accounts: [`${ROPSTEN_PRIVATE_KEY}`]
    }
  }
};
// require("@nomiclabs/hardhat-waffle");
//
// // This is a sample Hardhat task. To learn how to create your own go to
// // https://hardhat.org/guides/create-task.html
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();
//
//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });
//
// // You need to export an object to set up your config
// // Go to https://hardhat.org/config/ to learn more
//
// /**
//  * @type import('hardhat/config').HardhatUserConfig
//  */
// module.exports = {
//   solidity: "0.8.4",
// };
