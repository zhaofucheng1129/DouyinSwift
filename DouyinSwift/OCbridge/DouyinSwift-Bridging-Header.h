//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#if __has_include(<webp/decode.h>) && __has_include(<webp/encode.h>) && __has_include(<webp/demux.h>)  && __has_include(<webp/mux.h>)
#import <webp/decode.h>
#import <webp/encode.h>
#import <webp/demux.h>
#import <webp/mux.h>
#elif __has_include("webp/decode.h") && __has_include("webp/encode.h") && __has_include("webp/demux.h")  && __has_include("webp/mux.h")
#import "webp/decode.h"
#import "webp/encode.h"
#import "webp/demux.h"
#import "webp/mux.h"
#endif
