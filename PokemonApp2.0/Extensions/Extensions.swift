//
//  Extensions.swift
//  PokemonApp
//
//  Created by Mac on 11/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class ImageOperation:Operation{
    var completionHandler:(UIImage?,Error?)->()
    var url:String?
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.KeyPath())
            willChangeValue(forKey: state.KeyPath())
        }
        didSet{
            didChangeValue(forKey: oldValue.KeyPath())
            didChangeValue(forKey: state.KeyPath())
        }
    }
    
    enum State {
        case Ready, Executing, Finished
        
        func KeyPath() -> String {
            switch self {
            case .Executing:
                return "isExecuting"
            case .Finished:
                return "isFinished"
            case .Ready:
                return "isReady"
            }
        }
    }
    
    init(url:String,completionHandler:@escaping(UIImage?,Error?)->()) {
        self.completionHandler = completionHandler
        self.url = url
    }
    
    
    
    override func start() {
        if self.isCancelled{
            self.state = .Finished
        } else {
            guard let url = URL(string:(url ?? "")) else {
                completionHandler(nil, NetworkError.URLDoesNotConnect)
                self.state = .Finished
                return
            }
            guard !self.isCancelled else {
                self.state = .Finished
                return
            }
            let session = URLSession(configuration: .default)
            guard !self.isCancelled else {
                self.state = .Finished
                return
            }
            let task = session.dataTask(with: url) { (data, response, error) in
                guard !self.isCancelled else {
                    self.state = .Finished
                    return
                }
                guard error == nil else {
                    self.completionHandler(nil, error)
                    self.state = .Finished
                    return
                }
                guard let data = data else {
                    self.completionHandler(nil, NetworkError.NoData)
                    self.state = .Finished
                    return
                }
                //print(String(data: data, encoding: .utf8) ?? "nothing")
                guard let image = UIImage(data: data) else {
                    self.completionHandler(nil, NetworkError.NoImage)
                    self.state = .Finished
                    return
                }
                //print("About to call completion")
                self.completionHandler(image, nil)
                self.state = .Finished
            }
            guard !self.isCancelled else {
                self.state = .Finished
                return
            }
            task.resume()
            self.state = .Executing
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override var isExecuting: Bool{
        return state == .Executing
    }
    
    override var isFinished:Bool {
        return state == .Finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
}

extension UIImageView {
    
    
    
    func imageFrom(url:String,queue:OperationQueue){
        URLSession.shared.invalidateAndCancel()
        let cache = GlobalCache.shared.imageCache
        if let image = cache.object(forKey: url as NSString){
            self.image = image
            return
        }
        let operation = ImageOperation(url: url) {
            [unowned self](aimage, error) in
            guard error == nil else {return}
            guard let aimage = aimage else {return}
            cache.setObject(aimage, forKey: url as NSString)
            DispatchQueue.main.async{
                //print("completion")
                self.image = aimage
            }
        }
        queue.addOperation(operation)
        //print(queue.operationCount)
        
    }
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword()->Bool{
        let passwordRegEx = "^(?=.*[0-9]).{6,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
    
}
