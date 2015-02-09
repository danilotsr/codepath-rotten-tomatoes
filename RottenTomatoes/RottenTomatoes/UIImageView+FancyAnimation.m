//
//  UIImageView+FancyAnimation.m
//  RottenTomatoes
//
//  Created by Danilo Resende on 2/8/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AFNetworking.h"
#import "UIImageView+FancyAnimation.h"

@implementation UIImageView (FancyAnimation)

- (void)setImageWithURL:(NSURL*)url fadeIn:(BOOL)enableFadeIn duration:(NSTimeInterval)duration {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak UIImageView* weakSelf = self;
    self.alpha = enableFadeIn ? 0.0 : 1.0;
    [self setImageWithURLRequest:request
                placeholderImage:nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             weakSelf.image = image;
                             if (response.statusCode == 200 && enableFadeIn) {
                                 [UIView animateWithDuration:duration animations:^{
                                     weakSelf.alpha = 1.0;
                                 }];
                             } else {
                                 weakSelf.alpha = 1.0;
                             }
                         }
                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             // TODO(dresende): implement proper error handling
                         }];
}

- (void)setImageWithLowResURL:(NSURL*)lowResURL highResURL:(NSURL*)hiResURL {
    NSURLRequest *request = [NSURLRequest requestWithURL:lowResURL];
    __weak UIImageView* weakSelf = self;
    [self setImageWithURLRequest:request
                placeholderImage:nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *lowResImage) {
                             [weakSelf setImageWithURL:hiResURL placeholderImage:lowResImage];
                         }
                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             // TODO(dresende): implement proper error handling
                         }];
}

@end