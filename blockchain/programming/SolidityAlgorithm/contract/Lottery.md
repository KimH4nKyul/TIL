# 복권

복권은 이더리움 사용의 훌륭한 사례다.  
복권 역시 피라미드처럼 이더리움 블록체인 컨트랙트가 활용된 초기 사례다.   
결과는 공평하며, 중앙 운영자가 상금을 삭감할 걱정이 없고, 하나의 법렵에 귀속되지 않은 채 운영 가능하다.  
장래의 복권은 블록체인상에서 이루어질 가능성이 높다.  

## 난수 생성기(RNG)

* 엔트로피 소스로 활용할 수 있는 주요 수단은 **블록 해시**와 **외부 오라클**이다.  
* 복잡성과 외부 의존성을 최소화하기 위해 난수에 블록 해시를 적용할 것이다.  
* 현재 블록이 아닌 이전 블록 해시만 사용할 수 있는데, <u>이전 블록 해시는 트랜잭션이 실행되는 시점에 알려지기 때문에 최종 난수 결과값을 예측할 수 없게하는 추가 조치가 필요하다.</u>  
* 구체적으로, 티켓 구입 기간과 당첨자 추첨 사이에 **시간 지연**을 설정함으로써 복권 티켓이 배포되는 시점에 당첨자를 결정하는 데 사용된 블록 해시를 알 수 없게 만들 수 있다.  

## 만들어볼 컨트랙트
* SimpleLottrey
    * 간단한 복권은 반복적이지 않고, 난수에 블록 해시를 사용하며 단 한 명의 승자만 존재한다. 
* RecurringLottery
    * 사용성을 포기하고, 단순성에 집중한다. 
    * 메인넷에 배포 가능한 **현실적인 복권 컨트랙트**이다.
    * 새로운 복권은 여러 라운드에 걸쳐 일어나므로 추첨이 종료될 때마다 새로운 상금 풀이 시작된다. 
    * 사용자가 단일 티켓을 구입하는 것이 아니라 **복수로 티켓을 구매**할 수 있다.
    * **몇 가지 향상된 보안 기능**이 존재한다. 
* RNGLottery
    * 블록 해시를 RNG의 엔트로피 소스로 사용하는 데는 이론적으로 한계가 있다. 
    * <u>추첨을 위한 이더 상금이 블록 보상을 크게 초과하면, 채굴자들은 블록 해시를 조작해 자신이 상금을 받을 때까지 유효한 블록 해시를 버리게 만들 수 있다.</u>
    * 이 컨트랙트는 단품 구매만 가능한 **일회성 복권 판매**가 될 것이다.
    난수 복권의 개념은, <u>확증적인 순서를 사용해 검증 가능한 난수를 생성하는 것이다.</u> 모든 티켓 구매자는 티켓을 구입할 때 약정 해시를 제출한다. 이 약정 해시는 사용자의 주소와, 사용자만 아는 비밀번호의 조합을 해시함으로써 생성된다.
    * 발권 기간이 끝나면 각 구매자가 약정 해시 생성에 사용된 비밀번호를 공개해야 하는 기간(공개 기간)이 시작된다. 
    * 제출된 비밀번호는 블록체인상에서 제출자와 주소와 함께 해시되며, 이 해시가 처음에 티켓 구매 시에 사용자가 제출한 약정 해시와 일치하는지 확인하는 절차가 이어진다.
    * 공개 기간 동안 비밀번호를 공개하지 않은 사용자는 당첨자 추첨에서 제외된다.
    * 사용자들이 제출한 모든 비밀번호는 함께 해시돼 당첨자를 뽑을 수 있는 임의 시드를 생성한다. 
* PowerBall
    * 사용자는 티켓당 6개의 숫자를 선태한다.
    * 처음 5개의 숫자는 1~69까지의 표순 숫자이며 
    여섯 번째 숫자는 1~26의 특별한 파워볼 숫자로 추가 보상을 제공한다. 
    * 매 3~4일마다 추첨이 열리고 5개의 표준 번호와 파워볼 번호로 구성된 우승 티켓이 당첨된다. 
    * 시상은 티켓의 당첨 번호 숫자 일치율을 기준으로 지급된다. 
    * 여기에서 구현할 컨트랙트는 상(Prize)에 대해서 전체 잔고 인출권을 부여할 것이다.   

# SimpleLottery

```solidity
pragma solidity ^0.8.0;

contract SimpleLottery {
    uint256 public constant TICKET_PRICE = 1e16; // 0.01 ether

    address[] public tickets; // 티켓을 구매한 사용자 목록
    address public winner; // 당첨자, 당첨자는 상금을 청구할 수 있다. 당첨자가 결정되기 전까지 상금 출금 불가하다.
    // 복권 발권 과정에서 난수의 블록 해시를 알 수 없도록
    // 이 시간(`ticketingClose`)으로부터 적어도 5분 후에 당첨자 추첨이 이뤄져야 한다.
    uint256 public ticketingCloses;

    constructor(uint256 duration) {
        // `duration`은 초 단위로 입력 받아야 한다.
        // `block.timestamp`가 UNIX 타임스탬프이기 때문이다.
        ticketingCloses = block.timestamp + duration;
    }

    function buy() public payable {
        require(msg.value == TICKET_PRICE);
        require(block.timestamp < ticketingCloses);

        tickets.push(msg.sender);
    }

    function drawWinner() public {
        // 당첨자를 tickets에서 임의 선택한다.
        // 당첨자를 뽑기 위해서는 티켓 발권이 종료되고 적어도 5분이 경과되야 한다.
        // 이것은 티켓을 구입하는 동안 아무도 난수의 엔트로피 소스인 블록 해시를
        // 알 수 없도록 하기 위함이다.
        require(block.timestamp > ticketingCloses + 5 minutes);
        // 아직 당첨자 추첨이 이루어지지 않은 것을 검증하기 위해
        // 당첨자(`winner`)의 주소는 zero address로 설정돼 있음을 확인한다.
        require(winner == address(0));

        // 최근 블록 해시를 해시해 임의의 바이트열 `rand`를 생성한다.
        bytes32 source = blockhash(block.number - 1);
        bytes32 rand = keccak256(abi.encode(source));
        // 생성한 바이트열을 정수로 변환해 나눗셈 연산을 사용해 계수 범위를 제한하면 무작위 인덱스가 생성된다.
        // `tickets` 배열상에서 무작위 인덱스에 있는 주소가 당첨자 주소가 된다.
        winner = tickets[uint256(rand) % tickets.length];
    }

    function withdraw() public {
        require(msg.sender == winner);
        payable(msg.sender).transfer(address(this).balance);
    }

    fallback() external payable {
        buy();
    }
}
```

# RecurringLottery

```solidity 
```

# RNGLottery

```solidity
```

# PowerBall

```solidity
```