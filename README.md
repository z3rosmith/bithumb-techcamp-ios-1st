# 빗썸테크캠프 야곰 아카데미 iOS 1기

### 시작하기 앞서...

### 프로젝트의 결과물을 한눈에 보고 싶다면?
#### [프로젝트 소개 페이지](https://donggeonoh.github.io/bithumb-techcamp-ios-1st/) 참조 (gif 이미지)

### 프로젝트 중 일어난 자세한 일들을 알고 싶다면?
#### [Github Wiki](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki) 참조

## 개요

### 프로젝트 목표
#### 빗썸 Public API 사용한 앱 구현

### 프로젝트 기간
#### 2022.02.21 ~ 2022.03.13

### 팀원 소개
|오동건(DonggeonOh)|김진영(제로)|황제하(허황)|
|---|---|---|
|<img width="200" src="https://i.imgur.com/IMKlvRQ.jpg">|<img width="200" src="https://i.imgur.com/TzAWvqX.jpg">|<img width="200" src="https://i.imgur.com/x4f4Vbs.jpg">|
|cafa3@naver.com|zero0204@gmail.com|hyhpwang@gmail.com|
|https://github.com/DonggeonOh|https://github.com/z3rosmith|https://github.com/HJEHA|

### 프로젝트 기술 스택
<img width="300" src="https://i.imgur.com/MCgeDzH.png">

