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

        // orEmpty 값이 비어있는지 체크하는 변수
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
