//
//  SPBrowerCollectionView.m
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "SPBrowerCollectionView.h"
#import "UIImageView+WebCache.h"

@implementation SPBrowerCollectionView


-(void) formatData {
    NSLog(@"test");
    //    [SPBrowserPhoto photoAnyImageObjWith:obj];
}

#pragma mark -setter
- (void)setDataArray:(NSMutableArray *)dataArray {
//    _dataArray = dataArray;
    // 格式化传入数组
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:9];
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@", obj);
        [tmp addObject:[SPBrowserPhoto photoAnyImageObjWith:obj]];
    }];
    
    _dataArray = tmp;
    [self reloadData];
}

-(void) addDataArray:(NSArray *)addArray {
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:9];
    [addArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"%@", obj);
        [tmp addObject:[SPBrowserPhoto photoAnyImageObjWith:obj]];
    }];
    
    // 去重复添加
    for (SPBrowserPhoto *pho in tmp) {
        if (![_dataArray containsObject:pho]) {
            [_dataArray addObject:pho];
        } else {
            NSLog(@"%@", pho);
        }
    }
    
    [self reloadData];
}


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectAssets = [NSMutableArray array];
    }
    return self;
}

- (void)setupPickerImageViewOnCell:(SPBrowerCollectionViewCell *)cell
                           AtIndex:(NSIndexPath *)indexPath {
    
    SPBrowerImageView *cellImgView = nil;
    if (cell.contentView.subviews.count == 2 && [cell.contentView.subviews[0] isKindOfClass:[UIView class]]) {//如果是重用cell，则不用再添加cellImgView
        //@MARK cell里面 removeAllview后 不会进入这里
        cellImgView = cell.contentView.subviews[0];
        cellImgView.image = nil;
        NSLog(@"@@@@@@@@@@@@%ld@@@@@@@@@@@",(long)indexPath.item);
    } else {
        cellImgView = [[SPBrowerImageView alloc] initWithFrame:cell.bounds];
        [cell.contentView addSubview:cellImgView];
    }
    
//    return;
    
    SPBrowserPhoto *photo = self.dataArray[indexPath.item];

    if (photo.photoPath && photo.photoPath.length) {
        //缓存路劲获取
        NSLog(@"photo.photoPath:%@", photo.photoPath);
        [photo loadImageFromFileAsync:photo.photoPath];
        cellImgView.image = photo.photoImage;
    } else if (photo.photoURL.absoluteString.length) {
        [photo loadImageFromURLAsync:photo.photoURL];
        cellImgView.image = photo.photoImage;
        
        NSRange photoRange = [photo.photoURL.absoluteString rangeOfString:@"assets-library"];
        if (photoRange.location != NSNotFound){
            [[SPAlbums defaultPicker] getAssetsPhotoWithURLs:photo.photoURL callBack:^(UIImage *obj) {
                photo.photoImage = obj;
                cellImgView.image = obj;
            }];
        } else {           
            // 网络URL
            [cellImgView sd_setImageWithURL:photo.photoURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
//                    cellImgView.image = image;  sdwebimage会自动赋值imageview的image 不需要在block里面重复，而且cell服用的原因可能，赋值的时候不是用到的图片；
                }else{
                    cellImgView.image = [UIImage imageNamed:@"icon_pic_break.png"];
                }
            }];
        }
        
    } else {
        cellImgView.image = photo.photoImage;
    }
    
    cellImgView.maskViewFlag = NO;
    for (NSInteger i = 0; i < self.selectAssets.count; i ++) {
        if ([((SPBrowserPhoto *)self.selectAssets[i]).photoURL isEqual:photo.photoURL]) {
            cellImgView.maskViewFlag = YES;
        } else if ([((SPBrowserPhoto *)self.selectAssets[i]).asset.assetURL isEqual:photo.asset.assetURL]) {
            cellImgView.maskViewFlag = YES;
        }
    }
}

// 图片点击事件
- (void)tickBtnTouched:(NSIndexPath *)indexPath {
    SPBrowerCollectionViewCell *cell = (SPBrowerCollectionViewCell *) [self cellForItemAtIndexPath:indexPath];
    
    SPBrowserPhoto *photo = self.dataArray[indexPath.item];
    SPBrowerImageView *cellImageView = [cell.contentView.subviews objectAtIndex:0];
    // 如果没有就添加到数组里面，存在就移除
    if ([cellImageView isKindOfClass:[SPBrowerImageView class]] && cellImageView.isMaskViewFlag) {
        [self.selectAssets removeObject:photo];
//        NSLog(@"%@", photo);
    }else{
        // 1 判断图片数超过最大数或者小于0
        NSUInteger maxCount = (self.maxCount <= 0) ? KPhotoShowMaxCount :  self.maxCount;
        if (self.selectAssets.count >= maxCount) {
            NSString *format = [NSString stringWithFormat:@"最多只能选择%zd张图片",maxCount];
            if (maxCount == 0) {
                format = [NSString stringWithFormat:@"您最多只能选择9张图片"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:format delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return;
        }
        
        [self.selectAssets addObject:photo];
    }

    // 告诉代理现在被点击了!
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected: deletePhoto:)]) {
        if (cellImageView.isMaskViewFlag) {
            // 删除的情况下
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deletePhoto:photo];
        }else{
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deletePhoto:nil];
        }
    }
    
    cellImageView.maskViewFlag = ([cellImageView isKindOfClass:[SPBrowerImageView class]]) && !cellImageView.isMaskViewFlag;
}


#pragma mark -<UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"cellForItemAtIndexPath --- start");
    SPBrowerCollectionViewCell *cell = [SPBrowerCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    [self setupPickerImageViewOnCell:cell AtIndex:indexPath];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //cell被点击，进入相册浏览器
    NSLog(@"%@", indexPath);
    [self tickBtnTouched:indexPath];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 销毁所有sdimage缓存
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDWebImageManager sharedManager] cancelAll];
}

@end
