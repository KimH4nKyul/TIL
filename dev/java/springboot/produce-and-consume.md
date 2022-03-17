# SPRING_20210610

## Mapping에서 produces와 consumes란?
- 둘 다 **JSON을 사용하기** 위해 존재한다? (출처: https://whitekeyboard.tistory.com/175)
- 하나의 Mapping에 둘 다 사용 가능하다.

### produces
- HTTP 응답 헤더를 처리한다.
- 다음의 예에서,
```java
@GetMapping(value="/test", produces=MediaType.APPLICATION_JSON_UTF8_VALUE)
//... 
```
- HTTP 응답 헤더로
- application/json;charset=UTF-8를 반환한다.
- 생략시 메소드의 리턴타입에 따라 맞춰준다.

### consumes
- HTTP 요청 헤더를 처리한다. 
- 다음의 예에서,
```java
@GetMapping(value="/test", consumes=MediaType.APPLICATION_JSON_UTF8_VALUE)
//... 
```
- HTTP 요청 헤더가 들어오면,
- **헤더 정보의 Content-Type이 application/json;charset=UTF-8인 것만 처리한다.**
- 아니면, **org.springframework.web.HttpMediaTypeNotSupportedException** 예외가 발생한다.
