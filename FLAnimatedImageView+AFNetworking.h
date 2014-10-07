//
//  FLAnimatedImageView+AFNetworking.h
//  Kamio
//
//  Created by Jorge Garcia on 10/7/14.
//  Copyright (c) 2014 Kamio. All rights reserved.
//

#import "FLAnimatedImageView.h"
#import "UIImageView+AFNetworking.h"
#import "FLAnimatedImage.h"



@interface FLAnimatedImageView (AFNetworking)

- (void)setAnimatedImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, FLAnimatedImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
