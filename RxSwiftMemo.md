# RxSwift 학습 개인메모 

<br> 

### RxSwift 학습 전 숙지사항 

- Swift Language -> Functional Programming / Protocol Oriented Programming -> RxSwift 
- 학습난이도가 비교적 있는 편
- Observer, Subject, Driver 등의 사용을 위해선 기본적인 Swift 문법은 숙지되어있어야 한다. 

### RxSwift란?

- ReactiveX 라이브러리를 Swift로 구현한 것으로, Observable Stream을 이용한 비동기 API이다.

### 왜 RxSwift를 사용하는가?

- Key Value Observing, Notifications 등, 다양한 상황에서의 구현을 간결하게 표현할 수 있음.
- **보다 단순하고 직관적인 코드를 작성할 수 있음**

### Observable 

- Observable은 이벤트를 전달한다. 
- Next : 방출, Emission (Observer, Subscriber로 전달)
- Error : 에러 발생시 전달, Observable 주기 끝에 실행, Notification
- Completed : 성공적으로 실행 시 전달, Observable 주기 끝에 실행, Notification
-  **Observable은 error, completed이벤트를 전달한 뒤엔 더이상 이벤트를 전달하지 않는다.**
  - **Observable을 영원히 실행할 목적이 아니라면, onError, onComplted 둘 중 하나는 꼭 처리**해주어 Observable의 동작이 종료될 수 있도록 해야 한다.

### Observer

- Observer를 Subscriber라고도 부른다. 
- Observable을 감시하고 있다가 전달되는 이벤트를 처리한다.
- 이때 Observable을 감시하고 있는 것을 Subscribe라고 한다. 

- * Marble Diagram을 통해 다양한 RxMarble의 작동 과정을 확인 할 수 있다.
    - RxSwift를 공부할 때 큰 도움이 됨



<br>
<br>



## Observable의 생성

~~~ Swift
/// MARK: - Observable의 생성
// Observable을 생성하는 방법은 2가지 방법이 있다.
// * 1번째 방법
// create : Observable 타입 프로토콜에 선언되어있는 타입 메서드, Operator라고도 한다.
// - Observer를 인자로 받아 Disposable을 반환한다 .
Observable<Int>.create { (observer) -> Disposable in
    // observer애서 on 메서드를 호출하고, 구독자로 0이 저장되어있는 next 이벤트가 전달된다.
    observer.on(.next(0))
    
    // 1이 저장되어있는 next 이벤트가 전달된다.
    observer.onNext(1)
    
    // completed이벤트가 전달되고 Observable이 종료된다. 이후 다른 이벤트를 전달할 수는 없다.
    observer.onCompleted()
    
    // Disposables 는 메모리 정리에 필요한 객체이다.
    return Disposables.create()
}

// * 2번째 방법
// from 연산자는 파라미터(인자값)으로 전달받은 값을 순서대로 방출하고 Completed Event를 전달하는 Observable을 생성한다.
// 이처럼 create 이외로도 상황에 따른 다양한 Operator 사용이 가능한다.
Observable.from([0, 1])

// 이벤트 전달 시점은 언제? -> Observer가 Observable을 구독하는 시점에 Next이벤트를 통해 방출 및 Completed이벤트가 전달된다.
~~~

<br>
<br>

## 옵저버의 구독

- 1) 하나의 클로져를 통해 모든 이벤트를 처리하고자 할때는 아래와 같이 구독을 사용할 수 있다


~~~ Swift
import RxSwift
import RxCocoa
observer.subscribe {
    // * subscribe 클로져 내 "== Start ==" 가 연달아 "== End ==" 없이 두번 호출되는 경우는 없다.
    print("== Start ==")
    print($0)
    // 순수 값을 추출하여 출력할 수 있으며, Optional이므로 Optioanl Binding이 필요하다.
    if let value = $0.element {
        print($0)
    }
    print("== End ==")
}

print("===========================")
// 2) 세부적인 구독 처리도 가능
// '$0.element' 같은 방식으로 접근 할 필요 없이 onNext: 클로져 인자값을 통해 element에 바로 접근할 수 있다.
observer.subscribe(onNext: { (element) in
    // 순수 element 값만 출력 되는 것을 확인할 수 있다.
    print(element)
})
~~~

<br>
<br>

## Disposable

