//
//  PromiseViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import PromiseKit
import UIKit

/// MAEK: - RxSwift 대신 Promise를 사용하여 이미지를 받아 설정하는 뷰 컨트롤러
class PromiseViewController: UIViewController {
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

    @IBAction func onLoadImage(_: Any) {
        imageView.image = nil

        promiseLoadImage(from: LARGER_IMAGE_URL) // 이미지 처리가 완료(fulfill) 되면 그 이후에 .done, .catch 등으로 이미지 적용 및 예외처리를 설정한다.
            .done { image in
                self.imageView.image = image
            }.catch { error in
                print(error.localizedDescription)
            }
    }

    // MARK: - PromiseKit

    func promiseLoadImage(from imageUrl: String) -> Promise<UIImage?> {
        return Promise<UIImage?>() { seal in
            asyncLoadImage(from: imageUrl) { image in // 이미지가 다운로드 되면
                seal.fulfill(image) // seal에 fulfill로 "이미지 다운 완료 됐어" 하고 넘겨줍니다.
            }
        }
    }
}
