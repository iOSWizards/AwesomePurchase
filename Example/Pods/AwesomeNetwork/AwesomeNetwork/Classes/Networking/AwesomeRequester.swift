//
//  NetworkRequester.swift
//  AwesomeNetwork
//
//  Created by Evandro Harrison Hoffmann on 10/03/18.
//  Copyright © 2018 Awesome. All rights reserved.
//

import UIKit

public enum URLMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}

public typealias AwesomeDataResponse = (Data?, AwesomeError?) -> Void
public typealias AwesomeRetryDataResponse = (Data?, AwesomeError?, Int) -> Void
public typealias AwesomeRequesterHeader = [String: String]

public class AwesomeRequester: NSObject {
    
    var requestManager: AwesomeRequestManager = AwesomeRequestManager()
    var useSemaphore: Bool = false
    
    init(useSemaphore: Bool) {
        self.useSemaphore = useSemaphore
    }
    
    /// Retry fetching data as long as it's not a successful response
    ///
    /// - Parameters:
    ///   - request: Parameters for request
    ///   - retry count: Choice to use or not semaphore
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    func performRequestRetrying(_ request: AwesomeRequestProtocol,
                                retryCount: Int,
                                intermediate: AwesomeRetryDataResponse? = nil,
                                completion:@escaping AwesomeDataResponse) {
        performRequest(request) { (data, error) in
            intermediate?(data, error, retryCount)
            
            if !request.isSuccessResponse(data), retryCount > 0 {
                // adds a small timeout between calls
                request.queue.asyncAfter(deadline: .now()+AwesomeNetwork.shared.retryTimeout, execute: {
                    self.performRequestRetrying(request,
                                                retryCount: retryCount-1,
                                                intermediate: intermediate,
                                                completion: completion)
                })
            } else {
                completion(data, error)
            }
        }
    }
    
    /// Fetch data from URL with NSUrlSession
    ///
    /// - Parameters:
    ///   - request: Parameters for request
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    func performRequest(_ request: AwesomeRequestProtocol,
                        completion:@escaping AwesomeDataResponse) {
        guard let urlRequest = request.urlRequest else {
            return
        }
        
        if useSemaphore {
            AwesomeDispatcher.shared.executeBlock(queue: request.queue) { [weak self] in
                self?.performRequest(urlRequest, cancelPrevious: request.cancelPreviousRequest, completion: completion)
            }
        } else {
            performRequest(urlRequest, cancelPrevious: request.cancelPreviousRequest, completion: completion)
        }
        
    }
    
    /// Fetch data from URL with NSUrlSession
    ///
    /// - Parameters:
    ///   - urlRequest: Url Request to fetch data form
    ///   - completion: Returns fetched NSData in a block
    /// - Returns: URLSessionDataTask
    internal func performRequest(_ urlRequest: URLRequest,
                                 cancelPrevious: Bool = false,
                                 completion:@escaping AwesomeDataResponse) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            self.requestManager.removeRequest(to: urlRequest)
            
            if let error = error {
                print("There was an error \(error.localizedDescription)")
                
                let urlError = error as NSError
                if urlError.code == NSURLErrorTimedOut {
                    completion(nil, AwesomeError.timeOut(error.localizedDescription))
                } else if urlError.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, AwesomeError.noConnection(error.localizedDescription))
                } else if urlError.code == URLError.cancelled.rawValue {
                    completion(nil, AwesomeError.cancelled(error.localizedDescription))
                } else {
                    completion(nil, AwesomeError.unknown(error.localizedDescription))
                }
            }else{
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401  {
                    completion(nil, AwesomeError.unauthorized)
                } else {
                    completion(data, nil)
                }
            }
        }
        requestManager.addRequest(to: urlRequest, task: dataTask, cancelPrevious: cancelPrevious)
        dataTask.resume()
    }
}
