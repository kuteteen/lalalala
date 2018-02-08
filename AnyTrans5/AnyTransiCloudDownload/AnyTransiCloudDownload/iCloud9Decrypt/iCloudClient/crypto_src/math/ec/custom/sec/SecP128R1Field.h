//
//  SecP128R1Field.h
//  
//
//  Created by Pallas on 5/31/16.
//
//  Complete

#import <Foundation/Foundation.h>

@class BigInteger;

@interface SecP128R1Field : NSObject

// 2^128 - 2^97 - 1
// return == uint[]
+ (NSMutableArray*)P;
// return == uint[]
+ (NSMutableArray*)PExt;

// NSMutableArray == uint[]
+ (void)add:(NSMutableArray*)x withY:(NSMutableArray*)y withZ:(NSMutableArray*)z;
// NSMutableArray == uint[]
+ (void)addExt:(NSMutableArray*)xx withYY:(NSMutableArray*)yy withZZ:(NSMutableArray*)zz;
// NSMutableArray == uint[]
+ (void)addOne:(NSMutableArray*)x withZ:(NSMutableArray*)z;
// return == uint[]
+ (NSMutableArray*)fromBigInteger:(BigInteger*)x;
// return == uint[]
+ (void)half:(NSMutableArray*)x withZ:(NSMutableArray*)z;
// return == uint[]
+ (void)multiply:(NSMutableArray*)x withY:(NSMutableArray*)y withZ:(NSMutableArray*)z;
// return == uint[]
+ (void)multiplyAddToExt:(NSMutableArray*)x withY:(NSMutableArray*)y withZZ:(NSMutableArray*)zz;
// return == uint[]
+ (void)negate:(NSMutableArray*)x withZ:(NSMutableArray*)z;
// return == uint[]
+ (void)reduce:(NSMutableArray*)xx withZ:(NSMutableArray*)z;
// NSMutableArray == uint[]
+ (void)reduce32:(uint)x withZ:(NSMutableArray*)z;
// NSMutableArray == uint[]
+ (void)square:(NSMutableArray*)x withZ:(NSMutableArray*)z;
// NSMutableArray == uint[]
+ (void)squareN:(NSMutableArray*)x withN:(int)n withZ:(NSMutableArray*)z;
// NSMutableArray == uint[]
+ (void)subtract:(NSMutableArray*)x withY:(NSMutableArray*)y withZ:(NSMutableArray*)z;
// NSMutableArray == uint[]
+ (void)subtractExt:(NSMutableArray*)xx withYY:(NSMutableArray*)yy withZZ:(NSMutableArray*)zz;
// NSMutableArray == uint[]
+ (void)twice:(NSMutableArray*)x withZ:(NSMutableArray*)z;

@end