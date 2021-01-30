//
//  CTColumnView.swift
//  CoreTextMagazine
//
//  Created by 韩志峰 on 2021/1/4.
//

import UIKit
import CoreText
class CTColumnView: UIView {

    var ctFrame: CTFrame!
    var images: [(image: UIImage, frame: CGRect)] = []
    required init(frame: CGRect,ctframe: CTFrame) {
        super.init(frame: frame)
        self.ctFrame = ctframe
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return  }
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        CTFrameDraw(ctFrame, context)
        
        for imageData in images{
            if let image = imageData.image.cgImage{
                let imgBounds = imageData.frame
                context.draw(image, in: imgBounds)
            }
        }
    }
    

}
