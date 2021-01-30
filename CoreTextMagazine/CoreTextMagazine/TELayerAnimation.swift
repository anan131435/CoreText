//
//  TELayerAnimation.swift
//  CoreTextMagazine
//
//  Created by 韩志峰 on 2021/1/29.
//

import UIKit


typealias completionClosure = (_ finished: Bool) -> Void
private let textAnimationGroupKey = "textAnimationGroupKey"

class TELayerAnimation: NSObject, CAAnimationDelegate {
    var completionBlock: completionClosure? = nil
    var textLayer: CALayer?
    
    class func textLayerAnimation(layer: CALayer, durationTime: TimeInterval, delay: TimeInterval, effectAnimationClosure: effectAnimationLayerClosure?,finishedClosure: completionClosure?) -> Void{
        let animationObjct = TELayerAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let oldLayer = animationObjct.animatableLayerCopy(layer: layer)
            var newLayer: CALayer?
            var animationGroup: CAAnimationGroup?
            animationObjct.completionBlock = finishedClosure
            if let effectAnimationClosure = effectAnimationClosure{
                CATransaction.begin()
                //关闭隐式动画
                CATransaction.setDisableActions(true)
                newLayer = effectAnimationClosure(layer)
                CATransaction.commit()
            }
            animationGroup = animationObjct.groupAnimationWithLayerChanges(old: oldLayer, new: newLayer!)
            if let textAnimationGroup = animationGroup{
                animationObjct.textLayer = layer
                //设置动画格式 开始时间 持续时间 淡入淡出样式
                textAnimationGroup.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
                textAnimationGroup.beginTime = CACurrentMediaTime()
                textAnimationGroup.duration = durationTime
                textAnimationGroup.delegate = animationObjct
                // 给layer层添加动画
                layer.add(textAnimationGroup, forKey: textAnimationGroupKey)
            }else{
                if finishedClosure != nil{
                    finishedClosure!(true)
                }
            }
        }
    }
    
    func groupAnimationWithLayerChanges(old olderLayer:CALayer, new newLayer:CALayer) -> CAAnimationGroup?{
        var animationGroup: CAAnimationGroup?
        var animations: [CABasicAnimation] = [CABasicAnimation]()
        
        if !olderLayer.position.equalTo(newLayer.position){
            let animation = CABasicAnimation()
            animation.fromValue = NSValue.init(cgPoint: olderLayer.position)
            animation.toValue = NSValue.init(cgPoint: newLayer.position)
            animation.keyPath = "position"
            animations.append(animation)
        }
        if !CATransform3DEqualToTransform(olderLayer.transform, newLayer.transform) {
            let basicAnimation = CABasicAnimation(keyPath: "transform")
            basicAnimation.fromValue = NSValue(caTransform3D: olderLayer.transform)
            basicAnimation.toValue = NSValue(caTransform3D: newLayer.transform)
            animations.append(basicAnimation)
        }
        if !olderLayer.frame.equalTo(newLayer.frame)
        {
            let basicAnimation = CABasicAnimation(keyPath: "frame")
            basicAnimation.fromValue = NSValue(cgRect: olderLayer.frame)
            basicAnimation.toValue = NSValue(cgRect: newLayer.frame)
            animations.append(basicAnimation)
        }
        
        if !olderLayer.bounds.equalTo(olderLayer.bounds)
        {
            let basicAnimation = CABasicAnimation(keyPath: "bounds")
            basicAnimation.fromValue = NSValue(cgRect: olderLayer.bounds)
            basicAnimation.toValue = NSValue(cgRect: newLayer.bounds)
            animations.append(basicAnimation)
        }
        
        if olderLayer.opacity != newLayer.opacity
        {
            let basicAnimation = CABasicAnimation(keyPath: "opacity")
            basicAnimation.fromValue = olderLayer.opacity
            basicAnimation.toValue = newLayer.opacity
            animations.append(basicAnimation)

        }
        
        if animations.count > 0{
            animationGroup = CAAnimationGroup()
            animationGroup?.animations = animations
        }
        return animationGroup
    }
    
    func animatableLayerCopy(layer:CALayer)->CALayer
    {
        let layerCopy = CALayer()
        layerCopy.opacity = layer.opacity
        layerCopy.bounds = layer.bounds
        layerCopy.transform = layer.transform
        layerCopy.position = layer.position
        return layerCopy
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completeBlock = self.completionBlock{
            self.textLayer?.removeAnimation(forKey: textAnimationGroupKey)
            completeBlock(flag)
        }
    }
    
}
