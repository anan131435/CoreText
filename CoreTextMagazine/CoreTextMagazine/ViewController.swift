//
//  ViewController.swift
//  CoreTextMagazine
//
//  Created by 韩志峰 on 2021/1/4.
//

import UIKit

class ViewController: UIViewController,CAAnimationDelegate {
    var testView: UIView!
    var button: UIButton!
    var exlictBtn: UIButton!
    
    var textEffectLabel: TextAnimationLabel!
    var changeText:UIButton = UIButton(type: UIButtonType.system)
    var backgroundImage:UIImageView = UIImageView()
    var textLayer: CATextLayer!
    private var textArray = [
        "What is design?",
        "Design Code By Swift",
        "Design is not just",
        "what it looks like",
        "and feels like.",
        "Hello,Swift",
        "is how it works.",
        "- Steve Jobs",
        "Older people",
        "sit down and ask,",
        "'What is it?'",
        "but the boy asks,",
        "'What can I do with it?'.",
        "- Steve Jobs",
        "Swift",
        "Objective-C",
        "iPhone", "iPad", "Mac Mini",
        "MacBook Pro", "Mac Pro",
        "爱老婆"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
//        textLayerTest()
//        characterAnimation()
        test()
        
    }
    func textLayerTest(){
        textLayer = CATextLayer.init()
        textLayer.frame = CGRect.init(x: 10, y: 110, width: 300, height: 400)
        textLayer.string = "Steve jobs Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque massa arcu, eleifend vel varius in, facilisis pulvinar leo. Nunc quis nunc at mauris pharetra condimentum ut ac neque. Nunc elementum, libero ut porttitor dictum, diam odio congue lacus, vel fringilla sapien diam at purus. Etiam suscipit pretium nunc sit amet lobortis"
        textLayer.backgroundColor = UIColor.red.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.isWrapped = true
        textLayer.alignmentMode = kCAAlignmentNatural
        self.view.layer.addSublayer(textLayer)
    }
    func characterAnimation(){
        let frame =  CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 100)
        self.textEffectLabel = TextAnimationLabel(frame: frame)
        self.view.addSubview(self.textEffectLabel)
        self.view.backgroundColor = .red
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.textEffectLabel.font = UIFont.systemFont(ofSize: 38.0)//UIFont(name: "Apple SD Gothic Neo", size: 38)
        self.textEffectLabel.numberOfLines = 5
        self.textEffectLabel.textAlignment = NSTextAlignment.center
        self.textEffectLabel.text = "Yes,Hello World"
        self.textEffectLabel.textColor = UIColor.white
        
        self.changeButtonSetup()
    }
    func changeButtonSetup(){
        changeText.frame = CGRect.init(x: 0, y: 300, width: 100, height: 30)
        changeText.addTarget(self, action: #selector(changeTextClick), for: .touchUpInside)
        changeText.setTitle("Change Text", for: .normal)
        changeText.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(changeText)
    }
    @objc func changeTextClick(){
        let index = Int(arc4random_uniform(20))
        if index < textArray.count
        {
            let text:String = textArray[index]
            self.textEffectLabel.text = text
        }
    }
    
    
    func test(){
        testView = UIView.init(frame: CGRect.init(x: 10, y: 50, width: 200, height: 200))
        testView.backgroundColor = .red
        self.view.addSubview(testView)
        
        button = UIButton.init(frame: CGRect.init(x: 10, y: 400, width: 100, height: 30))
        button.setTitle("change", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(buttonDidClick), for: .touchUpInside)
        self.view.addSubview(button)
        
        exlictBtn = UIButton.init(frame: CGRect.init(x: 300, y: 400, width: 100, height: 30))
        exlictBtn.setTitle("change", for: .normal)
        exlictBtn.setTitleColor(.gray, for: .normal)
        exlictBtn.addTarget(self, action: #selector(exlictbuttonDidClick), for: .touchUpInside)
        self.view.addSubview(exlictBtn)
    }
    @objc func buttonDidClick(){
        //开启隐式动画
        
//        testView.layer.opacity = 0.5
        let basicAnimation = CABasicAnimation(keyPath: "opacity")
        basicAnimation.fromValue = testView.layer.opacity
        basicAnimation.toValue = 0.5
        basicAnimation.duration = 1.0
        basicAnimation.delegate = self
        testView.layer.add(basicAnimation, forKey: "ddd")
    }
    @objc func exlictbuttonDidClick(){
        CATransaction.setDisableActions(false)
        testView.backgroundColor = UIColor.blue
    }
    func setupCtViewAttr(){
        guard let file = Bundle.main.path(forResource: "zombies", ofType: "txt") else { return }
        do {
            let text = try String.init(contentsOfFile: file, encoding: .utf8)
            let parase = MarkupParaser()
            parase.paraseMarkup(text)
//            ctView.buildFrames(withAttrString: parase.attrString, andImages: parase.images)
        } catch _ {
            
        }
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        testView.layer.removeAllAnimations()
    }

}

