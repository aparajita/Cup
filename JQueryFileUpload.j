/*
 * JQueryFileUpload.j
 * upload
 *
 * Created by Aparajita Fishman on February 3, 2013.
 * Copyright 2013, Filmworkers. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPCompatibility.j>
@import <AppKit/CPPlatform.j>

@global jQuery

var widgetId = @"JQueryFileUpload_input",
    callbacks = nil,
    delegateAdd = 1 << 0,
    delegateSubmit = 1 << 1,
    delegateSend = 1 << 2,
    delegateSucceed = 1 << 3,
    delegateFail = 1 << 4,
    delegateComplete = 1 << 5,
    delegateProgress = 1 << 6,
    delegateOverallProgress = 1 << 7,
    delegateStart = 1 << 8,
    delegateStop = 1 << 9,
    delegateChange = 1 << 10,
    delegatePaste = 1 << 11,
    delegateDrop = 1 << 12,
    delegateDrag = 1 << 13,
    delegateChunkSend = 1 << 14,
    delegateChunkSucceed = 1 << 15,
    delegateChunkFail = 1 << 16,
    delegateChunkComplete = 1 << 17;


/*!
    @class JQueryFileUpload

    A wrapper for jQuery-File-Upload. The main configuration options
    are available as accessor methods in this class. If other options
    need to be set, use the options and setOptions: methods.

    This class exposes several read only bindings that are useful when creating
    interfaces that use this class:

    fileCount           The number of files in the upload queue
    uploading           A BOOL set to YES during uploading
    haveUploadSize      A BOOL that indicates whether the total size of the upload
                        queue is known. This affects what is reported in the progress callbacks.
    overallProgress     A dictionary with the following items:
                            uploaded        Number of bytes uploaded so far
                            total           Total number of bytes to be uploaded. If haveUploadSize
                                            is NO, this is undefined.
                            percentComplete Percentage of the total (0-100) uploaded so far
                            bitrate         The overall bitrate of the upload so far

                        You can bind both to the dictionary and to items within the dictionary.

    The full set of callbacks supported by jQuery-File-Upload are provided as delegate methods.
    See the jQueryFileUploadDelegate class for more info.
*/
@implementation JQueryFileUpload : CPObject
{
    // jQuery-File-Upload options
    JSObject            fileUploadOptions;
    CPString            URL @accessors;
    CPString            redirectURL @accessors;
    BOOL                sequential @accessors;
    BOOL                singleFileUploads @accessors;
    int                 multiFileLimit @accessors;
    int                 maximumChunkSize @accessors;
    int                 maxConcurrentUploads @accessors;
    CPView              dropTarget @accessors(readonly);
    JSObject            jQueryDropTarget;

    CPMutableArray      fileData;
    int                 fileCount @accessors;
    BOOL                uploading @accessors;
    BOOL                haveUploadSize @accessors;
    CPMutableDictionary overallProgress @accessors;

    BOOL                initialized;
    id                  delegate @accessors(readonly);
    int                 delegateImplementsFlags;
}

#pragma mark Initialization

- (id)initWithURL:(CPString)aURL
{
    self = [self init];

    if (self)
        [self setURL:aURL];

    return self;
}

- (id)init
{
    self = [super init];

    if (self)
        [self _init];

    return self;
}

#pragma mark Attributes

/*!
    Returns a copy of the options passed to jQuery-File-Upload.
    To set the options from your copy, use setOptions:.
*/
- (JSObject)options
{
    return [CPObject copyJSObject:[self makeOptions]];
}

/*!
    Sets the options to a copy of the passed in options.
    Callbacks and dropZone are ignored.
*/
- (void)setOptions:(JSObject)options
{
    fileUploadOptions = cloneOptions(options);

    URL = options["url"] || @"";
    redirectURL = options["redirect"] || @"";
    sequential = options["sequential"] || NO;
    singleFileUploads = options["singleFileUploads"] || NO;
    multiFileLimit = options["limitMultiFileUploads"] || 0;
    maximumChunkSize = options["maxChunkSize"] || 0;
    maxConcurrentUploads = ["limitConcurrentUploads"] || NO;
}

