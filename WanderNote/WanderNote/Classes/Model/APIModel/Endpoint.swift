//
//  Endpoint.swift
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//


import Foundation
import Alamofire
import RxSwift
import RxCocoa

class Endpoint {
    
    private static var persistentHeaders: [String: String] = [:]
    private static var persistentParams: [String:AnyObject] = [String:AnyObject]()
    private static var defaultSettings: Settings = Settings()
    
    struct Settings {
        var method: Method?
        var fullUrl: String?
        var baseUrl: String?
        var path: String?
        var params: [String:AnyObject]?
        var headers: [String: String]?
        var addPersistentParams: Bool?
        var addPersistentHeaders: Bool?
        var expectedResponse: ExpectedResponse?
        
        init() {
            method = Method.GET
            fullUrl = nil
            baseUrl = nil
            path = nil
            params = [:]
            headers = [:]
            addPersistentParams = true
            addPersistentHeaders = true
            expectedResponse = ExpectedResponse.JSON
        }
        
        func copy() -> Settings {
            var copy = Settings()
            
            copy.method = self.method
            copy.fullUrl = self.fullUrl
            copy.baseUrl = self.baseUrl
            copy.path = self.path
            copy.params = self.params
            copy.headers = self.headers
            copy.addPersistentParams = self.addPersistentParams
            copy.addPersistentHeaders = self.addPersistentHeaders
            copy.expectedResponse = self.expectedResponse
            
            return copy
        }
        
        mutating func config(settings: Settings) {
            if let method = settings.method {
                self.method = method
            }
            
            if let fullUrl = settings.fullUrl {
                self.fullUrl = fullUrl
            }
            
            if let baseUrl = settings.baseUrl {
                self.baseUrl = baseUrl
            }
            
            if let path = settings.path {
                self.path = path
            }
            
            if let params = settings.params {
                var newParams = [String:AnyObject]()
                
                // add old parameters
                if let storedParams = self.params {
                    for (key, value) in storedParams {
                        newParams[key] = value
                    }
                }
                
                // add new params
                for (key, value) in params {
                    newParams[key] = value
                }
                
                self.params = newParams
            }
            
            if let headers = settings.headers {
                var newHeaders = [String:String]()
                
                // add old parameters
                if let storedHeaders = self.headers {
                    for (key, value) in storedHeaders {
                        newHeaders[key] = value
                    }
                }
                
                // add new params
                for (key, value) in headers {
                    newHeaders[key] = value
                }
                
                self.headers = newHeaders
            }
            
            if let addPersistentParams = settings.addPersistentParams {
                self.addPersistentParams = addPersistentParams
            }
            
            if let addPersistentHeaders = settings.addPersistentHeaders {
                self.addPersistentHeaders = addPersistentHeaders
            }
            
            if let expectedResponse = settings.expectedResponse {
                self.expectedResponse = expectedResponse
            }
        }
    }
    
    enum Method {
        case GET
        case PUT
        case POST
        case PATCH
        case DELETE
        
        func toAFMethod() -> Alamofire.HTTPMethod {
            switch self {
            case .GET:
                return Alamofire.HTTPMethod.get
            case .PUT:
                return Alamofire.HTTPMethod.put
            case .POST:
                return Alamofire.HTTPMethod.post
            case .PATCH:
                return Alamofire.HTTPMethod.patch
            case .DELETE:
                return Alamofire.HTTPMethod.delete
            }
        }
    }
    
    enum ExpectedResponse {
        case String
        case JSON
        case Array
        case XML
        case Unknown
    }
    
    public enum APIError: Error, CustomStringConvertible {
        case ServerError
        case Unauthorized(String)
        case ClientError
        case BadRequest(String)
        case ResourceNotModified(String)
        case ResourceNotFound(String)
        case ResourceLocked(String)
        case Forbidden(String)
        case TooManyRequests(String)
        case InternalServerError(String)
        case Unknown
        
        var description: String {
            switch self {
            case .ServerError:
                return "Server Error"
            case .Unauthorized:
                return "Unauthorized"
            case .ClientError:
                return "Client Error"
            case .BadRequest(let message):
                return "Bad Request: \(message)"
            case .ResourceNotModified:
                return "Resource Not Modified"
            case .ResourceNotFound(let message):
                return message
            case .ResourceLocked(let message):
                return message
            case .Forbidden(let message):
                return message
            case .TooManyRequests(let message):
                return message
            case .InternalServerError:
                return "Internal Server Error"
            default:
                return "An unknown error occurred."
            }
        }
        
        var status: Int {
            switch self {
            case .ResourceNotModified: return 304
            case .Unauthorized: return 401
            case .BadRequest: return 400
            case .ResourceNotFound: return 404
            case .ResourceLocked: return 423
            case .Forbidden: return 403
            case .TooManyRequests: return 429
            case .InternalServerError: return 500
            default: return 500
            }
        }
        
