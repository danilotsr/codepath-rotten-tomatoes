//
//  UIImageView+FancyAnimation.h
//  RottenTomatoes
//
//  Created by Danilo Resende on 2/8/15.
//  Copyright (c) 2015 CodePath. All rights reserved.
//

#ifndef RottenTomatoes_UIImageView_FancyAnimation_h
#define RottenTomatoes_UIImageView_FancyAnimation_h

@interface UIImageView (FancyAnimation)
- (void)setImageWithURL:(NSURL*)url fadeIn:(BOOL)enableFadeIn duration:(NSTimeInterval)duration;
- (void)setImageWithLowResURL:(NSURL*)lowResURL highResURL:(NSURL*)hiResURL;
@end

#endif
