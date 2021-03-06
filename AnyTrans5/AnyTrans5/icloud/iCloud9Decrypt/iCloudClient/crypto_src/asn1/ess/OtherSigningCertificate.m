//
//  OtherSigningCertificate.m
//  crypto
//
//  Created by JGehry on 6/23/16.
//  Copyright (c) 2016 pallas. All rights reserved.
//

#import "OtherSigningCertificate.h"
#import "DERSequence.h"
#import "PolicyInformation.h"

@implementation OtherSigningCertificate
@synthesize certs = _certs;
@synthesize policies = _policies;

- (void)dealloc
{
#if !__has_feature(objc_arc)
    if (_certs) {
        [_certs release];
        _certs = nil;
    }
    if (_policies) {
        [_policies release];
        _policies = nil;
    }
    [super dealloc];
#endif
}

+ (OtherSigningCertificate *)getInstance:(id)paramObject {
    if ([paramObject isKindOfClass:[OtherSigningCertificate class]]) {
        return (OtherSigningCertificate *)paramObject;
    }
    if (paramObject) {
        return [[[OtherSigningCertificate alloc] initParamASN1Sequence:[ASN1Sequence getInstance:paramObject]] autorelease];
    }
    return nil;
}

- (instancetype)initParamASN1Sequence:(ASN1Sequence *)paramASN1Sequence
{
    self = [super init];
    if (self) {
        if (([paramASN1Sequence size] < 1) || ([paramASN1Sequence size] > 2)) {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"Bad sequence size: %d", [paramASN1Sequence size]] userInfo:nil];
        }
        self.certs = [ASN1Sequence getInstance:[paramASN1Sequence getObjectAt:0]];
        if ([paramASN1Sequence size] > 1) {
            self.policies = [ASN1Sequence getInstance:[paramASN1Sequence getObjectAt:1]];
        }
    }
    return self;
}

- (instancetype)initParamOtherCertID:(OtherCertID *)paramOtherCertID
{
    if (self = [super init]) {
        ASN1Sequence *sequence = [[DERSequence alloc] initDERParamASN1Encodable:paramOtherCertID];
        self.certs = sequence;
#if !__has_feature(objc_arc)
    if (sequence) [sequence release]; sequence = nil;
#endif
        return self;
    }else {
#if !__has_feature(objc_arc)
        [self release];
#endif
        return nil;
    }
}

- (NSMutableArray *)getCerts {
    NSMutableArray *arrayOfOtherCertID = [[[NSMutableArray alloc] initWithSize:(int)[self.certs size]] autorelease];
    for (int i = 0; i != [self.certs size]; i++) {
        arrayOfOtherCertID[i] = [OtherCertID getInstance:[self.certs getObjectAt:i]];
    }
    return arrayOfOtherCertID;
}

- (NSMutableArray *)getPolicies {
    if (!self.policies) {
        return nil;
    }
    NSMutableArray *arrayOfPolicyInformation = [[[NSMutableArray alloc] initWithSize:(int)[self.policies size]] autorelease];
    for (int i = 0; i != [self.policies size]; i++) {
        arrayOfPolicyInformation[i] = [PolicyInformation getInstance:[self.policies getObjectAt:i]];
    }
    return arrayOfPolicyInformation;
}

- (ASN1Primitive *)toASN1Primitive {
    ASN1EncodableVector *localASN1EncodableVector = [[ASN1EncodableVector alloc] init];
    [localASN1EncodableVector add:self.certs];
    if (self.policies) {
        [localASN1EncodableVector add:self.policies];
    }
    ASN1Primitive *primitive = [[[DERSequence alloc] initDERParamASN1EncodableVector:localASN1EncodableVector] autorelease];
#if !__has_feature(objc_arc)
    if (localASN1EncodableVector) [localASN1EncodableVector release]; localASN1EncodableVector = nil;
#endif
    return primitive;
}

@end
