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