- Disposed는 Observer가 전달하는 이벤트가 아니다. 
- 리소스가 해제되는 시점에 자동으로 호출되는 것이 Disposed이다.
  - 하지만, RxSwift 공식 문서에 따르면 Disposed를 정리/명시 해줄 것을 권고한다. 가능한 따르는 것이 좋을 것이다.

<br>

~~~ swift
import RxCocoa
import RxSwift

// 1씩 증가하는 정수를 1초간격으로 출력하는 Observable
// 해당 작업의 종료를 위해서는 Dispose 처리가 필요하다.
let subscription2 = Observable<Int>.interval(.seconds(1),
                                              scheduler: MainScheduler.instance)
.subscribe(onNext: { element in
    // Emmission
    // "Next 1~3" 이 출력
    print("Next",element)
}, onError: { (error) in
    // Notification
    print("Error",error)
}, onCompleted: {
    // Notification
    // Observable 완료 시 실행
    print("Completed")
    
    // Disposed는 Observable이 전달하는 이벤트는 아니다. Observable과 관련된 모든 리소스가 제거된 뒤 호출이 된다.
}) {
    print("Disposed")
}

// Disposable의 dispose() 메서드를 통해 3초 가 지나면 해당 Observable을 Dispose 처리한다.
// 해당 기능은 take, until 등의 Operator 등을 통해서도 구현할 수 있다. 
// 0, 1, 2까지만 출력됨
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    subscription2.dispose()
}

~~~

<br>

### Subscription Disposable

- Observer 구독시 사용하는 메서드, **subscribe의 반환형은 Disposable(Subscription Disposable)**이다. 
- 크게 리소스 해제와 실행 취소에 사용하는 것이 Subscription Disposable이다.



<br><br>

## DisposeBag

- subscription 시 반환되는 Disposable들을 담는 가방

~~~ swift
import RxSwift
import RxCocoa

var disposeBag = DisposeBag()

// Disposed는 옵저버가 전달하는 이벤트가 아니다.
// -> 리소스가 해제되는 시점에 자동으로 호출되는 것이 Disposed이다.
// * 하지만, RxSwift 공식 문서에서는 Disposed를 정리/명시해줄 것을 권고한다. -> 가능한 따르는 것이 좋음.
Observable.from([1,2,3])
    .subscribe {
        print($0)
}.disposed(by: disposeBag)
// - 위와 같이 disposed(by: bag) 식으로 DisposeBag을 사용할 수 있다.
// - 해당 subscription에서 반환되는 Disposable은 bag(DisposeBag)에 추가된다.
// - 이렇게 추가된 Disposable 들은 DisposeBag이 해제되는 시점에 함께 헤제되게 된다.

// 새로운 DisposeBag()으로 초기화하면 이전까지 담겨있던 Disposable들은 함께 헤제된다.
disposeBag = DisposeBag()
~~~

<br>



## Operator, 연산자

- RxSwift에서 자주 사용 되는 연산자(Operator)
- RxSwift가 제공하는 여러가지 타입 중, ObservableType Protocol이 있다 
  - RxSwift의 근간을 이루는 여러가지 기능이 담겨 있는데 이들을 Operator, 연산자라 한다. 

<br>

### 연산자의 특징

- 대부분의연산자는 Observable상에서 동작하며, Observable을 리턴한다. 
- Observable을 리턴하기 때문의 두개 이상의 다수의 Operator를 동시에 사용할 수 있다. 

~~~ swift
/// MARK: - 연산자의 사용 예시
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

// Operator 중 하나인 take(N)는 Observable이 방출하는 요소 중에서 처음부터 N개의 요소만 전달해주는 연산자이다.
// Operator 중 하나인 filter는 특정 요건을 충족한 요소만 필터링하여 전달해주는 연산자이다.
// 아래 코드는 take(N), filter Operator를 사용하여 1~5번째 까지의 요소 중 2의 배수만 필터링하여 전달해주는 과정이다.
Observable.from([1,2,3,4,5,6,7,8,9])
.take(5)
    .filter { $0.isMultiple(of: 2) }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// 위에서 사용한 take, filter 연산자 처럼 연산자를 필요에 따라 불여서 다수 사용이 가능하다.
// * 단, 연산자의 실행 순서에 따라 결과가 달라질 수 있음에 주의해야 한다.
~~~

<br><br>

### 연산자 종류 

