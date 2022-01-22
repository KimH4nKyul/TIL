pragma solidity ^0.8.0;

contract RNGLottery {
    uint256 public constant TICKET_PRICE = 1e16;

    address[] public tickets;
    address public winner;
    bytes32 public seed;
    mapping(address => bytes32) public commitments;

    uint256 public ticketDeadline;
    uint256 public revealDeadline;

    constructor(uint256 duration, uint256 revealDuration) {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
    }

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
        return keccak256(source);
    }

    function buy(bytes32 commitment) public payable {
        require(msg.value == TICKET_PRICE);
        require(block.number <= ticketDeadline);

        commitments[msg.sender] = commitment;
    }

    function reveal(uint256 N) public {
        require(block.number > ticketDeadline);
        require(block.number <= revealDeadline);

        bytes32 hash = createCommitment(msg.sender, N);
        require(hash == commitments[msg.sender]);

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