/*!
    Set the view that will be the drop target for files dragged into
    the browser. Pass [CPPlatformWindow primaryPlatformWindow] to make
    the entire window the drop target. Pass nil to disable drag and drop.
*/
- (void)setDropTarget:(CPView)target
{
    dropTarget = target;

    if (dropTarget === [CPPlatformWindow primaryPlatformWindow])
        jQueryDropTarget = jQuery(document);
    else if (!dropTarget)
        jQueryDropTarget = nil;
    else
        jQueryDropTarget = jQuery(dropTarget._DOMElement);

    // If drag and drop is enabled, disable the browser's default drag and drop action
    jQuery(document)[dropTarget ? "bind" : "unbind"]('drop dragover', function (e) {
        e.preventDefault();
    });
}

- (void)setDelegate:(id)aDelegate
{
    if (aDelegate === delegate)
        return;

    delegateImplementsFlags = 0;
    delegate = aDelegate;

    if (!delegate)
        return;

    if ([delegate respondsToSelector:@selector(fileUpload:didAddFilesWithEvent:data:)])
        delegateImplementsFlags |= delegateAdd;

    if ([delegate respondsToSelector:@selector(fileUpload:willSubmitFilesWithEvent:data:)])
        delegateImplementsFlags |= delegateSubmit;

    if ([delegate respondsToSelector:@selector(fileUpload:willSendFilesWithEvent:data:)])
        delegateImplementsFlags |= delegateSend;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidSucceedWithEvent:data:)])
        delegateImplementsFlags |= delegateSucceed;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidFailWithEvent:data:)])
        delegateImplementsFlags |= delegateFail;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidCompleteWithEvent:data:)])
        delegateImplementsFlags |= delegateComplete;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidProgressWithEvent:data:)])
        delegateImplementsFlags |= delegateProgress;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadsDidProgressOverallWithEvent:data:)])
        delegateImplementsFlags |= delegateOverallProgress;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidStartWithEvent:)])
        delegateImplementsFlags |= delegateStart;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidStopWithEvent:)])
        delegateImplementsFlags |= delegateStop;

    if ([delegate respondsToSelector:@selector(fileUpload:fileInputDidChangeWithEvent:data:)])
        delegateImplementsFlags |= delegateChange;

    if ([delegate respondsToSelector:@selector(fileUpload:didPasteFilesWithEvent:data:)])
        delegateImplementsFlags |= delegatePaste;

    if ([delegate respondsToSelector:@selector(fileUpload:didDropFilesWithEvent:data:)])
        delegateImplementsFlags |= delegateDrop;

    if ([delegate respondsToSelector:@selector(fileUpload:didDragOverFilesWithEvent:)])
        delegateImplementsFlags |= delegateDrag;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkDidSucceedWithEvent:data:)])
        delegateImplementsFlags |= delegateChunkSucceed;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkDidFailWithEvent:data:)])
        delegateImplementsFlags |= delegateChunkFail;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkDidCompleteWithEvent:data:)])
        delegateImplementsFlags |= delegateChunkComplete;
}

#pragma mark Actions

/*!
    Add files via a file chooser dialog.
    Can be used as an action method.
*/
- (@action)addFiles:(id)sender
{
    jQuery("#" + widgetId)[0].click();
}

/*!
    Upload the currently selected files.
    Can be used as an action method.
*/
- (@action)upload:(id)sender
{
    [self fileUpload:"option", [self makeOptions]];

    [fileData enumerateObjectsUsingBlock:function(data)
        {
            data.submit();
        }];
}

/*!
    Clears the queue of files to be uploaded.
    If an upload is in progress, nothing happens.
*/
- (@action)clearQueue:(id)sender
{
    if (uploading)
        return;

    [fileData removeAllObjects];
    [self setFileCount:0];
}

- (@action)reset:(id)sender
{
    [self clearQueue:sender];
    [self resetOverallProgress];
}

#pragma mark Delegate (private)

- (void)addFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if ([fileData count] === 0)
        [self resetOverallProgress];

    [fileData addObject:data];
    [self setFileCount:fileCount + data.files.length];

    if (haveUploadSize)
    {
        var total = [overallProgress valueForKey:@"total"];

        for (var i = 0; i < data.files.length; ++i)
            total += data.files[i]["size"];

        [self updateOverallProgressWithUploaded:0 total:total percentComplete:0.0 bitrate:0];
    }

    if (delegateImplementsFlags & delegateAdd)
        [delegate fileUpload:self didAddFilesWithEvent:anEvent data:data];

    // Pump the run loop, if files are dropped or pasted this method is called
    // outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (BOOL)submitFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateSubmit)
        return [delegate fileUpload:self willSubmitFilesWithEvent:anEvent data:data];

    return YES;
}

