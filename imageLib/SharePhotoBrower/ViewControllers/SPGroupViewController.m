//
//  SPGroupViewController.m
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "SPGroupViewController.h"
#import "SPBrowerCollectionView.h"
#import "SPBrowerCollectionViewCell.h"

#import "LGPhotoPickerViewController.h"
#import "CustomCameraViewController.h"

#import <SDImageCache.h>
#import <SDWebImageManager.h>


static CGFloat CELL_ROW = 3;
static CGFloat CELL_MARGIN = 2;
static CGFloat CELL_LINE_MARGIN = 2;
static CGFloat TOOLBAR_HEIGHT = 44;

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";

@interface SPGroupViewController ()<SPBrowerCollectionViewDelegate, LGPhotoPickerViewControllerDelegate, CustomCameraViewControllerDelegate>
// 相片View
@property (nonatomic , strong) SPBrowerCollectionView *collectionView;
// 工具条
@property (nonatomic , weak) UIToolbar *toolBar;

// 所有图片
@property (nonatomic , strong) NSMutableArray *assets;
// 选中图片
@property (nonatomic , strong) NSMutableArray *selectAssets;

// 菊花
@property (strong,nonatomic ) UIActivityIndicatorView *indicator;

// 配置传入参数
@property (nonatomic, strong) NSDictionary *shareData;

@end

@implementation SPGroupViewController

#pragma mark - circle life

- (instancetype)initWithData:(NSDictionary *) shareData
{
    if (self = [super init]) {
        _shareData = shareData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor redColor];
    
    // 初始化导航栏
    [self addNavBarButton];
    // 初始化底部ToorBar
    [self setupToorBar];
    // 初始化所有图片
    [self setupAssets];
    // 初始化菊花
    [self initProgressView];
}

//- (void)viewWillAppear:(BOOL)animated
//{
////    [self.collectionView reloadData];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // 解决sdimage内存暴涨不会收的问题；
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDWebImageManager sharedManager] cancelAll];
}

#pragma mark - view功能初始化
- (void)addNavBarButton{
    // 返回键
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    // 分享键
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"去分享" style:UIBarButtonItemStylePlain target:self action:@selector(goToshare:)];
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)goToshare:(id)sender
{
    if (self.selectAssets && self.selectAssets.count > 0) [self showShareCopyAlert:[self.shareData valueForKey:@"description"]];
}

- (void) initProgressView
{
    if (!_indicator) {
//        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _indicator.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
        self.indicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.indicator.color = [UIColor blackColor];
        [self.view addSubview:self.indicator];
    }
}

#pragma mark - 分享文字复制
- (void)showShareCopyAlert:(NSString *) message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"车辆描述" message:message preferredStyle:UIAlertControllerStyleAlert];
    //修改标题的内容，字号，颜色。使用的key值是“attributedTitle”
    /**
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:@"heihei"];
    [hogan addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:50] range:NSMakeRange(0, [[hogan string] length])];
    [hogan addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [[hogan string] length])];
    [alertController setValue:hogan forKey:@"attributedTitle"];
    **/
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 赋值文字到剪切板
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string=message;
        // 唤醒分享
        [self shareToWXTimeLine];
    }];
    [defaultAction setValue:[UIColor orangeColor] forKey:@"_titleTextColor"];
    [alertController addAction:defaultAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 唤起分享功能
-(void) shareToWXTimeLine
{
    // 格式化图片
    [_indicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        __block NSMutableArray *tmp = [NSMutableArray new];;
        // 格式化图片
        for (SPBrowserPhoto *photo in weakSelf.selectAssets) {
            if (photo.photoPath && photo.photoPath.length) {
                [photo loadImageFromFileAsync:photo.photoPath];
                [tmp addObject:photo.photoImage];
            } else if (photo.photoURL.absoluteString.length) {
                NSRange photoRange = [photo.photoURL.absoluteString rangeOfString:@"assets-library"];
                if (photoRange.location != NSNotFound){
                    [[SPAlbums defaultPicker] getAssetsPhotoWithURLs:photo.photoURL callBack:^(UIImage *obj) {
                        photo.photoImage = obj;
                        [tmp addObject:photo.photoImage];
                    }];
                } else {
                    // 网络URL
                    UIImage *tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:photo.photoURL]];
                    [tmp addObject:tmpImage];
                }
                
            } else {
                [tmp addObject:photo.photoImage];
            }
        }
        __block NSArray *sharePhotos = [weakSelf getJPEGImagerImgArr:tmp];
        if (sharePhotos && sharePhotos.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf == nil) {
                    sharePhotos = nil;
                    tmp = nil;
                    weakSelf.indicator = nil;
                    return;
                }
                // 更新界面
                // 唤醒ios自带微信
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: sharePhotos applicationActivities:nil];
                // 关闭无用的分享连接 UIActivityTypeSaveToCameraRoll
                NSMutableArray *excludedActivityTypes =  [NSMutableArray arrayWithArray:@[UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeMail, UIActivityTypePostToTencentWeibo, UIActivityTypeMessage, UIActivityTypePostToTwitter]];
                activityVC.excludedActivityTypes = excludedActivityTypes;
                [weakSelf presentViewController:activityVC animated:TRUE completion:^{
                    [weakSelf.indicator stopAnimating];
                }];
                activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
                    NSLog(@"%@  ----   %@", activityType, returnedItems);
                    if (activityType) {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                };
                
            });
        } else {
            [weakSelf.indicator stopAnimating];
        }
        
    });

    
}


