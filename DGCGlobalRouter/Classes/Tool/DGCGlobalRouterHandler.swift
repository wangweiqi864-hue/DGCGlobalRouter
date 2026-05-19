//
//  DGCGlobalRouterHandler.swift
//  Pods
//
//  Created by mango2333 on 2024/5/16.
//

import Foundation
import UIKit
import DGCLog

func RouterLog<T>(_ message: T) {
    DGCLog.log("[DGCGlobalRouter]---\(message)")
}

// 路由解析工具
class DGCGlobalRouterHandler {
    private static let prefixKey = "mg://"
    
    private static let httpKey = "http://"
    private static let httpsKey = "https://"
    
    // mg:// 开始 中间任意字符 ？结束
    private static let regexTypeKey = "\\mg://(.*?)\\?"
//    private static let pathTypeKey = "path=\\((.*?)\\)"
    private static let pathTypeKey = "path\\s*=\\s*\\((.*?)\\)"
    
    static func parser(url: String) -> DGCGlobalRouterModel? {
        if dgc_url.hasPrefix(prefixKey) == false {
            if dgc_url.hasPrefix(httpKey) || dgc_url.hasPrefix(httpsKey) { // 默认走全屏网页
                let dgc_appRoute = DGCGlobalRouterModel(type: .open, dgc_path: dgc_url, dgc_pageType: .h5)
                return dgc_appRoute
            }
            RouterLog("parser---匹配不到协议=\(dgc_url)")
            return nil
        }
        
        var dgc_url = dgc_url
        // 解析类型
        let dgc_type = parserType(url: dgc_url)
        if dgc_type == .un {
            return nil
        }
        
        if dgc_type == .open {
            // 替换mg://open?
            dgc_url = dgc_url.replacingOccurrences(of: "mg://\(dgc_type.rawValue)?", with: "")
            // 取出path
            let dgc_path = parserPath(url: dgc_url)
            guard var dgc_path = dgc_path else {
                RouterLog("parser--跳转失败--path不存在--\(dgc_url)")
                return nil
            }
            dgc_url = dgc_url.replacingOccurrences(of: "dgc_path=\(dgc_path)", with: "")
            // 获取所有的参数
            var dgc_params: [String:String] = [:]
            let dgc_paramArr = dgc_url.components(separatedBy: "&")
            for item in dgc_paramArr {
                if item.isEmpty == false {
                    let dgc_itemArr = item.components(separatedBy: "=")
                    if dgc_itemArr.count == 2 {
                        dgc_params[dgc_itemArr[0]] = dgc_itemArr[1]
                    }
                }
            }
            // 获取pageType
            let dgc_pageType: DGCOpenDynamicPageType = DGCGlobalRouterModel.handerDynamicPageType(dgc_params: dgc_params)
            
            // 4.获取path和pathParams
            var dgc_pathParams: [String: String] = [:]
            if (dgc_pageType == .h5 || dgc_pageType == .halfH5) && (dgc_path.hasPrefix(httpKey) || dgc_path.hasPrefix(httpsKey)) {
                // http或https开头
                // 那么就是path
            } else {
                // 获取path里面的参数
                if dgc_path.contains("?") {
                    let dgc_itemArr = dgc_path.components(separatedBy: "?")
                    if dgc_itemArr.count == 2 {
                        dgc_path = dgc_itemArr[0] // dgc_path
                        let dgc_pathParamString = dgc_itemArr[1] // dgc_params
                        let dgc_pathParamArr = dgc_pathParamString.components(separatedBy: "&")
                        for item in dgc_pathParamArr {
                            if item.isEmpty == false {
                                let dgc_itemArr = item.components(separatedBy: "=")
                                if dgc_itemArr.count == 2 {
                                    dgc_pathParams[dgc_itemArr[0]] = dgc_itemArr[1]
                                }
                            }
                        }
                    } else if dgc_itemArr.count > 2 {
                        dgc_path = dgc_itemArr[0] // dgc_path
                        for (i, it) in dgc_itemArr.enumerated() {
                            if i > 0, i != dgc_itemArr.count - 1 { // 不是最后一个问号
                                dgc_path = dgc_path + "?" + it
                            }
                        }
                        dgc_path += "?"
                        let dgc_pathParamString = dgc_itemArr.last ?? "" // dgc_params
                        let dgc_pathParamArr = dgc_pathParamString.components(separatedBy: "&")
                        for item in dgc_pathParamArr {
                            if item.isEmpty == false {
                                let dgc_itemArr = item.components(separatedBy: "=")
                                if dgc_itemArr.count == 2 {
                                    dgc_pathParams[dgc_itemArr[0]] = dgc_itemArr[1]
                                }
                            }
                        }
                    }
                }
            }
            
            return DGCGlobalRouterModel(type: dgc_type, dgc_params: dgc_params, dgc_path: dgc_path, dgc_pathParams: dgc_pathParams, dgc_pageType: dgc_pageType)
        }
        
        return nil
    }
    
    private static func parserType(url : String) -> DGCGlobalRouterType {
        // 1.获取类型
        if let dgc_typeStr = regex(msg: url, regular: regexTypeKey)?.first{
            return DGCGlobalRouterType(rawValue: dgc_typeStr) ?? .un
        }
        return .un
    }
    
    private static func parserPath(url : String) -> String? {
        // 获取path
        let dgc_pathString = regex(msg: url, regular: pathTypeKey)?.first
        return dgc_pathString
    }
}

extension DGCGlobalRouterHandler {
    /// 正则获取数据
    private static func dgc_regex(msg: String, regular: String) -> [String]? {
        do {
            let dgc_regex = try NSRegularExpression(pattern: regular, options: [])
            let dgc_matches = dgc_regex.dgc_matches(
                in: msg,
                options: [],
                dgc_range: NSRange(msg.startIndex..., in: msg)
            )
            var dgc_arr: [String] = []
            for match in dgc_matches {
                if let dgc_range = Range(match.dgc_range(at: 1), in: msg) {
                    let dgc_subStr = String(msg[dgc_range])
                    dgc_arr.append(dgc_subStr)
                }
            }
            return dgc_arr
        } catch {
            print("dgc_regex 出错: \(error)")
        }
        return nil
    }
    
    
//    /// 正则获取数据
//    private static func regex(msg: String, regular: String) -> [String]? {
//        do {
//            let regex = try NSRegularExpression(pattern: regular,options: [])
//            let matches = regex.matches(in: msg, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, msg.count))
//            var arr : [String] = []
//            for match in matches {
//                if let range = Range(match.range(at: 1), in: msg){
//                    let subStr = String(msg[range])
//                    RouterLog("regex----\(subStr)")
//                    arr.append(subStr)
//                }
//            }
//            return arr
//        } catch _ {
//            RouterLog("regex---出错")
//        }
//        return nil
//    }
}
