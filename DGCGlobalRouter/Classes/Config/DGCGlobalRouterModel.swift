//
//  DGCGlobalRouterModel.swift
//  Pods
//
//  Created by mango2333 on 2024/5/16.
//

import Foundation
import UIKit

private let dgc_dynamicKey = "dynamic"
public let dataKey = "data"

public enum DGCGlobalRouterType: String {
    case un = "un"
    case open = "open" // 通用路由
}

public enum DGCOpenDynamicPageType : String { // 第一位
    case un = "0"
    case h5 = "1" // 跳转全屏web
    case halfH5 = "2" // popUp半屏web
    case app = "3" // 跳转app内部页面
}

public enum DGCOpenDynamicTokenType : String { // 第二位
    case un = "0"
    case xToken = "1" // 需要拼接xToken --- key叫xToken
    case token = "2" // 需要拼接token --- key叫token
    case Universal = "6" // 表示走新的通配符方式替换path ,一般用作URL替换
}

public enum DGCOpenDynamicLangType : String { // 第三位
    case un = "0"
    case lang = "1" // 需要拼接lang
}

public enum DGCOpenDynamicUidType : String { // 第四位
    case un = "0"
    case uid = "1" // 需要拼接uid
}

public enum DGCOpenDynamicVersionType : String { // 第五位
    case un = "0"
    case version = "1" // 需要拼接版本号, version
}

public enum DGCOpenDataBottomSafeType : String { // WHData第一位
    case un = "0"
    case has = "1" // 原生保留底部安全距离
    case none = "2" // h5自行控制底部间距
}

public struct DGCGlobalRouterModel {
    public var type: DGCGlobalRouterType = .un
    
    public var params: [String: String] = [:]
    // path 里面的参数
    public var path = ""
    public var pathParams: [String: String] = [:]
    // 调整传递的参数
    public var extParam: [String: Any]?
    
    public var pageType: DGCOpenDynamicPageType = .un
    public var tokenType: DGCOpenDynamicTokenType {
        get {
            if let dynamic = params[dgc_dynamicKey], dynamic.isEmpty == false {
                let array = Array(dynamic)
                if array.count > 1 {
                    let c = array[1]
                    return DGCOpenDynamicTokenType(rawValue: String(c)) ?? .un
                }
            }
            return .un
        }
    }
    
    public var langType: DGCOpenDynamicLangType {
        get {
            if let dynamic = params[dgc_dynamicKey], dynamic.isEmpty == false {
                let array = Array(dynamic)
                if array.count > 2 {
                    let c = array[2]
                    return DGCOpenDynamicLangType(rawValue: String(c)) ?? .un
                }
            }
            return .un
        }
    }
    
    public var uidType: DGCOpenDynamicUidType {
        get {
            if let dynamic = params[dgc_dynamicKey], dynamic.isEmpty == false {
                let array = Array(dynamic)
                if array.count > 3 {
                    let c = array[3]
                    return DGCOpenDynamicUidType(rawValue: String(c)) ?? .un
                }
            }
            return .un
        }
    }
    
    public var versionType: DGCOpenDynamicVersionType {
        get {
            if let dynamic = params["dynamic"], dynamic.isEmpty == false {
                let array = Array(dynamic)
                if array.count > 4 {
                    let c = array[4]
                    return DGCOpenDynamicVersionType(rawValue: String(c)) ?? .un
                }
            }
            return .un
        }
    }
    
    public var bottomSafeType: DGCOpenDataBottomSafeType {
        get {
            if let whData = pathParams[dataKey], whData.isEmpty == false {
                let array = Array(whData)
                if array.count > 0 {
                    let c = array[0]
                    return DGCOpenDataBottomSafeType(rawValue: String(c)) ?? .un
                }
            }
            return .un
        }
    }
    
    /// 解析dynamic的第一位字符
    static func handerDynamicPageType(params: [String: String]) -> DGCOpenDynamicPageType {
        if let dgc_dynamic = params[dgc_dynamicKey], dgc_dynamic.isEmpty == false {
            let dgc_array = Array(dgc_dynamic)
            if dgc_array.count > 0 {
                let dgc_c = dgc_array[0]
                return DGCOpenDynamicPageType(rawValue: String(dgc_c)) ?? .un
            }
        }
        return .un
    }
}
