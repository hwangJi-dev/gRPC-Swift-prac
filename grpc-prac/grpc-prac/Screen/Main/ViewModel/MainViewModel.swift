//
//  MainViewModel.swift
//  grpc-prac
//
//  Created by hwangJi on 2023/03/14.
//

import Foundation
import RxCocoa
import RxSwift
import GRPC
import NIO

final class MainViewModel {
    private var bag = DisposeBag()
    private(set) var greeterData = BehaviorRelay<String>(value: "")
    
    init() {}
    
    deinit {
        bag = DisposeBag()
    }
}

// MARK: - Connect Server
extension MainViewModel {
    public func getGRPC(_ name: String) async {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = try? GRPCChannelPool.with(
            target: .host("localhost", port: 1234),
            transportSecurity: .plaintext,
            eventLoopGroup: group
        )
        
        defer {
            try! channel?.close().wait()
        }
        
        let greeter = Helloworld_GreeterAsyncClient(channel: channel!)
        let request = Helloworld_HelloRequest.with {
            $0.name = name
        }
        
        do {
            let greeting = try await greeter.sayHello(request)
            greeterData.accept(greeting.message)
        } catch {
            print("Greeter failed: \(error)")
        }
    }
}
