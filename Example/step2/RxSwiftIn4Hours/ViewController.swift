//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxSwift
import UIKit

class ViewController: UITableViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var progressView: UIActivityIndicatorView!

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - SideEffect란 무엇일까? Observable 실행 중간의 외부에 영향을 끼릴 수 있는 처리기능

    // SideEffect를 허용해주는 곳은 총 두 군데가 있다.
    // 1) subscribe
    // 2) do()

    // MARK: - Just

    // JUST() 출력결과: print가 바로 실행된다.
    // -> Hello World
    @IBAction func exJust1() {
        Observable.just("Hello World")
            .subscribe { event in // 이벤트에 따른 처리도 가능
                switch event {
                // 데이터가 전달 된다.(여러개의 operator를 사용할때 사용)
                case .next:
                    break
                // 에러 발생했을 때 실행
                case .error:
                    break
                // 완료 시 실행
                case .completed:
                    break
                }
            }

        // MARK: SubScribe의 용도

//            .subscribe() // "나 이제 구독 할거야!" // .subscribe() 위의 작업 내리고 그냥 실행종료(결과 출력 등 문제 없을때)

//            .subscribe(onNext: { str in
//                print(str)
//            })
//            .disposed(by: disposeBag)
    }

    // JUST() 출력결과: 배열이 바로 출력된다.
    // [Hello, World]
    @IBAction func exJust2() {
        Observable.just(["Hello", "World"])
            .subscribe(onNext: { arr in
                print(arr)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - From

    // FROM() 출력결과: 배열의 요소를 하나씩 하나씩 하나씩 차례대로 처리한다.
    // ✓ 작업 완료 후에 completed 분기가 실행이 된다!
    // ✓ single()을 실행하기 위해선 작업이 한개만 들어와야 한다!

    @IBAction func exFrom1() {
        // 출력 -> RxSwift \n In \n 4 \n Hours \n completed! \n disposed
        Observable.from(["RxSwift", "In", 4, "Hours"])
            .subscribe(onNext: { str in
                // 작업대상의 처리
                print(str)
            }, onError: { err in
                // Error 발생 시 실행
                print(err.localizedDescription)
            }, onCompleted: {
                // 작업 완료 시 실행
                print("completed!")
            }, onDisposed: {
                // 맨- 마지막 실행
                print("disposed!")
            })
            .disposed(by: disposeBag)

        //// MARK: From의 일반적인 동작
        // 출력 -> RxSwift \n In \n 4 \n Hours \n completed!
        //        Observable.from(["RxSwift", "In", "4", "Hours"])
//            .subscribe { event in
//                switch event {
//                case .next(let str):
//                    print("next: \(str)")
//                    break
//                case .error(let err):
//                    print("error: \(err.localizedDescription)")
//                    break
//                case .completed:
//                    print("completed!")
//                    break
//                }
//            }
//            .disposed(by: disposeBag)
    }

    // MARK: - Map : 내려온 작업, 데이터를 하나씩 다른 데이터로 변형시킨다.

    // MARK: - FlatMap : 내려온 작업, 데이터를 하나씩 스트림(Stream)으로 변형시킨다.

    // MARK: - Concat : 다수의 Observable을 하나로 순서대로 합쳐서 실행한다.

    // just -> map -> subcribe 순으로 실행
    @IBAction func exMap1() {
        Observable.just("Hello") // Hello 가 내려간다.
            .map { str in "\(str) RxSwift" } // Hollo RxSwift로 붙는다.
            .subscribe(onNext: { str in // 붙은 내용을 출력한다.
                print(str)
            })
            .disposed(by: disposeBag)
    }

    // with 한번, 곰튀김 한번
    // 4 \n 3
    @IBAction func exMap2() { // "with", "곰튀김" 이 한번씩 차례로 내려간다.
        Observable.from(["with", "곰튀김"]) // 줄을 세워 순서대로 내려가며 거쳐가는 것을 "stream 이라고 부른다!"
            .map { $0.count } // 내려온 문자열의 길이값으로 변환
            .subscribe(onNext: { str in // 변환 된 문자열 길이 값을 출력
                print(str)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exFilter() {
        Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) // 1 ~ 10이 순서대로 내려간다.
            .filter { $0 % 2 == 0 } // 짝수일 경우만 내려간다. 2,4,6,8,10
            .subscribe(onNext: { n in
                print(n) // 짝수 값만 출력 된다.
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exMap3() {
        Observable.just("800x600")
            .map { $0.replacingOccurrences(of: "x", with: "/") }
            .map { "https://picsum.photos/\($0)/?random" }
            .map { URL(string: $0) } // "https://picsum.photos/800/600/?random"
            .filter { $0 != nil } // URL?
            .map { $0! } // URL!
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .map { try Data(contentsOf: $0) } // Data
            .map { UIImage(data: $0) } // UIImage?
            .observeOn(MainScheduler.instance)
            .do(onNext: { image in
                print("imageSize is... : \(image?.size)")
            })
            .subscribe(onNext: { image in
                self.imageView.image = image
            })
            .disposed(by: disposeBag)

        // 현재 메인스레드로 만 전부 진행하기 때문에 실행간 렉이 걸린다. 이때 사용할 수 있는 것이 Scheduler이다.

        // ✭ 동시실행이 필요할 때 => 메인스레드 사용 전 동시성 실행 스케줄러 : .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
        // ✭메인스레드 동작에 사용되는 스케쥴러 지정 : .observeOn(MainScheduler.instance)를 사용한다.

        // ✓ subscribeOn은 어느 위치에 지정해도 문제없다. 사용하는것이 아닌 사용을 위해 등록만 하는 과정이기 때문이다.
        // ✓ subscribeOn이후 subscribe가 생기면 그 순간 해당 subscribe는 가장 최근에 지정한 subscribeOn 스케쥴러 정책에 따라 실행된다.
//        Observable.just("800x600")
//            .map { $0.replacingOccurrences(of: "x", with: "/") }
//            .map { "https://picsum.photos/\($0)/?random" }
//            .map { URL(string: $0) } // "https://picsum.photos/800/600/?random"
//            .filter { $0 != nil } // URL?
//            .map { $0! } // URL!
//            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
//            .map { try Data(contentsOf: $0) } // Data
//            .map { UIImage(data: $0) } // UIImage?
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { image in
//                self.imageView.image = image
//            })
//            .disposed(by: disposeBag)

        /// 메인스레드를 사용하지 않고 UI처리를 해서 버벅임이 생긴다. 메인스레드에서 동작시켜야 한다.
//        Observable.just("800x600")
//            .map { $0.replacingOccurrences(of: "x", with: "/") }
//            .map { "https://picsum.photos/\($0)/?random" }
//            .map { URL(string: $0) }
//            .filter { $0 != nil }
//            .map { $0! }
//            .map { try Data(contentsOf: $0) }
//            .map { UIImage(data: $0) }
//            .subscribe(onNext: { image in
//                self.imageView.image = image
//            })
//            .disposed(by: disposeBag)
    }
}
