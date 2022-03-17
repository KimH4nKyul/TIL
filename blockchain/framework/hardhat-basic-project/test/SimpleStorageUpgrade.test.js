const hre = require("hardhat");
const {expect} = require("chai");

describe("SimpleStorageUpgrade", function() {
    const wallets = waffle.provider.getWallets();

    before(async() => {
        // getSigner 메서드
        // () 안에 정한 순서에 해당하는 지갑을 가져오겠다.
        const signer = waffle.provider.getSigner();
        const SimpleStorageUpgrade = await hre.artifacts
            .readArtifact("SimpleStorageUpgrade");
        this.instance = await waffle.deployContract(signer, SimpleStorageUpgrade);
    })

    it("shoud change the value,", async()=> {
        const tx = await this.instance.connect(wallets[1]).set(500);
        const v = await this.instance.get();
        expect(v).to.be.equal(500);
    });

    it("should revert", async()=>{
        await expect(this.instance.set(500))
            .to.be.revertedWith("should be less than 5000");
    });
});