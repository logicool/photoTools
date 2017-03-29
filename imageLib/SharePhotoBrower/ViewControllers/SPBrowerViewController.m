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
    _groupVc = [[SPGroupViewController alloc] initWithData:@{}];
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
