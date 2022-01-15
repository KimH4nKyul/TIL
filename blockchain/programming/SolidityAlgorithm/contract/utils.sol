pragma solidity ^0.8.0;

contract DecimalUtils {
    function decimalPoint(
        uint256 value,
        uint256 data,
        uint256 n
    ) public view returns (uint256) {
        // value에 0을 n만큼 붙이고 소수점으로 출력하길 원하는 data를 입력한다.
        // value = 10 / n = 6 / data는 3일 경우, 10에 0을 6개 붙여 10000000,
        // 그 값에 3을 나누어 3333333이 나오고
        // 반환된 값은 3.333333을 의미하게 된다.
        // 즉 반환된 값의 마지막 n자리수가 소수점 자리수에 해당된다.
        return (value * 10**n) / data;
    }
}

/**
이 컨트랙트의 의미는, 
컨트랙트가 배포될 때 해당 컨트랙트에 보내 놓은 돈을 받을 수 있는데
컨트랙트 배포 이후 10일 이내에 claim() 함수 호출 트랜잭션을 생성해야 가능하다는 뜻이다.
 */
contract TimeUtils {
    // 시간 지연 기능
    uint256 start;

    function timePayout() public payable {
        start = block.timestamp; // now is deprecated, instead use block.timestamp
    }

    function claim() public {
        if (block.timestamp > start + 10 days) {
            // address not convert adress payable,
            // so use payable()
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}

