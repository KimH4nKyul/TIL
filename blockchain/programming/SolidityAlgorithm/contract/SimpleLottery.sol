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
