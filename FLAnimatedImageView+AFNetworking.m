//
//  FLAnimatedImageView+AFNetworking.h
//  Kamio
//
//  Created by Jorge Garcia on 10/7/14.
//  Copyright (c) 2014 Kamio. All rights reserved.
//

#import "FLAnimatedImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import <objc/runtime.h>

@interface FLAnimatedImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;

//This is externally implemented by UIImageView+AFNetworking
+ (NSOperationQueue *)af_sharedImageRequestOperationQueue;

@end

//AFImageCache is an extension of NSCache and also a protocol, can't extend the protocol so added
//a category to NSCache
@interface NSCache (_FLAnimatedImage)
- (FLAnimatedImage *)cachedAnimatedImageForRequest:(NSURLRequest *)request;
- (void)cacheAnimatedImage:(FLAnimatedImage *)image
        forRequest:(NSURLRequest *)request;
@end

@implementation FLAnimatedImageView (AFNetworking)

+ (id)sharedAnimatedImageCache {
    return [[self class] sharedImageCache];
}


- (void)setAnimatedImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response,  FLAnimatedImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    FLAnimatedImage *cachedImage = [[[self class] sharedAnimatedImageCache] cachedAnimatedImageForRequest:urlRequest];
    if (cachedImage) {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.animatedImage = cachedImage;
        }
        
        self.af_imageRequestOperation = nil;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }
        __weak __typeof(self)weakSelf = self;
        self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                FLAnimatedImage *responseImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:responseObject];
                if (success) {
                    success(urlRequest, operation.response, responseImage);
                } else if (responseObject) {
                    strongSelf.animatedImage = responseImage;
                }
                
                if (operation == strongSelf.af_imageRequestOperation){
                    strongSelf.af_imageRequestOperation = nil;
                }
            }
            
            [[[strongSelf class] sharedAnimatedImageCache] cacheImage:responseObject
                                                           forRequest:urlRequest];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }
                
                if (operation == strongSelf.af_imageRequestOperation){
                    strongSelf.af_imageRequestOperation = nil;
                }
            }
        }];
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

@end

@implementation NSCache (_FLAnimatedImage)

//Added a ANIMATED at the beginning so AFImageCache doesn't get confused
static inline NSString * AFAnimatedImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [NSString stringWithFormat:@"ANIMATED:%@",[[request URL] absoluteString]];
}

- (FLAnimatedImage *)cachedAnimatedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return [self objectForKey:AFAnimatedImageCacheKeyFromURLRequest(request)];
}

- (void)cacheAnimatedImage:(FLAnimatedImage *)image
                forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFAnimatedImageCacheKeyFromURLRequest(request)];
    }
}

@end
