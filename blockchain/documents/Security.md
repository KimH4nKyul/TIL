# 컨트랙트 보안

## 재진입 공격

### Re-entrancy attack  

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

### 재진입 공격을 막는 방법

외부 컨트랙트를 호출하기 전에 잔고를 0으로 만들거나 
msg.transfer를 사용해 가스 한도를 제한하고 재진입을 방지하는 두 가지 방법이 있다.  

```solidity
// 복잡한 폴백 함수를 안전하게 다루는 방법
function withdraw() {
    uint amount = balances[msg.sender];
    balances[msg.sender] = 0;
    payable(msg.sender).call.value(amount)();
}
```

```solidity
// 재진입 공격 가능한 컨트랙트 예시(수정)
contract HackableRoulette {
    mapping(address => uint) public balances;
    function betRed() payable {
        bool winner = (randomNumber() % 2 == 0);
        if(winner) balances[msg.sender] += msg.value * 2;
    }
    
    function randomNumber() returns (uint) { return 0; }
    
    function withdraw() {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).call.value(amount)();
    }
}
```
  

## 경합 조건

### Race Condition  

경합 조건은 외부 컨트랙트를 호출할 때 발생할 수 있는 버그의 종류를 가리키는 일반 용어이다.  

외부 함수 호출 시에 알 수 없는 상태 변경이 발생하면서 일어날 수 있다.  

재진입 공격 역시 경합 조건의 한 형태이다.  

두 개의 컨트랙트가 있는데 둘 다 세 번째 컨트랙트에서 동일한 변수를 수정하는 경우에도 또 다른 형태의 경합 조건이 발생할 수 있다.  


### 중지 가능한 컨트랙트  

> 짧은 시간 동안 많은 양의 이더를 보내거나 받는 모든 컨트랙트는 중지 가능(Suspendable) 하게 구현해야 한다.  
컨트랙트가 토큰 판매와 같이 제한된 기간 동안 이더를 수락하는 컨트랙트가 대표적이다. 컨트랙트를 자폭시키는 대신 중지 가능하게 설계하면 뒤늦게 참여하는 투자자의 이더를 보호할 수 있다.   

```solidity
// 중지 가능한 컨트랙트  
contract TokenSale {
    enum State { Alive, Suspended }

    address public owner;
    ERC20 public token;
    State public state; 

    function TokenSale(address tokenContractAddress) public {
        owner = msg.sender;
        token = ERC20(tokenContractAddress);
        state = State.Alive;
    }

    // 토큰과 이더를 1:1 비율로 교환
    function buy() public payable {
        require(state == State.Alive);
        token.transfer(msg.sender, msg.value);
    }

    function withraw() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }

    function suspend() public {
        require(msg.sender == owner);
        state = State.Suspended;
    }

    function alive() public {
        require(msg.sender == owner);
        state = State.Alive;
    }
}
```
중지된 컨트랙트에 이더를 보내면 트랜잭션 거부가 일어나고 이더는 사라지는 대신 투자자에게 반환된다.  

## 난수 생성  

```solidity
// block.blockhash를 사용해 구현한 난수 생성기
function random(uint send) public view returns (uint) {
    return uint(
        keccak256(block.blockhash(block.number-1), seed)
    );
}
```

이 함수는 부모 블록 해시를 사용자 생성 시드와 함께 해시한 다음 결과로 나오는 바이트 값을 정수형으로 반환한다.  
시드를 변경하면 출력도 함께 변경된다.  
이렇게 하면 0에서 2^256 사이의 수를 결과로 얻을 수 있는데, 나눗셈 연산을 사용하면 출력되는 결과값의 범위를 줄일 수 있다.  

```solidity
// 0~99 범위의 난수
random(0x7543def) % 100 
```

아쉽지만 현재 블록의 블록 해시는 블록이 채굴되기 전에는 사용할 수 없기 때문에 부모 블록의 블록 해시를 사용해야 한다.  
그런데 이는 부모 블록 해시 및 시드에 접근할 수 있는 모든 사용자가 어떤 난수가 나타날지 추측할 수 있음을 의미한다.  
또한 최근의 256개 블록에서만 블록 해시를 가져올 수 있으며 이 블록보다 오래된 블록에 대해 block.blockhash를 호출하면 0x0이 반환된다.  

