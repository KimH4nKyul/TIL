pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract SimpleStorageUpgrade {
    uint storedData;

    event Change(string message, uint newVal);

    function set(uint x) public {
        require(x<5000, "Should be less than 5000");
        storedData = x;
//        console.log(storedData);
        emit Change("set", x);
    }

    function get() public view returns (uint) {
//        console.log("get:", storedData);
        return storedData;
    }
}
