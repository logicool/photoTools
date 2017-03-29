//
//  SPAlbums.m
//  imageLib
//
//  Created by 高函 on 2017/3/17.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "SPAlbums.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SPAlbums()
@property (nonatomic , strong) ALAssetsLibrary *library;
@end

@implementation SPAlbums

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}

- (ALAssetsLibrary *)library {
    if (nil == _library)
    {
        _library = [self.class defaultAssetsLibrary];
    }
    
    return _library;
}

#pragma mark - getter
+ (instancetype) defaultPicker {
    return [[self alloc] init];
}

#pragma mark -传入一个AssetsURL来获取UIImage
- (void) getAssetsPhotoWithURLs:(NSURL *) url callBack:(groupCallBackBlock ) callBack {
    [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]);
        });
    } failureBlock:nil];
}

@end

