동기화 메소드
=============
- 스레드가 사용 중인 객체를 다른 스레드가 변경할 수 없게 한다.
    - 한 스레드가 작업이 끝날 때까지 **객체에 잠금**을 걸어서 다른 스레드가 사용할 수 없게!
- 멀티 스레드 프로그램에서 단 하나의 스레드만 실행할 수 있는 코드 영역을 **임계 영역, Critical section**
    - 임계 영역을 지정하기 위해 **동기화 메소드, Synchronized method**를 사용

동기화 메소드 생성
-----------------
```java
public synchronized void method() { // Synchronized method
    // Critical section;
}
```
- (주의!) 동기화 메소드가 여러개 있을 경우에, 스레드가 이들 중 하나를 실행하면 다른 스레드는 모든 동기화 메소드를 실행할 수 없다.
- 하지만 일반 메소드는 실행할 수 있다.

연습문제
========
동영상과 음악을 재생하기 위한 두 스레드 작성
```java
public class ThreadExam {
    public static void main(String args[]) {
        Thread th1 = new MovieThread();
        th1.start();

        Thread th2 = new Thread(new MusicRunnable());
        th2.start();
    }
}
//

public class MovieThread extends Thread {
    @Override
    public void run() {
        for(int i=0; i<3; i++) {
            System.out.println("동영상을 재생합니다.");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
//

public class MusicRunnable implements Runnable {
    @Override
    public void run() {
        for(int i=0; i<3; i++) {
            System.out.println("음악을 재생합니다.");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```

스레드 제어
===========
- 스레드는 다양한 상태를 갖는다.
- 자동으로 변경될 수 있고, 코드에 의해서 변경될 수 있다.

실행 대기 상태
-------------
- 스레드 객체를 생성하고 start() 메소드로 작업 스레드를 실행하면
- 바로 실행되는 것이 아니라 **실행 대기 상태**에 놓인다.
    - 언제든지 실행할 수 있는 상태
    - 운영체제가 실행 대기 상태의 스레드를 선택해서 실행 상태로 만든다.

실행 상태
--------
- 운영체제가 하나의 스레드를 선택해서 CPU가 run() 메소드를 실행하도록 한다.
    - 이를 **실행 상태** 라고 한다.
- run() 메소드를 모두 실행하기 전에 다시 실행 대기 상태로 돌아갈 수 있다.
    - 실행 상태와 실행 대기 상태를 번갈아가며 자신의 run() 메소드를 조금씩 수행한다.
- 경우에 따라서 **일시정지 상턔**가 되기도 한다.
    - 일시정지 상태는 스레드가 실행할 수 없는 상태이다.
    - 일시정지 상태에서는 바로 실행 상태로 갈 수 없고, 먼저 실행 대기 상태로 돌아가야 한다.
    <img src='./img/thread_status.png' width='50%' height='50%'> </img>


종료 상태
---------
- run() 메소드의 코드 내용이 모두 실행되면 스레드 실행이 멈추고 **종료 상태**가 된다.


스레드 상태 제어
===============
- 실행 중인 스레드의 상태를 변경하는 것

스레드 상태 제어 메소드
----------------------
- sleep()
    - 주어진 시간 동안 일시 정지
    - 시간이 다 되면 자동으로 실행 대기 상태가 된다.
- stop()
    - 스레드를 즉시 종료
    - 사용을 권장하지 않는다.
- interrupt() 
    - 스레드를 안전하게 종료
    - 일시 정지 상태의 스레드에서 InterruptException을 발생시킨다.
    - **예외 처리 코드(Catch)에서 실행 대기 상태로 가거나 종료 상태로 가게 한다.**

```java
public class ThreadExam {
    public static void main() {
        Toolkit tk = Toolkit.getDefaultToolkit();
        for(int i=0; i<10; i++) {
            tk.beep();
            try {
                Thread.sleep(3000);             // 3초동안 스레드를 일시정지 상태로 만듬
            } catch(InterruptException e) {}    // 3초가 다 지나면 실행 대기 상태가 됨
        }
    }
}
```




```
created) 2021-05-30
```