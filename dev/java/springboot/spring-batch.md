# Spring Batch

## Overview
비즈니스 운영에 필수적인 작업을 종종 벌크 프로세싱으로 개발
* 사용자 인터랙션 없이 다량의 정보 처리. 주로 시간 기간 이벤트(월말 정산 처리, 통지 등)
* 매우 큰 데이터 세트를 반복적, 주기적으로 처리(보험료)
* 데이터 통합. 포맷팅, 유효성 검사, 트랜잭션 처리(배치 처리로 매일 수십억 건 트랜잭션 처리)

## Intro
경량 배치 프레임워크로, 배치 애플리케이션 개발을 위해 설계  
스프링 배치는 스케줄러를 대체하지 않고, 스케줄러와 함께 동작하도록 함  
* 대용량 데이터 처리에 필수적인 기능을 재사용할 수 있는 형태로 제공(로깅/추적, 트랜잭션 관리, JOB 프로세싱 통계, JOB 재시작, 스킵, 리소스 관리 등)  
* 최적화나 파티셔닝 같은 기법 사용 가능  
* 데이터베이스로 파일을 읽거나 저장 프로시저를 실행하는 일  
* 데이터베이스 간 대용량 데이터를 이동시키고 변형하는 일  
