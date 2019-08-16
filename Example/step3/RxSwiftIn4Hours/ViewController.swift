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
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    // MARK: - IBOutlet

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var idValidView: UIView!
    @IBOutlet var pwValidView: UIView!

    // MARK: - Bind UI

    private func bindUI() {
        //
        // id input +--> check valid --> bullet
        //          |
        //          +--> button enable
        //          |
        // pw input +--> check valid --> bullet

        // 1) textView.delegate.self
        // 2) Using textView, textField's textchanged Delegate Method
        // 3) Verification both email and password text
        // 4) set Button Enabled status whenever the text value changed

        // orEmpty 값이 비어있는지 체크하는 변수 + 비동기, Async하게 실행 되는 것
        emailTextField.rx.text.orEmpty
            .map(checkEmailValid)
            .subscribe(onNext: { isEmpty in
                self.idValidView.isHidden = isEmpty // 만약 텍스트가 비어있다면 false로 빨간 구슬이 나온다.
            })
            .disposed(by: disposeBag)

        pwTextField.rx.text.orEmpty
            .map(checkPasswordValid)
            .subscribe(onNext: { isEmpty in
                self.pwValidView.isHidden = isEmpty
            })
            .disposed(by: disposeBag)

        /// 두 개의 Observable을 합쳐서 체크해보자
        // ✓ CombineLatest : 다른 Observable을 결합시켜 새로운 Observable을 생성해야 할때 사용한다.
        // ✓ Zip : 두 개 전부 데이터가 변경이 될 때 전달한다.
        // ✓ Merge : 데이터가 들어오는대로 한번 씩 한번씩 내린다.(?)
        Observable.combineLatest(
            pwTextField.rx.text.orEmpty.map(checkPasswordValid), // 합쳐서 실행 할 체크 옵저바블 1
            emailTextField.rx.text.orEmpty.map(checkEmailValid), // 합쳐서 실행 할 체크 옵저바블 2
            resultSelector: { s1, s2 in s1 && s2 } // 옵저바블 2개가 동시에 성립하는 지 체크한다.
        )
        .subscribe(onNext: { bool in
            // 두 개의 옵저바블(이메일, 비밀번호 체크)가 성립하면 로그인 버튼을 활성화 시킨다.
            print(bool)
            self.loginButton.isEnabled = bool
        })
        .disposed(by: disposeBag)
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