- (BOOL)sendFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateSend)
        return [delegate fileUpload:self willSendFilesWithEvent:anEvent data:data];

    return YES;
}

- (void)uploadDidSucceedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateSucceed)
        [delegate fileUpload:self uploadDidSucceedWithEvent:anEvent data:data];
}

- (void)uploadDidFailWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateFail)
        [delegate fileUpload:self uploadDidFailWithEvent:anEvent data:data];
}

- (void)uploadDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateComplete)
        [delegate fileUpload:self uploadDidCompleteWithEvent:anEvent data:data];
}

- (void)uploadProgressWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateProgress)
        [delegate fileUpload:self uploadDidProgressWithEvent:anEvent data:data];
}

- (void)overallProgressWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    [self updateOverallProgressWithUploaded:data.loaded
                                      total:data.total
                            percentComplete:data.loaded / data.total * 100
                                    bitrate:data.bitrate];

    if (delegateImplementsFlags & delegateOverallProgress)
        [delegate fileUpload:self uploadsDidProgressOverallWithEvent:anEvent data:data];

    // Pump the run loop, this is called outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (void)uploadDidStartWithEvent:(jQueryEvent)anEvent
{
    [self resetOverallProgress];
    [self setUploading:YES];

    if (delegateImplementsFlags & delegateStart)
        [delegate fileUpload:self uploadDidStartWithEvent:anEvent];
}

- (void)uploadDidStopWithEvent:(jQueryEvent)anEvent
{
    [self setUploading:NO];
    [self clearQueue:self];

    if (delegateImplementsFlags & delegateStop)
        [delegate fileUpload:self uploadDidStopWithEvent:anEvent];
}

- (void)fileInputDidChangeWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateChange)
        [delegate fileUpload:self fileInputDidChangeWithEvent:anEvent data:data];
}

- (void)filesWerePastedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegatePaste)
        [delegate fileUpload:self didPasteFilesWithEvent:anEvent data:data];
}

- (void)filesWereDroppedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateDrop)
        [delegate fileUpload:self didDropFilesWithEvent:anEvent data:data];

    // Pump the run loop, this is called outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (void)filesWereDraggedOverWithEvent:(jQueryEvent)anEvent
{
    if (delegateImplementsFlags & delegateDrag)
        [delegate fileUpload:self didDragOverFilesWithEvent:anEvent];

    // Pump the run loop, this is called outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (BOOL)chunkWillSendWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if ([delegate respondsToSelector:@selector(fileUpload:willSendChunkWithEvent:data:)])
        return [delegate fileUpload:self willSendChunkWithEvent:anEvent data:data];

    return YES;
}

- (void)chunkDidSucceedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateChunkSucceed)
        [delegate fileUpload:self chunkDidSucceedWithEvent:anEvent data:data];
}

- (void)chunkDidFailWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateChunkFail)
        [delegate fileUpload:self chunkDidFailWithEvent:anEvent data:data];
}

- (void)chunkDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    if (delegateImplementsFlags & delegateChunkComplete)
        [delegate fileUpload:self chunkDidCompleteWithEvent:anEvent data:data];
}

#pragma mark Private helpers

- (void)_init
{
    if (initialized)
        return;

    initialized = NO;

    [self makeFileInput];
    fileData = [];
    fileUploadOptions = {};
    delegateImplementsFlags = 0;

    URL = URL || @"";
    redirectURL = @"";
    sequential = NO;
    singleFileUploads = YES;
    multiFileLimit = 0;
    maxConcurrentUploads = 0;
    overallProgress = [CPMutableDictionary dictionary];
    dropTarget = [CPPlatformWindow primaryPlatformWindow];
    jQueryDropTarget = jQuery(document);

    [self updateOverallProgressWithUploaded:0 total:0 percentComplete:0.0 bitrate:0];
    [self setFileCount:0];
    [self setUploading:NO];
    [self setHaveUploadSize:CPFeatureIsCompatible(CPFileAPIFeature)];

    initialized = YES;

    // We have to wait till the next time through the run loop
    // so the display server has a chance to update the dom.
    [CPTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(finishInit) userInfo:nil repeats:NO];
}

- (void)makeFileInput
{
    var input = document.getElementById(widgetId);

    if (input)
        return;

    var bodyElement = [CPPlatform mainBodyElement],
        input = document.createElement("input");

    input.className = "cpdontremove";
    input.setAttribute("type", "file");
    input.setAttribute("id", widgetId);
    input.setAttribute("name", "files[]");
    input.setAttribute("multiple", "");
    input.style.visibility = "hidden";

    bodyElement.appendChild(input);
}

