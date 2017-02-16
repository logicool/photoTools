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
@interface ViewController ()

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
