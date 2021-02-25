//
//  ViewController.m
//  CoreTextCore
//
//  Created by 韩志峰 on 2021/1/20.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
#import "CTDisplayView.h"
#import "CTFrameParserConfig.h"
#import "CoreTextData.h"
#import "CTFrameParser.h"
@interface ViewController ()
@property (nonatomic, strong) CTDisplayView *displayView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.displayView = [[CTDisplayView alloc] initWithFrame:CGRectMake(10, 100, 200, 200)];
    self.displayView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview: self.displayView];
    
    CTFrameParserConfig *config = [[CTFrameParserConfig alloc] init];
    config.width = 300;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    CoreTextData *data = [CTFrameParser paraseTemplateFile:path config:config];
    self.displayView.data = data;
    self.displayView.frame = CGRectMake(10, 100, 300, data.height);

    
}


@end
