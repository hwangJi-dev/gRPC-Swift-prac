//
//  ViewController.swift
//  grpc-prac
//
//  Created by hwangJi on 2023/03/11.
//

import UIKit
import GRPC
import NIO
import SnapKit

final class ViewController: UIViewController {
    private let textField = UITextField()
    private let getHelloButton = UIButton()
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }
}

// MARK: - UI
extension ViewController {
    private func setupUI() {
        // textField
        textField.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        textField.placeholder = "인사하고 싶은 사람의 이름을 입력하세요."
        textField.borderStyle = .roundedRect
        
        // getHelloButton
        getHelloButton.setTitle("👆🏻인사하기", for: .normal)
        getHelloButton.backgroundColor = .lightGray
        getHelloButton.layer.cornerRadius = 5.0
        getHelloButton.addTarget(self, action: #selector(getHelloButtonDidTap), for: .touchUpInside)
        
        // resultLabel
        resultLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        resultLabel.textColor = .brown
    }
    
    private func configureUI() {
        self.view.addSubview(textField)
        self.view.addSubview(getHelloButton)
        self.view.addSubview(resultLabel)
        
        textField.snp.makeConstraints {
            $0.topMargin.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }
        
        getHelloButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(getHelloButton.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: - Custom Methods
extension ViewController {
    @objc
    private func getHelloButtonDidTap() {
        Task {
            let greetingMessage = await getGRPC(textField.text ?? "")
            
            DispatchQueue.main.async { [weak self] in
                self?.resultLabel.text = greetingMessage
                self?.textField.text = ""
            }
        }
    }
}

// MARK: - gRPC server connect
extension ViewController {
    private func getGRPC(_ name: String) async -> String {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 3)
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
            print("Greeter received: \(greeting.message)")
            return greeting.message
        } catch {
            print("Greeter failed: \(error)")
            return ""
        }
    }
}
