 //
//  MoviesViewController.m
//  Flix
//
//  Created by josemurillo on 6/26/19.
//  Copyright © 2019 josemurillo. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/* The movies array contains all the "Now Playing" mvovies and the filteredData
   has the ones that have been filtered by the search bar
*/
@property (nonatomic, strong) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredData;

// Properties for tools that can be used in the table view
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation MoviesViewController

// Sets layout of table view when loading
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Additional setups after loading the view
    // Sets dataSource and delegates for cells, where movies are displayed
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    // Calls function to get data from movies API
    [self fetchMovies];
    
    /* Refreshes data for movies when user hits refresh control by calling the fetchMovies
       function and setting the refresh control at the top of the table view.
    */
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents: UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

// Fetches data for Now Playing movies
- (void) fetchMovies {
    // Request code
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Conditonal to set layout, depending on success of movies fetching
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
            
            // Gets array of movies from dataDictionary
            self.movies = dataDictionary[@"results"];
            
            // FilteredData (for search bar) is originally equal to the whole movies set
            self.filteredData = self.movies;
            
            // Reloads data once that feteching finishes
            [self.tableView reloadData];
        }
        // Refreshing automatically ends after data has been fetched again
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

// Cells in table view are determined by the number of movies
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredData.count;
}

// Sets layout of each cell in the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Creates an objet to represent a cell
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    // Gets data of respective movie and saves it in the movie object
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    // Reads from movie object to set appropiate data in the title and synopsis of the cell
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    // API URL for images
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    // Gets string for poster URL
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: movie[@"poster_path"]];
    
    // Sets posterView to null and then adds appropiate image to its position in the cell. 
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    // Sets custom background color when selecting a cell
    UIColor *backColor = [UIColor colorWithRed:0.85 green:0.83 blue:0.83 alpha:1.0];
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = backColor;
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

// Uses animation to deselect cell after selecting it
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Adds cancel button to search bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

// Deletes search through cancel button
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Changes tableview display if user types search
    if (searchText.length != 0) {
        
        // Gets command for filter data using string for what the user has searched
        NSString *substring = [NSString stringWithString:searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", substring];
        
        // Executes command to save filteredData in object
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
    }
    else {
        // If no search, filteredData remains being the whole set of movies
        self.filteredData = self.movies;
    }
    // Reloads tableView with new set of data
    [self.tableView reloadData];
}


#pragma mark - Navigation

// Sends appropiate data to DetailsViewController when cell is clicked
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Gets appropiate data corresponding to the movie that the user selected
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    // Get the new view controller using [segue destinationViewController].
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    // Pass the selected object to the new view controller
    detailsViewController.movie = movie;
}


@end
