//
//  SPBrowerViewController.m
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "SPBrowerViewController.h"
#import "SPGroupViewController.h"

@interface SPBrowerViewController ()
@property (nonatomic , strong) SPGroupViewController *groupVc;
@end

@implementation SPBrowerViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc{
    _groupVc = nil;
}

#pragma mark - init Action
- (void) createNavigationController{
    NSArray *tmpArray = @[
                          
                          @"http://wx3.sinaimg.cn/large/b5dd6343gy1fdvv1hqzzwj20m80br75b.jpg",
                          @"http://wx2.sinaimg.cn/large/005vbOHfgy1fdvubbh7olj30ia0qhq51.jpg",
                          @"http://wx4.sinaimg.cn/large/005vbOHfgy1fdvub8xmzhj30fn0kwt9w.jpg",
                          @"http://wx1.sinaimg.cn/large/005vbOHfgy1fdvub4qclrj30m80xcgpf.jpg",
                          @"http://wx1.sinaimg.cn/large/6cca1403ly1fdvpepflg6j20gl0gkmyd.jpg"
                          ];
    
    _groupVc = [[SPGroupViewController alloc] initWithData:@{@"description":@"测试", @"photoList":tmpArray}];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_groupVc];
    
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}



#pragma mark - 展示控制器
- (void)showPickerVc:(UIViewController *)vc{
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
