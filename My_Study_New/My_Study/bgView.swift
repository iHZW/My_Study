
//
//  File.swift
//  My_Study
//
//  Created by Zhiwei Han on 2022/3/8.
//  Copyright © 2022 HZW. All rights reserved.
//

import Alamofire
import UIKit

class BGView: UIView {
    var downColor: UIColor
    var upColor: UIColor
    var bgColor: UIColor

    var titleName: String
    
    var nowColor: UIColor
    func createView() {
        let vc = ApplicationViewController() // 初始化
        vc.createView() // 调用viewcontroller方法
    }
    
    override init(frame: CGRect) {
        self.downColor = .red
        self.upColor = .black
        self.nowColor = .black
        self.bgColor = .purple
        self.titleName = "asd"
        super.init(frame: frame)
        self.setUpSubViews()
    }
    
    init(bgColor: UIColor, titleName: String) {
        self.bgColor = bgColor
        self.titleName = titleName
        self.downColor = .red
        self.upColor = .black
        self.nowColor = .black
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.setUpSubViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpSubViews() {
        self.backgroundColor = self.bgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.nowColor = self.downColor
        self.setNeedsDisplay()
        self.requestTest()
        super.touchesBegan(touches, with:event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        self.nowColor = self.upColor
        self.setNeedsDisplay()
        super.touchesEnded(touches, with: event)
    }
    
//    override func draw(_ rect: CGRect) {
//        let ctx = UIGraphicsGetCurrentContext()
//
//        CGContextClearRect(ctx, self.frame)
//
//        CGContextSetFillColorWithColor(ctx, nowColor!.CGColor)
//
//        CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, self.frame.width, self.frame.height))
//    }
    
//
//    override func draw(_ layer: CALayer, in ctx: CGContext) {
//        ctx.clear(self.frame)
//        ctx.setFillColor(nowColor!.cgColor)
//        ctx.fill(
//            CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
//    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.clear(self.frame)
        ctx.setFillColor(self.nowColor.cgColor)
        ctx.fill(
            CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
    }
    
    /// Qlamofire 测试
    func requestTest() {
        
        let url = "https://jsonplaceholder.typicode.com/posts?account=tom&password=147258"
//        let url = "http://127.0.0.1:4523/m1/1102411-0-5ea01a58/zq/wecomchat/chatrecord/detailList"
        let parameters:Parameters = ["account": "tom", "password": "147258"]
        Alamofire.request(url, method: .post, parameters:parameters).responseJSON { response in
            debugPrint(response)
            
            switch response.result {
            
            case .success(let json):
                print("json:\(json)")
                break
               
            case .failure(let error):
                print("error:\(error)")
                break
            }
        }
    }
}
