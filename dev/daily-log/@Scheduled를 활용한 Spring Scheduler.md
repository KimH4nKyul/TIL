# @Scheduled를 활용한 Spring Scheduler

## 스토리 
> 스프링 부트에서 `@Scheduled` 를 활용해 기능을 개발한 것을 기록해보려 합니다. 관리자가 단말기 공지사항을 등록할 때 예약을 걸어서 지정 시간에 자동으로 PUSH 해주는 기능이 있으면 좋겠다고 해 개발하게 되었습니다. 이 문서는 기능을 개발하면서 알게된 `@Scheduled` 와 `@Async` 애노테이션에 관련한 설명을 기록했습니다. 

> 저희 회사 백엔드 기슬 스택으로는 `Spring Boot 2.1.13`, `JAVA 8` 이 사용되고 있습니다. 저는 `Spring Boot` 에서 Scheduler를 개발하기 위해 `@Scheduled` 애노테이션을 사용했고, 관련 클래스들을 작성했습니다.  

## @Scheduled 애노테이션? 

Spring Scheduler는 `@Scheduled` 애노테이션을 명시해 사용할 수 있습니다.  
보통 실행하고자 하는 메소드명 위에 명시해 놓는데요.  
Scheduler가 정상 작동하기 위해서는 우선 스프링 애플리케이션에서 Scheduling을 활성화 시켜줄 필요가 있습니다. (😅)  
  
### Scheduling을 활성화 시키는 방법

Scheduling은 `@EnableScheduling` 애노테이션을 클래스 위에 명시해 활성화 시킵니다.  
이 때, `@Scheduled` 를 사용하고자 원하는 클래스 위에 명시할 수도 있고, `@SpringBootApplcation` 이 위치한 클래스 위에 명시해도 됩니다.  

```java
@EnableScheduling
public class MySchedulerClass {
  @Scheduled(cron="0/60 * * * * ?")
}
```

또는  

```java
@SpringBootApplication
@EnableScheduling
public class MySchedulerApplication { 
  public static void main(String[] args) {
    SpringApplication.run(MySchedulerApplication.class, args);
  }
}
```

### 선언은 했고! 그럼 어떻게 동작하지?

Spring Scheduler는 <u>동기적으로</u> 스케줄러를 실행하게 됩니다. 
이 때, `@Scheduled` 의 옵션으로 `fixedRate`, `fixedDelay`, `cron` 을 사용해서 각기 다른 방식으로 동작시킬 수 있습니다. 

### fixedRate

`fixedRate` 는 작업의 시작부터 시간을 카운트합니다.   

### 코드

```java
@Scheduled(fixedRate=1000) // 단위: ms
public void fixedRateScheduler() {
  System.out.println("나는 작업이 끝날때 까지 기다리지 않고 1000ms 마다 실핼될거야");
}
```

### fixedDelay

`fixedDelay` 는 작업이 끝난 시점부터 시간을 카운트합니다. 

### 코드

```java
@Schedueld(fixedDelay=1000) // 단위: ms 
public void fixedDelayScheduler() {
  System.out.println("나는 이 작업이 끝나고 나서 다시 1000ms 후에 실행될거야");
}
```

### cron 

`cron` 은 개발자가 `초, 분, 시, 일, 월, 주, (년)` 을 지정해 스케줄러를 동작 시킵니다.  
이 때, `(년)` 은 생략 가능합니다.   
  
저는 `cron` 이 정확히 지정한 시간에서만 실행됨을 보장하기 때문에 예약 발송 스케줄러에 더 적합한 방식이라고 생각해서 `cron` 을 채택했습니다. (👍)

### 코드 

```java
@Scheduled(cron="0/60 * * * * ?") 
public void cronScheduler() {
  System.out.println("나는 시스템 시간을 기준으로 1분 마다 주기적으로 실행될거야");
}
```

## @Async는 왜 필요했나?

앞서 Spring Scheduler는 동기적으로 실행된다고 했습니다. 
제가 구현한 예약 발송 스케줄러는 1분 주기로 실행되서 `RabbitMQAPI` 를 통해 단말기로 공지사항을 PUSH 하게됩니다. 
그런데 보내야할 공지사항이 많거나 단말기 개수가 점점 많아지면 1분 안에 처리가 안될 수도 있겠죠?
그러면 1분 후에 전송해야 할 예약 사항을 전달 못하는 상황이 발생할 수도 있습니다.
그렇기 때문에 스케줄러를 비동기적으로 실행해 PUSH를 보장할 수 있어야 합니다. 
`@Async` 를 활용하면 다음 스케줄러가 이전 스케줄러의 작업이 끝날때 까지 기다리지 않고 자신의 작업을 처리할 수 있게 될겁니다. 

> `@Async` 를 사용하기 전에 `@EnableAsync` 로 활성화 시켜 주어야 합니다. 
  ```java
  @SpringBootApplication
  @EnableScheduling
  @EnableAsync            // Async 활성화 
  public class MySchedulerApplication {
    public void main(String[] args) {
      SpringApplication.run(MySchedulerApplication.class, args); 
    }
  }
  ```

### 코드 

```java
@Async
@Scheduld(cron="0/60 * * * * ?")
public void cronScheduler() {
  System.out.println("나는 시스템 시간을 기준으로 1분 마다 주기적으로 실행될거야");
}
```

## Configuration 만들기 

### 코드

```java
package my.springboot.scheduler.sample;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;

import java.util.concurrent.Executor;

@Configuration
public calss SchedulerConfig implements AsyncConfigurer, SchedulingConfigurer {
  public ThreadPoolTaskScheduler threadPoolTaskScheduler() {
    ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
    scheduler.setPoolSize(Runtime.getRuntime().avaliableProcessors() * 2);
    scheduler.setThreadNamePrefix("MY-SCHEDULER-");
    scheduler.initialize();
    return scheduler;
  }
  
  @Override
  public Executor getAsyncExecutor() { return this.threadPoolTaskScheduler(); }
  
  @Override
  public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
    taskRegistrar.setTaskScheduler(this.threadPoolTaskScheduler());
  }
}
```
