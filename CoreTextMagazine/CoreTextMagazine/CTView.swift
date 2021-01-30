//
//  CTView.swift
//  CoreTextMagazine
//
//  Created by 韩志峰 on 2021/1/4.
//

import UIKit
import CoreText
class CTView: UIScrollView {
    var imageIndex: Int!
    func buildFrames(withAttrString attrstring:NSAttributedString, andImages images:[[String: Any]]){
        imageIndex = 0
        isPagingEnabled = true
        let frameSetter = CTFramesetterCreateWithAttributedString(attrstring as CFAttributedString)
        var pageView = UIView()
        pageView.layer.borderColor = UIColor.blue.cgColor
        pageView.layer.borderWidth = 0.5
        var texPos = 0;
        var columnIndex: CGFloat = 0;
        var pageIndex: CGFloat = 0;
        var setting = CTSetting()
        while texPos < attrstring.length {
            if columnIndex.truncatingRemainder(dividingBy: setting.columnsPerPage) == 0{
                columnIndex = 0
                pageView = UIView.init(frame: setting.pageRect.offsetBy(dx: pageIndex * bounds.width, dy: 0))
                addSubview(pageView)
                pageIndex += 1
            }
            let columnXOrigin = pageView.frame.size.width / setting.columnsPerPage
            let columnOffset = columnIndex * columnXOrigin
            let columnFrame = setting.columnRect.offsetBy(dx: columnOffset, dy: 0);
            
            
            let path = CGMutablePath()
            path.addRect(CGRect.init(origin: .zero, size: columnFrame.size))
            let ctframe = CTFramesetterCreateFrame(frameSetter, CFRangeMake(texPos, 0), path, nil)
            let column = CTColumnView.init(frame: columnFrame, ctframe: ctframe)
            if images.count > imageIndex{
                attachImagesWithFrame(images, ctframe: ctframe, margin: setting.margin, columnView: column)
            }
            
            pageView.addSubview(column)
            column.layer.borderWidth = 0.5
            column.layer.borderColor = UIColor.red.cgColor
            
            let frameRange = CTFrameGetVisibleStringRange(ctframe)
            texPos += frameRange.length
            
            columnIndex += 1
            contentSize = CGSize.init(width: CGFloat(pageIndex) * bounds.size.width, height: bounds.size.height)
            
        }
    }
    
    func attachImagesWithFrame(_ images: [[String: Any]],ctframe: CTFrame,margin: CGFloat,columnView: CTColumnView){
        let lines = CTFrameGetLines(ctframe) as NSArray
        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), &origins)
        var nextImage = images[imageIndex]
        guard var imgLocation = nextImage["location"] as? Int else {
            return
        }
        for lineIndex in 0..<lines.count{
            let line = lines[lineIndex] as! CTLine
            if let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun],
               let imageFilename = nextImage["filename"] as? String,
               let img = UIImage(named: imageFilename){
                for run in glyphRuns{
                    let runRange = CTRunGetStringRange(run)
                    if runRange.location > imgLocation || runRange.location + runRange.length <= imgLocation{
                        continue
                    }
                    var imgBounds: CGRect = .zero
                    var ascent: CGFloat = 0
                    imgBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, nil, nil))
                    imgBounds.size.height = ascent
                    //3
                    let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                    imgBounds.origin.x = origins[lineIndex].x + xOffset
                    imgBounds.origin.y = origins[lineIndex].y
                    //4
                    columnView.images += [(image: img, frame: imgBounds)]
                    //5
                    imageIndex! += 1
                    if imageIndex < images.count {
                      nextImage = images[imageIndex]
                      imgLocation = (nextImage["location"] as AnyObject).intValue
                    }
                }
            }
        }
    }
    
    

}
