#import "VSDKTrackingEvent.h"

@class VSDKProduct;

@interface VSDKProductFeedback : VSDKTrackingEvent

/**
  Rating given by the user to the product.
 */
@property float rating;

/**
  Text feedback given by the user to the product.
 */
@property (nullable) NSString *feedback;

/**
  List of products associated with this product feedback
 */
@property (nullable) NSMutableArray<VSDKProduct *> *products;

@end