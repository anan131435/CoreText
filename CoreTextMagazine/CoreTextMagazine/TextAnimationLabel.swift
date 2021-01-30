//
//  TextAnimationLabel.swift
//  CoreTextMagazine
//
//  Created by 韩志峰 on 2021/1/28.
//

import UIKit


typealias textAnimationClosure = () -> ()
typealias effectAnimationLayerClosure = (_ layer: CALayer) -> CALayer
typealias effectTextAnimationClosure = (calyer: CALayer,duration: TimeInterval, delay: TimeInterval,isFinished: Bool)

class TextAnimationLabel: UILabel,NSLayoutManagerDelegate {
    //继承NSMutableAttributedString 持有文字内容，字符发生改变时通知NSLayoutManager 对象
    let textStorage: NSTextStorage = NSTextStorage.init(string: "")
    let textLayoutManager: NSLayoutManager = NSLayoutManager()
    //确定region来放置 text
    let textContainser: NSTextContainer = NSTextContainer()
    var oldCharacterTextLayers:[CATextLayer] = []
    var newCharacterTextlayer: [CATextLayer] = []
    
    var animationOut: textAnimationClosure?
    var animationIn: textAnimationClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textKitObjectSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textKitObjectSetup()
        fatalError("init(coder:) has not been implemented")
    }
    func textKitObjectSetup(){
        textStorage.addLayoutManager(textLayoutManager)
        textLayoutManager.addTextContainer(textContainser)
        textLayoutManager.delegate = self
        textContainser.size = bounds.size
        textContainser.maximumNumberOfLines = numberOfLines
        textContainser.lineBreakMode = lineBreakMode
    }
    override var numberOfLines: Int{
        get{
            return super.numberOfLines
        }
        set{
            textContainser.maximumNumberOfLines = newValue
            super.numberOfLines = newValue
        }
    }
    
    override var bounds: CGRect{
        get{
            return super.bounds
        }
        set{
            textContainser.size = newValue.size
            super.bounds = newValue
        }
    }
    
    override var textColor: UIColor!{
        get{
            return super.textColor
        }
        set{
            super.textColor = newValue
            let text = self.textStorage.string
            self.text = text
        }
    }
    
    
    
    override var text: String!{
        get{
            return super.text
        }
        set{
            super.text = text
            let attributedText = NSMutableAttributedString.init(string: newValue)
            let textRange = NSMakeRange(0, newValue.count)
            let attrs = [NSAttributedStringKey.foregroundColor : self.textColor, NSAttributedStringKey.font : self.font]
            attributedText.setAttributes(attrs as [NSAttributedStringKey : Any], range: textRange)
            let paragryStyle = NSMutableParagraphStyle()
            paragryStyle.alignment = self.textAlignment
            attributedText.addAttributes([NSAttributedStringKey.paragraphStyle : paragryStyle], range: textRange)
            self.attributedText = attributedText
            
        }
    }
    
    override var attributedText: NSAttributedString?{
        get{
            return self.textStorage as NSAttributedString
        }
        set{
            cleanOutOldCharacterTextLayers()
            oldCharacterTextLayers = newCharacterTextlayer
            textStorage.setAttributedString(newValue!)
            self.startAnimation(animationClosure: nil)
            self.endAnimation(animationClosure: nil)
        }
    }
    
    
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        print(textStorage.string)
        calculateTextlayer()
    }
    func calculateTextlayer(){
        newCharacterTextlayer.removeAll()
        let attributedText = textStorage.string
        let wordRange = NSMakeRange(0, attributedText.count)
        let attributeString = self.internalAttributedText()
        let layoutRect = textLayoutManager.usedRect(for: textContainser)
        var index = wordRange.location
        let totalLength = NSMaxRange(wordRange)
        while index < totalLength {
            let glyphRange = NSMakeRange(index, 1)
            let characterRange = textLayoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let textContainer = textLayoutManager.textContainer(forGlyphAt: index, effectiveRange: nil)
            var glyphRect = textLayoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer!)
            
            let kerningRange = textLayoutManager.range(ofNominallySpacedGlyphsContaining: index)
            if kerningRange.location == index && kerningRange.length > 1 {
                if newCharacterTextlayer.count > 0 {
                    //如果前一个textlayer的frame.size.width不变大的话，当前的textLayer会遮挡住字体的一部分，比如“You”的Y右上角会被切掉一部分
                    let previousLayer = newCharacterTextlayer[newCharacterTextlayer.endIndex - 1]
                    var frame = previousLayer.frame
                    frame.size.width += glyphRect.maxX - frame.maxX
                    previousLayer.frame = frame
                }
            }
            //中间垂直
            glyphRect.origin.y += (self.bounds.size.height/2) - (layoutRect.size.height/2)
            //每个character生成对应的textlayer
            let textLayer = CATextLayer.init(frame: glyphRect, string: (attributeString?.attributedSubstring(from: characterRange))!)
            self.initialTextLayerAttributes(textLayer: textLayer)
            layer.addSublayer(textLayer)
            newCharacterTextlayer.append(textLayer)
            index += characterRange.length
        }
    }
    func cleanOutOldCharacterTextLayers(){
        for textlayer in oldCharacterTextLayers {
            textlayer.removeFromSuperlayer()
        }
        oldCharacterTextLayers.removeAll()
    }
    func internalAttributedText() -> NSMutableAttributedString! {
        let wordRange = NSMakeRange(0, textStorage.string.count);
        let attributedText = NSMutableAttributedString(string: textStorage.string);
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor , value: self.textColor.cgColor, range:wordRange);
        attributedText.addAttribute(NSAttributedStringKey.font , value: self.font, range:wordRange);
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range: wordRange)
        
        return attributedText;
    }
    func startAnimation(animationClosure: textAnimationClosure?){
        var longestAnimationDuration = 0.0
        var longestAnimationIndex = -1
        var index = 0
        
        for textLayer in oldCharacterTextLayers {
            let duration = TimeInterval(Double(arc4random()%100)/125.0) + 0.35
            //arc4random_uniform(100) 取值 0-99
            let delay = TimeInterval(arc4random_uniform(100)/500)
            //arc4random()%50 取值 0-49
            let distance = CGFloat(arc4random()%50) + 25
            let angle = CGFloat((Double((arc4random())) / Double.pi/2) - Double.pi/4)
            
            var transform = CATransform3DMakeTranslation(0, distance, 0)
            transform = CATransform3DRotate(transform, angle, 0, 0, 1)
            if delay + duration > longestAnimationDuration{
                longestAnimationDuration = delay + duration
                longestAnimationIndex = index
            }
            TELayerAnimation.textLayerAnimation(layer: textLayer, durationTime: duration, delay: delay) { (layer) -> CALayer in
                layer.transform = transform
                layer.opacity = 0.0
                return layer
            } finishedClosure: {[weak self] (finished) in
                guard let self = self else {return}
                textLayer.removeFromSuperlayer()
                if self.oldCharacterTextLayers.count > longestAnimationIndex && textLayer == self.oldCharacterTextLayers[longestAnimationIndex]{
                    if let out = animationClosure{
                        out()
                    }
                }
            }
            index = index + 1;
        }
    }
    func initialTextLayerAttributes(textLayer: CATextLayer) {
        textLayer.opacity = 0.0
    }
    func endAnimation(animationClosure: textAnimationClosure?){
        let duration = TimeInterval(arc4random()%200/100)+0.25
        let delay = 0.06
        for textLayer in newCharacterTextlayer {
            TELayerAnimation.textLayerAnimation(layer: textLayer, durationTime: duration, delay: delay) { (layer) -> CALayer in
                layer.opacity = 1.0
                return layer
            } finishedClosure: { (finished) in
                if let anima = animationClosure{
                    anima()
                }
            }

        }
    }
}

extension CATextLayer{
    convenience init(frame: CGRect, string: NSAttributedString) {
        self.init()
        self.contentsScale = UIScreen.main.scale
        self.frame = frame
        self.string = string
    }
}