- just 

  - 하나의 항목을 방출하는 Observable을 생성 

    ~~~ swift
    // Operator, just 사용 예시
    import UIKit
    import RxSwift
    
    let disposeBag = DisposeBag()
    let element = "😃"
    
    // element 항목을 방출하는 Observable 생성
    Observable.just(element)
      .subscribe { event in print(event) }
      .disposed(by: disposeBag)
    // 출력 예시)
    // next(😃) 
    // completed
    
    Observable.just([1,2,3])
    .subscribe { event in print(event) }
    .disposed(by: disposeBag)
    // 출력 예시)
    // next([1,2,3])
    // completed
    ~~~

- of

  - 배열을 차례대로 방출하는 Observable 생성

    ~~~ swift
    import RxSwift
    Observable.if(1, 2, 3) 
    .subscribe { element in print(element) }
    .disposed(by: disposeBag)
    // 출력 예시)
    // next(1)
    // next(3)
    // next(3)
    // completed
    ~~~

    

  

- from

  - 배열에 포함된 요소를 하나씩 순서대로 방출하는 Observable 생성 

    ~~~ swift
    import RxSwift
    
    let arr = [1,2,3]
    Observable.from(arr)
    .subscribe { element in print(element) }
    .disposed(by: disposeBag)
    // 출력 예시)
    // next(1)
    // next(2)
    // next(3)
    // completed
    ~~~

- range

  -  range(start: 1, count: 10) -> 1부터 시작에서 1씩 증가한 정수가 방출 된 뒤 complted 이벤트가 전달

  -  range는 특정 값으로부터 증가시키면 특정 반복 방출을 실행하나 중간에 증가된 크기를 바꾸거나 감소하는 시퀀스는 생성 불가

    - -> 이때는 대신 generate 를 사용한다.

    ~~~swift
    import RxSwift
    import RxCocoa
    let disposebag = DisposeBag()
    // 1 ... 10 의 Int 값 방출
    Observable.range(start: 1, count: 10)
    .subscribe { print($0) }
    .dispoesd(by: disposeBag)
    ~~~

- generate 

  - range 보다 세부적인 sequence tasking 작업이 가능

  - 세부적인 작업을 위한 parameter가 존재 

    - initialState : 시작값을 전달
    - condition : true르 리턴할때만 방출 아니면 complted 이벤트를 전달 및 종료
    - scheduler: scheduler 설정
    - iterate : 보통 값을 증가, 감소 시키는 등의 코드를 전달

    ~~~swift
    import RxSwift
    import RxCocoa
    import UIKit
    
    let disposeBag = DisposeBag()
    let red = "🍎"
    let blue = "🥶"
    
    Observable.generate(initialState: 10, condition: { $0 >= 0 }, iterate: { $0 - 2 })
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    Observable.generate(initialState: red, condition: { $0.count < 15 }, iterate: { $0.count.isMultiple(of: 2) ? $0+red : $0+blue})
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    ~~~

- defered

  - 특정 조건에 따라 Observable을 생성할 수 있게 해주는 Operator

  - deferred 연산자를 사용하면 특정조건 (Condition)에 따라 Observable을 생성 시킬 수 있다.

    ~~~swift
    /// MARK: - Deferred
    import UIKit
    import RxSwift
    
    let disposeBag = DisposeBag()
    let poker = ["❤️", "♦️", "♠️", "☘️"]
    let emoji = ["😃", "😂", "🎃", "💀"]
    var flag = true
    
    // 문자열을 방출하는 Observable, factory
    let factory: Observable<String> = Observable.deferred {
        flag.toggle() // toggle() 실행으로 true -> false로 flag값 변환
        
        if flag {
            return Observable.from(poker)
        } else { // flag == false로 emoji String이 순차적으로 from operator에 의해 방출
            return Observable.from(emoji)
        }
    }
    
    factory
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    ~~~

    

