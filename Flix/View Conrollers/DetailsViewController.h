//
//  DetailsViewController.h
//  Flix
//
//  Created by josemurillo on 6/26/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

// A DetailsViewController has a movie
@property (nonatomic, strong) NSDictionary *movie;

@end

NS_ASSUME_NONNULL_END
