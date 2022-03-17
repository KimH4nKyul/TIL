//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20Token.sol";

/**
@dev [2] 'Loan' 컨트랙트는 대출 조건을 적용한다.
생성자는 대출 매개변수만 저장한다. 
 */
contract Loan {
    address public lender;
    address public borrower;
    IERC20Token public token;
    uint256 public collateralAmount;
    uint256 public payoffAmount;
    uint256 public dueDate;

    constructor(
        address _lender,
        address _borrower,
        IERC20Token _token,
        uint256 _collateralAmount,
        uint256 _payoffAmount,
        uint256 loanDuration
    ) {
        lender = _lender;
        borrower = _borrower;
        token = _token;
        collateralAmount = _collateralAmount;
        payoffAmount = _payoffAmount;
        dueDate = block.timestamp + loanDuration;
    }

    /**
    @dev 'Loan' 컨트랙트를 통해 차용인(borrower)는 대출 기간 동안 대출금을 상환하여 토큰을 회수할 수 있다.
    차용인이 만기일 전에 대출금을 상환하지 못하면,
    대출 기관은 몰수된 토큰을 압류할 수 있다.
     */
    event LoanPaid();

    function payLoan() public payable {
        require(block.timestamp <= dueDate); // 만기일 전
        require(msg.value == payoffAmount); // 차용인의 상환 금액이 상태 변수에 저장된 상환 금액과 일치해야 한다.

        require(token.transfer(borrower, collateralAmount)); // 조건에 만족하면, 차용인에게 담보 토큰을 돌려준다.
        emit LoanPaid();
        selfdestruct(payable(lender)); // 모든 ETH를 대출 기관에 돌려 주고, 컨트랙트를 종료한다.
    }

    function repossess() public {
        require(block.timestamp > dueDate); // 만기일 후

        require(token.transfer(lender, collateralAmount)); // 토큰을 대출 기관이 압류한다.
        selfdestruct(payable(lender)); // 계약을 종료한다.
    }
}
