//
//  DetailsViewController.m
//  Flix
//
//  Created by josemurillo on 6/26/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()

// A details page has a poster, title, lable and backdrop image
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation DetailsViewController

// Sets layout of colleciton view when loading
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Reads from movie object to set appropiate data in the title and synopsis of the details page
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    
    // size to fit collection view cell
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    
    // API URL for images
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    // Gets string for poster URL and sets it in details page
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: self.movie[@"poster_path"]];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [self.posterView setImageWithURL:posterURL];
    
    // Gets string for backdrop URL and sets it in details page
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString: self.movie[@"backdrop_path"]];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropView setImageWithURL:backdropURL];
}

@end
