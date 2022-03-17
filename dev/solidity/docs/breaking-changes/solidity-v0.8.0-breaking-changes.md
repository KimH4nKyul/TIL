# Solidity v0.8.0 Breaking Changes

이 섹션은 솔리디티 0.8.0에서 주요 변경 사항에 대해 소개한다. 
전체 변경 사항 목록은 [the release changelog](https://github.com/ethereum/solidity/releases/tag/v0.8.0)를 확인하자. 

## 의미론적 변경 사항(Silent Changes of the Semantics)

이 섹션은 컴파일러가 사용자에게 알리지 않고 기존 코드가 동작을 변경하는 변경 사항을 나열한다. 

* 산술 연산은 언더플로와 오버플로에서 원래 상태로 되돌아(revert) 간다. 
이전의 래핑(wrapping) 동작 사용을 위해 `unchecked { ... }`를 사용할 수 있다.
오버플로 검사는 매우 일반적이므로 가스 비용이 약간 증가하더라도 
코드 가독성을 높이기 위해 기본값으로 설정했다.  
* ABI coder v2는 기본적으로 활성화 되어있다. 
`pragma abicoder v1;`을 사용해 이전 동작을 수행하도록 선택할 수 있다. 
`pragma experimental ABIEncoderV2;` 는 여전히 유효하지만, 사용되지 않으며 효과가 없다. 
만약에 명시하길 원한다면, `pragma abicoder v2;`로 명시한다.  
ABI coder v2는 v1보다 더 많은 타입을 지원하고 입력에 대해 더 많은 온전성 검사를 수행한다. 
ABI coder V2는 일부 함수 호출을 더 비싸게 만들고 파라미터 타입을 준수하지 않는 데이터를 포함했을 때 
ABI coder V1으로 되돌리지 않은 컨트랙트 호출로 되돌릴 수도 있다.  
* 지수화는 오른쪽 결합(right associative), 즉 계산식 `a**b**c`는 `a**(b**c)`로 구문 분석 된다. 
0.8.0 이전에는, `(a**b)**c`으로 구문 분석 되었다. 
이것이 지수 연산자를 구문 분석하는 일반적인 방법이다. 
* 실패한 assertion, 0으로 나누기, 또는 산술 오버플로와 같은 기타 내부 검사는 잘못된 연산 코드를 
사용하지 않는 대신 복귀 연산 코드를 사용한다. 보다 구체적으로, 상황에 특정한 오류 코드와 함께 
`Panic(uint256)`에 대한 함수 호출과 동일한 오류 데이터를 사용한다.  
이렇게 하면 오류 발생 시에 가스를 절약할 수 있는 동시에 정적 분석 도구가 `require` 실패와 같은 
잘못된 입력 시 되돌리기와 이러한 상황을 구별할 수 있다.  
* 길이가 잘못 인코딩된 스토리지의 바이트 배열에 액세스하면 패닉이 발생한다. 
인라인 어셈블리(inline assembly)를 사용하여 스토리지 바이트 배열의 원시 표현(raw representation)을 수정하지 않는 한 
컨트랙트는 이 상황에 빠질 수 없다.  
* 배열 길이 표현식에 상수가 사용되는 경우 이전 버전의 Solidity는 평가 트리의 모든 분기에서 임의의 
정밀도를 사용한다. 이제, 상수 변수를 중간 표현식으로 사용하면 런타임 표현식에서 사용할 때와 동일한 방식으로 
해당 값이 적절하게 반올림된다.  
* `byte` 타입은 제거 되었다. 이것은 `bytes1`의 별칭이어었다.  

## 새로운 제한 사항

이 섹션에는 기존 컨트랙트가 더 이상 컴파일되지 않을 수 있는 변경 사항을 나열했다.  

* 리터럴의 명시적 변환과 관련된 새로운 제한 사항이 있다. 다음 경우의 이전 동작은 모호했을 수 있다. :  
  1. 음수 리터럴 및 `type(uint160).max`보다 큰 리터럴에서 `address`로의 명시적 변환은 허용되지 않는다.
  2. 리터럴과 정수 타입 `T` 간의 명시적 변환은 리터럴이 `type(T).min`과 `type(T).max` 사이에 
  경우에만 허용된다. 특히, `uint(-1)`는 `type(uint).max`로 사용한다.  
  3. 리터럴과 열거형 간의 명시적 변환은 리터럴이 열거형의 값을 나타낼 수 있는 경우에만 허용된다.
  4. 리터럴과 `address`(예를 들어, `address(literal)`)간의 명시적 변환에는 `address payable` 
  대신에 `address` 타입이 있다. 명시적 변환, 즉, `payable(literal)`을 사용하여 지불 가능한 주소 타입을 
  얻을 수 있다.  
* [Address literals](https://docs.soliditylang.org/en/v0.8.11/types.html#address-literals1) 에는 `address payable` 대신 `address` 타입을 갖는다. 
명시적 변환을 사용하여 `address payable`로 변환할 수 있다. (예를 들어, `payable(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF)`)
* 명시적 형변환에 대한 새로운 제한 사항이 있다. 변환은 부호, 너비, 또는 타입 카테고리(`int`, `address`, `bytesNN`, etc)에 
최대 하나의 변경이 있는 경우에만 허용한다.
여러 변경을 수행하려면 여러 변환을 사용한다.  
`T(S)` 표기법을 사용하여 명시적 변환 `T(x)`를 나타낸다. 여기서 `T`와 `S`는 타입이고, `x`는 타입 `S`의 임의 변수이다.
허용되지 않는 변환의 예는 너비(8 bits에서 16 bits로)와 부호(부호 있는 정수에서 부호 없는 정수로) 
를 모두 변경하기 때문에 `uint16(uint8)` 처럼 되어야 한다. 변환을 하기 위해서는, 중간(intermediate) 타입을 
거쳐야 한다. 이전 예제에서, 이 점은 `uint16(uint8(int8))` 또는 `uint16(int16(int8))`처럼 되어야 한다. 
변환하는 두 가지 방법은 다른 결과를 생성할 것이다. 예를 들어 `-1` 같은. 다음은 규칙에서 허용하지 않는 변환의 몇 가지 예이다. 
  * `address(uint)`와 `uint(address)`: 타입 카테고리와 너비 모두 변환한다. 
  각각 `address(uint160(uint))`와 `uint(uint160(address))`로 대체한다.
  * `payable(uint160)`, `payable(bytes20)`과 `payable(integer-literal)`: 
  타입 카테고리와 상태 가변성(state-mutability) 모두 변환한다. 각각 `payable(address(uint160))`, `payable(address(bytes20))`과 `payable(address(integer-literal))`로 대체한다.
  `payable(0)`는 규칙 예외이며 유효하다.
  * `int80(bytes10)`과 `bytes10(int80)`: 타입 카테고리와 부호 모두 변환한다. 각각 `int80(uint80(bytes10))`과 `bytes10(uint80(int80))`으로 대체한다.
  * `Contract(uint)`: 타입 카테고리와 너비 모두 변경한다. `Contract(address(uint160(uint)))`로 대체한다.  
  
  이러한 변환은 모호성을 피하기 위해 허용되지 않는다. 예를들어, `uint16 x = uint16(uint8(-1))` 식에서 `x` 값은 
부호 또는 너비 변환이 먼저 적용되었는지 여부에 따라 달라진다.  
* 함수 호출 옵션은 한 번만 제공될 수 있다. 즉, `c.f{gas: 10000}{value: 1}()`은 유효하지 않고 `c.f{gas: 10000, value: 1}()`로 변경해야 한다.
* 글로벌 함수인 `log0`, `log1`, `log2`, `log3`와 `log4`는 제거되었다. 
이들은 크게 사용되지 않는 로레벨(low-level) 함수들이다. 그들의 동작은 인라인 어셈블리로 접근할 수 있다. 
* `enum`의 정의는 256 멤버 이상 포함될 수 없다. 
이렇게 하면 ABI의 기본 타입이 항상 `uint8`이라 가정하고 안전하게 만들어 준다.
* public 함수와 이벤트를 제외하고 이름이 `this`, `super` 및 `_`인 선언은 허용하지 않는다. 예외는 
그러한 함수 이름을 허용하는 Solidity 이외의 언어로 구현된 컨트랙트의 인터페이스를 선언하는 것을 가능케 하는 것이다.
* 코드에서 `\b`, `\f`, 그리고 `\v` 이스케이프 시퀀스에 대한 지원을 제거한다. 16진수 이스케이프를 통해 여전히 삽입할 수 있다. 
각각 `\x08`, `\x0c`, `\x0b` 이다.  
* 글로벌 변수인 `tx.origin`과 `msg.sender`는 `address payable` 대신 `address` 타입을 갖는다. 
명시적 변환, 즉 `payable(tx.origin)` 또는 `payalbe(msg.sender)`를 사용하여 `address payable` 타입으로 변환할 수 있다.
이 변경 사항은 컴파일러가 이러한 주소가 지불 가능한지 여부를 결정할 수 없기 때문에 수행되었다. 이제 이 요구 사항을 표시하려면 명시적 변환이 필요하다.  
* `address` 타입으로 명시적 변환은 항상 지불할 수 없는 `address` 타입을 반환한다. 특히, 다음과 같은 명시적 변환에는 
`address payable` 대신 `address` 타입을 갖는다. :  
  * `u`가 `uint160` 타입의 변수인 `address(u)`는 `payable(address(u))`와 같은 두 개의 명시적 변환을 이용해 `address payable` 타입으로 `u`를 변환할 수 있다.
  * `b`가 `bytes20` 타입의 변수인 `address(b)`는 `payable(address(b))`와 같은 두 개의 명시적 변환을 이용해 `address payable` 타입으로 `b`를 변환할 수 있다.
  * `c`가 컨트랙트인 `address(c)`는 이전에, 이 변환의 반환 타입이 이더(Ether) 받을 수 있는 컨트랙트인지 아닌지에 달려 있었다. (수신 함수 또는 지불 가능한 폴백 함수를 갖는지 의해) 
  `payable(c)`로의 변환은 `address payable` 타입을 가지며 이더를 받을 수 있는 컨트랙트 `c`일 경우만 허용된다. 일반적으로, 다음과 같은 명시적 변환을 사용하여 `c`를 `address payable` 타입으로 
  변환할 수 있다. : `payable(address(c))`  
  `address(this)`는 `address(c)`와 동일한 카테고리에 속하며 동일한 규칙이 적용된다.  
* 인라인 어셈블리에 내장된 `chainid`는 이제 `pure` 대신 `view`로 간주된다. 
* 부호 없는 정수에는 더 이상 단항 부정(Unary negation)을 사용할 수 없으며 부호 있는 정수에만 사용할 수 있다. 

## 인터페이스 변경 사항  

* `--combined-json`의 출력은 다음과 같이 변경되었다. : JSON 필드 `abi`, `devdoc`, `userdoc` 그리고 `storage-layout`은 이제 하위 객체(sub-objects)이다. 
0.8.0 전에 문자열로 직렬화 되었다. 
* "legacy AST"는 제거 되었다. (커맨드라인 인터페이스에서 `--ast-json`과 표준 JSON에서 `legacyAST`) 
대체제로 "compact AST"를 사용한다. (`--ast-compact--json` resp. `AST`)
* 오래된 에러 리포터(`--old-reporter`)는 제거 되었다.

## 코드 업데이트 방법   

* 래핑 산술에 의존하는 경우 각 연산을 `uncheckd { ... }`로 감싼다. 
* 선택 사항: SafeMath 또는 유사한 라이브러리를 사용하는 경우 `x.add(y)`를 `x + y`로, `x.mul(y)`를 `x * y` 등으로 변경한다.  
* 이전 ABI coder를 추가하려면 `pragma abicoder v1`을 추가한다. 
* 선택적으로 `pragma experimental ABIEncoderV2` 또는 `pragma abicoder v2`는 중복되므로 제거한다. 
* `byte`를 `bytes1`으로 변경한다.
* 필요한 경우 중간 명시적 형변환을 추가한다. 
* `c.f{gas: 10000}{value: 1}()`에서 `c.f{gas: 10000, value: 1}()`로 구성한다. 
* `msg.sender.transfer(x)`에서 `payable(msg.sender).transfer(x)` 또는 `address payable` 타입으로 저장된 변수를 사용하는 것으로 변경한다.  
* `x**y**z`에서 `(x**y)**z`로 변경한다.  
* `log0`, ..., `log4`에 대한 대체제로 인라인 어셈블리를 사용한다. 
* 부호가 없는 정수를 그 타입의 최대값에서 빼서 음수화 한다. (예를 들어, `type(uint(256).max - x + 1`, x가 0이 아님을 확인하면서)