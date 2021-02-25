//
//  CoreUntil.h
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/27.
//

#import <Foundation/Foundation.h>
#import "CoreTextLinkData.h"
#import <UIKit/UIKit.h>
#import "CoreTextData.h"
NS_ASSUME_NONNULL_BEGIN

@interface CoreUntil : NSObject
+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;
@end

NS_ASSUME_NONNULL_END
