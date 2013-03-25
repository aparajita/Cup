/*
 * JQueryFileUploadByteCountTransformer.j
 * JQueryFileUpload
 *
 * Created by Aparajita Fishman on March 25, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPByteCountFormatter.j>
@import <Foundation/CPValueTransformer.j>

var ByteCountTransformerFormatter = nil;

@implementation JQueryFileUploadByteCountTransformer : CPValueTransformer

+ (void)initialize
{
    if (self !== JQueryFileUploadByteCountTransformer)
        return;

    [CPValueTransformer setValueTransformer:[self new]
                                    forName:@"JQueryFileUploadByteCountTransformer"];

    ByteCountTransformerFormatter = [CPByteCountFormatter new];
    [ByteCountTransformerFormatter setAdaptive:YES];
    [ByteCountTransformerFormatter setAllowedUnits:CPByteCountFormatterUseKB | CPByteCountFormatterUseMB | CPByteCountFormatterUseGB];
    [ByteCountTransformerFormatter setAllowsNonnumericFormatting:NO];
    [ByteCountTransformerFormatter setZeroPadsFractionDigits:YES];
}

+ (Class)transformedValueClass
{
    return [CPString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    value = value === nil ? 0 : value;
    return [ByteCountTransformerFormatter stringFromByteCount:value];
}

@end
