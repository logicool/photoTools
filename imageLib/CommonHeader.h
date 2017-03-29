//
//  CommonHeader.h
//  imageLib
//
//  Created by 高函 on 2017/2/22.
//  Copyright © 2017年 高函. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height - [[UIApplication sharedApplication] statusBarFrame].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define GetImage(A)  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

#define XG_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define IOS9_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"9.0"] != NSOrderedAscending )
#define iOS7gt ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)


#define NEED_DEBUG
#ifdef NEED_DEBUG
#define NSLog(format, ...) \
do { \
NSLog(@"<%@ : %d : %s>-: %@", \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
__LINE__, \
__FUNCTION__, \
[NSString stringWithFormat:format, ##__VA_ARGS__]); \
} while(0)
#else
#define NSLog(format, ...) do{ } while(0)
#endif

//图片显示器分类
typedef NS_ENUM(NSInteger, LGShowImageType) {
    LGShowImageTypeImagePicker = 0, //照片选择器
    LGShowImageTypeImageBroswer    //照片浏览器
};

// maxCount的默认值，不设置maxCount的时候有效
static NSInteger const KPhotoShowMaxCount = 9;

// ScrollView 滑动的间距
static CGFloat const LGPickerColletionViewPadding = 20;

// ScrollView拉伸的比例
static CGFloat const LGPickerScrollViewMaxZoomScale = 3.0;
static CGFloat const LGPickerScrollViewMinZoomScale = 1.0;

// 进度条的宽度/高度
static NSInteger const LGPickerProgressViewW = 50;
static NSInteger const LGPickerProgressViewH = 50;

// 分页控制器的高度
static NSInteger const LGPickerPageCtrlH = 25;

// NSNotification
static NSString *PICKER_TAKE_DONE = @"PICKER_TAKE_DONE";
static NSString *PICKER_TAKE_PHOTO = @"PICKER_TAKE_PHOTO";
static NSString *PICKER_TAKE_CANCEL = @"PICKER_TAKE_CANCEL";

static NSString *PICKER_PowerBrowserPhotoLibirayText = @"您屏蔽了选择相册的权限，开启请去系统设置->隐私->我的App来打开权限";


#endif /* CommonHeader_h */