공격자는 간단한 공격만으로 난수를 추측할 수 있다.  
위 예제의 random() 함수를 복사해 공격자의 컨트랙트에 붙여넣은 다음, random() 함수를 사용하는 트랜잭션과 동일한 블록에서 해당 함수가 채워지는지 확인하면 된다.  

이렇게 하면 부모 블록 해시가 동일하게 되고 시드만 유일하게 다른 요소가 된다. 시드는 트랜잭션의 사용자 입력 또는 컨트랙트의 결정적 소스에서 가져와야 하며 이 중 하나를 미리 알 수 있다.  

대규모 이더를 다룰 때는 간단한 난수 생성에 의존해서는 안된다.

## 정수형의 문제  

### 언더플로/오버플로  

솔리디티는 언더플로/오버플로 오류를 방지하지 못한다.  
오버플로는 정수형의 값이 해당 자료형의 최대값을 초과할 때 발생한다.  
값이 최소값보다 작아지면 언더플로가 발생한다.  

uint의 최소값은 0이며 최대값은 2^b-1 이다. 
여기서 b는 자료형의 길이를 비트 단위로 표현한 값이다.  
따라서 uint8의 최대값은 2^8-1=255이며, 256비트의 길이를 갖는 uint256은 최대값은 2^256-1이다.  
int의 최소값은 -(2^(b-1))이고 최대값은 2^(b-1)-1이다.  

정수가 오버플로 되면 다시 최소값으로 돌아가며, 정수가 언더플로 되면 최대값으로 올라간다.  

```solidity
uint a = 5;
a -= 6; //2^256-1, 언더플로
a += 1; //0, 오버플로

uint[300] numbers;
uint sum = 0;
for (uint8 i=0; i<numbers.length; i++) {
    sum ++ numbers[i];
    // i가 오버플로 되기에 이 반복문은 영원히 반복된다.  
}
```

### 언더플로 및 오버플로 방지

언더플로 및 오버플로 방지를 위해 개발자들은 `SafeMath`라는 표준 컨트랙트를 사용한다.  

`SafeMath` 컨트랙트는 오버플로 및 언더플로 조건을 확인하고 오류 조건을 인식하면 오류를 발생시킨다.  

```solidity
// 언더플로와 오버플로를 방지하는 SafeMath 컨트랙트 
contract SafeMath {
    function safeMul(uint a, uint b) internal pure ruturns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c; 
    }

    function safeDiv(uint a, uint b) internal pure returns (uint) {
        assert( b > 0);
        uint c = a / b;
        assert( a == b * c + a % b );
        return c; 
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert( b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert( c>=a && c>=b);
        return c;
    }
}
```

### 나눗셈으로 인한 버림

솔리디티는 소수점을 지원하지 않으므로 소수점 연산을 근사화하기 위해 정수를 응용해야 한다.  

정수 나눗셈으로 인한 버림은 두 개의 숫자로 나눗셈을 수행할 때 나머지가 발생할 경우에 발생한다.  

즉, 솔리디티에서 11 / 2가 5.5가 되는게 아니라, 5를 출력하고 0.5를 버리게 된다.  

```solidity 
// 버림으로 인한 자산 유실
// 주의 : 본 컨트랙트는 Stock 컨트랙트를 정의하기 전에는 컴파일 불가  
contract MarriageInvestment {
    address wife = address(0);
    address husband = address(1);
    Stock GOOG = Stock(address(2));

    function split() public {
        uint amount = GOOG.balanceOf(address(this));
        uint each = amount / 2;
        GOOG.transfer(husband, each);
        GOOG.transfer(wife, each);
    }
}
```

이 컨트랙트는 주식을 wife와 husband에게 나눠준다.  
한 부부가 3주를 나눠갖는 상황을 가정해보자.  
부부간에 주식을 나눠 가지려면 아내와 남편은 1주씩만 가지게 된다.  
마지막 남은 주식은 정수 연산 규칙에 의해 1 / 2 = 0이므로 유실된다.  

이때, 남은 주식을 참여자 중 한 명에게 이전하는 방식으로 이를 해결할 수도 있다.  

```solidity
function split() public {
    uint amount = GOOG.balanceOf(address(this));
    uint each = amount / 2;
    uint remainder = amount % 2;
    GOOG.transfer(husband, each + remainder);
    GOOG.transfer(wife, each);
}
```

## 함수는 기본적으로 public이다.  

가장 바람직한 코딩 방식은 각 함수에 가시성 제어자를 명시적으로 지정하는 것이다.  

