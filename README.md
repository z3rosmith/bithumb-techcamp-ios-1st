### 프로젝트 목표

기존 빗썸 Public API를 사용한 앱을 MVC → MVVM으로 RxSwift를 이용해서 리팩토링

### 프로젝트 기간

2022.07 ~

### 기술

- MVVM, RxSwift
- UIKit, Storyboard
- URLSession(REST API, WebSocket)
- Core Data

### 리팩토링 내용

- 앱의 핵심인 메인 화면을 리팩토링
- ViewModel의 Input, Output 프로퍼티를 통해 ViewController와 데이터 교환
- WebSocket을 통해 실시간으로 cell이 업데이트되는 로직을 Observable을 이용해 구현
- Model인 ViewCoin의 조작을 도와주는 CoinController class 생성, 적용

### 메인 화면 아키텍쳐

![](https://user-images.githubusercontent.com/52317025/205429970-893901db-82b5-4bc2-a0d5-a7080200b99e.png)

### 스크린샷

<img src="https://user-images.githubusercontent.com/52317025/205429965-26ddae2a-dfe1-4cc9-88e1-92d9215ed034.png" width="250"/>

- **주요 기능**
    - 코인 목록 표시
        - 빗썸 Public API 사용
        - 아래로 끌어당겨 새로고침 가능
    - 실시간 현재가 업데이트
        - WebSocket 이용
        - 0.5초 동안 UnderLine View 표시
    - 관심 코인 설정
        - 주황색 하트버튼 클릭
        - 셀 왼쪽으로 스와이프
        - CoreData 이용, 관심 코인 목록 데이터 저장 및 불러오기
    - 검색, 정렬 기능
    - 관심/원화 버튼
        - 클릭 시 스크롤 뷰 이동
        - 현재 보고있는 섹션에 따라 밑줄 이동
