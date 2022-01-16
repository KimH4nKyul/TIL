// 나쁜 코드의 예시! (사용 금지, 참고용)
/**
여러 개를 전송하거나 다른 상태 업데이트를 수행하는 경우,
여러 건의 전송 및 업데이트가 실패한 전송과 함께 롤백될 것이다. 
공격자는 이를 이용해 컨트랙트를 잠그고 컨트랙트가 원하는 상태에 도달하는 것을 막을 수 있다. 
 */
pragma solidity ^0.8.0;

contract NoTrustFund {
    address[3] public children;

    constructor(address[3] memory _children) {
        children = _children;
    }

    function updateAddress(uint256 child, address newAddress) public {
        require(msg.sender == children[child]);
        children[child] = newAddress;
    }

    function disperse() public {
        uint256 balance = address(this).balance;
        // 하나의 children이 악의적으로 잠그는 것을 방지하고나 transfer 대신 send를 쓸 수 있으나
        // (send는 하나의 명령에 대해서만 false를 반환 하므로!)
        // 대규모 주소에 전송해야 하는 경우에는 비효율적일 것이다.
        // send는 한 작업에 9000gas를 소모 하는데 만약 1000명의 주소가 등록되면 9000000gas를 소모하게 된다.
        // 이 취약점을 이용해 공격자는 무더기로 주소를 등록하여 '스팸 공격'을 강행하고
        // 이를 통해 컨트랙트를 잠글 수 이다.
        // 이 문제를 방지하려면 내부 잔고를 통한 withdraw() 함수를 사용하는 것이 가장 좋다.
        // Roulette contract를 확인하자!
        payable(children[0]).transfer(balance / 2);
        payable(children[1]).transfer(balance / 4);
        payable(children[2]).transfer(balance / 4);
    }

    fallback() external payable {}
}

/**
본인이 두번째 Children 이고 자금을 공평하게 분배받지 못해 화가 났다고 가정하자.
children은 자신의 주소를 업데이트 할 수 있으므로, 자신의 주소로 폴백 함수가 없는 빈 컨트랙트를 넣으면
자금을 분배하는 disperse() 함수가 무조건 실패하고 롤백되게 만들 수 있다.
즉, 아무도 기금에 접근할 수 없도록 컨트랙트를 잠글 수 있다. 
 */
contract SaltyChild {
    // 이 컨트랙트가 공격에 쓰인 빈 컨트랙트이다.
    // 폴백 함수도 없기 때문에 이 컨트랙트에 이더를 보내더라도 거부할 것이다.
}

// Roulette
contract Roulette {
    mapping(address => uint256) balances;

    function betRed() public payable {
        bool winner = (randomNumber() % 2 == 0);
        if (winner) balances[msg.sender] += msg.value * 2;
        // if( winner ) payable(msg.sender).transfer(msg.value * 2);
        /**
            if( winner ) payable(msg.sender).transfer(msg.value * 2); 와 같이 작성하면,
            내부 잔고와 withdraw() 가 필요하지 않게 된다. 그래도 안전하다.
            그러나 withdraw()를 사용하는 것이 가장 안전하다!
         */
    }

    function randomNumber() public returns (uint256) {
        // 0~36 범위의 숫자를 반환하는 부분
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

// 대규모의 수신인 주소 목록으로 이더를 분해하는 안전한 방법
contract Welfare {
    address[] recipients; // 수신인 주소 목록
    uint256 totalFunding;
    mapping(address => uint256) withdrawn;

    function register() public {
        recipients.push(msg.sender);
    }

    fallback() external payable {
        totalFunding += msg.value;
    }

    function withdraw() public {
        uint256 withdrawnSofar = withdrawn[msg.sender]; // 사용자가 지금까지 인출한 금액
        uint256 allocation = totalFunding / recipients.length;

        require(allocation > withdrawnSofar);

        uint256 amount = allocation - withdrawnSofar;
        withdrawn[msg.sender] = allocation;
        payable(msg.sender).transfer(amount);
    }
}

// 복잡한 폴백 함수를 가진 컨트랙트가 이더를 인출하는 방법
contract Marriage {
    address wife = address(0); // dummy
    address husband = address(1); // dummy
    mapping(address => uint256) balances;

    // function withraw() public {
    //     uint256 amount = balances[msg.sender];
    //     balances[msg.sender] = 0;
    //     payable(msg.sender).transfer(amount);
    // }

    // address.call.value 방법 (재진입 공격에 대한 이해 필요)
    function withraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool state, bytes memory bData) = msg.sender.call{value: amount}("");
        // address.call.value(amount)()는 이더를 보내기 위한 세번째 방법이다.
        /**
        address.call(data)는 외부 컨트랙트 함수를 호출하는 데 사용할 수 있다.
        또한 주어진 값과 가스로 외부 호출을 하기 위해 .value(amount) 와 .gas(limit)의 두 가지 제어자를 사용할 수 있다.  
        .gas가 생략됐을 경우에는 디폴트로 가스 제한 없이 호출을 수행한다.  
        이러한 외부 컨트랙트 호출은 경합 조건(race condition)이나 재진입 공격(re-entrancy attack)을 유발한다. 
         */
        require(state); // if success
        // if not success, 모든 상태 변경을 롤백한다.
    }

    fallback() external payable {
        balances[wife] += msg.value / 2;
        balances[husband] += msg.value / 2;
    }
}
