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
    * 처음 5개의 숫자는 1 ~ 69까지의 표순 숫자이며 
    여섯 번째 숫자는 1 ~ 26의 특별한 파워볼 숫자로 추가 보상을 제공한다. 
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
pragma solidity ^0.8.0;

contract RecurringLottery {
    struct Round {
        // endBlock에 해당하는 번호의 블록이 채굴되면 한 라운드 종료
        // 이 과정에서 무작위로 당첨자가 결정된다.
        uint256 endBlock; // 라운드 종료 시간 역할
        // 당첨자를 결정하는 난수 시드는 drawBlock에 해당하는 번호의 블록에서 나오는 블록 해시
        uint256 drawBlock; // 추첨 시간 역할
        Entry[] entries;
        // 하나의 Entry가 둘 이상의 ticket을 보유할 수 있기에
        // Entry를 바탕으로 판매된 총 티켓 수를 계산하려면 Entry의 수가 늘어남에 따라
        // 계산 비용이 많이 들게 된다.
        // 그래서 대신 Round 구조체 내의 `totalQuantity`를 정의해
        // 각 라운드에서 판매되는 티켓 수를 추적하게 했다.
        uint256 totalQuantity;
        address winner;
    }
    struct Entry {
        address buyer; // 구매자 주소
        uint256 quantity; // 구입한 티켓 수량
    }

    uint256 public constant TICKET_PRICE = 1e15;

    uint256 public round;
    uint256 public duration; // 블록 내 단일 라운드 지속 시간. 24시간은 약 5500블록
    mapping(address => uint256) public balances; // 사용자 잔고를 담는 표준 매핑
    mapping(uint256 => Round) public rounds; // round를 Rounds 구조체로 연결하는 매핑 변수

    // duration is in blocks. 1 day = ~5500 blocks
    // `duration`은 블록 단위의 시간으로, 1일은 약 5500 블록에 해당한다.
    constructor(uint256 _duration) {
        // duration을 비롯한 시간은 초 단위가 아니라 블록 단위로 측정한다.
        // 이는 티켓 구매 시점과 추첨 시점 사이의 초 경과가 아닌 블록 수를 고려하기 때문이다.
        duration = _duration;
        round = 1;
        // endBlock과 drawBlock 사이의 시간 간격은 5 블록으로 설정돼,
        // 어떤 참가자도 블록 해시를 알 수 없다.

        // endBlock에 해당하는 번호의 블록이 채굴되면 한 라운드 종료
        // 이 과정에서 무작위로 당첨자가 결정된다.
        rounds[round].endBlock = block.number + duration;
        // 당첨자를 결정하는 난수 시드는 drawBlock에 해당하는 번호의 블록에서 나오는 블록 해시
        rounds[round].drawBlock = block.number + duration + 5;
    }

    function buy() public payable {
        // buy()는 라운드 증가 로직이다.
        // 먼저, 트랜잭션의 이더 값이 티켓 가격의 배수인지 확인한다.
        // 한 번에 여러 티켓을 구입할 수 있지만 하나의 티켓을 쪼개서 구입할 수는 없다.
        require(
            msg.value % TICKET_PRICE == 0,
            "It must be a multiple of the ticket price."
        );

        // 현재 라운드의 endBlock보다 현재 블록 번호가 크면 한 라운드가 만료된 것
        // (현재 라운드가 만료됐는지 여부를 확인)
        if (block.number > rounds[round].endBlock) {
            // 현재 라운드가 만료됐을 경우 라운드 카운터를 증가
            round += 1;
            // 새로운 라운드의 종료 시간과 추첨 시간을 설정한다.
            rounds[round].endBlock = block.number + duration;
            rounds[round].drawBlock = block.number + duration + 5;
        }

        // 새로운 라운드라면 이 구매는 새로운 라운드의 첫 구매가 될 것이다.
        uint256 quantity = msg.value / TICKET_PRICE;
        Entry memory entry = Entry(msg.sender, quantity); // 한 구매자의 총 티켓 구매량을 entry 메모리에 담아두고,
        rounds[round].entries.push(entry); // 해당 라운드에 매핑된 Round 구조체의 Entry[]에 entry 메모리 값을 넣음
        rounds[round].totalQuantity += quantity; // 해당 라운드에 매핑된 총 구매량에 한 구매자의 총 티켓 구매량을 더해줌
    }

    function drawWinner(uint256 roundNumber) public {
        // 당첨자 추첨을 위한 `drawWinner()` 함수의 초기 조건 및 로컬 변수 선언
        Round storage drawing = rounds[roundNumber];
        // 현재 회차의 당첨자는 아직 없어야 하므로 zero addrees와 비교한다.
        require(drawing.winner == address(0));
        // 당첨자를 결정하는 난수 시드인 drawBlock이 있어야 당첨자를 추첨할 수 있으므로(블록 해시를 얻는다.)
        // 현재 블록 번호는 drawBlock의 블록 번호보다 높아야 한다.
        require(block.number > drawing.drawBlock);
        // 현재 회차에 당첨자를 추첨하기 위해선 1명 이상의 티켓 구매자들이 존재해야 한다.
        require(drawing.entries.length > 0);

        // pick winner
        // 승자 선정
        bytes32 source = blockhash(drawing.drawBlock);
        // 난수 생성기는 추첨이 언제 이루어지는지에 관계없이
        // drawBlock의 블록 해시를 사용해 임의의 시드를 생성한다.
        bytes32 rand = keccak256(abi.encode(source));
        // `counter`는 당첨 티켓에 해당하며, 이 당첨 티켓이 속하는 주소를 결정해야 한다.
        uint256 counter = uint256(rand) % drawing.totalQuantity;
        for (uint256 i = 0; i < drawing.entries.length; i++) {
            uint256 quantity = drawing.entries[i].quantity;
            if (quantity > counter) {
                drawing.winner = drawing.entries[i].buyer;
                break;
            } else counter -= quantity;
        }

        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function deleteRound(uint256 _round) public {
        /**
        라운드가 완료되고 당첨자가 상금을 수령하고 나면 해당 라운드는 더이상 필요치 않다.
        컨트랙트가 유명해지면 상태 정보의 크기가 매우 커질 수 있으므로 deleteRound()를 통해
        오래된 데이터를 정리함으로써 블록체인 시민 의식을 준수할 수 있다. 
         */
        require(block.number > rounds[_round].drawBlock + 100);
        require(rounds[_round].winner != address(0));
        delete rounds[_round];
    }

    fallback() external payable {
        buy();
    }
}
```

# RNGLottery

```solidity
pragma solidity ^0.8.0;

contract RNGLottery {
    uint256 public constant TICKET_PRICE = 1e16;

    address[] public tickets;
    address public winner;
    // `seed` 는 당첨자를 결정하는 데 사용할 임의의 시드다.
    // 새로운 비밀번호가 제출될 때마다 시드는 이를 포함하도록 업데이트 된다.
    bytes32 public seed;
    // 모든 티켓 구매자는 구매에 대한 약정 해시를 제출한다.
    // 제출된 약정 해시는 이 매핑 변수 `commitments` 에 저장된다.
    mapping(address => bytes32) public commitments;

    // RecurringLottery의 endBlock과 동일하다.
    // 이 블록 번호가 경과하고 나면 티켓을 구매할 수 없다.
    uint256 public ticketDeadline; // 티켓 판매 종료 데드라인
    // 약정 해시 공개는 이 컨트랙트에서 도입된 새로운 요소이다.
    // 약정 해시 공개에 대한 마감도 필요하다.
    // 이 변수는 해시 공개 마감 시간에 해당하며 모든 공개는 티켓 마감일과
    // 공개 마감 전에 이루어져야 한다.
    uint256 public revealDeadline;

    constructor(uint256 duration, uint256 revealDuration) {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
    }

    /**
        사용자는 티켓을 구매하기 전에 먼저 약정 해시를 제출한다. 
        이 함수는 주소와 비밀번호 N으로 약정 해시를 생성한다.
        해당 주소는 사용자의 주소여야 하므로 공개 단계에서 약정 해시가 유효한지
        체인상에서 제대로 확인할 수 있다. 
        
        사용자의 주소는 비밀번호와 함께 해시된다. 이는 비밀번호 저장에 salt가 사용됨과 같다.
        숫자만 사용하면 사전 방식 공격으로 약정 정보가 노출될 수 있기 때문이다. 
        대신 사용자 주소를 추가하면 공격자의 레인보우 테이블 공격을 막을 수 있다. 
        
        함수에서 pure 키워드를 사용하는 것은 이번이 처음이다.
        pure의 출력은 함수의 인수에만 의존한다.
        그 덕분에 pure 함수를 호출할 때는 트랜잭션을 전송할 필요가 없다. 
        pure 함수는 상태 트리를 업데이트하거나 합의 프로토콜을 거치지 않는다.
        로컬에서 결과를 계산하고 사용해야만 한다.
     */
    function createCommitment(address user, uint256 N)
        public
        pure
        returns (bytes32 commitment)
    {
        // bytes memory source = abi.encodePacked(user, N);
        /**
        abi.encodePacked(arg)가 a, b라는 arg를 받을 때, a와 b 둘 중 하나가 동적 유형인지 확인해야 한다.
        a, b 중에 하나가 동적 유형이라면 입력 순서에 따라 결과값이 다를 수 있다.
        따라서 abi.encode(arg)를 사용할 것을 권장한다. 
         */
        bytes memory source = abi.encode(user, N);
        return keccak256(source); // 약정 해시를 32bytes의 16진수 문자열로 나타낸다. 이 약정 해시가 티켓 구매 트랜잭션에 사용된다.
    }

    function buy(bytes32 commitment) public payable {
        require(msg.value == TICKET_PRICE);
        require(block.number <= ticketDeadline);

        commitments[msg.sender] = commitment;
    }

    function reveal(uint256 N) public {
        // 비밀번호를 공개하고 검증한다.
        // 블록 넘버는 티켓 구매 마감 후에
        // 약정 해시 공개 기간은 지나지 않아야 한다.
        require(block.number > ticketDeadline);
        require(block.number <= revealDeadline);

        // 입력한 비멀번호와 함수를 호출한 사용자 주소를 검증할 약정 해시를 생성하고
        bytes32 hash = createCommitment(msg.sender, N);
        // 생성된 약정 해시가 과거에 사용자가 만든 약정 해시와 같은지 검사한다.
        require(hash == commitments[msg.sender]);

        // 같다면 비밀번호를 현재 seed와 합치고
        // 합쳐진 바이트 시퀀스인 source를 해시해 새로운 seed로 업데이트 한다.
        bytes memory source = abi.encode(seed, N);
        seed = keccak256(source);
        tickets.push(msg.sender);
    }

    function drawWinner() public {
        require(block.number > revealDeadline);
        require(winner == address(0));

        uint256 randIndex = uint256(seed) % tickets.length;
        winner = tickets[randIndex];
    }

    function withdraw() public {
        require(msg.sender == winner);
        payable(msg.sender).transfer(address(this).balance);
    }
}
```

# PowerBall

```solidity
pragma solidity ^0.8.0;

/**
파워볼 컨트랙트는 복권 컨트랙트 중에서 가장 복잡하다.
티켓 구매와 다중 당첨금 지급을 모두 가진 순환 복권이다. 
 */
contract Powerball {
    struct Round {
        /**
        Round 구조체는 RecurringLottery과 유사하다.
         */
        uint256 endTime; // 티켓 구매 기한
        uint256 drawBlock; // 임의 숫자를 생성하는 데 사용할 미래의 블록 번호
        uint256[6] winningNumbers; // 여섯 개의 당첨번호 배열
        mapping(address => uint256[6][]) tickets; // 하나의 플레이어가 여러 티켓을 가질 수 있는 티켓 매핑
        /**
        솔리디티에서 다차원 배열은 자바나 C와는 다르다.
        솔리디티에서 uint256[6][]은 uint256[6]개의 원소를 갖는 동적 배열을 의미한다. 
         */
    }

    uint256 public constant TICKET_PRICE = 2e15; // 단일 티켓 가격, 0.002이더
    uint256 public constant MAX_NUMBER = 69;
    uint256 public constant MAX_POWERBALL_NUMBER = 26;
    uint256 public constant ROUND_LENGTH = 3 days; // 라운드 길이의 초 단위, 게임이 진행될 시간

    uint256 public round; // 현재 라운드
    mapping(uint256 => Round) public rounds; // 현재 라운드에 대한 정보를 Round 구조체로 매핑

    constructor() {
        round = 1;
        rounds[round].endTime = block.timestamp + ROUND_LENGTH;
    }

    /** 
    buy() 함수의 전반부는 입력 데이터에 대한 일련의 검사를 진행한다. 
    */
    function buy(uint256[6][] memory numbers) public payable {
        // 구매할 티켓 가격이 전달한 이더와 매치가 되는지 확인한다.
        require(numbers.length * TICKET_PRICE == msg.value);

        // Ensure the non-powerball numbers on each ticket are unique
        // 티켓의 각 번호가 유니크한지 검사한다.
        for (uint256 k = 0; k < numbers.length; k++) {
            for (uint256 i = 0; i < 4; i++) {
                for (uint256 j = i + 1; j < 5; j++) {
                    require(numbers[k][i] != numbers[k][j]);
                }
            }
        }

        // Ensure the picked numbers are within the acceptable range
        // 티켓의 각 번호가 적절한 범위 내에 있는지 검사한다.
        for (uint256 i = 0; i < numbers.length; i++) {
            for (uint256 j = 0; j < 6; j++) require(numbers[i][j] > 0); // 각 번호는 0보다 커야함
            for (uint256 j = 0; j < 5; j++)
                require(numbers[i][j] <= MAX_NUMBER); // 티켓 번호는 MAX_NUMBER보단 작아야 함
            require(numbers[i][5] <= MAX_POWERBALL_NUMBER); // 파워볼 번호(마지막 자리)는 최대 파워볼 번호보다 작아야 함
        }

        // check for round expiry
        // 라운드 마감 확인
        if (block.timestamp > rounds[round].endTime) {
            /**
            여기서 해결해야 할 문제는 drawBlock이다.
            drawBlock은 추첨 기간과 같은 역할을 한다.
            그러나 이 컨트랙트에서 한 라운드의 drawBlock은 다음 라운드의 첫번째 티켓 구매를 할 때까지 설정되지 않는다.
            이는 아무도 다음 라운드 티켓을 구매하지 않으면
            한 라운드를 위한 추첨이 영원히 지연됨을 의미한다. 
            또한 누군가 임의로 다음 라운드 티켓을 구매해 추첨을 트리거할 수도 있음을 의미한다.
             */
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = block.timestamp + ROUND_LENGTH;
        }

        // 검사에 합격하면 해당 티켓으로 컨트랙트 상태를 업데이트한다.
        // 위에서 라운드 설정이 완료되면 해당 라운드의 티켓 풀에 티켓이 하나씩 들어간다.
        for (uint256 i = 0; i < numbers.length; i++)
            rounds[round].tickets[msg.sender].push(numbers[i]);
    }

    function drawNumbers(uint256 _round) public {
        // 이 함수는 해당 라운드의 우승 티켓이 될 6개 번호를 무작위로 추첨한다.
        uint256 drawBlock = rounds[_round].drawBlock; // 해당 라운드에 drawBlock이 있어야 추첨 진행을 했다를 의미함
        require(block.timestamp > rounds[_round].endTime); // 티켓 구매 마감이 되어야 함
        require(block.number >= drawBlock); // 추첨 기간이 끝나야 함
        require(rounds[_round].winningNumbers[0] == 0); //당첨 번호는 아직 설정되지 않았어야 함. 따라서 0과 비교함

        uint256 i = 0;
        uint256 seed = 0;
        // 파워볼 당첨 번호를 추첨한다.
        while (i < 5) {
            // 이 로직은 drawBlock으로부터 256블록(약 80분) 내에 실행되어야 한다.
            bytes32 source = blockhash(drawBlock);
            /**
            난수를 생성할 때 매번 동일한 블록해시를 재사용할 수 없다.
            그렇게 되면 동일한 수가 5번 연속으로 출력될 것이기 때문이다.
            그 대신 블록 수에 매번 고유한 숫자(이 경우 i)를 연결해 만든 바이트 문자열을 해시해 시드를 얻는다. 
             */
            bytes memory encodedSource = abi.encode(source, seed);
            bytes32 _rand = keccak256(encodedSource);
            uint256 numberDraw = (uint256(_rand) % MAX_NUMBER) + 1;

            // non-powerball numbers must be unique
            bool duplicate = false;
            for (uint256 j = 0; j < i; j++) {
                if (numberDraw == rounds[_round].winningNumbers[j]) {
                    duplicate = true;
                    seed++;
                    break;
                }
            }
            if (duplicate) continue;

            rounds[_round].winningNumbers[i] = numberDraw;
            i++;
            seed++;
        }
        bytes32 source = blockhash(drawBlock);
        bytes memory encodedSource = abi.encode(source, seed);
        bytes32 _rand = keccak256(encodedSource);
        uint256 powerballDraw = (uint256(_rand) % MAX_POWERBALL_NUMBER) + 1;
        rounds[_round].winningNumbers[5] = powerballDraw;
    }

    /**
    번호 추첨이 끝난 후, 당첨 티켓을 소지한 사용자는 해당 라운드에 대한
    보상을 청구할 수 있다.
     */
    function claim(uint256 _round) public {
        require(rounds[_round].tickets[msg.sender].length > 0); // 당첨자는 티켓을 소유하고 있어야 하고,
        require(rounds[_round].winningNumbers[0] != 0); // 당첨번호가 0이 아니어야 한다. (이는 당첨 번호가 추첨된 상태임을 의미)

        uint256[6][] storage myNumbers = rounds[_round].tickets[msg.sender];
        uint256[6] storage winningNumbers = rounds[_round].winningNumbers;

        uint256 payout = 0;
        for (uint256 i = 0; i < myNumbers.length; i++) {
            uint256 numberMatches = 0;
            for (uint256 j = 0; j < 5; j++) {
                for (uint256 k = 0; k < 5; k++) {
                    if (myNumbers[i][j] == winningNumbers[k])
                        numberMatches += 1;
                }
            }
            bool powerballMatches = (myNumbers[i][5] == winningNumbers[5]);

            // win conditions
            if (numberMatches == 5 && powerballMatches) {
                payout = address(this).balance;
                break;
            } else if (numberMatches == 5) payout += 1000 ether;
            else if (numberMatches == 4 && powerballMatches) payout += 50 ether;
            else if (numberMatches == 4)
                payout += 1e17; // .1 ether
            else if (numberMatches == 3 && powerballMatches)
                payout += 1e17; // .1 ether
            else if (numberMatches == 3)
                payout += 7e15; // .007 ether
            else if (numberMatches == 2 && powerballMatches)
                payout += 7e15; // .007 ether
            else if (powerballMatches) payout += 4e15; // .004 ether
        }

        // 설정된 payout으로 최종 상금 지급후 해당 라운드의 사용자 티켓을 삭제해
        // 중복 수령을 방지한다.
        delete rounds[_round].tickets[msg.sender];
        payable(msg.sender).transfer(payout);
    }

    /**
    솔리디티의 구조체가 public이라면 getter를 자동으로 생성해준다. 
    그러나 솔리디티는 반환되는 배열에 복합 자료형을 포함할 수 없다.
    따라서 매핑과 배열의 경우 자체 view() 함수를 생성해줘야 한다.
    */
    function ticketsFor(uint256 _round, address user)
        public
        view
        returns (uint256[6][] memory tickets)
    {
        return rounds[_round].tickets[user];
    }

    function winningNumbersFor(uint256 _round)
        public
        view
        returns (uint256[6] memory winningNumbers)
    {
        return rounds[_round].winningNumbers;
    }
}
```