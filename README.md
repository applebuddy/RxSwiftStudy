# 곰튀김 RxSwift 스터디 정리

RxSwift의 입문 공부 기록

<br>

## 개요

iOS 프로개발자이신 곰튀김님이 제공하는 RXSwift 4시간안에 끝내기 강의를 통해 RxSwift의 기본을 배우고 기록합니다.

<br>
<br>

### Model

### ReactiveX, RxSwift란? 
* An API for asynchronous programming with observable streams, 감시 스트림을 사용한 비동기 프로그래밍 API

#### ReactiveX는 어디서 처음 만들었는가? 
- MS에서 처음 만들었다.

#### RxSwift의 요소 
- Observable : 제일 중요한 기능, 이것만 알면 다 쓸 수 있다.
- Operators : 이걸 쓰면 좀더 효율적으로 구현 가능
- Scheduler  : 여러군데 활용이 가능
- Subject  : 무언가 만들 수 있음
- Single : 가장 중요하지 않음

* Reactivex.io 홈페이지 내 Resources -> Tutorial 을 활용하면 RxSwift 학습자료를 찾아볼 수 있음

#### RxSwift를 공부하기 전 알아야 할 지식, 비동기(Asynchronization)
* DispatchQueue에는 크게 sync, async 두가지가 있음. 더 세부적으로 보자면..
- Concurrency async
- Concurrency sync
- Serial async
- Serial sync 
총 네가지 분류를 해볼 수 있다.

* Async한 코드를 보다 간결하게 표현할 수 있는 방법이 바로 RxSwift이다.
* 비동기 구현내용이 간단할때는 RxSwift와 일반 코드의 차이를 느끼기 힘들다. 
* 보다 복잡한 구현이 이루어질때 RxSwift가 진가를 발휘한다.
* 기존 iOS에서 제공하는 Promise kit vs RxSwift 둘다 구현은 가능하다. 하지만 간결함의 차이가 난다.



# RxSwift 4시간에 끝내기

![](docs/rxswift_in_4_hours_logo.png)

<br/>

## Preface

요즘 관심이 높은 RxSwift!

RxSwift는 Swift에 ReactiveX를 적용시켜 비동기 프로그래밍을 직관적으로 작성할 수 있도록 도와주는 **라이브러리**입니다. 

즉, RxSwift는 도구입니다. 하지만 높은 러닝커브에 쉽게 접근하지 못하는 분이 많습니다.<br/>
도구를 이용하려고 배우고 노력하는 시간이 너무 큰 것은 배보다 배꼽이 더 큰 격입니다.<br/>
RxSwift의 근본적인 학습 자체보다는, 빠르게 사용법을 익혀 프로젝트에 적용하는 것이 *현실주의 프로그래머들에게는* 더 중요합니다.

<br/>

## Contents

### 1. 개념잡기

#### 동기/비동기
- Blocking / Non-Blocking
	- Sync / Async
	- Thread, Concurrent, Parallel
	- [Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
	- pthread, Thread, Operation, OperationQueue, GCD
- Async Result 의 처리
	- Closure Callback
	- Delegate
	- 나중에 Wrapper

#### 나중에 Wrapper
- [PromiseKit](https://github.com/mxcl/PromiseKit)
- [Bolts](https://github.com/BoltsFramework/Bolts-Swift)
- [RxSwift](https://github.com/ReactiveX/RxSwift)

<br/>
	
### 2. 기본 사용법

#### Observable
- Observable `create`
- subscribe 로 데이터 사용
- Disposable 로 작업 취소
- stream의 life-cycle
	- Subscribed
	- Next
	- Completed / Error
	- Disposabled

<br/>

### 3. Sugar API

#### Operators
- 간단한 생성 : `just`, `from`
- 필터링 : `filter`, `take`
- 데이터 변형 : `map`, `flatMap`
- 그 외 : [A Decision Tree of Observable Operators](http://reactivex.io/documentation/ko/operators.html)
- Marble Diagram
  - [http://rxmarbles.com/](http://rxmarbles.com/)
  - [http://reactivex.io/documentation/operators.html](http://reactivex.io/documentation/operators.html)
  - [https://itunes.apple.com/us/app/rxmarbles/id1087272442?mt=8](https://itunes.apple.com/us/app/rxmarbles/id1087272442?mt=8)

#### Schedulers
- DispatchQueue
- `observeOn`, `subscribeOn`

#### Subject
- Data Control
- Hot Observable / Cold Observable

<br/>

### 4. RxCocoa

- UI 작업의 특징
- Observable / Driver
- Subject / Relay

<br/>

### 5. Extension

- [RxViewController](https://github.com/devxoul/RxViewController)
- [RxOptional](https://github.com/RxSwiftCommunity/RxOptional)
- [RxExtension](https://github.com/tokijh/RxSwiftExtensions)
- [RxSwift Community Projects](https://community.rxswift.org/)
<br/><br/>
- [methodInvoked Example](https://gist.github.com/iamchiwon/bd200395a0d0ced65d91d0fa7abe54cb)
- [DelegateProxy example](https://gist.github.com/iamchiwon/f007d67c8365b612daa99d6f19ad3992)

<br/>

### 6. Test

- [RxBlocking](https://github.com/ReactiveX/RxSwift/tree/master/RxBlocking)
- [RxTest](https://github.com/ReactiveX/RxSwift/tree/master/RxTest)
- [Video] [Testing an operator with TestScheduler - RxSwift](https://www.youtube.com/watch?v=HKigVK1eqwE)
- [Video] [Understanding RxSwift using RxTests — Yvette Cook](https://www.youtube.com/watch?v=FgbTenGH-P0)
- [Article] [Testing Your RxSwift Code](https://www.raywenderlich.com/7408-testing-your-rxswift-code)

<br/>

## References

- [Official] [ReactiveX](http://reactivex.io/)
- [Video] [RxSwift 4시간에 끝내기](https://www.youtube.com/watch?v=w5Qmie-GbiA&index=1&list=PL03rJBlpwTaAh5zfc8KWALc3ADgugJwjq)<br/>
  ![]()
  [![오프라인 모임 종햡편](https://img.youtube.com/vi/w5Qmie-GbiA/0.jpg)](https://www.youtube.com/watch?v=w5Qmie-GbiA&index=1&list=PL03rJBlpwTaAh5zfc8KWALc3ADgugJwjq)
- Unfinished Observable / Memory Leak
	- (참조) [클로져와 메모리 해제 실험](https://iamchiwon.github.io/2018/08/13/closure-mem/)
- [카카오톡 RxSwift 오픈 채팅방](https://open.kakao.com/o/gl2YZjq)

<br/>

## License

![](docs/cc_license.png)
<br />이 저작물은 <a rel="license" href="http://creativecommons.org/licenses/by/2.0/kr/">크리에이티브 커먼즈 저작자표시 2.0 대한민국 라이선스</a>에 따라 이용할 수 있습니다.

<br/>
