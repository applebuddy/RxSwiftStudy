//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Subject

    // - Subject의 종류 : Async Subject, BehaviorSubject, publishSubject, ReplaySubject

    // ❋ Behavior Subject : 스스로 데이터를 발생 가능 + Subscribe 가능 Observable
    // - 최초 SubScribe 이후, Default값으로 상태를 지켜보며 기다리다가 어떤 subscribe가 발생하면 그 Subscribe에 최근 데이터값을 넘겨준다.
    // 해당 Subject가 종료 되면 이후 라는 스트림에서 Subscribe를 해도 해당 Subject는 종료된다.
    // ✓ Bullet View만 상황을 지켜보다가 Enable or Disable 여부를 판단하여 변경할 수 있다.
    // * value: false 는 default 값

    // ❋ Async Subject : 해당 Subject가 종료되는 시점의 맨 마지막 전달된 데이터를 SubScribe한 Stream들에 전달시킨다.

    // ❋ Publish Subject : "최초 Default값이 없다." 데이터가 생성되면 그때 데이터를 전달한다.
    // - 데이터가 생성될 때마다 해당 Subject를 Subscribe한 놈들에게 전부 해당 데이터를 전달한다.

    // ❋ Replay Subject : "최초 Default값이 없다." 데이터가 생성되면 지금까지 생성했던 데이터를 한꺼번에 전달한다.
    // - 마블 3개가 지나간 뒤 다른 Subscribe가 진행되면 해당 Stream에 이전 마블 3개를 전부 전달한다. 이후 생성되는 데이터는 모든 Stream에 전달된다.

    // MARK: - Drive

    // MainScheduler 등 명시 안하고 메인스레드로 돌려서 UI 등 처리할 수 있는 또 다른 방법 정도로 이해해두면 됨
    //    viewModel.idBulletVisible
    //    .asDriver()
    //    .drive(onNext: idValidView.isHidden = $0)
    //    .disposed(by: disposeBag)

    let emailInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let emailValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let pwInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let pwValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: 1) Subject 없이 구현

        //        bindUI()

        // MARK: 2) Subject와 혼용하여 구현

        bindInput()
        bindOutput()
    }

    // MARK: - IBOutlet

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var emailValidView: UIView!
    @IBOutlet var pwValidView: UIView!

    // MARK: - Bind UI

    private func bindInput() {
        // Input : 아이디 입력, 비번 입력

        // * 이메일 텍스트필드의 데이터도 각각의 Subject로 bind하여 감시한다.
        emailTextField.rx.text.orEmpty
            .bind(to: emailInputText)
            .disposed(by: disposeBag)

        // 텍스트필드의 데이터 판별 Subject에도 bind처리로 감시한다.
        emailInputText
            .map(checkEmailValid)
            .bind(to: emailValid)
            .disposed(by: disposeBag)

        // * 비번 텍스트필스의 데이터도 각각의 Subject와 binding 하여 감시를 한다.
        pwTextField.rx.text.orEmpty
            .bind(to: pwInputText)
            .disposed(by: disposeBag)

        pwInputText
            .map(checkPasswordValid)
            .bind(to: pwValid)
            .disposed(by: disposeBag)

        // * UI Input 은 Complete 되지 않는다 그래서 UI의 Reference Count가 1로 계속 유지 될 수 있다. 이로 인한 메모리 누수 방지를 위해 할 수 있는 방법
        // 1) 클로져 내 [weak self]를 고려해야 한다.
        // 2) disposeBag = DisposeBag() 의 활용

        // * 기타 유용한 RxSwift Library
        // RxOptional : .filterNil() 등을 사용하여 쉽게 옵셔널 데이터 처리가 가능하다.
        // RxViewController :
        //        self.rx.viewWillDisappear.subscribe...
        //        self.rx.viewWillAppear().take(1).subscribe...(viewWillAppear에 여러번 들러도 한번만 처리하게 하는 기능) 등의 접근 가능
        // RxGesture : 제스쳐기능의 코드부 간략화 가능
        //    view.rx
        //        .anyGesture(.top(), .swipe([up, .down]))
        //        .when(.recognized)
        //        .subscribe(onNext: { _ in
        //            // dismiss presented photo
        //        })
        //        .disposed(by: disposeBag)

        // 결론 : 여러분들은 RxSwift를 4시간만에 끝내기는 커녕 3시간만에 끝내셨습니다(?)
        // Promise 등의 기본 기능이 있지만 굉장히 다양한 Operator 기능 + 커뮤니티가 있어 유용하게 사용이 가능하며 취업에도 유리한 강점이 될 수 있다.
    }

    private func bindOutput() {
        // Output : Bullet, Login Button Enabled or Disabled
        emailValid.subscribe(onNext: { bool in
            self.emailValidView.isHidden = bool
        })
            .disposed(by: disposeBag)

        pwValid.subscribe(onNext: { bool in
            self.pwValidView.isHidden = bool
        })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            emailValid,
            pwValid,
            resultSelector: { $0 && $1 }
        )
        .subscribe(onNext: { bool in
            self.loginButton.isEnabled = bool
        })
        .disposed(by: disposeBag)
    }

    private func bindUI() {
        //
        // id input +--> check valid --> bullet
        //          |
        //          +--> button enable
        //          |
        // pw input +--> check valid --> bullet

        // MARK: 따로 Observable 만들기

        // 1) textView.delegate.self
        // 2) Using textView, textField's textchanged Delegate Method
        // 3) Verification both email and password text
        // 4) set Button Enabled status whenever the text value changed

        //        // orEmpty 값이 비어있는지 체크하는 변수 + 비동기, Async하게 실행 되는 것
        //        emailTextField.rx.text.orEmpty
        //            .map(checkEmailValid)
        //            .subscribe(onNext: { isEmpty in
        //                self.idValidView.isHidden = isEmpty // 만약 텍스트가 비어있다면 false로 빨간 구슬이 나온다.
        //            })
        //            .disposed(by: disposeBag)
        //
        //        pwTextField.rx.text.orEmpty
        //            .map(checkPasswordValid)
        //            .subscribe(onNext: { isEmpty in
        //                self.pwValidView.isHidden = isEmpty
        //            })
        //            .disposed(by: disposeBag)

        // MARK: Observable 합쳐서 처리하기

        //        /// => 두 개의 Observable을 합쳐서 체크해보자
        //        // ✓ CombineLatest : 다른 Observable을 결합시켜 새로운 Observable을 생성해야 할때 사용한다.
        //        // ✓ Zip : 두 개 전부 데이터가 변경이 될 때 전달한다.
        //        // ✓ Merge : 데이터가 들어오는대로 한번 씩 한번씩 내린다.(?)
        //        Observable.combineLatest(
        //            pwTextField.rx.text.orEmpty.map(checkPasswordValid), // 합쳐서 실행 할 체크 옵저바블 1
        //            emailTextField.rx.text.orEmpty.map(checkEmailValid), // 합쳐서 실행 할 체크 옵저바블 2
        //            resultSelector: { s1, s2 in s1 && s2 } // 옵저바블 2개가 동시에 성립하는 지 체크한다.
        //        )
        //        .subscribe(onNext: { bool in
        //            // 두 개의 옵저바블(이메일, 비밀번호 체크)가 성립하면 로그인 버튼을 활성화 시킨다.
        //            print(bool)
        //            self.loginButton.isEnabled = bool
        //        })
        //        .disposed(by: disposeBag)

        // MARK: 좀 더 세련되게 Observable 처리하기.

        //        let emailInputObservable: Observable<String> = emailTextField.rx.text.orEmpty.asObservable()
        //
        //        // emailValid라는 behavior Subject에 데이터를 넘겨 데이터에 따른 판별을 실행한다.
        //        let emailValidObservable = emailInputObservable
        //            .map(checkEmailValid)
        //            .bind(to: emailValid)
        //            .disposed(by: disposeBag)

        //        // Subject에 데이터 넣는 1번째 방법
        //        emailValidObservable.subscribe(onNext: { bool in
        //            // BehaviorSubject에 bool 데이터값을 넣어준다.
        //            self.emailValid.onNext(bool)
        //        })

        //        // Subject에 데이터 넣는 2번째 방법
        //        // 난 이제 emailValidObservable 데이터를 emailValid Subject로 넘길거야!
        //        emailValidObservable.bind(to: emailValid)

        //        let passwordInputObservable: Observable<String> = pwTextField.rx.text.orEmpty.asObservable()
        //        let passwordValidObservable = passwordInputObservable.map(checkPasswordValid)

        // * Behavior Subject를 사용할 때

        //        // * Subject 를 사용 안하고 사용할 때
        //        // Output : Bullet, Login Button Enable or Disable Check
        //
        //        emailValidObservable.subscribe(onNext: { bool in self.emailValidView.isHidden = bool })
        //        .disposed(by: disposeBag)
        //        passwordValidObservable.subscribe(onNext: { bool in
        //            self.pwValidView.isHidden = bool })
        //        .disposed(by: disposeBag)
        //
        //        Observable.combineLatest(
        //            emailValidObservable,
        //            passwordValidObservable,
        //            resultSelector: { $0 && $1 } )
        //            .subscribe(onNext: { bool in self.loginButton.isEnabled = bool} )
        //            .disposed(by: disposeBag)
    }

    // MARK: - Logic

    /// * 이메일 포맷 여부 체크 메서드
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }

    /// * 패스워드 포맷 여부 체크 메서드
    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
}