- create

  - create 연산자는 사용 할 Observable의 동작을 직접 구현하고자 할 때 사용할 수 있다.

    ~~~swift
    /// MARK: - Operator; Craete
    //  - create 연산자는 Observable의 동작을 직접 구현하고자 할 때 사용할 수 있다.
    import UIKit
    import RxSwift
    
    let disposeBag = DisposeBag()
    
    enum MyError: Error {
        case error
    }
    
    // Obervable을 파라미터로 받아서 disposable을 반환하는 클로져를 전달
    Observable<String>.create { (observer) -> Disposable in
        guard let url = URL(string: "https://www.apple.com") else {
            // Error 발생 시 Error이벤트를 전달하고 종료 -> error(error)
            observer.onError(MyError.error) // 구독자에게 Error가 전달
            // * Disposable.craete()가 아닌 Disposables.create()로 사용해야 한다.
            return Disposables.create()
        }
        // url을 접근한 뒤 html을 가져와 문자열을 저장한다.
        guard let html = try? String(contentsOf: url, encoding: .utf8) else {
            // Error 발생 시 Error이벤트를 전달하고 종료 -> error(error)
            observer.onError(MyError.error)
            return Disposables.create()
        }
        
        // 문자열 생성이 정상적으로 진행되었다면, 해당 Observable을 방출
        observer.onNext(html)
        observer.onNext("Will Be Completed")
        observer.onCompleted()
        
        // ✭ Observable은 error, completed이벤트를 전달한 뒤엔 더이상 이벤트를 전달하지 않는다.
        // Observable을 영원히 실행할 목적이 아니라면, onError, onComplted 둘 중 하나는 꼭 처리해주어 Observable의 동작이 종료될 수 있도록 해야 한다.
        observer.onNext("After Completed")
        return Disposables.create()
    }
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    ~~~

- empty 

  - 어떠한 요소도 방출하지 않는 Operator
  - 어떠한 동작도 진행않고 종료하고자 할 때 사용할 수 있다. 

  ~~~ swift
  /// MARK: - Empty, Error
  //  - 어떠한 요소도 방출하지 않는 Operator, Empty/Error
  
  import UIKit
  import RxSwift
  
  let disposeBag = DisposeBag()
  
  /// MARK: empty
  //  - 요소의 형식은 중요하지 않다. 요소를 방출하지 않기 때문이다.
  //  - 옵저버가 아무런 동작없이 종료해야할 때 사용할 수 있다.
  Observable<Void>.empty()
      .subscribe { print($0) }
      .disposed(by: disposedBag)
  ~~~



- error

  - 지정한 Error 이벤트를 전달하고 종료하는 Observable을 생성한다.
  - Error처리를 할때 사용한다.

  ~~~swift
  /// MARK: - Operator; Error
  import UIKit
  import RxSwift
  
  let disposeBag = DisposeBag()
  
  enum MyError: Error {
      case error
  }
  
  // - error이벤트를 전달하고 종료하는 Observable을 생성한다.
  // - Error처리를 할때 사용한다.
  Observable<Void>.error(MyError.error)
      .subscribe {. rint($0) }
      .disposed(by: disposeBag)
  // 해당 Observable은 error 이벤트가 전달되고 종료된다.
  
  ~~~

  

<br><br>




# Subject 

- Observable인 동시에 Observer

### Subject 종류

- PublishSubject
  - Subject로 전달되는 새로운 이벤트를 구독자에게 전달
- BehaviorSubject
  - 생성시점에 시작이벤트를 지정, 가장 마지막 전달된 최신이벤트를 전달해두었다가 새로운 구독자에게 전달
- ReplaySubject
  - 하나 이상의 최신 이벤트를 버퍼에 저장한다. 
  - -> 옵저버가 구독을 시작하면 버퍼에 있는 모든이벤트를 전달 
- AsyncSubject
  - Subject로 completed 이벤트가 전달되는 시점에 마지막으로 전달된 next 이벤트를 구독자로 전달한다. 

#### Subject Relay

- Relay 이벤트는 next 이벤트만 받고 completed, error 이벤트는 받지 않는다. 

- 주로 종료 없이 계속적으로 실행되는 이벤트를 처리할때 사용한다. 

- PublishRelay

  - Publish Subject를 랩핑한 것

- BehaviorRelay

  - Behavior Subject를 랩핑한 것

  

### PublishSubject

- Subject로 전달되는 이벤트를 옵저버로 전달하는 가장 기본적인 Subject 
- 최초로 생성되는 시점 ~ 첫 구독이 시작되는 시기 사이에는 이벤트가 처리되지않고 사라진다.
  - 만약 이벤트가 사라지는것이 문제가 된다면? -> ReplaySubject, ColdObservable을 사용한다.

~~~ swift
/// MARK: -Subject 사용 예시)
import UIKit
import RxSwift
import RxCocoa

/// MARK: Observable : 이벤트를 전달
/// MARK: Observer : Observable을 구독하고, 전달받은 이벤트를 처리

