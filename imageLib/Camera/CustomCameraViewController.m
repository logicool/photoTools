//
//  CustomCameraViewController.m
//  imageLib
//
//  Created by 高函 on 17/2/8.
//  Copyright © 2017年 高函. All rights reserved.
//
#define kScreenScale [UIScreen mainScreen].scale
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width
#define kScreenHeight kScreenBounds.size.height
#define kFrameWidth (self.view.frame.size.width)
#define kFrameHeight (self.view.frame.size.height)
//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]


#import "CustomCameraViewController.h"

typedef void(^codeBlock)();

static CGFloat BOTTOM_HEIGHT = 60;
static CGFloat TOP_HEIGHT = 44;

@interface CustomCameraViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate, CameraFocusDelegate, CameraConfirmViewDelegate>

@end

@implementation CustomCameraViewController

/**
 * 拍照时隐藏statusbar内容
 */
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// 开启session
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.session) {
        [self.session startRunning];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self startMotionManager];
    
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    UIDevice *device = [UIDevice currentDevice];
//    [notificationCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_motionManager stopDeviceMotionUpdates];
    
}

// 关闭session
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.session) {
        [self.session stopRunning];
    }
    
    NSNumber* value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    _canCa = [self canUserCamear];
    if (_canCa) {
        [self customCamera];
        [self makeTopViewUI];
        [self makeDownViewUI];
    }else{
        return;
    }
}

#pragma mark - 重力加速度判断屏幕旋转
// 每隔一个间隔做轮询，调用处理函数
- (void)startMotionManager{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (_motionManager.deviceMotionAvailable) {
        NSLog(@"Device Motion Available");
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                                
                                            }];
    } else {
        NSLog(@"No device motion on device.");
        [self setMotionManager:nil];
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    
    // 默认设置竖屏
    NSNumber *value;
    
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            // UIDeviceOrientationPortraitUpsideDown;
            value = [NSNumber numberWithInt:UIDeviceOrientationPortraitUpsideDown];
            [self rotation_button:180.0];
            self.gridView.hidden = NO;
        }
        else{
            // UIDeviceOrientationPortrait;
            value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
            [self rotation_button:0.0];
            self.gridView.hidden = NO;
        }
    }
    else
    {
        if (x >= 0){
            // UIDeviceOrientationLandscapeRight;
            value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeRight];
            [self rotation_button:90.0*3];
            self.gridView.hidden = YES;
        }
        else{
            // UIDeviceOrientationLandscapeLeft;
            value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
            [self rotation_button:90.0];
            self.gridView.hidden = YES;
        }
    }
    
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}


-(void)rotation_button:(float)n {
    _cancelButton.transform = CGAffineTransformMakeRotation(n*M_PI/180.0);
}

#pragma mark - core部分
/**
 * 顶部工具条
 */
- (void)makeTopViewUI
{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFrameWidth, TOP_HEIGHT)];
    topView.backgroundColor = [UIColor blackColor];
    
    topView.alpha = 0.7f;
    [self.view addSubview:topView];
    
    //设置闪光灯默认状体为关闭
    UIButton *flashBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 4, 70, 35)];
    flashBtn.tag = 2015;
    if (self.device.flashMode == 0) {
        [flashBtn setTitle:@"灯关" forState:UIControlStateNormal];
    }else if(self.device.flashMode == 1){
        [flashBtn setTitle:@"灯开" forState:UIControlStateNormal];
    }else if(self.device.flashMode == 2){
        [flashBtn setTitle:@"自动" forState:UIControlStateNormal];
    }
    [flashBtn addTarget:self action:@selector(flashOfCamera:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:flashBtn];

}
/**
 * 底部工具条
 */
- (void)makeDownViewUI
{
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, kFrameHeight - BOTTOM_HEIGHT, kFrameWidth, BOTTOM_HEIGHT)];
    _downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_downView];
    
    CGFloat x = (_downView.frame.size.width) / 3;
    
    _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, x, BOTTOM_HEIGHT)];
//    _cancelButton.backgroundColor = [UIColor redColor];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_cancelButton];
    
    UIButton *takePhotoBtn = [[UIButton alloc]initWithFrame:CGRectMake(x, 5, x, BOTTOM_HEIGHT - 10 )];
