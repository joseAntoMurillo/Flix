//
//  MovieCollectionViewCell.h
//  Flix
//
//  Created by josemurillo on 6/27/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieCollectionViewCell : UICollectionViewCell

// For the control view, for each movie, only the poster is shown
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end

NS_ASSUME_NONNULL_END
