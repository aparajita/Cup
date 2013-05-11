/*
 * CupByteCountTransformer.j
 * Cup
 *
 * Created by Aparajita Fishman on March 25, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPByteCountFormatter.j>
@import <Foundation/CPValueTransformer.j>

var CupByteCountTransformerSharedFormatter = nil;

/*!
    This class is a CPValueTransformer that converts numbers into
    formatted byte counts by using a CPByteCountFormatter. For information
    on how byte counts are formatted, see:

    https://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSByteCountFormatter_Class/Reference/Reference.html

    By default this class uses a shared formatter with the following properties:

    adaptive: YES
    allowedUnits: CPByteCountFormatterUseKB | CPByteCountFormatterUseMB | CPByteCountFormatterUseGB
    allowsNonNumericFormatting: NO
    zeroPadsFractionDigits: YES

    If you want to change the properties of the shared formatter, you can retrieve it with the
    +sharedFormatter method.

    If you want to change the properties of the formatter for a specific transformer instance,
    you can either create a new CPByteCountFormatter yourself and use the -setFormatter: method,
    or use the -formatter method, which will return a new instance of CPByteCountFormatter that
    belongs to the transformer instance. You can then set the properties of the returned formatter
    as you wish.
*/
@implementation CupByteCountTransformer : CPValueTransformer
{
    CPByteCountFormatter valueFormatter;
}

/*! @ignore */
+ (void)initialize
{
    if (self !== CupByteCountTransformer)
        return;

    [CPValueTransformer setValueTransformer:[self new]
                                    forName:@"CupByteCountTransformer"];

    CupByteCountTransformerSharedFormatter = [self makeFormatter];
}

/*! @ignore */
+ (CPByteCountFormatter)makeFormatter
{
    var formatter = [CPByteCountFormatter new];

    [formatter setAdaptive:YES];
    [formatter setAllowedUnits:CPByteCountFormatterUseKB | CPByteCountFormatterUseMB | CPByteCountFormatterUseGB];
    [formatter setAllowsNonnumericFormatting:NO];
    [formatter setZeroPadsFractionDigits:YES];

    return formatter;
}

/*!
    Returns the shared CPByteCountFormatter used by default by all instances of this class.
*/
+ (CPByteCountFormatter)sharedFormatter
{
    return CupByteCountTransformerSharedFormatter;
}

+ (Class)transformedValueClass
{
    return [CPString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

/*!
    Returns the receiver's instance of CPByteCountFormatter. If the receiver does not yet
    have its own formatter, a new CPByteCountFormatter is assigned and then returned.
*/
- (CPByteCountFormatter)formatter
{
    if (!valueFormatter)
        valueFormatter = [CPByteCountFormatter new];

    return valueFormatter;
}

/*!
    Sets the formatter used by the receiver. If aFormatter is nil, the shared formatter will be used
    when transforming values.
*/
- (void)setFormatter:(CPByteCountFormatter)aFormatter
{
    valueFormatter = aFormatter;
}

- (id)transformedValue:(id)value
{
    value = value === nil ? 0 : value;

    return [(valueFormatter ? valueFormatter : CupByteCountTransformerSharedFormatter) stringFromByteCount:value];
}

@end
