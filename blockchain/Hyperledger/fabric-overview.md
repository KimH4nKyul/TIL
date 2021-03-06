# 하이퍼레저 패브릭 개요

========================

## 하이저레저 프로젝트

- 2015년
- 리눅스 재단
- 기업용 블록체인 개발
- 오픈소스 프로젝트

### 하이퍼레저 프로젝트 종류

- 하이퍼레저 프레임워크
  - 분산원장, 스마트 컨트랙트, 합의 알고리즘 등
  - 블록체인 전반에 필요한 기술 개발 프로젝트
  - 패브릭, 소투스, 이로하, 인디, 버로우
- 하이퍼레저 툴
  - 블록체인 시스템 성능 측정, 운영, 개발을 손쉽게 할 수 있도록 도와주는 도구 프로젝트
  - 캘리퍼, 컴포저, 퀼트, 첼로, 익스플로러

---

## 하이퍼레저 패브릭

- 허가형 프라이빗 블록체인(Permissioned and Private BlockChain)
- MSP(Membership Service Provider)라는 인증 시스템에 등록된 사용자만이 패브릭 블록체인에 참여 가능 ⭐
  - 관련 개념: Identity
- 비즈니스 목적에 맞는 형태로 패브릭 블록체인 구축 가능
  - 비즈니스 시스템에 적합한 블록 생성 알고리즘, 트랜잭션 정책 등을 선택 가능
- 채널(Channel)을 통해 참여자들의 프라이버시 강화 ⭐
  - 모든 사용자가 동일 원장을 갖고 모든 정보를 공유 하거나
  - 채널을 통해서 별도의 원장을 생성하고 민감한 정보를 공유하고 싶은 참여자들 간에만 공개

---

## 하이퍼레저 패브릭의 원장

- Shared Ledger
  - World State
    - 원장의 현재 상태
  - BlockChain
    - 원장의 전체 기록

## 체인코드(ChainCode)

- 기존의 Smart Contract
- 원장에 데이터를 읽고/쓰기 위한 프로그램

## 시스템 체인코드(System ChainCode)

- 블록체인 시스템 설정 가능한 체인코드

---

## 하이퍼레저 패브릭의 특징 ⭐

- 프라이버시
- 기밀성
  - 블록체인 참여 기업 중 특정 정보를 특정 회사에만 공유(협정과 채널 이용)
- 작업 구간별 병렬처리
  - 하이퍼레저 패브릭의 합의 과정을 **[실행(Execution) -> 정렬(Ordering) -> 검증(Validation)]** 으로 작업을 분리하여
    - ⭐ 실행(Execution)
      - 트랜잭션을 실행하고 결과를 검증하는 과정
    - ⭐ 정렬(Ordering)
      - 검증이 끝난 트랜잭션을 취합하고 손서대로 정렬된 블록을 생성
    - ⭐ 검증(Validation)
      - 블록에 포함된 결괏값을 검증하고, 각종 디지털 인증서를 확인
      - 이상 없을 시 블록체인 업데이트
  - 각 노드(실행하고 검증하는 노드, 정렬하는 노드)들의 부하를 줄이고,
  - 동시에 두가지 이상 작업을 수행하는 병렬처리 가능
- 체인코드
  - 기존의 스마트 컨트랙트(Smart Contract)
  - 시스템 체인코드는 트랜잭션의 보증, 블록의 검증, 채널 설정 등
- 모듈화된 디자인
  - 시스템 구축 시, 인증/합의/암호화 등의 기능을 참여자들이 원하는 형태로 선택 및 운영 가능
  - 다양한 비즈니스 모델에 맞게 개발 가능한 유연성 제공
