//
//  BWNetworkingService.swift
//  My_Study
//
//  Created by Zhiwei Han on 2022/3/8.
//  Copyright © 2022 HZW. All rights reserved.
//

import Alamofire
import CommonCrypto
import Foundation

// 网络请求方式的Key
let BWRequestMethodKey = "BWRequestMethodKey"

// 网络请求成功的回调
typealias BWNetworkSuccess = (_ isSuccess: Bool, _ code: String, _ hint: String, _ list: AnyObject, _ responseData: AnyObject) -> Void
// 网络请求失败的回调
typealias BWNetworkFail = (_ error: AnyObject) -> Void
// 网络状态
typealias BWNetworkStatusBlock = (_ networkStatus: UInt32) -> Void

enum BWNetworkStatus: Int32 {
    case unkonw = -1 // 未知网络
    case notReachable = 0 // 网络无连接
    case wwan = 1 // 2，3，4G网络
    case wifi = 2 // wifi网络
}

class BWNetworkingService: NSObject {
    // MARK: var & let
    
    static let shareService = BWNetworkingService()
    // 记录当前请求路由
    private var currentRequestUrl: String = ""
    // 记录当前请求方式
    private var currentRequestMethod: HTTPMethod = .get
    // 记录当前请求接口参数
    private var currentParams: [String: Any]?
    // 记录当前接口是否需要缓存到本地
    private var shouldCache: Bool = false
    // 超时时间
    private let requestTimeout: TimeInterval = 20
    // 获取资源超时时间
    private let resourceTimeout: TimeInterval = 20
    // header
    private lazy var httpHeader: [String: Any] = {
        let header: HTTPHeaders = SessionManager.defaultHTTPHeaders
//        header["Authorization"] = ""
//        header.updateValue("application/json", forKey: "Accept")
        return header
    }()

    // 数据缓存路径
    private let cachePath = NSHomeDirectory() + "/Documents/NetworkingCaches/"
    // 当前网络状态
    private var networkStatus: BWNetworkStatus = .wifi
    // sessionManager
    private lazy var sessionManager: SessionManager = {
        #warning("此处换成其他的SessionManager在任务组中处理时第一次请求会报cancel错误，暂时换成default，以后再处理此处")
        return SessionManager.default
        
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
//        configuration.timeoutIntervalForRequest = self.requestTimeout
//        configuration.timeoutIntervalForResource = self.resourceTimeout
//        return SessionManager(configuration: configuration)
    }()
    
    // MARK: 基础网络请求
       
    /// 基础网络请求
    ///
    /// - Parameters:
    ///   - url: 请求链接
    ///   - method: 请求方式
    ///   - shouldCache: 是否需要缓存此处数据
    ///   - success: 请求成功回调
    ///   - fail: 请求失败回调
    public func baseRequestWith(url: String,
                                method: HTTPMethod,
                                shouldCache: Bool,
                                params: [String: Any]?,
                                success: @escaping BWNetworkSuccess,
                                fail: @escaping BWNetworkFail)
    {
        var urlPath: String = url
           
        let host: String = ""
        // 拼接域名
        urlPath = host + urlPath // CWAppConfig.shared.routerUrl + urlPath
        if self.networkStatus.rawValue == BWNetworkStatus.unkonw.rawValue || self.networkStatus.rawValue == BWNetworkStatus.notReachable.rawValue {
            if shouldCache == true {
                // 从缓存中取出此处的数据
                let cacheData = self.cacheDataFrom(urlPath: urlPath)
                if cacheData != nil {
                    // 数据处理
                    self.fetchData(cacheData as AnyObject, success)
                }
                if self.networkStatus == .notReachable || self.networkStatus == .unkonw {
                    return
                }
            }
        }
        // 清除空格
        if urlPath.contains(" ") {
            urlPath = urlPath.replacingOccurrences(of: " ", with: "")
        }
        var tempParams = params
        if tempParams == nil {
            tempParams = [String: Any]()
        }
        // 设置token
        tempParams?["token"] = "" // USERINFO.token ?? ""
        self.currentRequestUrl = urlPath
        self.currentRequestMethod = method
        self.currentParams = tempParams
        self.shouldCache = shouldCache
        debugPrint("当前请求接口:\(self.currentRequestUrl) 请求参数:\(String(describing: self.currentParams))")
        // 从服务器获取数据
        self.sessionManager.request(self.currentRequestUrl, method: self.currentRequestMethod, parameters: self.currentParams, encoding: URLEncoding.default, headers: nil).responseJSON { responseData in
            switch responseData.result {
            case .success:
                if let value = responseData.result.value as? [String: Any] {
                    // 是一个字典  此处可自定义一些处理 (判断接口是否返回了正确数据 接口是否报错 接口报错类型 是否需要重新登录。。。)
                    self.fetchData(value as AnyObject, success)
                    let resultDic: [String: AnyObject] = value as [String: AnyObject]
                    let code: String = resultDic["code"] as! String
                    let isSuccess = code == "40000"
                    if code == "40004" {
                        // 删除用户信息 重新登录
//                           USERINFO.removeLocalUserInfo()
//                           CWLoginHandle.showLoginVC()
                    }
                    // 判断是否需要缓存数据
                    if shouldCache == true, isSuccess == true {
                        // 缓存当前接口返回的数据
                        self.cacheResponseDataWith(responseData: value as AnyObject, urlPath: urlPath)
                    }
                }
            case .failure(let error):
                fail(error as AnyObject)
                debugPrint("接口请求失败--\(error)")
            }
        }
    }
       
