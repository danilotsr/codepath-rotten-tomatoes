//
//  MovieDetailViewController.m
//  RottenTomatoes
//
//  Created by Danilo Resende on 2/7/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+FancyAnimation.h"
#import "AppConstants.h"

@interface MovieDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *synopsisView;
@property (weak, nonatomic) IBOutlet UILabel *criticsLabel;
@property (weak, nonatomic) IBOutlet UILabel *mpaaLabel;
@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.bottomView.backgroundColor = [AppConstants backgroundColor];
    self.title = self.movieDict[@"title"];
    [self.posterView setImageWithLowResURL:[self posterLowResURL] highResURL:[self posterHighResURL]];
    self.titleView.text = [NSString stringWithFormat:@"%@ (%@)",
                           self.movieDict[@"title"],
                           self.movieDict[@"year"]];
    
    self.criticsLabel.text = [NSString stringWithFormat:@"Critics Score: %@, Audience Score: %@",
                                                        [self.movieDict valueForKeyPath:@"ratings.critics_score"],
                                                        [self.movieDict valueForKeyPath:@"ratings.audience_score"]];
    
    self.mpaaLabel.text = self.movieDict[@"mpaa_rating"];
    
    self.synopsisView.text = self.movieDict[@"synopsis"];

    [self.synopsisView sizeToFit];
    CGSize contentSize = self.synopsisView.frame.size;
    contentSize.height += self.bottomView.frame.origin.y + self.synopsisView.frame.origin.y + 7;
    self.scrollView.contentSize = contentSize;
}

- (NSURL*)posterLowResURL {
    NSString *thumbURLString = [self.movieDict valueForKeyPath:@"posters.thumbnail"];
    NSString *posterURLString = [thumbURLString stringByReplacingOccurrencesOfString:@"tmb" withString:@"pro"];
    return [NSURL URLWithString:posterURLString];
}

- (NSURL*)posterHighResURL {
    NSString *thumbURLString = [self.movieDict valueForKeyPath:@"posters.thumbnail"];
    NSString *posterURLString = [thumbURLString stringByReplacingOccurrencesOfString:@"tmb" withString:@"ori"];
    return [NSURL URLWithString:posterURLString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
