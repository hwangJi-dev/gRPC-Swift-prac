//
//  ViewController.swift
//  grpc-prac
//
//  Created by hwangJi on 2023/03/11.
//

import UIKit
import GRPC
import NIO
import NIOSSL

final class ViewController: UIViewController {
    let textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await getGRPC()
        }
    }
    
    func getGRPC() async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let channel = try? GRPCChannelPool.with(
                target: .host("localhost", port: 1234),
                transportSecurity: .plaintext,
                eventLoopGroup: group
            )
            
            defer {
                try! channel?.close().wait()
            }
            
            // Provide the connection to the generated client.
            let greeter = Helloworld_GreeterAsyncClient(channel: channel!)
            
            // Form the request with the name, if one was provided.
            let request = Helloworld_HelloRequest.with {
                $0.name = "jieun"
            }
            
            do {
                let greeting = try await greeter.sayHello(request)
                print("Greeter received: \(greeting.message)")
            } catch {
                print("Greeter failed: \(error)")
            }
    }
}