#pragma mark - 压缩图片 最大宽高1280 类似于微信算法
static float KCompressibilityFactor = 1280.00;
- (UIImage *)getJPEGImagerImg:(UIImage *)image{
    CGFloat oldImg_WID = image.size.width;
    CGFloat oldImg_HEI = image.size.height;
    //CGFloat aspectRatio = oldImg_WID/oldImg_HEI;//宽高比
    if(oldImg_WID > KCompressibilityFactor || oldImg_HEI > KCompressibilityFactor){
        //超过设置的最大宽度 先判断那个边最长
        if(oldImg_WID > oldImg_HEI){
            //宽度大于高度
            oldImg_HEI = (KCompressibilityFactor * oldImg_HEI)/oldImg_WID;
            oldImg_WID = KCompressibilityFactor;
        }else{
            oldImg_WID = (KCompressibilityFactor * oldImg_WID)/oldImg_HEI;
            oldImg_HEI = KCompressibilityFactor;
        }
    }
    UIImage *newImg = [self imageWithImage:image scaledToSize:CGSizeMake(oldImg_WID, oldImg_HEI)];
    NSData *dJpeg = nil;
    if (UIImagePNGRepresentation(newImg)==nil) {
        dJpeg = UIImageJPEGRepresentation(newImg, 0.5);
    }else{
        dJpeg = UIImagePNGRepresentation(newImg);
    }
    return [UIImage imageWithData:dJpeg];
}
// 压缩多张图片 最大宽高1280 类似于微信算法
- (NSArray *)getJPEGImagerImgArr:(NSArray *)imageArr{
    NSMutableArray *newImgArr = [NSMutableArray new];
    for (int i = 0; i<imageArr.count; i++) {
        UIImage *newImg = [self getJPEGImagerImg:imageArr[i]];
        [newImgArr addObject:newImg];
    }
    return newImgArr;
}
// 根据宽高压缩图片
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 初始化所有的组
- (void) setupAssets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    NSArray *tmp = [[NSArray alloc] initWithArray:[self.shareData valueForKey:@"photoList"]];
    self.collectionView.dataArray = [NSMutableArray arrayWithArray:tmp];
    [self.assets setArray:tmp];
    
    // 默认选中前9张图片
    NSMutableArray *selected = [self formatAssets:tmp];
    [self.selectAssets setArray:selected];
    self.collectionView.selectAssets =  selected;
}

//// 格式化图片数组
- (NSMutableArray *) formatAssets: (NSArray*) assests {
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:9];
    int i = 0;
    for (id obj in assests) {
        if (i == 9) {
            break;
        }
        [tmp addObject:[SPBrowserPhoto photoAnyImageObjWith:obj]];
        i++;
    }
    return tmp;
}