    // 数据第一次处理
    func fetchData(_ responseData: AnyObject, _ success: BWNetworkSuccess) {
        let resultDic: [String: AnyObject] = responseData as! [String: AnyObject]
        let code: String = resultDic["code"] as! String
        let hint: String = resultDic["hint"] as! String
        let list: AnyObject = resultDic["list"] as AnyObject
        let isSuccess: Bool = code == "40000"
        success(isSuccess, code, hint, list, responseData as AnyObject)
    }
    
    // MARK: GET请求--不带接口缓存
       
    /// GET请求
    ///
    /// - Parameters:
    ///   - url: 请求链接
    ///   - params: 请求参数
    ///   - success: 成功的回调
    ///   - fail: 失败的回调
    public func requestGetWith(url: String,
                               params: [String: Any]?,
                               success: @escaping BWNetworkSuccess,
                               fail: @escaping BWNetworkFail)
    {
        self.requestGetWith(url: url, params: params, shouldCache: false, success: success, fail: fail)
    }
       
    // MARK: POST请求--不带接口缓存
       
    /// POST请求
    ///
    /// - Parameters:
    ///   - url: 请求链接
    ///   - params: 请求参数
    ///   - success: 成功的回调
    ///   - fail: 失败的回调
    public func requestPostWith(url: String,
                                params: [String: Any]?,
                                success: @escaping BWNetworkSuccess,
                                fail: @escaping BWNetworkFail)
    {
        self.requestPostWith(url: url, params: params, shouldCache: false, success: success, fail: fail)
    }
       
    // MARK: GET请求--携带是否缓存参数
       
    /// GET请求---携带是否缓存参数
    ///
    /// - Parameters:
    ///   - url: 请求路由
    ///   - params: 请求参数
    ///   - shouldCache: 是否需要缓存数据
    ///   - success: 成功的回调
    ///   - fail: 失败的回调
    public func requestGetWith(url: String,
                               params: [String: Any]?,
                               shouldCache: Bool,
                               success: @escaping BWNetworkSuccess,
                               fail: @escaping BWNetworkFail)
    {
        self.baseRequestWith(url: url, method: .get, shouldCache: shouldCache, params: params, success: success, fail: fail)
    }
       
    // MARK: POST请求---携带是否缓存参数
       
    /// POST请求---携带是否缓存参数
    ///
    /// - Parameters:
    ///   - url: 请求路由
    ///   - params: 请求参数
    ///   - shouldCache: 是否需要缓存数据
    ///   - success: 成功的回调
    ///   - fail: 失败的回调
    public func requestPostWith(url: String,
                                params: [String: Any]?,
                                shouldCache: Bool,
                                success: @escaping BWNetworkSuccess,
                                fail: @escaping BWNetworkFail)
    {
        self.baseRequestWith(url: url, method: .post, shouldCache: shouldCache, params: params, success: success, fail: fail)
    }
    
    /// 异步多接口请求--返回的数据由[urlPath: responseData]的字典数组形式按传入mutableUrls中的顺序返回
    ///
    /// - Parameters:
    ///   - mutableUrls: 多个请求接口
    ///   - params: 各接口请求参数  如果是POST请求 一定要传BWRequestMethodKey=.posto 否则将当做get请求处理
    ///   - completionHandle: 回调
    public func asyncMutablRequestWith(mutableUrls: [String],
                                       shouldCache: Bool,
                                       params: [[String: Any]]?,
                                       completionHandle: @escaping ([String: Any]) -> Void)
    {
        if params != nil, params?.count ?? 0 > 0 {
            // 抛出异常  参数字典数组(params)与请求路由数组(mutableUrls)数量需一致
            if params?.count != mutableUrls.count {
                assert(false, "参数字典数组(params)与请求路由数组(mutableUrls)数量需一致")
            }
        }
        // 创建字典于接收服务器返回的数据
        var resultDictionary: Dictionary = [String: AnyObject].init()
        // 创建调度组
        let dispatchGroup = DispatchGroup()
        // 创建并发队列
        let concurrentQueue = DispatchQueue(label: "com.mutableNetwork.xiongbenwan", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        for (index, url) in mutableUrls.enumerated() {
            var urlPath = url
            if urlPath.contains(" ") {
                // 清除urlPath中的空格
                urlPath = urlPath.replacingOccurrences(of: " ", with: "")
            }
            if urlPath.count <= 0 {
                // 抛出异常 传入的url不能为空字符串
                assert(false, "下标为\(index)的url不能为空字符串")
            }
            var paramDic: [String: Any]?
            var httpMethod: HTTPMethod = .get
            if params != nil, params?.count ?? 0 > 0 {
                paramDic = params?[index]
                if paramDic != nil {
                    // 取出字典中的请求方式的value  如果没有 则默认为GET请求
                    let requestMethod: HTTPMethod? = paramDic![BWRequestMethodKey] as? HTTPMethod
                    if requestMethod == HTTPMethod.post {
                        httpMethod = .post
                    }
                }
            }
            dispatchGroup.enter()
            concurrentQueue.async {
                self.baseRequestWith(url: urlPath, method: httpMethod, shouldCache: shouldCache, params: paramDic, success: { _, _, _, _, responseData in
                    // 将服务器返回的数据按照url:data的形式放在字典中
                    resultDictionary[urlPath] = responseData
                    dispatchGroup.leave()
                }, fail: { error in
                    resultDictionary[urlPath] = error
                    dispatchGroup.leave()
                })
            }
        }
        // 线程通知的方式等待任务组完成---回到主线程中处理数据
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandle(resultDictionary)
        }
    }
}