let disposeBag = DisposeBag()
enum MyError: Error {
    case error
}

// PublishSubject는 처음 생성 당시 저장하고 있는 이벤트가 없다.
// Subject는 Observable이자, Observer이다.
let subject = PublishSubject<String>()

// subject로 Next이벤트가 전달, 구독하고있는 옵저버가 없으므로 처리되지 않고 사라진다.
// Hello 출력 x
subject.onNext("Hello")

// publish Subject는 구독이후에 전달되는 새로운 이벤트만 구독자에게 전달한다.
// 구독자가 구독하기 전의 생성된 이벤트는 전달되지 않는다.
// 들어온 값에 대한 ">> 1 ~~~~" 출력을 실행하는 subject를 구독한 observer
let observer = subject.subscribe { print(">> 1", $0) }
observer.disposed(by: disposeBag)

subject.onNext("RxSwift")

// observer가 subject를 구독한 이후의 onNext 이벤트에 대해 처리가 된다. 이전의 onNext처리("Hello")는 x
// 들어온 값에 대한 ">> 2 ~~~~" 출력을 실행하는 subject를 구독한 observer2
let observer2 = subject.subscribe { print(">> 2", $0) }
observer2.disposed(by: disposeBag)

subject.onNext("Subject")
// >>1, >>2 둘다 completed() 처리

//subject.onCompleted()
subject.onError(MyError.error)

// completed(), onError() 등의 처리 이후, 해당 Subject의 새로운 구독자가 발생시, 해당 새로운 구독자, observer3에게도 해당 이벤트가 전달된다.
let observer3 = subject.subscribe { print(">> 3", $0) }
observer.disposed(by: disposeBag)

// * 최초로 생성되는 시점 ~ 첫 구독이 시작되는 시기 사이에는 이벤트가 처리되지않고 사라진다.
// -> 만약 이벤트가 사라지는것이 문제가 된다면? ReplaySubject, ColdObservable을 사용한다.

~~~

<BR>



### BehaviorSubject

- BehaviorSubject는 PublishSubject와 달리, 초기값이 존재한다.

- 초기 생성된 생성값, 새로운 구독자가 생기는 순간 이벤트가 바로 전달된다.
- 새로운 구독자가 발생할 경우 BehaviorSubject는 가장 최신의 이벤트를 전달한다.
  - 즉, BehaviorSubject는 구독자가 구독시 가장 최신의 이벤트만을 전달한다.



~~~ swift
/// MARK: - Behavior Subject
import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

enum Myerror: Error {
    case error
}

// PublishSubject는 내부 이벤트가 비어있는 상태로 생성된다.
let p = PublishSubject<Int>()
p.subscribe { print("PublishSubject >>", $0) }
    .disposed(by: disposeBag)

// BehaviorSubject는 PublishSubject와 달리, 초기값이 존재한다.
// 초기 생성된 생성값, 새로운 구독자가 생기는 순간 이벤트가 바로 전달된다.
let b = BehaviorSubject<Int>(value: 0)
b.subscribe { print("BehaciorSubject >>", $0) }
    .disposed(by: disposeBag)
// 새로운 Next이벤트에 대해서도 구독자들에게 이벤트를 전달한다.
b.onNext(1)

// 새로운 구독자가 발생할 경우 BehaviorSubject는 가장 최신의 이벤트를 전달한다.
// 새로운 구독자가 BehaviorSubject를 구독 시 가장 최신 이벤트(1)를 전달 받게 된다.
b.subscribe { print("BehaviorSubject2 >>", $0) }
.disposed(by: disposeBag)

//b.onCompleted()
b.onError(MyError.error)

// completed(), onError() 처리 이후, 새로운 BehaviorSubject 구독자가 생길 시, 해당 구독자의 next 이벤트는 실행되지 않고, completed(), onError() 처리 된다.
b.subscribe { print("BehaviorSubject3 >>", $0) }
.disposed(by: disposeBag)

~~~

<br>



### ReplaySubject

- BehavoirSubject가 구독자에게 단 하나의 최신 이벤트를 전달하는 반면, ReplaySubject는 구독자 구독 시, 특정 버퍼 크기의 최신 이벤트를 모두 구독자에게 전달할 수 있다. 
- ReplaySubject는 종료 여부에 관계없이 구독자들에게 버퍼에 저장되어있는 이벤트를 새로운 구독자에게 전달한다.
- 필요이상의 불필요한 퍼버 할당은 지양해야 한다. 

