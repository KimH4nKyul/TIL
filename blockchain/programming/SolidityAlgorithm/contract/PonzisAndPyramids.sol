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
        previousInvestor.transfer(msg.value); // 그리고 이전의 투자자에게 투자금을 지급한다.
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

/**
점점 더 커지는 피라미드를 형성하면서 참가자들에게 수익금을 지불해야 한다.
각 단계는 전 단계보다 두 배 크며, 각 단계는 다음 단계가 채워지면 투자금을 회수한다.
 */
contract SimplePyramid {
    uint256 public constant MINIMUM_INVESTMENT = 1e15; // 0.001 ether
    uint256 public numInvestors = 0; // numInvestors가 충분히 클 경우 동작하지 않을 수도 있다. (블록 가스 한도)
    uint256 public depth = 0;
    address[] public investors;
    mapping(address => uint256) public balances;
    uint256 public investorsLength = 3;

    constructor() payable {
        // 첫번째 투자자는 컨트랙트 작성자이다.
        require(msg.value >= MINIMUM_INVESTMENT);
        // investors.length = 3;
        // investors[0] = msg.sender;
        investors.push(msg.sender);
        numInvestors = 1;
        depth = 1; // 현재 피라미드 단계, 각 단계의 투자자 수는 depth의 2제곱(depth ** 2)
        balances[address(this)] = msg.value;
    }

    fallback() external payable {
        require(msg.value >= MINIMUM_INVESTMENT); // 투자가 들어오면
        balances[address(this)] += msg.value; // 이 컨트랙트 주소의 잔고를 업데이트하고

        numInvestors += 1; // 투자자 수를 증가시칸다.
        investors[numInvestors - 1] = msg.sender; // 그리고 투자자 주소를 담는다.

        if (numInvestors == investorsLength) {
            // pay out previous layer
            // 이전 단계 투자자 지급
            uint256 endIndex = numInvestors - 2**depth;
            uint256 startIndex = endIndex - 2**(depth - 1);
            for (uint256 i = startIndex; i < endIndex; i++)
                balances[investors[i]] += MINIMUM_INVESTMENT;

            // spread remaining ether among all participants
            // 남은 이더를 전체 참여자에게 분배
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
        // 호출자의 모든 잔액을 인출한다.
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}
