//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
새로운 투자자가 보낸 돈을 이전 투자자에게 옮기는 방식
각 투자가 이전 투자보다 크면 마지막 투자자를 제외한 모든 투자자가 투자 수익을 얻는다.
 */
contract SimplePonzi {
    address payable public currentInvestor;
    uint256 public currentInvestment = 0;

    fallback() external payable {
        // new investments must be 10% greater than current
        // 새로운 투자는 현재 투자금보다 10% 이상이야 한다.
        uint256 minimumInvestment = (currentInvestment * 11) / 10; // 솔리디티에서는 소수점을 사용할 수 없기에 11을 곱한 다음 10으로 나누어야 한다.
        require(msg.value > minimumInvestment);

        // document new investor
        // 새로운 투자자 정보 저장
        address payable previousInvestor = currentInvestor; // 이전 투자자 정보에 현재 투자자 정보를 옮기고,
        currentInvestor = payable(msg.sender); // 새로운 투자자 정보를 현재 투자자 정보로 입력
        currentInvestment = msg.value; // 투자금 정보와 함께!

        // payout previous investor
        previousInvestor.send(msg.value); // 그리고 이전의 투자자에게 투자금을 지급한다.
    }
}

/**
SimplePonzi는 간단하지만 사용자가 돈을 돌려받을지 여부를 확신할 수 없는 컨트랙트이다.
보통의 실제 폰지 구조는 전체 펀드의 규모가 너무 커서 유지가 어려울 때까지 평균 이상의 수익률로 투자자에게 
점진적으로 수익금을 지불하는 경향을 갖는다. 
GradualPonzi는 현실적인 시나리오를 구현한 폰지 구조이다.
 */
contract GradualPonzi {
    address payable[] public investors;
    mapping(address => uint256) public balances;
    uint256 public constant MINIMUM_INVESTMENT = 1e15;

    constructor() payable {
        investors.push(payable(msg.sender));
    }

    fallback() external payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        uint256 eachInvestorGets = msg.value / investors.length;
        for (uint256 i = 0; i < investors.length; i++) {
            balances[investors[i]] += eachInvestorGets;
        }
        investors.push(payable(msg.sender));
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}

contract SimplePyramid {
    uint256 public constant MINIMUM_INVESTMENT = 1e15; // 0.001 ether
    uint256 public numInvestors = 0;
    uint256 public depth = 0;
    address[] public investors;
    mapping(address => uint256) public balances;
    uint256 public investorsLength = 3;

    constructor() payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        // investors.length = 3;
        // investors[0] = msg.sender;
        investors.push(msg.sender);
        numInvestors = 1;
        depth = 1;
        balances[address(this)] = msg.value;
    }

    fallback() external payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        balances[address(this)] += msg.value;

        numInvestors += 1;
        investors[numInvestors - 1] = msg.sender;

        if (numInvestors == investorsLength) {
            // pay out previous layer
            uint256 endIndex = numInvestors - 2**depth;
            uint256 startIndex = endIndex - 2**(depth - 1);
            for (uint256 i = startIndex; i < endIndex; i++)
                balances[investors[i]] += MINIMUM_INVESTMENT;

            // spread remaining ether among all participants
            uint256 paid = MINIMUM_INVESTMENT * 2**(depth - 1);
            uint256 eachInvestorGets = (balances[address(this)] - paid) /
                numInvestors;
            for (uint256 i = 0; i < numInvestors; i++)
                balances[investors[i]] += eachInvestorGets;

            // update state variables
            balances[address(this)] = 0;
            depth += 1;
            // investors.length += 2**depth;
            investorsLength += 2**depth;
        }
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}
