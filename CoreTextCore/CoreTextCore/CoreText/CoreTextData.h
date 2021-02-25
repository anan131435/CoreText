//
//  CoreTextData.h
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
NS_ASSUME_NONNULL_BEGIN
/*
 排版类用于实现文字的排版，持有CTFrameRef 实例以及 CTFrameRef实际绘制需要的高度
 */
@interface CoreTextData : NSObject
@property (nonatomic, assign) CTFrameRef ctframe;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSAttributedString *content;
@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, copy) NSArray *linkArray;
@end

NS_ASSUME_NONNULL_END
