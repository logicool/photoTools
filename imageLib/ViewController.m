//
//  ViewController.m
//  imageLib
//
//  Created by 高函 on 17/2/8.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "ViewController.h"
#import "CustomCameraViewController.h"
#import "PhotoPickerViewController.h"
#import "LGPhotoPickerViewController.h"
#import "LGPhotoAssets.h"
#import "SPBrowerViewController.h"

@interface ViewController () <LGPhotoPickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 30, CGRectGetMidY(self.view.frame) - 30, 60, 60);
    [testButton setTitle:@"照相" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [testButton setBackgroundColor:[UIColor purpleColor]];
    
    testButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [testButton addTarget:self action:@selector(openCarame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    
    
    
    UIButton *pickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pickerBtn.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 30, CGRectGetMidY(self.view.frame) - 100, 60, 60);
    [pickerBtn setTitle:@"选择" forState:UIControlStateNormal];
    [pickerBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [pickerBtn setBackgroundColor:[UIColor purpleColor]];
    
    pickerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [pickerBtn addTarget:self action:@selector(openPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickerBtn];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 30, CGRectGetMidY(self.view.frame) - 170, 60, 60);
    [moreBtn setTitle:@"多选择" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [moreBtn setBackgroundColor:[UIColor purpleColor]];
    
    moreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [moreBtn addTarget:self action:@selector(presentPhotoPickerViewControllerWithStyle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 30, CGRectGetMidY(self.view.frame) - 240, 60, 60);
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [shareBtn setBackgroundColor:[UIColor purpleColor]];
    
    shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [shareBtn addTarget:self action:@selector(presentPhotoShare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    NSNumber* value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

}


-(void) openCarame
{
    CustomCameraViewController *cc = [[CustomCameraViewController alloc] init];
    [self presentViewController:cc animated:YES completion:nil];
}

-(void) openPicker
{
    PhotoPickerViewController *pp = [[PhotoPickerViewController alloc] init];
    [self presentViewController:pp animated:YES completion:nil];
}

/**
 *  初始化相册选择器
 */
- (void)presentPhotoPickerViewControllerWithStyle {
    LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.maxCount = 11;   // 最多能选11张图片
    pickerVc.delegate = self;
    [pickerVc showPickerVc:self];
}

/**
 * 初始化分享
 */
- (void)presentPhotoShare {
    SPBrowerViewController *pickerVc = [[SPBrowerViewController alloc] init];
    [pickerVc showPickerVc:self];
//    [self.navigationController pushViewController:pickerVc animated:YES];
}

#pragma mark - LGPhotoPickerViewControllerDelegate

- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original{
    /*
     //assets的元素是LGPhotoAssets对象，获取image方法如下:
     NSMutableArray *thumbImageArray = [NSMutableArray array];
     NSMutableArray *originImage = [NSMutableArray array];
     NSMutableArray *fullResolutionImage = [NSMutableArray array];
     
     for (LGPhotoAssets *photo in assets) {
     //缩略图
     [thumbImageArray addObject:photo.thumbImage];
     //原图
     [originImage addObject:photo.originImage];
     //全屏图
     [fullResolutionImage addObject:fullResolutionImage];
     }
     */
    for (LGPhotoAssets *photo in assets) {
        NSLog(@"%@ withUrl: %@", photo.originImage, photo.absoluteURL);
    }
    
    NSInteger num = (long)assets.count;
    NSString *isOriginal = original? @"YES":@"NO";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送图片" message:[NSString stringWithFormat:@"您选择了%ld张图片\n是否原图：%@",(long)num,isOriginal] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

-(void) cancelPickerViewController
{
    NSLog(@"callBackTest", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
