pragma solidity ^0.8.0;

contract BugSquash {
    enum State {
        Alive,
        Squashed
    }
    State state;
    address owner;

    constructor() {
        state = State.Alive;
        owner = msg.sender;
    }

    function squash() public {
        // 에러 처리되지 않음
        assert(owner != address(0));

        if (state == State.Alive) {
            state = State.Squashed;
        } else if (state == State.Squashed) revert();
    }

    function kill() public {
        // 컨트랙트가 소유자가 아닌 계정이 컨트랙트를 소멸시키고자 하면
        // 부정한 의도가 있는 것으로 판단
        require(owner == msg.sender);

        // 현재 컨트랙트와 관련된 모든 데이터를 상태 트리에서 제거한다.
        // 또한 컨트랙트에 남은 이더, this.balance를 recipient에게 전달한다.
        selfdestruct(payable(owner));
    }
}
