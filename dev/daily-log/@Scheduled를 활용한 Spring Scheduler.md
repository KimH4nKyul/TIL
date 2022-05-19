# @Scheduled를 활용한 Spring Scheduler

## 스토리 
> 스프링 부트에서 `@Scheduled` 를 활용해 기능을 개발한 것을 기록해보려 합니다. 관리자가 단말기 공지사항을 등록할 때 예약을 걸어서 지정 시간에 자동으로 PUSH 해주는 기능이 있으면 좋겠다고 해 개발하게 되었습니다. 이 문서는 기능을 개발하면서 알게된 `@Scheduled` 와 `@Async` 애노테이션에 관련한 설명을 기록했습니다. 

> 저희 회사 백엔드 기슬 스택으로는 `Spring Boot 2.1.13`, `JAVA 8` 이 사용되고 있습니다. 저는 `Spring Boot` 에서 Scheduler를 개발하기 위해 `@Scheduled` 애노테이션을 사용했고, 관련 클래스들을 작성했습니다. :) 

## @Scheduled 애노테이션? 

## @Async는 왜 필요했나?

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
}
```
