FLAnimatedImage_AFNetworking
============================

Extension of FLAnimatedImageView (https://github.com/Flipboard/FLAnimatedImage) to support async download and caching using AFNetworking (https://github.com/AFNetworking/AFNetworking)

You need those libraries in your project.

If you use a FLAnimatedImageView then just do this:

    [animatedImageView setAnimatedImageWithURLRequest:request placeholderImage:placeHolderImage 
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, FLAnimatedImage *animatedImage){
                        animatedImageView.animatedImage = animatedImage;
    					//do more things
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                        //handle failure
                    }];

or

[animatedImageView setAnimatedImageWithURLRequest:request placeholderImage:placeHolderImage 
                success:nil
                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    //handle failure
                }];
