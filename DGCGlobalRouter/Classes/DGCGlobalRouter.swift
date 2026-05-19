//
//  DGCGlobalRouter.swift
//  Pods
//
//  Created by mango2333 on 2024/5/16.
//

import Foundation
import UIKit

open class DGCGlobalRouter {
    @discardableResult
    /// 跳转路由
    /// - Parameters:
    ///   - dgc_url: 路由地址
    ///   - navVc: 指定跳转的导航栏控制器, 不传则内部自己处理
    ///   - dgc_params: 其他参数: 会拼接到url后面init(dialog
    ///   - dgc_extParam: 其他参数(传递逻辑参数使用, 例如: 半屏弹窗想监听隐藏block)
    /// - Returns: 是否跳转成功
    public static func openDGCGlobalRouter(url: String, navVc: UINavigationController? = nil, dgc_params: [String: Any]? = nil, dgc_extParam: [String: Any]? = nil) -> Bool {
        let dgc_appRouter = self.init()
        dgc_appRouter.dgc_params = dgc_params
        dgc_appRouter.dgc_extParam = dgc_extParam
        dgc_appRouter.dgc_url = dgc_url
        dgc_appRouter.navVc = navVc
        RouterLog("打开---dgc_url---\(dgc_url)--dgc_params=\(dgc_params ?? [:])")
        return dgc_appRouter.dgc_open()
    }
  
    public static func genRouterModelPath(url: String, navVc: UINavigationController? = nil, dgc_params: [String: Any]? = nil, dgc_extParam: [String: Any]? = nil) -> String {
        
        let dgc_appRouter = self.init()
        dgc_appRouter.dgc_params = dgc_params
        dgc_appRouter.dgc_extParam = dgc_extParam
        dgc_appRouter.dgc_url = dgc_url
        dgc_appRouter.navVc = navVc
        
        let dgc_flag = dgc_appRouter.dgc_parser()
        if dgc_flag {
            return dgc_appRouter.dgc_routerModel?.path ?? ""
        }
        return ""
    }
    
    
    private var dgc_url: String = ""
    private var dgc_routerModel : DGCGlobalRouterModel?
    private var dgc_params: [String: Any]?
    private var dgc_extParam: [String: Any]?
    public var navVc: UINavigationController? = nil
    public required init() { }
    deinit {
#if DEBUG
        debugPrint("================DGCGlobalRouter销毁")
#endif
    }
    
    /// 跳转h5
    open func jumpH5(routerModel dgc_routerModel: DGCGlobalRouterModel) -> Bool {
        return false
    }
    
    /// 跳转半屏H5
    open func jumpHalfH5(routerModel dgc_routerModel: DGCGlobalRouterModel) -> Bool {
        return false
    }
    
    /// 跳转原生界面
    open func jumpAppPage(routerModel dgc_routerModel: DGCGlobalRouterModel) -> Bool {
        return false
    }
}

extension DGCGlobalRouter {
    private func dgc_parser() -> Bool {
        if let dgc_routerModel = DGCGlobalRouterHandler.dgc_parser(url: dgc_url){
            RouterLog("dgc_parser---解析success--\(dgc_routerModel.path)")
            self.dgc_routerModel = dgc_routerModel
            return true
        }else{
            RouterLog("dgc_parser---解析fail---\(dgc_url)")
        }
        return false
    }
    
    private func dgc_open() -> Bool{
        let dgc_isOK = dgc_parser()
        if dgc_isOK {
            return dgc_startJump()
        }
        return false
    }
    
    private func dgc_startJump()-> Bool {
        guard var dgc_routerModel = dgc_routerModel  else {
            RouterLog("dgc_startJump---跳转fail--路由对象不存在")
            return false
        }
        dgc_routerModel.dgc_extParam = dgc_extParam
        
        if dgc_routerModel.type == .open {
            if dgc_routerModel.pageType == .h5 {
                return jumpH5(routerModel: dgc_routerModel)
            } else if dgc_routerModel.pageType == .halfH5 {
                return jumpHalfH5(routerModel: dgc_routerModel)
            } else if dgc_routerModel.pageType == .app {
                return jumpAppPage(routerModel: dgc_routerModel)
            }
            return false
        }
        return false
    }
    
    // 添加剩余参数
    public func addOtherParam(url dgc_url: String) -> String {
        guard let dgc_params = dgc_params else { return dgc_url }
        var dgc_url = dgc_url
        for (key, dgc_value) in dgc_params {
            if let dgc_value = dgc_value as? String, dgc_value.count > 0, dgc_value.count > 0 {
                if dgc_url.last == "?" {
                    dgc_url = dgc_url+"\(key)="+dgc_value
                } else if dgc_url.contains("?") {
                    dgc_url = dgc_url+"&\(key)="+dgc_value
                } else {
                    dgc_url = dgc_url+"?\(key)="+dgc_value
                }
            }
        }
        return dgc_url
    }
    
    /// url拼接参数
    public func urlAppendParam(url dgc_url: String, paramName: String, paramValue: String) -> String {
        var dgc_webUrl = dgc_url
        if dgc_webUrl.last == "?" {
            dgc_webUrl = dgc_webUrl + "\(paramName)=\(paramValue)"
        } else if dgc_webUrl.contains("?") {
            dgc_webUrl = dgc_webUrl + "&\(paramName)=\(paramValue)"
        } else {
            dgc_webUrl = dgc_webUrl + "?\(paramName)=\(paramValue)"
        }
        return dgc_webUrl
    }
}