#pragma mark collectionView
- (SPBrowerCollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT / 2);
        
        SPBrowerCollectionView *collectionView = [[SPBrowerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[SPBrowerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:_collectionView = collectionView belowSubview:self.toolBar];
        collectionView.frame = self.view.bounds;
    }
    return _collectionView;
}

#pragma mark -初始化底部ToorBar
- (void) setupToorBar{
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    toorBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl = @"V:[toorBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    // leftBtn
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    leftBtn.enabled = YES;
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    leftBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    leftBtn.frame = CGRectMake(0, 0, 100, 45);
    [leftBtn setTitle:@"拍照添加" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(openCarame) forControlEvents:UIControlEventTouchUpInside];
    
    
    // rightBtn
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    rightBtn.enabled = YES;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    rightBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    rightBtn.frame = CGRectMake(0, 0, 100, 45);
    [rightBtn setTitle:@"从相册选择" forState:UIControlStateNormal];
    
    [rightBtn addTarget:self action:@selector(presentPhotoPickerViewControllerWithStyle) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 左视图 中间距 右视图
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    toorBar.items = @[leftItem,fiexItem,rightItem];
}

#pragma mark - 相机选择器
-(void) openCarame
{
    CustomCameraViewController *cc = [[CustomCameraViewController alloc] init];
    cc.delegate = self;
    [self presentViewController:cc animated:YES completion:nil];
}

#pragma mark 相机选择器回掉
- (void)cancelSave:(CustomCameraViewController *) viewController
{
    __weak typeof(viewController)weakVc = viewController;
    if (weakVc != nil) {
        [weakVc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    // 初始化本地保存路径
    NSString *fileName;
    NSString *tempFileName = [[NSUUID UUID] UUIDString];
    fileName = [tempFileName stringByAppendingString:@".jpg"];
    
    // 默认保存到tempray路径下
    NSString *path = [[NSTemporaryDirectory() stringByStandardizingPath] stringByAppendingPathComponent:fileName];
    
    // 压缩图片并保存到本地路径
    NSData *data = UIImageJPEGRepresentation(savedImage, 0.4);

    [data writeToFile:path atomically:YES];
    
    // 获取图片本地路径
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSString *filePath = [fileURL absoluteString];
    
    // 保存图片到相册
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __weak typeof(self) weakSelf = self;
    [library writeImageToSavedPhotosAlbum:savedImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Error while saving picture into photo album");
        } else {
            // when the image has been saved in the photo album
            NSLog(@"保存成功！");
            [weakSelf.collectionView addDataArray:@[filePath]];
        }
    }];
}

#pragma mark - 照片选择器
- (void)presentPhotoPickerViewControllerWithStyle {
    LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.maxCount = 9;   // 最多能选9张图片
    pickerVc.delegate = self;
    [pickerVc showPickerVc:self];
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
    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
    for (LGPhotoAssets *photo in assets) {
        // NSLog(@"%@ withUrl: %@", photo.originImage, photo.absoluteURL);
        [self.assets addObject:photo];
        [tmpArr addObject:photo];
    }
    
    if (![self.assets.lastObject isEqual:self.collectionView.dataArray.lastObject]) {
        [self.collectionView addDataArray:tmpArr];
    }
    

}

-(void) cancelPickerViewController
{
    NSLog(@"callBackTest", nil);
}

# pragma mark - cell点击时会被调用
- (void) pickerCollectionViewDidSelected:(SPBrowerCollectionView *) pickerCollectionView deletePhoto:(SPBrowserPhoto *)deletePhoto
{
    if (self.selectAssets.count == 0){
        self.selectAssets = [NSMutableArray arrayWithArray:pickerCollectionView.selectAssets];
    } else if (deletePhoto == nil) {
        [self.selectAssets addObject:[pickerCollectionView.selectAssets lastObject]];
    } else if(deletePhoto) { //取消所选的照片
        [self.selectAssets removeObject:deletePhoto];
    }
}

@end
