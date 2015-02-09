//
//  ListMoviesViewController.m
//  RottenTomatoes
//
//  Created by Danilo Resende on 2/4/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieTableViewCell.h"
#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+FancyAnimation.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property NSInteger lastSelectedTabIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *displayControl;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.movies = [[NSArray alloc] init];
    self.title = @"Movies";
    
    self.view.backgroundColor = [AppConstants backgroundColor];
    
    self.searchBar.barStyle = UIBarStyleBlack;
    self.searchBar.tintColor = [AppConstants darkYellowColor];
    self.searchBar.delegate = self;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 100;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.gridView setHidden:YES];
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.backgroundColor = [AppConstants backgroundColor];
    [self.gridView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MovieThumbnail"];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UINib *movieCellNib = [UINib nibWithNibName:@"MovieTableViewCell" bundle:nil];
    [self.tableView registerNib:movieCellNib forCellReuseIdentifier:@"MovieTableViewCell"];
    
    self.tabBar.delegate = self;
    self.tabBar.tintColor = [AppConstants darkYellowColor];
    self.tabBar.barStyle = UIBarStyleBlack;
    
    self.tabBar.selectedItem = self.tabBar.items[0];
    self.lastSelectedTabIndex = self.tabBar.selectedItem.tag;
    
    self.displayControl.tintColor = [UIColor lightGrayColor];
    self.displayControl.backgroundColor = [UIColor clearColor];
    [self.displayControl addTarget:self action:@selector(onDisplayChange:) forControlEvents:UIControlEventValueChanged];

    [SVProgressHUD show];
    [self downloadMovies];
}

- (void)onRefresh {
    [self downloadMovies];
}

- (NSURL*)getRottenTomatoesURLForPath:(NSString*)path {
    NSString *apiKey = @"cs9x59p8eb2c8nfr5wwfbp5u";
    NSString *url = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/%@?limit=50&apikey=%@", path, apiKey];
    return [NSURL URLWithString:url];
}

- (NSURL*)getBoxOfficeMoviesURL {
    return [self getRottenTomatoesURLForPath:@"lists/movies/box_office.json"];
}

- (NSURL*)getDVDsNewReleasesURL {
    return [self getRottenTomatoesURLForPath:@"lists/dvds/new_releases.json"];
}

- (NSURL*)getMoviesURL {
    switch (self.tabBar.selectedItem.tag) {
        case 0:
            return [self getBoxOfficeMoviesURL];
        case 1:
            return [self getDVDsNewReleasesURL];
    }
    // TODO(dresende): throw Exception
    return nil;
}

- (void)downloadMovies {
    NSURL *url = [self getMoviesURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         [SVProgressHUD dismiss];
         [self.refreshControl endRefreshing];
         if (connectionError) {
             [self showConnectionError:connectionError];
         } else {
             NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             self.movies = jsonDict[@"movies"];
             [self.tableView reloadData];
             [self.gridView reloadData];
         }
     }
     ];
}


- (void)showConnectionError:(NSError*)error {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Network Error"
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {}];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.movies count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieTableViewCell" forIndexPath:indexPath];
    NSDictionary *movieDict = self.movies[indexPath.item];
    cell.title.text = movieDict[@"title"];
    NSURL *thumbnailSource = [NSURL URLWithString:[movieDict valueForKeyPath:@"posters.thumbnail"]];
    [cell.thumbnail setImageWithURL:thumbnailSource fadeIn:YES duration:2.0];

    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] init];
    UIFont *smallBoldFont = [UIFont boldSystemFontOfSize:10];
    NSDictionary *attributes = @{
         NSFontAttributeName: smallBoldFont,
         NSForegroundColorAttributeName: [UIColor whiteColor],
     };
    NSAttributedString *mpaa = [[NSAttributedString alloc] initWithString:movieDict[@"mpaa_rating"]
                                                               attributes:attributes];
    [description appendAttributedString:mpaa];
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [description appendAttributedString:[[NSAttributedString alloc] initWithString:movieDict[@"synopsis"]]];
    cell.synopsis.attributedText = description;

    cell.backgroundColor = [AppConstants backgroundColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)showMovieDetailsAtIndexPath:(NSIndexPath *)indexPath {
    MovieDetailViewController *movieDetailVC = [[MovieDetailViewController alloc] init];
    movieDetailVC.movieDict = self.movies[indexPath.item];
    [self.navigationController pushViewController:movieDetailVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self showMovieDetailsAtIndexPath:indexPath];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag != self.lastSelectedTabIndex) {
        [SVProgressHUD show];
        [self downloadMovies];
        self.lastSelectedTabIndex = item.tag;
        self.searchBar.text = nil;
        [self.searchBar endEditing:YES];
    }
}

- (IBAction)onDisplayChange:(id)sender {
    BOOL showGrid = self.displayControl.selectedSegmentIndex == 1;
    [self.tableView setHidden:showGrid];
    [self.gridView setHidden:!showGrid];
    [self.tableView reloadData];
    [self.gridView reloadData];
}

- (NSArray*)movies {
    if ([self.searchBar.text length] == 0) {
        return _movies;
    }
    NSMutableArray *filteredMovies = [[NSMutableArray alloc] init];
    for (NSDictionary *movie in _movies) {
        NSRange range = [[movie[@"title"] lowercaseString] rangeOfString:[self.searchBar.text lowercaseString]];
        if (range.location != NSNotFound) {
            [filteredMovies addObject:movie];
        }
    }
    return filteredMovies;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.movies count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieThumbnail" forIndexPath:indexPath];
    UIImageView *thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 80)];
    NSDictionary *movieDict = self.movies[indexPath.item];
    
    NSURL *thumbnailSource = [NSURL URLWithString:[movieDict valueForKeyPath:@"posters.thumbnail"]];
    [thumbnail setImageWithURL:thumbnailSource fadeIn:YES duration:2.0];
    [cell addSubview:thumbnail];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self showMovieDetailsAtIndexPath:indexPath];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView reloadData];
    [self.gridView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
