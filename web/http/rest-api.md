출처: NHN Cloud Meetup - REST API 제대로 알고 사용하기

# REST API(Representational State Transfer API)

REST API란 <b>CRUD Operation 구조</b>를 `자원`과 `행위`로 `표현`해 분산 하이퍼미디어 시스템에서 사용할 수 있는 소프트웨어 아키텍처의 한 형식이다.  
웹, HTTP 기술을 그대로 활용해 웹의 장점을 최대한 활용할 수 있도록 로이 필딩이 최초로 소개했다.  

# REST API 구조
REST API는 위에서 소개 하였듯이, 
* `자원(Resource)` : URI
* `행위(Verb)` : HTTP METHOD
* `표현(Representations)`

위 세가지로 구성된다. 

# REST API 특징

* Uniform Interface
  * URI로 지정한 리소스에 대한 조작을 `통일`되고 `한정적`인 인터페이스로 수행한다.


* Stateless
  * 작업을 위한 상태정보를 따로 저장하고 관리하지 않는다.
  * API 서버는 들어오는 요청만을 단순히 처리한다.
  * 서비스의 자유도가 높아지고 구현이 단순해진다.


* Cacheable
  * HTTP라는 기존 웹표준을 그대로 사용하기 때문에 HTTP의 캐싱 기능을 적용 가능하다.
  * HTTP 프로토콜 표준에서 사용하는 `Last-Modified`, `E-Tag`를 이용한다.

* Client-Server
  * REST 서버는 API를 제공하고, 클라이언트는 사용자 인증이나 컨텍스트(세션, 로그인 정보) 등을 직접 관리하는 구조로 작동한다. 
  * 서버에서 개발해야 할 내용이 명확해지고 서로간 의존성이 줄어든다. 

* Self-descriptiveness
  * REST API 메시지만 보고도 이를 쉽게 이해할 수 있다.  

* Layer structure
  * REST 서버는 다중 계층으로 구성되어 보안, 로드밸런싱, 암호화 계층을 추가할 수 있다.
  * PROXY, 게이트웨이 등 중간매체를 사용할 수 있다. 

# REST API 디자인 가이드

* 자원(Resoruce, URI)는 명사를 사용한다.  
   * URI는 자원을 표현하는데 중점을 둬야 하며, delete 같은 행위에 대한 표현은 들어가선 안된다.
   * 예로 `GET /members/delete/1` 같은 표현은 잘못된 표현이고,
   * `DELETE /members/1` 이 올바른 표현이다.  

* 자원에 대한 행위는 HTTP METHOD로 표현한다.
  * HTTP METHOD는 GET/POST/PUT/DELETE 등이 있다. 
  * <b>회원을 추가하는 URI</b>가 있다면,  
    `GET /members/insert/2` 는 올바른 Method와 자원이 아니므로, `POST /members/2` 라 표현한다.  
    
# URI 설계 시 주의점

* 슬래시 구분자(`/`)는 계층 관계를 나타낸다.  
  ```
  http://hankyul.com/houses/apartments
  http://hankyul.com/animals/mammals/whales
  ```

* URI 마지막 문자로 `/`를 포함하지 않는다.
  * REST API는 분명한 URI를 만들어 표현해야 하므로, 혼동을 줄 수 있는 요소를 없애는 것이 좋다.


* 하이픈(`-`)은 가독성을 높인다.
  * 불가피하게 긴 URI를 사용한다면 `-`를 사용한다. 

* 언더라인(`_`)은 사용하지 않는다. 
  * 경우에 따라 `-`은 보기 어렵게 하거나 문자가 가려질 수 있다.

* URI 경로는 <b>소문자</b>로 표현한다.
  * 대소문자에 따라 다른 자원으로 인식한다.
  * `RFC3986`에서 URI 스키마와 호스트를 제외하고 대소문자를 구별하도록 규정되어 있다.  
    `RFC 3986 is the URI (Unified Resource Identifier) Syntax document`
    
* 파일 확장자는 URI에 포함시키지 않는다.  
  * `http://hankyul.com/members/soccer/345/photo.png` 는 URI의 잘못된 표현이다.   
  * 확장자를 포함시켜야 할 때는 `Accept Header`를 사용토록 한다.  
    `GET / members/soccer/345/photo HTTP/1.1 Host: hankyul.com Accept: image/png`
    
# 리소스 간의 관계를 표현하는 방법

* <b>연관관계</b>로 표현한다.   

* /리소스명/리소스 ID/관계가 있는 다른 리소스명    
 `/users/{userid}/devices` (소유 'has'의 관계로 표현)
 
* 관계명이 복잡하다면 서브 리소스에 명시적 표현한다.   
  `/users/{userid}/likes/devices`
  
# 자원을 표현하는 `Collection` 과 `Document`

