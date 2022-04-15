# Null Check Handling 10 Tips  

> 이 글은 https://dzone.com/articles/10-tips-to-handle-null-effectively 에 게시된 포스팅을 공부도 할 겸 번역한 글이다. `NPE(NullPointerException)` 은 런타임 예외이기 때문에 컴파일 환경에서 잡아내기 어렵다. 그렇기 때문에 프로덕션 환경에서 `NPE` 를 잘 처리하는 것은 매우 중요하다고 생각한다.  

## Contents

1. 지나치게 null 체크를 하지 말라.
2. 스트림을 사용할때는 조건자로 Objects의 isNull 또는 nonNull 을 사용하라.
3. 파라미터로 null을 넘기지 말라.
4. 공개 API의 파라미터를 검증하라.
5. Optional을 잘 활용하라.
6. null 대신 빈 컬랙션을 반환하라.
7. Optional은 필드에서 사용하지 말라.
8. 문제가 발생하는 경우 null 보다 예외를 사용하라.
9. 코드를 테스트 하라. (테스트로 NPE 를 방지 하자.)
10. 한번 더 체크하자

## Don't overcomplicate Things 

> 지나치게 null 체크를 하지 말라.

Null을 체크하는 것은 아주 명확, 깔끔해야 한다. 몇몇 코드에서 본 아주 나쁜 습관은 간단한 null 체크로도 충분할 곳에서 `Objects` 메소드, `Optional` 클래스를 남발하는 경우다.  

```java
if(Optional.ofNullable(myVar).isPresent()) {} //bad
if(Objects.nonNull(myVar)) {}// better, but still bad
if(myVar != null) {} // good
```

## Use Objects Methos as Stream Predicates  

> 스트림을 사용할때는 조건자로 Objects의 isNull 또는 nonNull을 사용해라.  

비록 `Objects.isNull` 과 `Objects.nonNull` 이 전형적인 Null 체크에서 최고의 핏은 아닐지라도, `Stream` 에서 만큼은 유용하다. 필터링 또는 매칭 라인은 연산자를 쓰는 것보다 훨씬 가독성이 좋다. 

```java
myStream.filter(Objects::nonNull);
myStream.anyMatch(objects::isNUll);
```

## Neber Pass Null as an Argument

> 파라미터로 Null을 넘기지 말아라.  

좋은 코딩의 중요한 원리중 하나다. 주어진 파라미터에 대한 값이 없음을 나타내기 위해 Null을 전달하는 것은 실행 가능한 옵션처럼 보인다. 그러나 두 가지 단점이 있다.  

1. ㅁ
2. ㄴ


## References
* https://careerly.co.kr/comments/54927?utm_campaign=user-share
* https://dzone.com/articles/10-tips-to-handle-null-effectively