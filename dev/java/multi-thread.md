멀티 스레드
===========

- 프로세스
    - 운영체제(OS)에서 실행 가능하도록 메모리에 할당한 하나의 애플리케이션 코드


- 멀티 프로세스 
    - 둘 이상의 프로세스가 존재하는 것
    - 각각은 독립된 메모리 공간에 할당 되기 때문에 서로 다른 프로세스이며,
    - 하나의 프로세스가 오류가 나도 다른 프로세스에 영향을 미치지 않는다.

- 스레드
    - 프로세스에 존재하는 하나의 코드 실행 흐름

- 멀티 스레드
    - 프로세스에 존재하는 둘 이상의 코드 실행 흐름
    - 하나의 프로세스 내에 존재하기 때문에
    - 하나의 스레드가 오류가 생기면 다른 스레드도 영향을 받는다.

- 메인 스레드
    - 자바의 모든 애플리케이션은 메인 스레드가
    - **main() 메소드**를 실행하면서 시작된다.

작업 스레드 생성과 실행
======================

- 먼저 몇 개의 작업을 병렬로 실행할지 결정하고
- 각 작업별로 스레드를 생성한다.
- 자바에서는 작업 스레드도 객체로 생성되기 때문에 클래스가 필요하다.
    ```java
    java.lang.Thread
    ```
    - Thread 클래스로부터 직접 생성
        - 작업 스레드를 직접 생성하기 위해선 **Runnable 객체를 매개값으로 갖는 생성자를 호출**한다.
        ```java
        class Task implements Runnable {
            
            @Override
            public void run() {
                // 작업 스레드에서 실행할 코드 구현
            }
        }

        Runnable r = new Task();
        Thread th = new Thread(r);
        ```

        - 이때 Runnable 객체 매개값을 **익명 구현 객체**로 사용할 수도 있고,
        - 주로 이 방법을 많이 쓴다.
        ```java 
        Thread th = new Thread(new Runnable() { 
            
            @Override 
            public void run() {
                // 작업 스레드에서 실행할 코드 구현
            }

        }); // 세미콜론 넣어주는거 잊지말기!
        ```
        
        - 그리고 작업 스레드를 실행할 때는 
        - start() 메소드를 사용한다.
        ```java
        th.start();
        ```

    - Thread 하위 클래스로부터 생성
        - Thread 클래스를 상속 받아 run() 메소드를 재정의해 사용
        ```java
        class ThreadTest extends Thread {
            
            @Override
            public void run() {
                // 작업 스레드에서 실행할 코드 구현
            }

        }

        // 어딘가에서..
        Thread th = new ThreadTest();
        th.start();
        ```
           
        - 아니면 **익명 자식 객체**로 구현해서 사용한다.
        ```java
        Thread thread = new Thread() {
            public void run() {
                // 작업 스레드가 실행할 코드 구현
            }
        }
        ```

스레드 이름
===========
- 스레드 이름은 설정하지 않으면 Thread-1, Thread-2, ... Thread-n 이라고 이름이 붙는다. (여기서 n은 숫자)
- 스레드 이름은 setName() 메소드로 설정할 수 있다.
    ```java 
    thread.setName("MyThread");
    ```
- 스레드 이름은 getName() 메소드로 확인할 수 있다.
    ```java
    thread.getName();
    ```
- 현재 코드를 실행하는 스레드 객체가 누군지 알고 싶다면 
    ```java
    Thread thread = Thread.currentThread();
    ```

```
created) 2021-05-27
```