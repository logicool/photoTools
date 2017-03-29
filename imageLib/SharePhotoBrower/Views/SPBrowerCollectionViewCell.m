//
//  SPBrowerCollectionViewCell.m
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "SPBrowerCollectionViewCell.h"

static NSString *const _cellIdentifier = @"cell";

@implementation SPBrowerCollectionViewCell
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SPBrowerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)]; //耗时较长
    return cell;
}
@end