## 앱 구동 화면
### 코인 리스트 화면
|라이트 모드|다크 모드|
|---|---|
|![](https://i.imgur.com/56Wtez4.gif)|![](https://i.imgur.com/dRwSqR2.gif)|

### 코인 상세 화면(차트)
|라이트 모드|다크 모드|
|---|---|
|![](https://i.imgur.com/rYy11N0.gif)|![](https://i.imgur.com/4D0dgNL.gif)|

### 코인 상세 화면(호가)
|라이트 모드|다크 모드|
|---|---|
|![](https://i.imgur.com/0Po9aG2.gif)|![](https://i.imgur.com/x8R2TMb.gif)|


### 코인 상세 화면(체결 내역)
|라이트 모드|다크 모드|
|---|---|
|![](https://i.imgur.com/974EQpQ.gif)|![](https://i.imgur.com/QOVmO5E.gif)|


### 입출금 현황 화면
|라이트 모드|다크 모드|
|---|---|
|![](https://i.imgur.com/lE7djxM.gif)|![](https://i.imgur.com/RyZgcmg.gif)|

### 더보기 화면
|라이트 모드|다크 모드|
|---|---|
|![Simulator Screen Recording - iPhone 11 - 2022-03-12 at 22 42 50](https://user-images.githubusercontent.com/98801129/158020405-13af274e-f7ae-4dc0-a93a-410c05ae0523.gif)|![Simulator Screen Recording - iPhone 11 - 2022-03-12 at 22 42 35](https://user-images.githubusercontent.com/98801129/158020402-6ff9d99c-8211-46cb-a4b1-b7830a223237.gif)|





## 주요 기능 소개
### 네트워크
- Bithumb HTTP Public API Ticker, Order book, Transaction history, Assets status 사용
- Bithumb Candlestick API 사용
- Bithumb WebSocket Public API Ticker, Orderbook, Transaction 사용

### 코어데이터
- 코인 차트 데이터 저장 및 불러오기
- 코인 상세 화면 오른쪽 상단의 차트 데이터 저장 및 불러오기
- 관심 코인 목록 데이터 저장 및 불러오기

### 코인 리스트 화면
- 관심/원화 탭으로 관심/원화 셀로 스크롤 기능
    > 유저가 터치를 한번 더 해서 관심목록에 접근할 필요 없이 한 화면에서 관심/원화 목록에 접근할 수 있도록 하기 위해서 한 화면에 관심/원화 목록을 넣었음
- 코인명 및 심볼로 검색 기능 
- 인기순(최근 24시간 거래금액 기준), 이름순, 현재가순, 변동률순 정렬 기능
- 셀 슬라이드 시 즐겨찾기 추가
- 현재가 및 변동률 실시간 업데이트

### 코인 상세 화면
- 웹소켓을 이용한 실시간 데이터 반영(현재가, 변동가, 변동률)
- 차트 구현 (최근 3개월 시가 기준)

### 코인 상세 화면(차트)
- 시간(1분, 10분, 30분, 1시간, 1일) 별 차트 데이터 표시
- 차트의 캔들스틱 터치 시 정보(시가, 고가, 저가, 종가) 표시
- 웹소켓을 이용한 실시간 캔들스틱 데이터 반영

### 코인 상세 화면(호가)
- 매수, 매도 영역 분리
- 웹소켓을 이용한 실시간 데이터 반영
- 매도, 매수의 전체 수량을 표시
- 매도 또는 매수 셀만 화면에 표시될 경우 반대 주문의 최저가, 최고가 뷰 노출

### 코인 상세 화면(체결 내역)
- 웹 소켓을 이용한 실시간 데이터 반영

### 입출금 현황 화면
- 코인의 입출금 현황 상태 표시
- 코인명, 심볼 검색 시 필터링
- 현황 상태에 대한 전체, 정상, 중단 모아보기
- 코인 이름, 입금, 출금 순으로 정렬

### 더보기 화면
- 팀원들의 정보 및 라이센스를 한 화면에 간단하게 표시

## 가장 기억에 남았던 트러블 슈팅
### 오동건 (DonggeonOh)
- Candlestick API의 가장 최신 데이터의 경우 시간에 대한 기준과 다른 경우에 대한 문제
  > 예를들어, 24시간을 기준으로 하면 제일 마지막(최신) 데이터는 12시(자정)을 기준으로 한 데이터가 아닌 현재 시간의 1시간을 기준(현재 8시 반이라면 8시)으로 한 데이터가 넘어왔습니다.
  > 
  > 그리고 실시간으로 업데이트 하기 위해 WebSocket Ticker API를 사용하여 데이터를 가져올 땐, 현재 시간에 대한 데이터를 넘겨받기 때문에 최신 캔들스틱에 대한 업데이트를 어떻게 해야할 지에 대한 고민을 하였습니다.
  > 
  > 이 방법을 해결해주기 위해서 최근 데이터와 실시간으로 받은 데이터의 time을 Epoch timestamp로 변환한 후 둘의 타임스탬프 간 차이를 이용하였습니다.
  > 
  > 그리고 각 단위(1분 = 60, 10분 = 600...)마다의 타임스탬프를 계산 후 데이터 간 차이 값과 단위 값의 차이를 비교하여 단위보다 적은 경우엔 업데이트, 큰 경우엔 데이터를 추가해주는 방식으로 해결하였습니다.
  
### 김진영 (z3rosmith)
- 코인 목록 화면 현재가 웹소켓 적용 시 스크롤이 무작위로 되는 버그
    > 체결(transaction) 웹소켓 api를 이용해서 symbols에 현재 받아와진 모든 코인들의 symbol을 넣어서 웹소켓을 열었습니다.
    > 
    > 이 때 웹소켓 통신으로 날아온 데이터들이 들어올 때마다 diffable data source에 apply를 해 줬는데 현재 화면에 보이지 않는 셀까지 바뀐 데이터가 적용이 되어서인지 스크롤이 계속 위아래로 조금씩 움직이는 현상이 나타났습니다.
    > 
    > 그래서 현재 화면에 보이는 cell에만 웹소켓 통신으로 날아온 데이터를 적용 시켜주기 위해서 collection view의 visibleCells 프로퍼티를 data manager에 전달해준 후 해당 cell들의 현재가가 변할때만 diffable data source에 apply 시켜주는 방법으로 문제를 해결하였습니다.

### 황제하 (허황)
- 범용적으로 사용할 수 있는 NetworkService
    > 처음에는 API 별로 request() 메서드를 따로 만드려고 했으니 그렇게 되면 중복 코드가 너무 많다고 생각했습니다.
    > 하나의 request() 메서드에서 여러 API를 받을 수 있는 방법을 고민해봤습니다.
    > 열거형을 사용해서 API 별로 연산 프로퍼티를 만들어서 사용하려고 했으나 그렇게 설계하게 되면 API가 추가될 때마다 열거형을 수정해줘야하는 상황이 생겼습니다.(개방 폐쇄 원칙 위반)
    > 다른 방법을 생각한게 프로토콜을 사용하여 API 별로 구체타입을 가지게 되면 중복 코드도 방지할 수 있고, API가 추가될 때마다 기존 코드를 수정해줄 필요가 없기 때문에 확장에 용이하다 판단했습니다.
    > HTTPNetworkService의 인터페이스는 하나만 사용하고 있습니다.
    ```swift=
    request(
        api: APIable,
        completionHandler: @escaping ((Result<Data, NetworkError>) -> Void
    )
    ```

## 이번 프로젝트를 통해 나는...
### 오동건 (DonggeonOh)
 효율적으로 협업하는 방법과 다른 개발자들과의 커뮤니케이션 능력을 향상시킬 수 있었습니다.
 
커뮤니케이션의 경우 프로젝트를 하기 이전에는 의견을 전달 할 때 논리적이지 못했다면 이제는 근거를 들어 객관적인 설명을 할 수 있게 되었습니다.

 그리고 프로젝트를 하면서 겪었던 문제들을 팀원들과 고민해보기도 하였고 목표했던 기능도 다 만들 수 있어서 좋았습니다.
 
 마지막으로 개인적인 목표가 있었는데 (메서드 10줄 이내 작성, 코드 들여쓰기 2번 이상 금지) 개발을 하면서 지켜지기 힘든 부분이여서 아쉬웠습니다.

### 김진영 (z3rosmith)
 PR을 통한 코드리뷰가 처음이었는데, 처음에는 팀원의 코드를 이해하기가 쉽지는 않았지만, 서로 물어보고 답변하면서 코드를 이해하게 되는 과정에서 나중에는 따로 코드리뷰 없이도 서로의 코드를 좀더 쉽게 파악하게 될 수 있었습니다.
 
 빗썸 테크캠프 사전과제 이후 두번째로 diffable data source를 써보는 것이었는데 데이터의 변화에 대해 신경을 덜 쓰고 통째로 apply하는 편함이 있었지만, 예상치 못했고 해결도 어려웠던 버그(현재 보이는 셀 밖에서 데이터가 변할때 스크롤이 무작위로 튀는 버그)가 생겼어서 이 부분에서는 또 어려움을 느꼈습니다. 무언가 편해보이는 것도 장단점이 있다는 것을 배웠습니다.


### 황제하 (허황)
 프로젝트를 하기 전까지 Git-flow 전략을 사용해서 협업을 진행해 본 경험 없었는데 이번 프로젝트를 진행하면서 진짜 협업이 무엇인가 느끼는 좋은 경험을 했습니다.
 
 또, 프로젝트 진행 중 문제가 생겼을 때 서로 토론하면서 커뮤니케이션 할 때의 자세에 대해서 배웠습니다.
 
 이번 프로젝트를 통해서 기술적인 성장 뿐 아니라 소프트 스킬도 같이 성잘할 수 있었습니다.



## 트러블 슈팅
### [Network](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-Network)
### [Core Data](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-Core-Data)
### [코인 리스트 (메인 화면)](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-%EC%BD%94%EC%9D%B8-%EB%A6%AC%EC%8A%A4%ED%8A%B8)
### [코인 상세 화면](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%08%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-%EC%BD%94%EC%9D%B8-%EC%83%81%EC%84%B8)
### [코인 차트 화면](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-%EC%BD%94%EC%9D%B8-%EC%83%81%EC%84%B8-%EC%B0%A8%ED%8A%B8)
### [코인 호가 화면](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-%EC%BD%94%EC%9D%B8-%EC%83%81%EC%84%B8-%ED%98%B8%EA%B0%80)
### [입출금 현황 화면](https://github.com/DonggeonOh/bithumb-techcamp-ios-1st/wiki/%ED%8A%B8%EB%9F%AC%EB%B8%94-%EC%8A%88%ED%8C%85-%EC%9E%85%EC%B6%9C%EA%B8%88-%ED%98%84%ED%99%A9)