//    takePhotoBtn.backgroundColor = [UIColor purpleColor];
    [takePhotoBtn setImage:IMAGE(@"photograph.png") forState:UIControlStateNormal];
    takePhotoBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [takePhotoBtn setImage:IMAGE(@"photograph_Select.png") forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:takePhotoBtn];
    
}

/**
 * 初始化拍摄主页面
 */
- (void)customCamera
{
    //创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // input
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // output
    self.photoOutput = [[AVCaptureStillImageOutput alloc] init];
    // Session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.videoInput])
    {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.photoOutput])
    {
        [self.session addOutput:self.photoOutput];
    }
    //预览层的生成
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = viewWidth / 480 * 640;
    self.previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = CGRectMake(0, TOP_HEIGHT, viewWidth, viewHeight);
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];

    
    //设备取景开始
    if (self.session) {
        [self.session startRunning];
    }
    
    // 配置初始化相机属性
    if ([_device lockForConfiguration:nil]) {
        // 开启自动闪光灯
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        // 开启持续自动聚焦
        if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        [_device unlockForConfiguration];
    }
    
    // 添加竖屏取景框边界
    self.gridView = [[CameraGridView alloc]initWithFrame:self.previewLayer.frame];
    [self.view addSubview:self.gridView];
    self.gridView.hidden = NO;
    
    // 添加聚焦框
    CameraFocusView *focuseView = [[CameraFocusView alloc]initWithFrame:self.previewLayer.frame];
    focuseView.delegate = self;
    [self.view addSubview:focuseView];
}

#pragma mark - 聚焦框
-(void)cameraFocusOptionsWithPoint:(CGPoint)point
{
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        // 计算聚焦点
        CGPoint pointInCamera = [self.previewLayer captureDevicePointOfInterestForPoint:point];
        if ([self.device isFocusPointOfInterestSupported]) {
            [self.device setFocusPointOfInterest:pointInCamera];
        }
        // 聚焦模式
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        // 曝光模式
        if ([self.device isExposurePointOfInterestSupported]) {
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [self.device setExposurePointOfInterest:pointInCamera];
        }
        
        [self.device setSubjectAreaChangeMonitoringEnabled:YES];
        [self.device setFocusPointOfInterest:pointInCamera];
        
        
        
        //对焦模式和对焦点
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {

            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        [self.device unlockForConfiguration];
    }
}
//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        
    }
}

#pragma mark - 闪光灯开光
- (void)flashOfCamera:(UIButton *)btn
{
    if (btn.tag == 2015) {
        if (self.device.flashMode == 0) {
            [self flashLightModel:^{
                [self.device setFlashMode:AVCaptureFlashModeAuto];
            }];
            [btn setTitle:@"自动" forState:UIControlStateNormal];
        }else if (self.device.flashMode == 1){
            [self flashLightModel:^{
                [self.device setFlashMode:AVCaptureFlashModeOff];
            }];
            [btn setTitle:@"灯关" forState:UIControlStateNormal];
        }else if (self.device.flashMode == 2){
            [self flashLightModel:^{
                [self.device setFlashMode:AVCaptureFlashModeOn];
            }];
            [btn setTitle:@"灯开" forState:UIControlStateNormal];
        }
    }
}
- (void) flashLightModel : (codeBlock) codeBlock{
    if (!codeBlock) return;
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    codeBlock();
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
    [self.session startRunning];
}

#pragma mark - 拍照
- (void)takePhoto{
    [self captureImage];
    UIView *lightScreenView = [[UIView alloc] init];
    lightScreenView.frame = self.view.bounds;
    lightScreenView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lightScreenView];
    [UIView animateWithDuration:.5 animations:^{
        lightScreenView.alpha = 0;
    } completion:^(BOOL finished) {
        [lightScreenView removeFromSuperview];
    }];
}

#pragma mark - 截取照片
- (void) captureImage
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.photoOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    __weak typeof (self) weakSelf = self;
    [self.photoOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *t_image = [UIImage imageWithData:imageData];
        //拍摄后的照片
        t_image = [weakSelf cutImage:t_image];
        t_image = [weakSelf fixOrientation:t_image];

        weakSelf.imageToDisplay = t_image;
        
        [weakSelf displayImage:t_image];
//        [self saveImageToPhotoAlbum:t_image];
    }];
}