extension BWNetworkingService {
    /// 从缓存中获取数据
    ///
    /// - Parameter urlPath: 请求路由
    /// - Returns: 缓存数据
    public func cacheDataFrom(urlPath: String) -> Any? {
        // 对请求路由base64编码
        let base64Path = urlPath.md5String()
        // 拼接缓存路径
        var directorPath: String = self.cachePath
        directorPath.append(base64Path)
        let data: Data? = FileManager.default.contents(atPath: directorPath)
        let jsonData: Any?
        if data != nil {
            print("从缓存中获取数据:\(directorPath)")
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                return jsonData
            } catch {
                return data
            }
        }
        return nil
    }

    /// 将接口请求成功的数据缓存到本地
    ///
    /// - Parameters:
    ///   - responseData: 服务器返回的数据
    ///   - urlPath: 请求路由
    ///   - params: 请求参数
    public func cacheResponseDataWith(responseData: AnyObject,
                                      urlPath: String)
    {
        var directorPath: String = self.cachePath
        // 创建目录
        self.createRootCachePath(path: directorPath)
        // 对请求的路由进行base64编码
        let base64Path = urlPath.md5String()
        // 拼接路径
        directorPath.append(base64Path)
        // 将返回的数据转换成Data
        var data: Data?
        do {
            try data = JSONSerialization.data(withJSONObject: responseData, options: .prettyPrinted)
        } catch {}
        // 将data存储到指定的路径
        if data != nil {
            let cacheSuccess = FileManager.default.createFile(atPath: directorPath, contents: data, attributes: nil)
            if cacheSuccess == true {
                debugPrint("当前接口缓存成功:\(directorPath)")
            } else {
                debugPrint("当前接口缓存失败:\(directorPath)")
            }
        }
    }
    
    // 新建数据缓存路径
    func createRootCachePath(path: String) {
        if !FileManager.default.fileExists(atPath: path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("create cache dir error:" + error.localizedDescription + "\n")
                return
            }
        }
    }
}

extension BWNetworkingService {
    /// 网络状态监听
    public func monitorNetworkingStatus() {
        let reachability = NetworkReachabilityManager()
        reachability?.startListening()
        reachability?.listener = { [weak self] status in
            guard let weakSelf = self else { return }
            if reachability?.isReachable ?? false {
                switch status {
                case .notReachable:
                    weakSelf.networkStatus = BWNetworkStatus.notReachable
                case .unknown:
                    weakSelf.networkStatus = BWNetworkStatus.unkonw
                case .reachable(.wwan):
                    weakSelf.networkStatus = BWNetworkStatus.wwan
                case .reachable(.ethernetOrWiFi):
                    weakSelf.networkStatus = BWNetworkStatus.wifi
                }
            } else {
                weakSelf.networkStatus = BWNetworkStatus.notReachable
            }
        }
    }
}

//
// extension String {
//   //MD5加密
//   func md5String() -> String {
//       let utf8_str = self.cString(using: .utf8)
//
//       let str_len = CC_LONG(self.lengthOfBytes(using: .utf8))
//       let digest_len = Int(CC_MD5_DIGEST_LENGTH)
//       let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digest_len)
//       CC_MD5(utf8_str, str_len, result)
//       let str = NSMutableString()
//       for i in 0..<digest_len {
//           str.appendFormat("%02x", result[i])
//       }
//       result.deallocate()
//       return str as String
//   }
// }

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    // MD5加密
    func md5String() -> String {
        let utf8_str = self.cString(using: .utf8)
     
        let str_len = CC_LONG(self.lengthOfBytes(using: .utf8))
        let digest_len = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digest_len)
        CC_MD5(utf8_str, str_len, result)
        let str = NSMutableString()
        for i in 0 ..< digest_len {
            str.appendFormat("%02x", result[i])
        }
        result.deallocate()
        return str as String
    }
}
