# 컨트랙트의 에러 처리
## revert
악의적인 사용자의 경우 가스비를 환불해줄 필요가 없지만, 그렇지 않은  
일반 사용자의 경우에는 가스비를 환불해줄 필요가 있다.

<u>*Q. 그렇다면 악의적인 사용자인지 아닌지 어떻게 판단할까?*</u>  

revert는 수동 오류를 발생시키고 사용하지 않은 모든 가스를 환불한다.  
(구버전 솔리디티에서는 throw를 사용했다. )  

require(condtion) 및 assert(condtion)이 조건을 검사해서 거짓일 때 오류를 던지고  
사용하지 않은 모든 가스를 소비한다.  

<u>*Q. require, assert, condition은 뭘까?*</u>
- condition은 개발자가 정의한 조건을 의미한다. 
- assert 오류는 내부적인 일관성을 검사하는데 사용한다.  
- 정상적으로 작동하는 코드는 절대적으로 assert 오류를 발생시켜선 안된다.
- assert는 condition이 true여야 할 것이라 예상하고 작성한다. 
- 에러가 발생한다면 코드에 __버그__ 가 있는 것이다.  
- require는 코드 작동이 의심스러운 부분에서 입력조건을 확인한다.
- 입력된 condition이 조건에 부합해 true인지 검사하며, false라면 실행을 중단시키고  
  require가 선언된 코드의 나머지 부분이 실행되지 않도록 한다. (**게이트 조건**)  

selfdestruct(address recipient)는 
현재 컨트랙트와 관련된 모든 데이터를 상태 트리에서 제거,
컨트랙트에 남은 이더, this.balance를 recipient에 송금한다.  