#pragma mark - 展示确认页
- (void)displayImage:(UIImage *) images {
    CameraConfirmView *view = [[CameraConfirmView alloc] initWithFrame:self.view.frame];
    view.delegate = self;
    [view imageForConfirm: images];
    [self.view addSubview:view];
}

#pragma mark - 保存至相册 // @FIX 做成protocol协议，在其他controller实现保存方法
//- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
//{
////    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    __block NSString *createdAssetID =nil;//唯一标识，可以用于图片资源获取
//    
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:savedImage].placeholderForCreatedAsset.localIdentifier;
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//        if (success) {
//            if (createdAssetID != nil) {
//                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
//                [result.firstObject requestContentEditingInputWithOptions: nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//                    NSLog(@"%@", [contentEditingInput fullSizeImageURL]);
//                }];
//            } else {
//                NSLog(@"获取保存Image失败！", nil);
//            }
//        } else {
//            NSLog(@"保存失败：%@",error);
//        }
//    }];
//}

#pragma mark - 指定回调方法
//- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
//{
//    NSLog(@"%@", contextInfo);
////    NSString *msg = nil ;
////    if(error != NULL){
////        msg = @"保存图片失败" ;
////    }else{
////        msg = @"保存图片成功" ;
////    }
////    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
////                                                    message:msg
////                                                   delegate:self
////                                          cancelButtonTitle:@"确定"
////                                          otherButtonTitles:nil];
////    [alert show];
//}

- (void)cancel
{
    [self flashLightModel:^{
        [self.device setFlashMode:AVCaptureFlashModeOff];
    }];
//    [self dismissViewControllerAnimated:YES completion:nil];
    if ([_delegate respondsToSelector:@selector(cancelSave:)]) {
        [_delegate cancelSave:self];
    }
}

- (void)done{
//    [self saveImageToPhotoAlbum:self.imageToDisplay];
    if ([_delegate respondsToSelector:@selector(saveImageToPhotoAlbum:)]) {
        [_delegate saveImageToPhotoAlbum:self.imageToDisplay];
    }
    // 返回保存图片绝对地址 @FIXME @TODO
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 100) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark - 屏幕
- (BOOL)shouldAutorotate{
    return NO;
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}
//// 支持屏幕旋转
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    return YES;
//}
//// 画面一开始加载时就是竖向
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}


#pragma mark - 图片旋转
//裁剪image
- (UIImage *)cutImage:(UIImage *)srcImg {
    //这个rect是指横屏时的rect，即屏幕对着自己，home建在右边
    CGRect rect = CGRectMake((srcImg.size.height / CGRectGetHeight(self.view.frame)) * TOP_HEIGHT * kScreenScale, 0, srcImg.size.width * 1.33, srcImg.size.width);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
    CGFloat subWidth = CGImageGetWidth(subImageRef);
    CGFloat subHeight = CGImageGetHeight(subImageRef);
    CGRect smallBounds = CGRectMake(0, 0, subWidth, subHeight);
    //旋转后，画出来
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, subWidth);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    CGContextRef ctx = CGBitmapContextCreate(NULL, subHeight, subWidth,
                                             CGImageGetBitsPerComponent(subImageRef), 0,
                                             CGImageGetColorSpace(subImageRef),
                                             CGImageGetBitmapInfo(subImageRef));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, smallBounds, subImageRef);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(subImageRef);
    CGImageRelease(cgimg);
    return img;
}
//旋转image
- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat width = srcImg.size.width;
    CGFloat height = srcImg.size.height;
    
    CGContextRef ctx;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown: //竖屏，不旋转
            // 截取中间4：3的部分
            transform = CGAffineTransformTranslate(transform, 0, -(height - width * 0.75) * 0.5);
            ctx = CGBitmapContextCreate(NULL, width, width * 0.75,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeLeft:  //横屏，home键在右手边，逆时针旋转90°
            transform = CGAffineTransformTranslate(transform, height, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeRight:  //横屏，home键在左手边，顺时针旋转90°
            transform = CGAffineTransformTranslate(transform, 0, width);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        default:
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0,0,width,height), srcImg.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}
/*
- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
*/

#pragma mark -  展示页面 protocol
- (void)cameraConfirmViewSendBtnTouched {
    // 保存
    [self done];
}
- (void)cameraConfirmViewCancelBtnTouched {
    // 重拍
}

- (void)cameraConfirmViewEditBtnTouched {
    // 进入编辑页面
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
