//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import UIKit

class AsyncViewController: UIViewController {
    // MARK: - Field

    var counter: Int = 0
    let IMAGE_URL = "https://picsum.photos/1280/720/?random"

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

    // MARLL Synchronous Task Method
    @IBAction func onLoadSync(_: Any) {
        let image = loadImage(from: IMAGE_URL)
        imageView.image = image
    }

    // MARK: Asynchronous Task Method

    @IBAction func onLoadAsync(_: Any) {
        // TODO: async
        DispatchQueue.global().async { // Concurrency, 비동기방식으로 동시에 실행한다.
            guard let url = URL(string: self.IMAGE_URL) else { return } // 데이터 요청할 URL을 준비한다.
            guard let data = try? Data(contentsOf: url) else { return } // URL에 대한 데이터를 요정한다.

            let image = UIImage(data: data) // 데이터를 받았으면 해당 테이터에 맞는 이미지를 가져온다.

            DispatchQueue.main.async {
                // ★ 비동기로 UI를 건드리는 경우에는 메인스레드 내에서 건드려주어야 한다.
                self.imageView.image = image // imageView의 이미지를 셋팅 해준다.
            }
        }
    }

    private func loadImage(from imageUrl: String) -> UIImage? {
        guard let url = URL(string: imageUrl) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }

        let image = UIImage(data: data)
        return image
    }
}
