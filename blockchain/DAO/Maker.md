# What is Maker?  

![](.Maker_images/f5883223.png)  

## Overview

암호화폐 담보 대출 방식의 스테이블코인인 다이(DAI)에서 `대출 수수료 지불`을 위해 사용하는 암호화폐다.  
`메이커토큰`은 시스템의 중요한 변화에 대한 결정을 내릴 때, `투표권`을 행사하기 위해 사용할 수 있다.

`메이커 플랫폼`에서 사용되며(메이커 플랫폼에는 다이와 메이커토큰 두 종류 토큰이 존재)  
메이커 플랫폼에서 여러 기능을 수행하는 중요한 역할을 하는데, 주로 투표에 사용된다.  
투표로 결정된 사안은 메이커 플랫폼 정책에 반영된다.  

메이커 플랫폼은 스테이블코인인 다이를 관리하고 제공하는 이더리움 기반 블록체인 플랫폼이다.  
사용자가 플랫폼을 통해 이더(ETH)를 담보로 맡기면 스테이블 코인인 DAI를 생성한다.  

생선한 DAI를 되돌려주면 맡겼던 담보를 찾을 수 있다.  

메이커의 목표는 1DAI를 1달러로 안정화 시키는 것이며, 이를 위해 _<u>담보 부채권 포지션(CDP) 동적 시스템,  
자율적 피드백 매커니즘, 인센티브 시스템 등</u>_ 을 이용해 다이의 가치를 1달러로 일정하게 유지시키는  
`이러디움 스마트 컨트랙트 플랫폼`이다.

이 때, DAI의 사용자는 별도로 안정화 수수료(`Stability fee`)를 메이커 토큰(MKR)로 낸다.  

## Features 

1. 다이 스테이블 코인 시스템
   - 다이 스테이블 코인은 미국 달러화 대비 가치가 안정적인 암호 화폐
2. 담보 부채권 포지션(CDP)
   - 담보자산을 보유한 사람은 누구나 담보자산을 활용함
   - `CDP` 라고 하는 메이커의 고유한 스마트 컨트랙트를 통해 메이커 플랫폼에서 다이 생성
     - CDP는 사용자가 예치한 담보자산 보유
     - 사용자가 다이를 생성하도록 허용하지만 `부채` 또한 발생 시킬 수 있음
     - 부채는 나중에 동등한 금액의 다이를 갚을 떄까지 CDP 내부에 예금된 담보자산을 효과적으로 걸어 잠금  
     - 활성화된 CDP는 항상 초과 담보 상태를 유지
       - 담보 크기가 부채의 크기보다 항상 큼을 의미
3. CDP 상호 작용 절차
   - CDP 개설과 담보 입금
     - 사용자는 CDP 개설하겠다는 트랜잭션을 플랫폼에 보냄
     - 다이 생성에 사용될 담보자산의 종류와 양을 명시하여 자금 조달을 위한 다른 트랜잭션 전송
     - 이 시점부터 CDP는 담보된 것으로 간주 
   - 담보화된 CDP로부터 다이 생성
     - 사용자는 CDP에서 받기 원하는 다이 수량을 회수하기 위해 트랜잭션 보냄
     - 그 대가로 CDP는 동일한 금액 부채를 지게 되고 상환될 때까지 담보물에 대한 접근 차단 
   - 부채 상환과 안정화 수수료
     - 사용자가 담보물을 돌려받기 원할 시, CDP 상의 부채와 부채에 누적된 안정화 수수료를 함께 상환해야 함
     - 안정화 수수료는 메이커 토큰(`MKR`)로만 지불
     - 필요한 만큼의 다이(`부채`)와 MKR이 전송되면 부채와 안정화 수수료는 상환됨
       - CDP는 부채가 없는 상태가 됨 
   - 담보 인출과 CDP 계약 종료 
     - 부채와 안정화 수수료가 상환되면, 사용자는 거래를 플랫폼에 보내어 담보의 전부 또는 일부를 지갑으로 자유롭게 되찾음  