적절한 가시성 제어자를 사용해 private 돼야 하는 함수를 private 함수로 만들지 못하면 패리티 멀티시그 해킹의 원인이 된다.  

internal이어야 하는 함수가 internal 함수가 되지 못하면 지갑에 통제권을 개방하는 것이나 다름없다.  

## tx.origin 대신 msg.sender 사용하기

tx.origin은 원래 트랜잭션을 서명한 지갑 주소를 가리키고, msg.sender는 특정 함수를 호출한 최근의 컨트랙트 또는 지갑 주소를 가리킨다.  

컨트랙트에서 tx.origin을 사용하면 사용자가 전달 공격을 받을 수 있다. 권한 부여를 위해 tx.origin을 사용하는 함수를 만들고 이를 해킹할 방법을 살펴보자.  

```solidity
// tx.origin으로 인한 잘못된 접근 권한의 예
function transferTo(address dest) {
    require(tx.origin == owner);
    dest.transfer(address(this).balance);
}
```

이 함수를 사용하면 컨트랙트 소유자가 컨트랙트 잔액을 목적지 주소로 보낸다. 공격자는 전달 컨트랙트로 이를 활용할 수 있다.  

```solidity
contract ForwardingAttack {
    HackableTransfer hackable;
    address attacker;

    function ForwardingAttack(address _hackable) public {
        hackable = HackableTransfer(_hackable);
        attacker = msg.sender;
    }

    function () payable public {
        hackable.transferTo(attacker)l
    }
}
```

공격자는 일반 지갑 주소로 가장해 지불을 요청함으로써 대상 컨트랙트가 공격 컨트랙트의 주소로 이더를 전송하게 만든다. 

이더를 전송하면 공격 컨트랙트의 폴백 함수가 공격 대상 컨트랙트의 transferTo() 함수를 호출하고 공격 대상 컨트랙트의 잔고를 공격자의 지갑 주소로 전송하려고 시도한다.  

트랜잭션이 지갑 주소에서 시작됐으므로 적절한 권한이 부여되고 공격자는 공격 대상 컨트랙트의 모든 이더를 자신의 지갑 주소로 전송한다.  

이러한 공격을 막는 방법은 다음과 같다.  

```solidity
// 전달 공격 방지 코드
function transferTo(address dest) {
    require(msg.sender == owner);
    dest.transfer(address(this).balance);
}
```

## 프론트 러닝

`트랜잭션`은 전체 네트워크로 브로드캐스트되며 일반적으로 블록에 포함되기 전에 모든 노드에서 볼 수 있다.  
트랜잭션이 블록에 포함될 때는 트랜잭션 비용순(혹은 **가스 가격이 높은 순**)으로 포함된다.  
이것은 `프론트 러닝(front running)`의 여지를 만든다.  

> 프론트 러닝이란?  
증권 거래 용어, 국문으로 선매매, 또는 선행 매매라고 한다.  
증권 업계에서는 기관 투자가의 매매 정보가 확실한 경우, 펀드 매니저나 주식 중개인이 고객 주문을 체결하기 전에 '동일한 증권'을 자기계산으로 매매하거나 제3자에게 매매를 권유해 부당 이득을 챙기는 행위  

`프론트 러닝`은 트랜잭션을 보고 그 내용을 이용해 자신의 트랜잭션을 보내는 방법이다. 
만약 누군가가 만든 트랜잭션이 그가 참조한 트랜잭션보다 먼저 완료된다면 이는 프론트 러닝을 한 것이다.   

*<u>모든 트랜잭션이 공개적으로 표시되고 트랜잭션 순서를 강제하는 `전역 매커니즘`이 없기 때문에 어떤 트랜잭션이든 프론트 러닝에 노출되있다.</u>*

## DAO 해킹 사건  

DAO 해킹은 복잡한 재진입 공격이었다.  

취약점을 가진 코드를 재현해보자.
재진입을 허용하는 두 줄이 포함되어 있다.
보다시피, 잔고는 외부 컨트랙트로 이전된 후 0으로 초기화 된다.  

```solidity
// splitDAO 함수의 마지막 부분
    Transfer(msg.sender, 0, balances[msg.sender]);
    withdrawRewardFor(msg.sender);
    totalSupply = totalSupply - balances[msg.sender];
    balances[msg.sender] = 0;
    paidOut[msg.sender] = 0;
    return true; 
}
```

