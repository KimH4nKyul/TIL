# Zero address 

## address(0)가 의미하는 것이 무엇일까?  

```solidity
assert(owner != address(0))  
```

위 코드에서 `address(0)`은 무엇을 의미할까?
`address(0)`은 `Zero address` 라고 한다.  

결론부터 말하자면, `Zero address`는 `fake account`와 비슷한 것이다.  
위 코드는 `owner`의 계정이 `fake account`가 아님이 `true` 이어야 함을 의미한다.  

(`openzeppelin`의 `BurnableToken.sol`에서는 소각된 토큰을 보내는 주소이기도 하다. )

`Solidity docs`에 따르면,  
> If the target account is the zero-account (the account with the address 0), the transaction creates a new contract. As already mentioned, the address of that contract is not the zero address but an address derived from the sender and its number of transactions sent (the “nonce”). The payload of such a contract creation transaction is taken to be EVM bytecode and executed. The output of this execution is permanently stored as the code of the contract. This means that in order to create a contract, you do not send the actual code of the contract, but in fact code that returns that code.

~~라고 되어 있는데, 애시 당초 무슨 소린지 알아 들을 수 없었다.~~  

좀 더 쉽게, `Stack Overflow`에서 서치해보니 아래와 같이 정리 할 수 있었다.   

`Zero address`는 ethereum 트랜잭션 내에서 새 계약이 배포되고 있음을 나타내는 데 사용되는 특별한 경우일 뿐이다.  

두 개의 외부 계정 간의 전송이든, 계약 코드 실행 요청이든, 새 계약 배포 요청이든 모든 이더리움 트랜잭션은 동일한 방식으로 인코딩됩니다. 원시 트랜잭션 개체는 다음과 같다.  

```javascript
transaction = {
  nonce: '0x0', 
  gasLimit: '0x6acfc0', // 7000000
  gasPrice: '0x4a817c800', // 20000000000
  to: '0x0',
  value: '0x0',
  data: '0xfffff'
};
```

`to`가 `0x0`이 아닌 다른 것으로 설정되면 이 요청은 `ether`를 주소로 전송하고(값이 0이 아닌 경우)   데이터 필드에 인코딩된 기능을 실행합니다.   
주소는 계약 또는 외부 계정일 수 있습니다.

받는 사람 주소가 `Zero address`인 경우 데이터의 코드를 실행하여 새 계약이 생성됩니다(이는 "코드를 반환하는 코드"를 의미함). 새로 생성된 컨트랙트의 주소는 발신자의 주소와 현재 nonce를 기반으로 하기 때문에 기술적으로 미리 알려져 있습니다. 그 주소는 채굴 후 계약의 공식 주소가 됩니다.  

> Registering a contract on Ethereum involves creating a special transaction whose destination is the address 0x0000000000000000000000000000000000000000, also known as the zero address. (Antonopoulos and Wood, 2018, p29).

이더리움에 계약을 등록하려면 대상이 주소 0x00000000000000000000000000000000000000(`Zero address`라고도 함)인 특수 트랜잭션을 생성해야 합니다.

이더리움 가상 머신(EVM)은 트랜잭션이 수신자 필드에 0 주소로 알려진 특정 주소를 지정할 때 새 계약을 생성하려는 의도를 이해합니다.   
제로 주소는 "가짜 계정"과 비슷합니다. 일반 이더리움 주소와 마찬가지로 0 주소도 20바이트 길이지만 빈 바이트만 포함합니다. 따라서 아래와 같이 0x0 값만 포함하므로 이름이 0인 주소입니다.  

> `0x0000000000000000000000000000000000000000`

따라서 이 주소로 자금을 보내는 것은 실제로 어떤 에테르도 전송하지 않습니다. 이더리움 네트워크에서 광부는 이 수신자를 포함하는 트랜잭션을 새로운 스마트 계약을 생성하기 위한 명령으로 해석합니다.  