        var message: String {
            switch self {
            case .Unauthorized(let string): return string
            case .BadRequest(let string): return string
            case .ResourceNotModified(let string): return string
            case .ResourceNotFound(let string): return string
            case .ResourceLocked(let string): return string
            case .Forbidden(let string): return string
            case .TooManyRequests(let string): return string
            case .InternalServerError(let string): return string
            default: return "Error, please try again!"
            }
        }
    }
    
    class Request {
        private var settings: Settings
        var urlStr = ""
        
        init() {
            self.settings = Endpoint.defaultSettings.copy()
        }
        
        init(settings: Settings) {
            self.settings = Endpoint.defaultSettings.copy()
            self.settings.config(settings: settings)
        }
        
        func config(settings: Settings) {
            self.settings.config(settings: settings)
        }
        
        func get(path: String,params: [String:String]? = nil) -> Observable<Any?> {
            var path: String = path
            urlStr = path
            // append query parameters
            if let _params: [String:String] = params, _params.count > 0  {
                path += "?"
                
                var i = 0
                for (key, value) in _params {
                    path += key + "=" + value
                    if (i != _params.count - 1) {
                        path += "&"
                    }
                    i = i + 1
                }
            }
            self.settings.path = path
            self.settings.method = Endpoint.Method.GET
            return self.execute()
        }
        
        func post(path: String, params: [String:AnyObject]? = nil) -> Observable<Any?> {
            urlStr = path
            self.settings.path = path
            self.settings.params = params
            self.settings.method = Endpoint.Method.POST
            return self.execute()
        }
        
        func put(path: String, params: [String:AnyObject]? = nil) -> Observable<Any?> {
            urlStr = path
            self.settings.path = path
            self.settings.params = params
            self.settings.method = .PUT
            return self.execute()
        }
        
        func patch(path: String, params: [String:AnyObject]? = nil) -> Observable<Any?> {
            self.settings.path = path
            self.settings.params = params
            self.settings.method = .PATCH
            
            return self.execute()
        }
        
        func delete(path: String, params: [String:AnyObject]? = nil) -> Observable<Any?> {
            self.settings.path = path
            self.settings.params = params
            self.settings.method = .DELETE
            
            return self.execute()
        }
        
        func execute() -> Observable<Any?> {
            return Observable.create { observer in
                let request = Alamofire.request(
                    URL(string: self.urlStr)!,
                    method: self.getMethod(),
                    parameters: self.getParameters(),
                    encoding: self.getEncoding(),
                    headers: self.getHeaders()
                )
                
                if let expectedResponse: ExpectedResponse = self.settings.expectedResponse {
                    switch expectedResponse {
                    case .JSON:
                        request.responseJSON(completionHandler: { (data: DataResponse<Any>) in
                            guard let status = data.response?.statusCode else {
                                observer.on(.error(self.parseError(data: data)))
                                observer.on(.completed)
                                return
                            }
                            
                            if status >= 200 && status < 300 {
                                if let _data: [String:AnyObject] = data.result.value as? [String:AnyObject] {
                                    observer.on(.next(_data))
                                } else if let _data: [[String:AnyObject]] = data.result.value as? [[String:AnyObject]] {
                                    observer.on(.next(_data))
                                } else {
                                    observer.on(.next(data.result.value))
                                }
                            } else {
                                let error: Endpoint.APIError = self.parseError(data: data)
                                observer.on(.error(error))
                            }
                            
                            observer.on(.completed)
                        })
                        
                        break
                    default:
                        request.response(completionHandler: { (data: DefaultDataResponse) in
                            guard let status = data.response?.statusCode else {
                                observer.on(.error(self.parseError(data: data)))
                                observer.on(.completed)
                                return
                            }
                            
                            if status >= 200 && status < 300 {
                                observer.on(.next(data))
                            } else {
                                let error: Endpoint.APIError = self.parseError(data: data)
                                observer.on(.error(error))
                            }
                            
                            observer.on(.completed)
                        })
                        
                        break
                    }
                }
                
                return Disposables.create()
            }
        }
        
        private func parseError(data: DefaultDataResponse) -> Endpoint.APIError {
            let message: String? = nil
            
            if let unwrappedResponse = data.response {
                let statusCode = unwrappedResponse.statusCode
                
                switch statusCode {
                case 400:
                    return Endpoint.APIError.BadRequest(message ?? "Bad request made.")
                case 401:
                    return Endpoint.APIError.Unauthorized(message ?? "Unauthorized request made.")
                case 403:
                    return Endpoint.APIError.Forbidden(message ?? "Resource locked.")
                case 404:
                    return Endpoint.APIError.ResourceNotFound(message ?? "Resource not found.")
                case 423:
                    return Endpoint.APIError.ResourceLocked(message ?? "Resource not found.")
                case 429:
                    return Endpoint.APIError.TooManyRequests(message ?? "Resource not found.")
                case 500:
                    return Endpoint.APIError.InternalServerError(message ?? "Resource not found.")
                default:
                    return Endpoint.APIError.Unknown
                }
            } else {
                return Endpoint.APIError.Unknown
            }
        }
        
