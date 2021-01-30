//
//  CTSettings.swift
//  CoreTextMagazine
//
//  Created by 韩志峰 on 2021/1/4.
//

import Foundation
import UIKit

class CTSetting {
    let margin : CGFloat = 20
    let columnsPerPage: CGFloat!
    var pageRect: CGRect!
    var columnRect: CGRect!
    init() {
        columnsPerPage = UIDevice.current.userInterfaceIdiom == .phone ? 1: 2
        pageRect = UIScreen.main.bounds.insetBy(dx: margin, dy: margin)
        columnRect = CGRect.init(x: 0, y: 0, width: pageRect.width / columnsPerPage, height: pageRect.height).insetBy(dx: margin, dy: margin)
    }
}