4. 가격 안정화 원리
   - 목표 가격
     - 다이의 목표가는 플랫폼에서 두 가지 주요 기능이 있음
       - CDP 부채 대 담보 비율을 계산
       - 전체 청산이 진행될 때 다이 보유자의 담보 자산 가치 측정
     - 목표가는 초기에 `USD`로 표시, `1`로 시작(<u>즉, USD와 1:1로 페깅</u>)
   - 목표가 비율 피드백 매커니즘(`TRFM, Target Rate Feedback Mechanism`)
     - 시장이 극도로 불안할 경우, 목표가 비율 피드백 매커니즘이 적용됨 
     - TRFM은 다이의 가치 고정을 깨지만, 오히려 이를 통해 액면가를 동일하게 유지
     - TRFM은 시간의 경과에 따른 목표 가격의 변동을 결정하므로, 목표가의 반복적인 변화 속에서  
     다이를 보유하는 것과, 다이를 빌리는 것 중 어떤 것이 나은지 판단
     - 목표가 비율이 `0%`가 되면 더이 상 목표가가 변동하지 않고 TRFM 개입의 필요가 없어짐  
     - 다이의 시장가를 목표가가 되도록 유도하고, 변동성을 낮추어 수요가 급감한 기간에도 실시간 유동성 공급
     - 다이 시장가가 목표가 아래로 내려가면 목표가 조정 비율 증가
       - 목표가를 높은 비율로 증가시키고, 결국 CDP의 다이 생성 비용 또한 증가
       - 이와 동시에, 목표가 조정비의 증가로 다이 보유를 통해 얻는 자본 이익 증가시킴
         - _"다이 수요를 증가시키게 된다"_
       - 공급의 감소와 수요의 증가는 다이 시장가를 올리고, 목표가로 향하도록 유도
         - 반대의 경우도 마찬가지 
   - 감도 변수(`Sensitivity Parameter`)
     - TRFM의 `감도 변수`는 다이 목표가와 시장가 변동으로 인한 목표가 조정 비율의 강도를 결정
     - 감도 변수의 변경을 통해 시스템의 피드백 비율 조절
     - 감도 변수는 메이커 토큰 투표자들에 의해 변경될 수 있음
       - 하지만 이러한 방식은 TRFM이 적용되면 시장에서 다이나믹하게 목표가와 목표 비율 정하는 것이지,  
       MKR 투표자가 시스템에 직접 개입하는 것은 아님
     - 감도 변수는 TRFM의 개입 여부를 판단하는 용도로 사용
     - 만일 감도 변수와 목표가 조정비가 모두 `0`이면 다이는 현재 목표가에 고정되고,  
     TRFM의 개입을 필요로 하지 않음  
   - 전체 청산
     - 전체 청산은 다이 보유자에게 목표가를 보장하는 암호화 방식의 최후의 보루
     - 다이 보유자와 CDP 사용자 모두가 자신이 소유한 자산을 돌려 받음
     - 이 과정은 완벽하게 탈중앙화 되어있고, MKR 투표자는 아주 심각한 상황에만 사용하는 수단임을 인지  
     - 예) 비이성적 시장, 해킹, 시스템 업그레이드 등
5. 위기 관리
   - 새로운 형태의 CDP 추가
     - 각각 독립적인 위기 변수들과 함께 새로운 형태의 CDP 생성
   - 기존 CDP 형태 수정
     - 기존에 추가된 CDP의 위기 변수 중, 하나 혹은 둘 이상 수정 
   - 감도 변수 수정
     - TRFM 감도 변경 
   - 목표가 비율 수정
     - MKR 투표자들이 다이 가격을 현재의 목표가에 고정하고자 할 때 실행
       - 이는 항상 감도 변수 수정과 동반됨
   - 신뢰할 수 있는 오라클 집단 선택
     - 탈중앙화된 오라클 구조를 통해 담보와 다이 시장가를 판단
     - MKR 투표자는 신뢰할 수 있는 오라클 집단이 몇 개의 노드로 구성되는지,  
     구성원은 누가 되는지를 정함
     - 오라클의 절반까지는 타협하거나 작동하지 않더라도, 시스템 안정성은 방해하지 않음 
   - 가격 책정 감도 수정
     - 가격 책정 시 변동되는 최대한의 폴을 설정하는데 사용  
   - 전체 청산인 집단 선택 
     - 거버넌스 절차를 통해 얼마나 많은 청산인이 전체 청산을 위해 필요한지 판단하고,  
     전체 청산인을 지정함 
