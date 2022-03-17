# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

# Intro

## What is hardhat?

1. 이더리움 DApp 개발 도구
2. Web3.js 대신 Ethers.js 사용
    * Plugin 형태로 web3.js를 설치해 사용할 수 있음   
3. in-process 가상 이더리움 네트워크 제공
4. console.log() 사용 가능  
    * 테스트 용도, 배포시 삭제  
    * `import "hardhat/console.sol";`

## How to install?

```shell
yarn init -y
yarn add hardhat --dev
npx hardhat help 
```

## Hardhat project structure

```text
project
|-artifacts         -> 컴파일 결과
|-cache
|-contracts         -> 컨트랙트
|-scripts           -> 배포 및 실행 스크립트
|-test              -> 단위테스트
|-hardhat-config.js -> 환경 설정
```

## Requirements

```text
단위 테스트 
@nomiclabs/hardhat-waffle
ethereum-waffle
chai

Ethers.js 라이브러리
@nomiclabs/hardhat-ethers
ethers

Openzeppelin 라이브러리
@openzeppelin/hardhat-upgrades
```

