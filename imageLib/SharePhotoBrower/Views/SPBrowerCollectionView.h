//
//  SPBrowerCollectionView.h
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"

#import "SPBrowerCollectionViewCell.h"
#import "SPBrowerImageView.h"
#import "SPBrowserPhoto.h"
#import "SPAlbums.h"
#import "SPBrowerCollectionViewCell.h"

@class SPBrowerCollectionView;
@protocol SPBrowerCollectionViewDelegate <NSObject>

// 选择相片就会调用
- (void) pickerCollectionViewDidSelected:(SPBrowerCollectionView *) pickerCollectionView deletePhoto:(SPBrowserPhoto *)deletePhoto;

@end

@interface SPBrowerCollectionView : UICollectionView <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
// delegate
@property (nonatomic , weak) id <SPBrowerCollectionViewDelegate> collectionViewDelegate;
// 所有的数据
@property (nonatomic , strong) NSMutableArray *dataArray;
// 选中的数据
@property (nonatomic , strong) NSMutableArray *selectAssets;

// 限制最大数
@property (nonatomic , assign) NSInteger maxCount;

-(void) addDataArray:(NSArray *)addArray;
@end
