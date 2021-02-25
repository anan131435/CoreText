//
//  CTFrameParserConfig.h
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/*
 配置类用于实现排版时的可配置数据
 */
@interface CTFrameParserConfig : NSObject
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) UIColor *textColor;
@end

NS_ASSUME_NONNULL_END
