//
//  PhotoPickerViewController.m
//  imageLib
//
//  Created by 高函 on 17/2/13.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "PhotoPickerViewController.h"

@interface PhotoPickerViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoTweaksViewControllerDelegate>

@end

@implementation PhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.navigationBarHidden = YES;

    // Check permissions
    void (^showPickerViewController)() = ^void() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:picker animated:YES completion:nil];
        });
    };
    
    
    [self checkPhotosPermissions:^(BOOL granted) {
        if (!granted) {
            return;
        }
        
        showPickerViewController();
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:image];
    photoTweaksViewController.delegate = self;
    photoTweaksViewController.autoSaveToLibray = YES;
    photoTweaksViewController.maxRotationAngle = M_PI;
    [picker pushViewController:photoTweaksViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 相册权限验证
- (void)checkPhotosPermissions:(void(^)(BOOL granted))callback
{
    if (![PHPhotoLibrary class]) {
        callback(YES);
        return;
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        callback(YES);
        return;
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                callback(YES);
                return;
            }
            else {
                callback(NO);
                return;
            }
        }];
    }
    else {
        callback(NO);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:YES completion:^{
//            self.callback(@[@{@"didCancel": @YES}]);
        }];
    });
}

#pragma mark - 图片选取回调方法
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [self saveImageToPhotoAlbum:croppedImage];
    // 返回保存图片绝对地址 @FIXME @TODO
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    __block NSString *createdAssetID =nil;//唯一标识，可以用于图片资源获取
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:savedImage].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            if (createdAssetID != nil) {
                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
                [result.firstObject requestContentEditingInputWithOptions: nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                    
                    
                    
                    NSURL *fileURL = [contentEditingInput fullSizeImageURL];
                    NSString *filePath = [fileURL absoluteString];
                    
                    
                    NSLog(@"%@", filePath);
                    
                    
                }];
            } else {
                NSLog(@"获取保存Image失败！", nil);
            }
        } else {
            NSLog(@"保存失败：%@",error);
        }
    }];
}

@end
