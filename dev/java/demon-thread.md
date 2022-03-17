스레드의 안전 종료
=================

- 우선, **Deprecated**의 의미
    - 중요도가 떨어져 더이상 사용하지 않으니 다른 것을 쓰도록 하라는 의미!

스레드를 안전하게 종료하는 방법들
-------------------------------
- stop 플래그 (메소드 아님!)
    ```java
    public class ThreadExam extends Thread { 
        private boolean stop;

        public void run() {
            while(!stop) {          // stop이 true가 되야 run() 종료
               // 스레드 실행 코드 
            }

            // 스레드 사용 자원 정리
            ...
        }
    }
    ```

- interrupt() 메소드
    - interrupt()는 **스레드가 일시 정지 상태**에 있을 때 InterruptException을 발생시켜 run() 메소드를 정상 종료 시켜준다.
        - 예외를 발생시키니까 안전하게 종료되는 것인가?
    
        ```java
        public class InterruptExam {
            main() {
                Thread th1 = new PrintThread();
                th1.start();

                try {Thread.sleep(1000);} catch (InterruptException e) {}

                th1.interrupt();        // PrintThread에 interrupt() 메소드로 InterruptException을 발생시킴
            }
        }

        public class PrintThread extends Thread {
            @Override
            run() {
                try {
                    while(true) {
                        sysout("실행중");
                        Thread.sleep(1000);         // 스레드가 일시 정지 상태
                    }   
                } catch (InterruptException e) {    // 스레드가 일시 정지 상태라면,
                                                    // interrupt() 메소드로 InterruptException 예외를 발생시켜 안전하게 종료시킬 수 있음
                }

                // 스레드 사용 자원 정리
            }
        }
        ```
    - (주의) 스레드가 일시 정지 상태가 아닌, 
    - 실행 상태 또는 실행 대기 상태일 경우에 interrupt() 메소드가 호출되면
    - 스레드가 미래에 일시 정지 상태가 되었을 때, InterruptException이 발생된다.

- 일시 정지를 만들지 않고 interrupt()의 호출 여부를 알기 
    - interrupted()
        - 정적 메소드로 현재 스레드가 interrupted 되었는지 확인     
        ```java
        boolean status = Thread.interrupted();
        ```
    - isInterrupted()
        - 인스턴스 메소드로 현재 스레드가 interrupted 되었는지 확인
        ```java
        boolean status = objThread.isInterrupted();
        ```
    - 둘 중 하나 사용하자!
    - 예제
    ```java
    public class PrintThread extends Thread {
        public void run() {
            while(true) {
                System.out.println("실행 중");
                if(Thread.interrupted()) {
                    break;                  // 스레드가 인터럽트 되었다면(interrupt() 메소드가 호출 되었다면)
                }                           // while문 빠져나와서 작업 스레드 정상 종료
            }
            // 스레드 사용 자원 정리
        }
    }
    ```

데몬 스레드
===========
- 주 스레드의 작업을 돕는 보조 스레드
- 주 스레드가 종료되면 보조 스레드인 데몬 스레드는 강제 종료
- 워드 프로세서의 자동 저장 / 미디어 플레이어의 동영상 및 음악 재생, JVM의 가비지 컬렉션 등
```java
public class DeamonExam {
    public static void main(String args[]) { // 메인 스레드
        AutoSaveThread ast = new AutoSaveThread();
        ast.setDaemon(true);                // setDaemon() 메소드로 데몬 스레드라 설정한다.
        ast.start();                        // 데몬 스레드는 시작 전에 설정해야 한다. (안그러면 IllegalThreadException 발생)

        try {
            Thread.sleep(3000);
        } catch (InterruptException e) {
            //
        }

        // 메인 스레드 종료
    }
}

public class AutoSaveThread extends Thread {
    public void save() {
        // 
    }

    @Override 
    public void run() {
        while(true) {
            try {
                Thread.sleep(1000);
            } catch(InterruptException e) { // 일시 정지되면 정상 종료
                break;
            }
        }
        
        save();
    }
}
```

```
created) 2021-05-31
```