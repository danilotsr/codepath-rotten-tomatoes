//
//  MovieTableViewCell.h
//  RottenTomatoes
//
//  Created by Danilo Resende on 2/5/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *synopsis;
@end
