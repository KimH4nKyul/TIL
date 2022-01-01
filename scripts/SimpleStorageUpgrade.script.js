const hre = require("hardhat");

async function main() {
    const SimpleStorageUpgrade = await hre.ethers.getContractFactory("SimpleStorageUpgrade");
    const simpleStorageUpgrade = await SimpleStorageUpgrade.deploy();

    const contract = await simpleStorageUpgrade.deployed();

    console.log(contract.address.toString());

    await contract.set(100);
    await contract.get().then((value)=>{
       console.log(value);
    });

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
