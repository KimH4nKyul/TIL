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
