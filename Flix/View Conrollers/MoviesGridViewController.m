 //
//  MoviesGridViewController.m
//  Flix
//
//  Created by josemurillo on 6/27/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake (itemWidth, itemHeight);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents: UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

// Fetches data for Family-type movies
- (void) fetchMovies {
    
    // Request code
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            
            // Alert message with title and content
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot get movies" message:@"The internet connection appears to be offline" preferredStyle:(UIAlertControllerStyleAlert)];
            
            // OK action: button that lets user close the alert message
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            // Adds the OK action to the alert controller
            [alert addAction:okAction];
            
            // Shows the alert
            [self presentViewController:alert animated:YES completion:^{
            }];
        }
        else {
            // Data from API is saved on dataDictionary
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            // Gets array of all movies from dataDictionary
            NSArray *allMovies = dataDictionary[@"results"];
            
            // Sets movies property as result of filtering allMovies
            self.movies = [self filterFamily: allMovies];
            
            // Reloads data once that feteching finishes
            [self.collectionView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // Creates an objet to represent a cell in the control view
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionViewCell" forIndexPath:indexPath];
    
    // Gets data of respective movie and saves it in the movie object
    NSDictionary *movie = self.movies[indexPath.item];
    
    NSString *fullLowPosterURLString = [@"https://image.tmdb.org/t/p/w45" stringByAppendingString: movie[@"poster_path"]];
    NSString *fullHighPosterURLString = [@"https://image.tmdb.org/t/p/original" stringByAppendingString: movie[@"poster_path"]];
    NSURL *lowURL = [NSURL URLWithString:fullLowPosterURLString];
    NSURL *highURL = [NSURL URLWithString:fullHighPosterURLString];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL: lowURL];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL: highURL];
    
    // Code to first  put low-resolution image and then hihg-resolution one
    [cell.posterView setImageWithURLRequest:requestSmall placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
         // smallI will be nil if the smallImage is already available
         // in cache (might want to do something smarter in that case).
         cell.posterView.alpha = 0.0;
         cell.posterView.image = smallImage;
        
         [UIView animateWithDuration:0.3 animations:^{
            cell.posterView.alpha = 1.0;
         }];
        
         // Fading animation for loading images in collection view
         [UIView animateWithDuration:0.3 animations:^{
               cell.posterView.alpha = 1.0;
             
         } completion:^(BOOL finished) {
         // The AFNetworking ImageView Category only allows one request to be sent at a time
         // per ImageView. This code must be in the completion block.
             [cell.posterView setImageWithURLRequest:requestLarge placeholderImage:smallImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                 cell.posterView.image = largeImage;
             }
             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             }];
         }];
      }
      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
      }];

    // Sets custom background color when selecting a cell
    UIColor *backColor = [UIColor colorWithRed:0.85 green:0.83 blue:0.83 alpha:1.0];
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = backColor;
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

// Uses animation to deselect cell after selecting it
- (void)collectionView:(UICollectionView *)collectionView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

// Cells in control view are determined by the number of family-type movies
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
     return self.movies.count;
}

// Filters array of all the movies to an array of family-type movies
- (NSArray *)filterFamily:(NSArray *) moviesArray {
    NSMutableArray *familyArray = [[NSMutableArray alloc] init];
    NSNumber *familyId = @12;
    
    // Loops through all movies
    for (NSDictionary *movie in moviesArray)
    {
        NSArray *movieIDs = movie[@"genre_ids"];
        
        // Checks if an individual movie has the family-type id
        if ([movieIDs containsObject: (NSNumber *) familyId]) {
            [familyArray addObject:movie];
        }
    }
    return familyArray;
}

// Sends appropiate data to DetailsViewController when cell is clicked
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Gets appropiate data corresponding to the movie that the user selected
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    // Get the new view controller using [segue destinationViewController].
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller
    detailsViewController.movie = movie;
}

@end