~~~ swift
/// MARK: - Replay Subject
import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

enum MyError: Error {
    case error
}

// Buffer Size가 3인 ReplaySubject를 생성한다. 구독자 구독 시 최신 최대 3개의 이벤트를 전달할 수 있다.
let replaySubject = ReplaySubject<Int>.create(bufferSize: 3)

// ReplaySubject에 1~10의 값을 차례대로 next처리한다. 버퍼사이즈는 3이므로 최대 3개의 이벤트만을 저장할 수 있다.
(1...10).forEach { replaySubject.onNext($0) }

// 구독자가 해당 ReplaySubject를 구독 시, 최신 이벤트인 8,9,10이 출력된다.
replaySubject.subscribe { print("Observer 1 >>", $0) }
.disposed(by: disposeBag)

// 새로운 구독이 발생해도 동일한 이벤트, 8,9,10을 전달받는다.
replaySubject.subscribe { print("Observer 2 >>", $0) }
.disposed(by: disposeBag)

// ReplaySubject에 새로운 이벤트를 전달하면, 구독자들에게도 전달된다. (다른 Subject들도 동일)
replaySubject.onNext(11)

// 11 이벤트를 전달 받은 버퍼크기 3의 ReplaySubject는 9,10,11 값을 갖게 되므로 이후 새로운 구독자들이 구독 시, 9,10,11이 전달된다.
replaySubject.subscribe { print("Observer 3 >>", $0) }
    .disposed(by: disposeBag)

replaySubject.onCompleted()
//rs.onError(MyError.error)

// * ReplaySubject는 종료 여부에 관계없이 구독자들에게 버퍼에 저장되어있는 이벤트를 새로운 구독자에게 전달한다.
replaySubject.subscribe { print("Observer 4 >>", $0) }
.disposed(by: disposeBag)

~~~

<br><br>



### AsyncSubject

- 다른 Subject와 이벤트 전달 시점의 차이가 있다. 
- Completed 이벤트가 전달되기 전 까지는 어떠한 이벤트도 구독자에게 전달하지 않는다.
- Completed 이벤트 전달 시 구독자에게 가장 최신의 Subject 이벤트를 전달한다. 
  - 만약 subject가 이전까지 전달받은 이벤트가 없다면 별도의 이벤트 없이 completed 만 처리된다.
  - Completed이벤트 전달 받기 전 Error 이벤트를 전달받으면 별도의 이벤트는 구독자들에게 전달되지 않는다. 

~~~ swift
/// MARK: - Async Subject
import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

enum MyError: Error {
    case error
}

let subject = AsyncSubject<Int>()
subject
    .subscribe { print($0) }
.disposed(by: disposeBag)

// 아직 AsyncSubject로 completed 이벤트가 전달되지 않았으므로, 하단의 onNext(1...3) 이벤트는 구독자에게 전달되지 않는다.
subject.onNext(1)
subject.onNext(2)
subject.onNext(3)

// AsyncSubject에 completed 이벤트가 전달되는 순간의 가장 최신 이벤트를 구독자들에게 전달한다.
// 가장 최신 이벤트인 '3'이 구독자에게 전달된다.
//subject.onCompleted()

// error 이벤트 전달 시, completed이벤트를 전달받지 못했으므로 별도의 이벤트는 구독자에게 전달되지 않는다.
subject.onError(MyError.error)

~~~

<br>

### Subject Relays

- RxSwift는 두개의 Subject Relays를 제공한다. (RxCocoa 프레임워크를 통해 제공)
  - PublishRelay, BehaviorRelay
- 일반적인 Subject와의 가장 큰 차이점은 **SubjectRelay는 Next이벤트만을 전달**한다는 것이다.
  - SubjectRelay(PublishRelay, BehaviorRelay)는 Completed, Error 이벤트는 전달받지도 전달하지도 않는다. 
- 구독자가 Disposed 되기 전까지 종료없이 계속 이벤트를 처리한다 .
- Subject Replay는 주로 UI 이벤트 처리에 활용된다.

~~~ swift
/// MARK: - Async Subject
import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

// PublishRelay의 생성방식은 PublishSubject와 동일하다.
let publishRelay = PublishRelay<Int>()

publishRelay.subscribe { print("1: \($0)") }
.disposed(by: disposeBag)

// SubjectRelay는 onNext메서드 대신 accept 메서드를 지원한다.
publishRelay.accept(1)

