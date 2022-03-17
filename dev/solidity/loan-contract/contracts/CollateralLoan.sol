//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Loan.sol";

/**
@dev [1] ERC20 토큰을 담보로 보유하면서 ether 대출을 관리하는 컨트랙트,
지불을 정말 간단하게 유지하기 위해 주어진 마감일 전에 이루어져야 하는 단일 ether 지불로 대출을
상환한다고 가정한다. 
예를 들어, 어떤 토큰이 약 0.05 ether의 가치가 있다면 대출 기관은 1.0 SomeTokens를 담보로 
기꺼이 양도하려는 차용인에게 2주 동안 0.03 ether를 빌려준다. 
대출 기관은 담보물의 가치가 대출 금액보다 훨씬 높기 때문에 이를 수행할 것이며,
따라서, 채무 불이행 시에 대출 기관이 담보물을 강제로 회수해야 하는 경우 그 문제는 해결될 것이다. 

이러한 금융 거래를 조정하기 위해 두 가지 컨트랙트를 사용한다. 
1. 차용인(borrower, 빌려쓰는 사람)은 대출 시작을 나타내는 ether를 위한 토큰 교환을 처리할 대출 요청 컨트랙트를 배포한다. 
이 컨트랙트는 지정된 조건으로 ether를 차용하려는 차용인의 요청을 나타낸다. 
2. 대출 기관(lender, 빌려주는 사람)이 조건을 수락하면 대출 계약이 생성된다. 
이 대출 계약은 담보로 토큰을 보유하고, 차용인이 대출을 상환하거나 또는 지불 마감일을 놓쳐서 불이행할 때까지 
대출 조건(deadline)을 시행한다. 
 */
contract CollateralLoan {
    /**
    @dev 대출 생성을 위해 차용인은 차용인과 대출 기관 간에 대출을 생성할 수 있는 컨트랙트를 배포한다. 
    'CollateralLoan' 컨트랙트는 대출 조건을 나타내는 아래 값을 매개변수로 갖는다. 
     */
    address public borrower; // 차용인(대출을 위해 컨트랙트를 배포한 사람)
    IERC20Token public token; // 대출 기관이 담보로 수락하는 토큰
    uint256 public collateralAmount; // 토큰 담보의 단위 금액
    uint256 public loanAmount; // 대출 금액(차용인이 차용한 wei 금액)
    uint256 public payoffAmount; // 차용인이 토큰을 회수하기 위해 지불해야 하는 wei 금액
    uint256 public loanDuration; // 대출 기간(차용인이 대출을 받은 후 대출금을 상환하는 기간)

    constructor(
        IERC20Token _token,
        uint256 _collateralAmount,
        uint256 _loanAmount,
        uint256 _payoffAmount,
        uint256 _loanDuration
    ) {
        borrower = msg.sender;
        token = _token;
        collateralAmount = _collateralAmount;
        loanAmount = _loanAmount;
        payoffAmount = _payoffAmount;
        loanDuration = _loanDuration;
    }

    /**
    @dev 이제 대출 기관(lender)은 CollateralLoan 컨트랙트의 계약 조건에 따라 ETH를 기꺼이 빌려줄 의향이 있는 경우,
    'lendEther()'를 호출할 수 있다. 
     */
    Loan public loan;

    event LoanRequestAccepted(address loan);

    /**
    @dev 'lendEther()'는 ETH를 차용인에게 전송하고 담보 토큰을 새로운 대출 계약(new Loan(..))으로 
    전송하여 대출 조건을 시행한다. 
     */
    function lendEther() public payable {
        require(msg.value == loanAmount);
        loan = new Loan(
            msg.sender,
            borrower,
            token,
            collateralAmount,
            payoffAmount,
            loanDuration
        );
        // 차용인의 토큰 담보를 대출 계약(컨트랙트)로 이전한다. (차용인에서 대출 조건으로 담보로 맡길 토큰량 전송)
        require(token.transferFrom(borrower, address(loan), collateralAmount));
        payable(borrower).transfer(loanAmount); // 대출된 이더는 차용인에게 전송된다.
        emit LoanRequestAccepted(address(loan)); // 트랜잭션을 기록하고, 차용인에게 그의 요청이 이행되었음을 알리고 계약 주소를 알린다.
    }
}
/**
@dev 차용인은 대출된 이더를 보유하게 되고, 'Loan' 컨트랙트는 담보 토큰을 보유한다. 
양 당사자는 `Loan public loan;` 상태 변수 덕분에 대출 계약을 쉽게 찾을 수 있다. 

만약 차용인이 토큰 전송을 승인하는데 실패하면 어떻게 될까? 
전송이 승인되지 않으면 'transferFrom()'이 실패하고, 전체 트랜잭션은 중단된다.
즉, 차용인은 ETH를 잃지 않는다. 

트랜잭션이 실패하고 차용인이 ETH를 얻지 못하면 토큰은 어떻게 될까?
그들에게 아무 일도 일어나지 않는다. 차용인은 이체만 승인했고 실제 이체는 일어나지 않는다.

대출 기관이 나타나지 않고 대출자가 더 이상 대출을 받고 싶어하지 않는다면?
대출자는 대출 기관이 나타나기 전에 언제든 토큰 전송 승인을 취소할 수 있다.
 */
