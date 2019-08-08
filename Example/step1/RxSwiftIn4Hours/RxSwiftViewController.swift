//
//  RxSwiftViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxSwift
import UIKit

/// MAEK: - RxSwift를 사용하여 이미지를 받아 설정하는 뷰 컨트롤러
class RxSwiftViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    // MARK: - IBAction

    //    var disposable: Disposable?
    var disposeBag: DisposeBag = DisposeBag()

    @IBAction func onLoadImage(_: Any) {
        imageView.image = nil

        let disposable = rxswiftLoadImage(from: LARGER_IMAGE_URL)
            .observeOn(MainScheduler.instance) // UI는 메인스레드 내에서 처리해야하기 때문에 MainScheduler.instance를 사용한다.
            .subscribe { result in // Promise의 done 대신 RxSwift에서는 subscribe를 사용하여 이미지 처리, 예외처리를 한다.
                // subscribe는 실행 후 Disposable을 리턴한다.
                switch result {
                case let .next(image):
                    self.imageView.image = image

                case let .error(err):
                    print(err.localizedDescription)

                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
        //        disposeBag.insert(disposable)
    }

    @IBAction func onCancel(_: Any) {
        // disposeBag을 만들어 비동기 작업의 dispose처리를 할 수도 있다.
        // disposeBag은 dispose다른 작업을 제공하지 않아 새로 만들어주어야 한다. -> 이 자체의 작업이 dispose작업이 딘다.
        // disposeBag = disposeBag()
        // OR .disposed(by: disposeBag) 도 가능하다!

        // TODO: cancel image loading
        //        disposable?.dispose() // 이미지 불러오기 작업을 취소한다.
        // ★ Observable 동작이 진행 되는 동안에 작업을 dispose 함으로서 다시 취소시킬 수 있다.
        // Ex) 로그인 과정에서 실패했다거나, 네트워킹 인디케이터가 진행중일때 문제가 발생했을 때 등 취소시킬 수 있다.
    }

    // MARK: - RxSwift

    func rxswiftLoadImage(from imageUrl: String) -> Observable<UIImage?> { // RxSwift를 활용하기 위해 Observable을 리턴한다. Observable을 리던하는 메서드, rxswiftLoadImage
        return Observable.create { seal in // Observable을 생성한다.
            asyncLoadImage(from: imageUrl) { image in
                seal.onNext(image) // Promise에서는 fullfill을 사용한 반면, RxSwift에서는 onNext/ onCompleted를 사용할 수 있다.
                seal.onCompleted()
            }
            return Disposables.create()
        }
    }
}