// BehaviorRelay의 BehaviorSubject와 생성 방식은 동일하다.
let behaviorRelay = BehaviorRelay(value: 1)
behaviorRelay.accept(2)
// BehavoirRelay의 가장 최근 이벤트인 '2'가 구독자에게 전달된다.
behaviorRelay.subscribe {
    print("2: \($0)")
}.disposed(by: disposeBag)

// BehaviorRelay에 새로운 이벤트가 전달 될 때마다 구독자에게 최신 이벤트 1개가 전달된다.
// BehaviorSubject와의 차이점은 Completed, Error 이벤트 전달받기/전달하기를 하냐, 안하냐 차이
behaviorRelay.accept(3)

~~~

<br><br>



## Scheduler

- 일반적으로는 스레드처리에 GCD를 사용하는데 RxSwift에서는 Scheduler를 사용한다. 
- 추상형 Context, 큰 그림으로 보면 GCD와 유사하고 규칙에따라 Scheduler를 사용하면 된다. 

#### Scheduler의 사용

- UI를 처리할때 GCD는 Main Queue를 사용했다면, Rx에선 MainScheduler를 사용

- 백그라운드 처리 시 GCD는 Global Queue를 사용했다면, Rx에서 BackgroundScheduler를 사용

- Serial Scheduler 

  - CurrentThreadScheduler : 기본적 스케쥴러
  - MainScheduler : UI처리 시 메인스레드 동작을 위해 사용
  - SerialDispatchQueueScheduler

- Concurrent Scheduler

  - ConcurrentDispatchQueueScheduler
  - OperationQueueScheduler : GCD가 아닌 OperationQueue를 사용

- Test Scheduler : 테스트 목적의 스케쥴러

- Custom Scheduler : 사용자 정의 스케쥴러

- Scheduler, observeOn, subscribeOn 활용 예시)

  ~~~swift 
  import UIKit
  import RxSwift
  import RxCocoa
  
  // * 옵저버블이 생성되고 연산자가 호출되는 시점은 구독이 시작된 시점이 된다.
  let disposeBag = DisposeBag()
  
  // Background Scheduler의 지정
  let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
  
  Observable.of(1,2,3,4,5,6,7,8,9,0)
      .filter { num -> Bool in
          print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> filter")
          return num.isMultiple(of: 2) // of에서 방출하는 Observable 요소 중 2의 배수만을 필터링 한다.
  } // map Operator를 background Scheduler로 동작하게 한다.
  .observeOn(backgroundScheduler) // map연산자 이후에는 background Thread에서 동작함을 출력 결과를 통해 알 수 있다.
  .map { num -> Int in
      print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> map")
      return num * 2 // 걸러진 짝수 값들을 각각 2배씩 맵핑처리한다. 이후 값들은 4,8,12,16 이 될 것이다.
  }
  //.subscribeOn(MainScheduler.instance) // subscrobeOn(MainScheduler.instance)는 Observable이 시작하는 시점에 어떤 스케쥴러를 사용할 지를 지정하는 것이다. 또한 호출하는 시점이 자유롭다. 
  .observeOn(MainScheduler.instance) //-> 만약 하단의 subscribe시점에 스케쥴러를 지정하려면 subscribeOn대신, ovserveOn을 사용하면 된다.
  .subscribe {
      print(Thread.isMainThread ? "Main Thread" : "Background Thread", ">> subscribe")
      print($0)
  }
  .disposed(by: disposeBag)
  ~~~

  

#### ObserveOn

- 이어지는 작업에 대해 사용할 스레드를 지정하는데 사용할 수 있다. 

  ~~~swift
  .observeOn(backgroundScheduler)
  ~~~

#### SubscribeOn

- Observable이 시작하는 시점에 어떤 스케쥴러를 사용할 지를 지정한다.

  - subscrobeOn(MainScheduler.instance)는 해당 시점에 메인스케쥴러를 사용하는 것이 아님 -> 이때는  observeOn을 사용함

- 호출하는 시점이 자유롭다. (맨 위에 지정하나, 중간에 지정하나 본인의 역할에는 상관없음) 

  - 만약 하단의 subscribe시점에 스케쥴러를 지정하려면 subscribeOn대신, observeOn을 사용하면 된다.

  ~~~swift
  .subscribeOn(MainScheduler.instance)
  ~~~

<br><br>