        private func parseError(data: DataResponse<Any>) -> Endpoint.APIError {
            let message: String? = (data.result.value as? [String:AnyObject])?["message"] as? String
            
            if let unwrappedResponse = data.response {
                let statusCode = unwrappedResponse.statusCode
                
                switch statusCode {
                case 400:
                    return Endpoint.APIError.BadRequest(message ?? "Bad request made.")
                case 401:
                    return Endpoint.APIError.Unauthorized(message ?? "Unauthorized request made.")
                case 403:
                    return Endpoint.APIError.Forbidden(message ?? "Resource locked.")
                case 404:
                    return Endpoint.APIError.ResourceNotFound(message ?? "Resource not found.")
                case 423:
                    return Endpoint.APIError.ResourceLocked(message ?? "Resource not found.")
                case 429:
                    return Endpoint.APIError.TooManyRequests(message ?? "Resource not found.")
                case 500:
                    return Endpoint.APIError.InternalServerError(message ?? "Resource not found.")
                default:
                    return Endpoint.APIError.Unknown
                }
            } else {
                return Endpoint.APIError.Unknown
            }
        }
        
        private func getError(response: HTTPURLResponse?, result: Result<AnyObject>? = nil) -> Endpoint.APIError {
            let message: String? = result?.value?["message"] as? String
            
            if let unwrappedResponse = response {
                let statusCode = unwrappedResponse.statusCode
                switch statusCode {
                case 400:
                    return Endpoint.APIError.BadRequest(message ?? "Bad request made.")
                case 401:
                    return Endpoint.APIError.Unauthorized(message ?? "Unauthorized request made.")
                case 403:
                    return Endpoint.APIError.Forbidden(message ?? "Resource locked.")
                case 404:
                    return Endpoint.APIError.ResourceNotFound(message ?? "Resource not found.")
                case 423:
                    return Endpoint.APIError.ResourceLocked(message ?? "Resource not found.")
                case 429:
                    return Endpoint.APIError.TooManyRequests(message ?? "Resource not found.")
                case 500:
                    return Endpoint.APIError.InternalServerError(message ?? "Resource not found.")
                default:
                    return Endpoint.APIError.Unknown
                }
            } else {
                return Endpoint.APIError.Unknown
            }
        }
        
        private func getEncoding() -> ParameterEncoding {
            if settings.method == Endpoint.Method.GET {
                return Alamofire.URLEncoding.default
            } else {
                return Alamofire.JSONEncoding.default
            }
        }
        
        private func getUrl() -> URLConvertible {
            //            var url: String = ""
            //
            //            if let fullUrl: String = settings.fullUrl {
            //                print(fullUrl)
            //                return fullUrl
            //            }
            //
            //            if let baseUrl: String = settings.baseUrl {
            //                url += baseUrl
            //            }
            //
            //            if let path: String = settings.path { // ?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            //                url += path
            //            }
            let urlStr = ""
            
            return URL(string: urlStr)!
        }
        
        private func getMethod() -> Alamofire.HTTPMethod {
            if let method = self.settings.method {
                return method.toAFMethod()
            } else {
                return Alamofire.HTTPMethod.get
            }
        }
        
        private func getHeaders() -> [String:String] {
            var headers = [String:String]()
            headers["Accept"] = "application/json"
            headers["Content-Type"] = "application/json"
            return headers
        }
        
        private func getParameters() -> Alamofire.Parameters {
            var params = [String:AnyObject]()
            let method: Endpoint.Method = self.settings.method ?? .GET
            
            if let storedParams = self.settings.params {
                for (key, value) in storedParams {
                    if method != .GET {
                        
                        params[key] = value
                    } else if let _: String = (value as AnyObject).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                        params[key] = value
                    }
                }
            }
            
            // unwrap `addPersistentParams` variable
            if let addPersistentParams = self.settings.addPersistentParams {
                // check stored value
                if addPersistentParams == true {
                    for (key, value) in Endpoint.persistentParams {
                        if method != .GET {
                            params[key] = value
                        } else if let _: String = (value as AnyObject).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                            params[key] = value
                        }
                    }
                }
            }
            return params
        }
    }
    
    class func config(settings: Settings) {
        defaultSettings.config(settings: settings)
    }
    
    class func addPersistentHeader(key: String, value: String) {
        persistentHeaders[key] = value
    }
    
    class func removePersistentHeader(key: String) {
        persistentHeaders.removeValue(forKey: key)
    }
    
    class func removeAllPersistentHeaders() {
        persistentHeaders.removeAll()
    }
    
    class func addPersistentParam(key: String, value: Any) {
        persistentParams[key] = value as AnyObject
    }
    
    class func removePersistentParam(key: String) {
        persistentParams.removeValue(forKey: key)
    }
    
    class func removeAllPersistentParams() {
        persistentParams.removeAll()
    }
}
