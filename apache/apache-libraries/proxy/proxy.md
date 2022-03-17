# Commons Proxy  

GOF의 프록시 디자인 패턴은 객체에 대한 접근 제어를 위해 대리자 또는 플레이스홀더를 제공한다.  

> __플레이스홀더__
미리 사용 방법을 정의해 나중에 필요한 정보만 받아 실행하는 것 

프록시는 아래와 같은 방법으로 사용될 수 있다.
* 초기화 지연(Deferred Initialization)  
    - 프록시는 실제 구현을 위한 `stand-in` 역할을 하여 절대적으로 필요할 때만 인스턴스화할 수 있다.  
* 보안(Security)
    - 프록시 객체는 사용자가 실제로 메소드를 실행할 수 있는 권한을 갖고 있는지 확인할 수 있다.  
* 로깅(Logging)
    - 프록시는 모든 메소드 호출(`method invocation`)을 기록하여 디버깅 정보를 제공한다. 
* 성능 모니터링(Performance Monitoring)  
    - 프록시는 성능 모니터에 각 메소드 호출을 기록할 수 있으므로 시스템 관리자는 시스템의 어떤 부분이 잠재적으로 정체되어 있는지 확인할 수 있다. 

# Proxy Factories   

`ProxyFactory`는 코드에서 필요한 모든 프록시 로직을 캡슐화한다.  
프록싱 테크닉을 전환하는 것은 다른 프록시 팩토리 구현체를 사용하는 것만큼 간단하다.
* `commons-proxy2-jdk`
    - 핵심 JDK(the core JDK)에서 제공하는 프록시 매커니즘을 사용해 동적 프록시 인스턴스 생성 
    - 이 프록시 팩토리는 인터페이스만 노출 
* `commons-proxy2-cglib`
    - `cglib` 라이브러리를 사용해 프록시 클래스를 생성하는 `CglibProxyFactory` 제공
* `commons-proxy2-javassist`
* `commons-proxy2-asm4`  

핵심 라이브러리는 Java ServiceLoader 매커니즘을 사용해 검색 가능한 인스턴스에 위임하는 프록시 팩토리 구현 제공 

프록시 팩토리를 이용하면 다음 세가지 유형 프록시 객체를 만들 수 있다.  
* 델리게이터 프록시(Delegator Proxy) 
    - 각 메소드 호출은 `ObjectProvider`에서 제공하는 객체에 위임한다. 
* 인터셉터 프록시(Interceptor Proxy) 
    - 인터셉터가 각 메소드 호출을 가로채서 호출 대상으로 가는 것을 허용한다. 
* 인보커 프록시(Invoker Proxy) 
    - `Invoker`를 사용해 모든 메소드 호출을 처리한다. 

# Object Providers  

## Core Object Providers     

## Decorating Object Providers   

# Invokers

# Interceptors   

# Serialization   

# Stubbing  


