//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//이 컨트랙트는 오픈제펠린 컨트랙트 4.4.1 버전을 참고한다.

/**
@dev [0]EIP(Ethereum Improvement Proposal, 이더리움 개선 제안)에 정의된 ERC20 표준 인터페이스이다. 
 */
interface IERC20Token {
    /**
    @dev 'tokens(value)' 토큰이 하나의 계정(from)에서 다른 계정으로(to) 이동했을 때 발생한다.
    'tokens(value')는 0 일 수도 있다. 
     */
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    /**
    @dev 'tokenlender'에 대한 'spender'의 허용량이 {approve}에 대한 호출에 의해 설정된 경우 발생한다.
    'tokens(value)'는 새롭게 설정할 허용량이다. 
     */
    event Approval(
        address indexed tokenlender,
        address indexed spender,
        uint256 tokens
    );

    // 존재하는 토큰 총량을 반환한다.
    function totalSupply() external returns (uint256);

    //  'account'에 의해 소유된 토큰의 개수를 반한한다.
    function balanceOf(address tokenlender) external returns (uint256 balance);

    /**
    @dev {transferFrom}을 통해 spender가 tokenlender를 대신해 사용할 수 있는 나머지 토큰 수를 반환한다.
    기본적으로 0이다. 
    이 값은 {approve} 또는 {transferForm}이 호출될 때 바뀐다. 
     */
    function allowance(address tokenlender, address spender)
        external
        returns (uint256 remaining);

    /**
    @dev 호출자의 계정에서 받는 사람(to 또는 recipient)에게 amount(또는 tokens) 만큼의 토큰을 이동시킨다. 
     */
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    /**
    @dev 호출자의 토큰에 대해 'spender'가 'amount'의 허용량을 설정한다. 
     명령이 성공했는지 아닌지 나타내는 값으로 boolean을 반환한다.
     
     중요: 이 방법으로 허용량을 변경하면 누군가는 불행한 트랜잭션 오더링으로 오래되고 새로운 허용량 둘 다 사용될 수도 있는 위험이 따른다. 
     이러한 race condition을 완화하기 위한 한가지 가능한 해결책은 
     spender의 허용량을 0으로 줄이거나 나중에 원하는 값으로 설정하는 것이다. 
     (https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729)
     
     {Approval} 이벤트를 발생시킨다.  
     */
    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    /**
    @dev 허용 메커니즘을 사용해 'sender(from)'에서 'to(recipient)'로 'tokens(amount)' 토큰을 이동시킨다. 
    amount는 호출자의 허용으로 부터 차감된다. 

    명령이 성공했는지에 대한 값으로 boolean을 반환한다.

    {Transfer} 이벤트를 발생시킨다. 
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);
}
