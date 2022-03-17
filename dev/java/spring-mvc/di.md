# DI (Dependency Injection, 의존성 주입)

- 의존성 주입?

  - 더 좋은 해석은 '부품의 조립'
  - Dependency란 객체와 객체의 결합 관계

- 객체를 일체형(Composition)으로 만들지 않고,
- 조립형(Association)으로 만들어야 함

```java
// Compostion has a
class A {
    private B b;

    A() {
        b = new B(); // 객체 B가 A와 일체되어 있음
    }
}

// Association has a
class A{
    private B b;

    A() {}

    public void setB(B b) { // 객체 B가 A와 상관 없음 (조립이 가능)
        this.b = b;
    }
}
```

- 위의 예제에서 Association has a를 선호함
- **객체를 조립형으로 만들어 조립하는 것을 Dependency Injection이라 할 수 있음**

```java
B b = new B(); // Dependency
A a = new A();

a.setB(b);  // Injection
```

- 조립하는 방법
  - Setter Injection
    - Setter를 이용한 조립 방법
    ```java
    //Setter Injection
    B b = new B();
    A a = new A();
    a.setB(b);
    ```
  - Construction Injection
    - 생성자를 이용한 조립 방밥
    ```java
    //Construction Injection
    B b = new B();
    A a = new A(b);
    ```

# 스프링의 의존성 관리

- 스프링 프레임워크의 가장 중요한 특징

  - 객체의 생성/의존관계를 **컨테이너** 가 자동으로 관리 (IoC의 핵심원리)

- IoC를 두 가지 형태로 지원
  - Dependency Lookup
    - 컨테이너가 애플리케이션 운용에 필요한 객체를 생성하고 클라이언트가 컨테이너가 생성한 객체를 검색(Lookup)하여 사용하는 방식
    - **실제 개발 과정에서 사용되지 않음**
  - Dependency Injection
    - **객체 사이의 의존관계를 스프링 IoC 컨테이너가 자동으로 처리해 줌**