6. 부채 한도
   - `부채 한도`는 하나의 CDP에서 생성할 수 있는 최대 부채량 
   - 어떤 형태의 CDP라도 충분한 양의 부채가 생성되면, 기존 CDP가 종료되지 않는 한,  
   추가 생성은 불가능
   - 부채 한도를 통해 충분한 양의 담보 포트폴리오가 확보되어 있음을 확인 가능  
     - 청산 비율
       - CDP가 정리에 취약한 상태에서의 담보 대비 부채 비율
       - 낮은 청산 비율은 MKR 투표자들이 담보의 가격 변동성을 낮게 예측한다는 뜻
       - 반면 높은 청산 비율은 MKR 투표자들이 그 반대 상황을 예측한다는 뜻  
     - 안정화 수수료
       - 안정화 수수료는 모든 CDP에 청구되는 수수료
       - 금액은 다이로 계산하지만, 납부는 MKR 토큰으로만 가능
       - 납부된 MKR은 소각되고 총 공급량에서 영원히 차감
     - 패널티 비율
       - 패널티 비율은 청산 우선 순위에 있는 CDP 사용자에게 초과 담보를 환원하고,  
       청산 경매를 통해 MKR을 소각하는데 드는 다이 최대 수량 결정  
       - 청산 매커니즘의 비효율성을 보완
         - 단일 담보 다이 단계에서, 청산 패널티는 PETH의 구입과 소각을 통해 PETH와 ETH 비율을 효율적인 상태로 만듬
7. 위기 변수
   - CDP는 위기 변수를 여럿 갖고 있음
   - 각각의 CDP 형식은 독자적인 위기 변수를 보유
   - CDP 형태에 의해 사용되는 담보 위기 프로필을 기반으로 판단
   - MKR 보유자들에 의해 직접 관리
   - MKR 1개 당 하나의 투표권 행사
8. MKR 토큰 거버넌스
   - 거버넌스는 MKR 투표자들의 `제안`에 대한 `투표`로 이루어짐
   - 제안은 MKR 투표에 의해 메이커 플랫폼의 내부 거버넌스 변수를 바꾸기 위한  
   최고 관리자 권한을 얻는 스마트 컨트랙트 형태로 구성
   - 제안은 `단일 실행 제안 계약`(SAPC, Single Action Proposal Contracts)과 `위임형 제안 계약`(DPC, Delegating Proposal Contract) 두 가지 형태
     - `SAPC`는 실행 권한을 획득한 뒤 한 번만 실행
     - 실행 후, 메이커 플랫폼의 내부 거버넌스 변수 즉시 변경
     - 실행 후, 스스로 삭제되며 재사용 불가 
     - `DPC`는 두 번째 거버넌스 레이어에서 최고 관리자 권한을 획득하여 반복적으로 실행되는 코드 형태 제안 
     - 시간을 지정하여 특정 거버넌스 행동이나 규모를 제한하거나, 특정인 혹은 전체에 권한을 이양하여 세 번째 레이어에 해당하는 DPC를 만드는 등 복잡한 형태로 구현 가능    
9. MKR과 다중 담보 DAI
   - 다중 담보 다이로 업그레이드 되면, MKR은 PETH를 대신하여 자본 재구성에 더 중요한 여할
   - 시장 붕괴로 CDP가 담보 부족 상태가 되면, MKR 공급은 자동 희석되고 시스템이 충분한 기금을 유지할 수 있도록 매각 
10. 위험한 CDP 자동 청산 
    - 청산 제공 계약
      - 단일 담보 다이를 위한 청산 매커니즘은 `청산 제공 계약`
      - 스마트 컨트랙트 형태
      - 시스템 가격 책정에 따라 이더리움 사용자와 보유자 간 직접 거래
      - CDP가 정리되는 즉시, 시스템은 이를 획득
      - CDP 보유자는 남은 담보에서 부채와 안정화 수수료, 청산 패널티를 제외한 가치를 돌려 받음  
    - 부채와 담보 경매
      - 반대 매매가 진행되면, 메이커 플랫폼은 CDP 담보를 구입하고 이를 자동으로 경매 매각
      - 경매 매커니즘은 가격 정보가 없는 CDP의 청산을 가능케 함   
      