- (void)finishInit
{
    jQuery("#" + widgetId).fileupload([self makeOptions]);
}

- (void)setCallbacks:(JSObject)options
{
    if (!callbacks)
    {
        callbacks =
        {
            add: function (e, data) { [self addFilesWithEvent:e data:data]; },
            submit: function (e, data) { return [self submitFilesWithEvent:e data:data]; },
            send: function (e, data) { return [self sendFilesWithEvent:e data:data]; },
            done: function (e, data) { [self uploadDidSucceedWithEvent:e data:data]; },
            fail: function (e, data) { [self uploadDidFailWithEvent:e data:data]; },
            always: function (e, data) { [self uploadDidCompleteWithEvent:e data:data]; },
            progress: function (e, data) { [self uploadProgressWithEvent:e data:data]; },
            progressall: function (e, data) { [self overallProgressWithEvent:e data:data]; },
            start: function (e) { [self uploadDidStartWithEvent:e]; },
            stop: function (e) { [self uploadDidStopWithEvent:e]; },
            change: function (e, data) { [self fileInputDidChangeWithEvent:e data:data]; },
            paste: function (e, data) { [self filesWerePastedWithEvent:e data:data]; },
            drop: function (e, data) { [self filesWereDroppedWithEvent:e data:data]; },
            dragover: function (e) { [self filesWereDraggedOverWithEvent:e]; },
            chunksend: function (e, data) { return [self chunkWillSendWithEvent:e data:data]; },
            chunkdone: function (e, data) { [self chunkDidSucceedWithEvent:e data:data]; },
            chunkfail: function (e, data) { [self chunkDidFailWithEvent:e data:data]; },
            chunkalways: function (e, data) { [self chunkDidCompleteWithEvent:e data:data]; }
        };
    }

    for (var key in callbacks)
        if (callbacks.hasOwnProperty(key))
            options[key] = callbacks[key];
}

- (id)fileUpload:(id)firstObject, ...
{
    // The arguments array contains self and _cmd, so the first object is at position 2.
    var args = Array.prototype.slice.apply(arguments, [2]),
        widget = jQuery("#" + widgetId);

    if (!initialized)
        [self initWithURL:URL];

    if (args[0] !== nil)
        return widget.fileupload.apply(widget, args);
    else
        return widget.fileupload();
}

- (JSObject)makeOptions
{
    fileUploadOptions["dataType"] = "json";
    fileUploadOptions["url"] = URL;
    fileUploadOptions["redirect"] = redirectURL;
    fileUploadOptions["sequentialUploads"] = sequential;
    fileUploadOptions["singleFileUploads"] = singleFileUploads;
    fileUploadOptions["limitMultiFileUploads"] = multiFileLimit;
    fileUploadOptions["maxChunkSize"] = maximumChunkSize;
    fileUploadOptions["limitConcurrentUploads"] = maxConcurrentUploads;
    fileUploadOptions["dropZone"] = jQueryDropTarget;

    [self setCallbacks:fileUploadOptions];

    return fileUploadOptions;
}

- (void)updateOverallProgressWithUploaded:(int)uploaded total:(int)total percentComplete:(float)percentComplete bitrate:(int)bitrate
{
    // Allow bindings to see the change in the dictionary values
    [self willChangeValueForKey:@"overallProgress"];

    [overallProgress setValue:uploaded forKey:@"uploaded"];
    [overallProgress setValue:total forKey:@"total"];
    [overallProgress setValue:percentComplete forKey:@"percentComplete"];
    [overallProgress setValue:bitrate forKey:@"bitrate"];

    [self didChangeValueForKey:@"overallProgress"];
}

- (void)resetOverallProgress
{
    [self updateOverallProgressWithUploaded:0 total:0 percentComplete:0.0 bitrate:0];
}

@end


var cloneOptions = function(options)
{
    var clone = {};

    for (var key in options)
        if (options.hasOwnProperty(key))
            if (typeof(options[key] === "function"))
                continue;
            else if (options[key].constructor === Array)
                clone[key] = options[key].slice(0);
            else if (typeof(options[key]) === "object")
                clone[key] = [CPObject copyJSObject:options[key]];
            else
                clone[key] = options[key];

    return clone;
}
