//
//  customerView.swift
//  My_Study
//
//  Created by Zhiwei Han on 2022/3/8.
//  Copyright © 2022 HZW. All rights reserved.
//

import Foundation

class CustomerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
