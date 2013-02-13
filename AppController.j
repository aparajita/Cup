/*
 * AppController.j
 * upload
 *
 * Created by You on February 3, 2013.
 * Copyright 2013, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>

@import "JQueryFileUpload.j"
@import "JQueryFileUploadQueueController.j"


@implementation AppController : CPObject
{
    @outlet CPWindow            testWindow;
    @outlet JQueryFileUpload    upload;
    @outlet CPButton            uploadButton;
    @outlet CPButton            resetButton;
    @outlet CPProgressIndicator progressBar;
    @outlet CPView              queueContainer;

    JQueryFileUploadQueueController queueController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
}

- (void)awakeFromCib
{
    [upload initWithURL:@"http://dev.upload.com/index.php"];
    [upload setDropTarget:[testWindow contentView]];
    [upload setMaximumChunkSize:50000];

    queueController = [[JQueryFileUploadQueueController alloc] initWithFileUpload:upload];

    var queueView = [queueController view];

    [queueView setFrame:[queueContainer bounds]];
    [queueContainer addSubview:queueView];
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didAddFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %s", _cmd, [data.files description]);
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSubmitFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %s", _cmd, [data.files description]);
    return YES;
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %s", _cmd, [data.files description]);
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidSucceedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidFailWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidProgressWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadsDidProgressOverallWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidStartWithEvent:(jQueryEvent)anEvent
{
    console.log("%s: %o", _cmd, anEvent);
    [uploadButton setEnabled:NO];
    [resetButton setEnabled:NO];
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidStopWithEvent:(jQueryEvent)anEvent
{
    console.log("%s: %o", _cmd, anEvent);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload fileInputDidChangeWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didPasteFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didDropFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didDragOverFilesWithEvent:(jQueryEvent)anEvent
{
    console.log("%s: %o", _cmd, anEvent);
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendChunkWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidSucceedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidFailWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    console.log("%s: %o", _cmd, data);
}

@end


var OverallProgressDisplayTransformerFormatter = nil;

@implementation OverallProgressDisplayTransformer : CPValueTransformer

+ (void)initialize
{
    if (self !== OverallProgressDisplayTransformer)
        return;

    [CPValueTransformer setValueTransformer:[self new]
                                    forName:@"OverallProgressDisplayTransformer"];

    OverallProgressDisplayTransformerFormatter = [CPByteCountFormatter new];
    [OverallProgressDisplayTransformerFormatter setAllowsNonnumericFormatting:NO];
    [OverallProgressDisplayTransformerFormatter setZeroPadsFractionDigits:YES];
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
    return [CPString stringWithFormat:@"%s of %s uploaded", [OverallProgressDisplayTransformerFormatter stringFromByteCount:[value valueForKey:@"uploaded"]], [OverallProgressDisplayTransformerFormatter stringFromByteCount:[value valueForKey:@"total"]]];
}

@end
