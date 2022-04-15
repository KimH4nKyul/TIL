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

좋은 코딩의 중요한 원칙중 하나다. 주어진 파라미터에 대한 값이 없음을 나타내기 위해 Null을 전달하는 것은 실행 가능한 옵션처럼 보인다. 그러나 두 가지 단점이 있다.  

1. 함수 구현사항, 잠재적으로 영향을 받는 모든 함수가 Null을 올바르게 처리할 수 있는지 파악한다. 
2. 함수 구현사항을 변경할 때 사용자를 위해 Null을 처리할 수 있는 것을 버리지 않도록 주의한다. 그렇지 않으면 전체 소스코드를 검색해 Null이 어디로든 전달되고 있는지 확인해야 한다.  

Null을 전달하지 않는다는 원칙을 받아들이면 이 두 가지 문제가 영원히 사라진다.  
선택적 파마리터가 있는 함수는 어떨까? 간단하다. 다른 파라미터 세트로 함수를 오버로드 한다.  

```java
void kill() {
    kill(self);
}

void kill(Person person) {
    person.setDeathTime(now());
}
```

위의 두 가지 문제가 단일 클래스의 범위에서 보이지 않기 때문에 `private` 메소드를 다룰 때 원칙을 포기할 수도 있다. 그게 외부로부터 안전한지 확인해야 한다.


## Validate Public API Arguments

> 공개 API 파라미터를 검증하라. 

공개 API는 Null을 사용자와 함수에 전달하는 것을 제어할 수 없다. 이러한 이유로 항상 공개 API에 전달되는 파라미터의 정확성을 확인해야 한다. 유일한 관심사가 인수(`argument`)의 무효인 경우 `Objects` 클래스의 `requireNonNull` 함수 사용을 고려하자. 

```java
public Foo(Bar bar, Baz baz) {
    this.bar = Objects.requireNonNull(bar, "bar must not be null");
    this.baz = Objects.requireNonNull(baz, "baz must not be null");
}
```

## Leverage Optional  

> Optional을 잘 활용하라.  

Java 8 이전에는 값이 누락된 경우 메서드가 Null을 반환하는 것이 일반적이었다. 
이 부분은 개발자가 항상 문서를 확인해야 하거나 문서가 누락된 경우 Null 가능성에 대한 기본 소스 코드를 반환해야 했기 때문에 본질적으로 오류가 발생하기 쉬웠다. JDK 8이 릴리즈된 이후 반환 값이 누락되었을 수 있음을 나타내도록 특별히 설계된 `Optional` 클래스를 사용할 수 있다.  
반환 값으로 `Optional` 을 사용하여 메서드를 호출하는 개발자는 값이 없는 경우를 명시적으로 처리해야 한다. 따라서 해당되는 경우 반환 유형을 `Optional` 로 래핑한다. 

```java
Optional<String> makingYouCheck() {
    // stuff
}
makingYouCheck().orElseThrow(ScrewYouException::new);
```



## References
* https://careerly.co.kr/comments/54927?utm_campaign=user-share
* https://dzone.com/articles/10-tips-to-handle-null-effectively