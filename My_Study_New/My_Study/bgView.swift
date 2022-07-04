
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nowColor = self.upColor
        self.setNeedsDisplay()
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
        let url = "https://51237c7d-cc9f-4698-a457-e41200573681.mock.pstmn.io/client/privatesea/operationlogbyid"
        let _: Parameters = [:]
        Alamofire.request(url, method: .post).responseJSON { response in
            debugPrint(response)
        }
    }
}
