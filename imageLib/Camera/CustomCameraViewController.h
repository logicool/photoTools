//
//  CustomCameraViewController.h
//  imageLib
//
//  Created by 高函 on 17/2/8.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreMotion/CMMotionManager.h>
#import <Photos/Photos.h>

#import "CameraFocusView.h"
#import "CameraGridView.h"
#import "CameraConfirmView.h"

@class CustomCameraViewController;

@protocol CustomCameraViewControllerDelegate <NSObject>
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage;
- (void)cancelSave:(CustomCameraViewController *) viewController;
@end

@interface CustomCameraViewController : UIViewController

/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;

/**
 *  捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
 */
@property (nonatomic, strong) AVCaptureDevice *device;

/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
//@property (nonatomic, strong) AVCaptureMetadataOutput* photoOutput;
@property (nonatomic, strong)AVCaptureStillImageOutput *photoOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
//底部工具条
@property (nonatomic, strong) UIView* downView;
@property (nonatomic)UIButton *flashButton;
@property (nonatomic)UIButton *cancelButton;
@property (nonatomic)CameraGridView *gridView;
@property (nonatomic, strong) UIImage *imageToDisplay;
@property (nonatomic)BOOL canCa;
@property (nonatomic, weak) id <CustomCameraViewControllerDelegate> delegate;
// 螺旋仪和加速器
@property (nonatomic, strong) CMMotionManager * motionManager;
@end
