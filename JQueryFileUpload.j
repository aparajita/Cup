/*
 * JQueryFileUpload.j
 * JQueryFileUpload
 *
 * Created by Aparajita Fishman on February 3, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPDictionary.j>
@import <Foundation/CPRunLoop.j>
@import <Foundation/CPTimer.j>

@import <AppKit/CPArrayController.j>
@import <AppKit/CPCompatibility.j>
@import <AppKit/CPPlatform.j>
@import <AppKit/CPPlatformWindow.j>

@import "JQueryFileUploadByteCountTransformer.j"
@import "jQueryFileUploadTableCellView.j"

@global jQuery

JQueryFileUploadFileStatus_Pending   = 0;
JQueryFileUploadFileStatus_Uploading = 1;
JQueryFileUploadFileStatus_Complete  = 2;

var FileStatuses = [];

/*!
    @class JQueryFileUploadFile

    A wrapper for the File API (https://developer.mozilla.org/en/DOM/file)
    that allows the values to be used in bindings.

    If the browser does not support the File API, only the name will be
    set, and indeterminate will return YES.

    The data instance variable stores the Javascript data object used
    by jQuery-File-Upload.
*/
@implementation JQueryFileUploadFile : CPObject
{
    JQueryFileUpload    uploader;
    CPString            name @accessors(readonly);
    int                 size @accessors(readonly);
    CPString            type @accessors(readonly);
    int                 status @accessors;
    BOOL                uploading @accessors;
    int                 uploadedBytes @accessors;
    float               bitrate @accessors;
    BOOL                indeterminate @accessors(readonly);
    JSObject            data @accessors;
}

+ (void)initialize
{
    if (self !== [JQueryFileUpload class])
        return;

    FileStatuses[JQueryFileUploadFileStatus_Pending]   = @"Pending";
    FileStatuses[JQueryFileUploadFileStatus_Uploading] = @"Uploading...";
    FileStatuses[JQueryFileUploadFileStatus_Complete]  = @"Complete";
}

/*!
    Designated initializer.

    Init with a Javascript File object and jQuery-File-upload data.
*/
- (id)initWithUploader:(JQueryFileUpload)anUploader file:(JSObject)aFile data:(JSObject)someData
{
    if (self = [super init])
    {
        uploader = anUploader;
        name = aFile.name;
        status = JQueryFileUploadFileStatus_Pending;
        uploading = NO;
        bitrate = 0.0;
        data = someData;

        if (aFile.hasOwnProperty("size"))
        {
            size = aFile.size;
            type = aFile.type;
            indeterminate = NO;
        }
        else
        {
            size = 0;
            type = @"";
            indeterminate = YES;
        }
    }

    return self;
}

- (void)setUploadedBytes:(int)bytes
{
    [self willChangeValueForKey:@"percentComplete"];

    uploadedBytes = bytes;

    [self didChangeValueForKey:@"percentComplete"];
}

/*!
    Return the upload percentage as a number from 0-100.
    Returns zero if indeterminate == YES.
*/
- (int)percentComplete
{
    return indeterminate ? 0 : FLOOR(uploadedBytes / size * 100);
}

- (void)submit
{
    [self setStatus:JQueryFileUploadFileStatus_Uploading];
    [self setUploadedBytes:0];

    data.submit();
}

- (void)start
{
    [self setUploading:YES];
}

- (void)stop
{
    [self setStatus:JQueryFileUploadFileStatus_Pending];
    [self setUploading:NO];

    data.abort();
}

- (void)abort
{
    [self stop];

    [uploader uploadWasAbortedForFile:self];
}

- (CPString)description
{
    return [CPString stringWithFormat:@"%@ \"%@\", size=%d, type=%s, uploadedBytes=%d, status=%s", [super description], name, size, type, uploadedBytes, FileStatuses[status]];
}

@end


var widgetId = @"JQueryFileUpload_input",
    callbacks = nil,
    delegateFilter = 1 << 0,
    delegateWillAdd = 1 << 1,
    delegateAdd = 1 << 2,
    delegateSubmit = 1 << 3,
    delegateSend = 1 << 4,
    delegateSucceed = 1 << 5,
    delegateFail = 1 << 6,
    delegateComplete = 1 << 7,
    delegateAbort = 1 << 8,
    delegateProgress = 1 << 9,
    delegateOverallProgress = 1 << 10,
    delegateStart = 1 << 11,
    delegateStop = 1 << 12,
    delegateChange = 1 << 13,
    delegatePaste = 1 << 14,
    delegateDrop = 1 << 15,
    delegateDrag = 1 << 16,
    delegateChunkWillSend = 1 << 17,
    delegateChunkSucceed = 1 << 18,
    delegateChunkFail = 1 << 19,
    delegateChunkComplete = 1 << 20,
    delegateStartQueue = 1 << 21,
    delegateClearQueue = 1 << 22,
    delegateStopQueue = 1 << 23;

/*!
    @class JQueryFileUpload

    A wrapper for jQuery-File-Upload. The main configuration options
    are available as accessor methods in this class. If other options
    need to be set, use the options and setOptions: methods.

    NOTE: The singleFileUpload option is not supported, it is always set to true.

    This class exposes several read only bindings that are useful when creating
    interfaces that use this class:

    queueController     A CPArrayController which manages the queue of files to be uploaded.
    uploading           A BOOL set to YES during uploading
    indeterminate       A BOOL that indicates whether the total size of the upload
                        queue is known. This affects what is reported in the progress callbacks.
    overallProgress     A dictionary with the following items:
                            uploaded        Number of bytes uploaded so far
                            total           Total number of bytes to be uploaded. If indeterminate
                                            is YES, this is undefined.
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
    int                 maximumChunkSize @accessors;
    int                 maxConcurrentUploads @accessors;
    CPView              dropTarget @accessors(readonly);
    JSObject            jQueryDropTarget;

    CPString            filenameFilter @accessors;
    RegExp              filenameFilterRegex @accessors;
    BOOL                removeCompletedFiles @accessors;

    jQueryEvent         currentEvent @accessors(readonly);
    JSObject            currentData @accessors(readonly);

    CPMutableArray      queue @accessors;
    BOOL                uploading @accessors;
    BOOL                indeterminate @accessors;
    CPMutableDictionary overallProgress @accessors;

    id                  delegate @accessors(readonly);
    int                 delegateImplementsFlags;

    Class               fileClass;

    @outlet CPArrayController queueController @accessors(readonly);
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
    sequential = options["sequential"] || YES;
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
    jQuery(document)[dropTarget ? "bind" : "unbind"]('drop dragover', function(e)
    {
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

    if ([delegate respondsToSelector:@selector(fileUpload:didFilterFile:)])
        delegateImplementsFlags |= delegateFilter;

    if ([delegate respondsToSelector:@selector(fileUpload:willAddFile:)])
        delegateImplementsFlags |= delegateWillAdd;

    if ([delegate respondsToSelector:@selector(fileUpload:didAddFile:)])
        delegateImplementsFlags |= delegateAdd;

    if ([delegate respondsToSelector:@selector(fileUploadDidStart:)])
        delegateImplementsFlags |= delegateStart;

    if ([delegate respondsToSelector:@selector(fileUpload:willSubmitFile:)])
        delegateImplementsFlags |= delegateSubmit;

    if ([delegate respondsToSelector:@selector(fileUpload:willSendFile:)])
        delegateImplementsFlags |= delegateSend;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkWillSendForFile:)])
        delegateImplementsFlags |= delegateChunkWillSend;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkDidSucceedForFile:)])
        delegateImplementsFlags |= delegateChunkSucceed;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkDidFailForFile:)])
        delegateImplementsFlags |= delegateChunkFail;

    if ([delegate respondsToSelector:@selector(fileUpload:chunkDidCompleteForFile:)])
        delegateImplementsFlags |= delegateChunkComplete;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadForFile:didProgress:)])
        delegateImplementsFlags |= delegateProgress;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadsDidProgressOverall:)])
        delegateImplementsFlags |= delegateOverallProgress;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidSucceedForFile:)])
        delegateImplementsFlags |= delegateSucceed;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidFailForFile:)])
        delegateImplementsFlags |= delegateFail;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidCompleteForFile:)])
        delegateImplementsFlags |= delegateComplete;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadWasAbortedForFile:)])
        delegateImplementsFlags |= delegateAbort;

    if ([delegate respondsToSelector:@selector(fileUploadDidStop:)])
        delegateImplementsFlags |= delegateStop;

    if ([delegate respondsToSelector:@selector(fileUpload:fileInputDidSelectFiles:)])
        delegateImplementsFlags |= delegateChange;

    if ([delegate respondsToSelector:@selector(fileUploadDidStartQueue:)])
        delegateImplementsFlags |= delegateStartQueue;

    if ([delegate respondsToSelector:@selector(fileUploadDidClearQueue:)])
        delegateImplementsFlags |= delegateClearQueue;

    if ([delegate respondsToSelector:@selector(fileUploadDidStopQueue:)])
        delegateImplementsFlags |= delegateStopQueue;

    if ([delegate respondsToSelector:@selector(fileUpload:didPasteFiles:)])
        delegateImplementsFlags |= delegatePaste;

    if ([delegate respondsToSelector:@selector(fileUpload:didDropFiles:)])
        delegateImplementsFlags |= delegateDrop;

    if ([delegate respondsToSelector:@selector(fileUpload:wasDraggedOverWithEvent:)])
        delegateImplementsFlags |= delegateDrag;
}

- (void)setFileClass:(Class)aClass
{
    if ([aClass isKindOfClass:[JQueryFileUploadFile class]])
    {
        fileClass = aClass;
        [queueController setObjectClass:fileClass];
    }
    else
        CPLog.warn("%s the file class must be a subclass of JQueryFileUploadFile.", [aClass className]);
}

/*!
    Sets the filter used to validate filenames that are being added to the queue.
    The string is passed to `new RegExp()`, so no delimiters should be included in the string.
*/
- (void)setFilenameFilter:(CPString)aFilter
{
    if (filenameFilter === aFilter)
        return;

    [self _setFilenameFilter:aFilter caseSensitive:YES];
}

/*!
    Sets the filter used to validate filenames that are being added to the queue.
    The string is passed to `new RegExp()`, so no delimiters should be included in the string.
*/
- (void)setFilenameFilter:(CPString)aFilter caseSensitive:(BOOL)caseSensitive
{
    [self willChangeValueForKey:@"filenameFilter"];

    [self _setFilenameFilter:aFilter caseSensitive:caseSensitive];

    [self didChangeValueForKey:@"filenameFilter"];
}

/*!
    Sets the filter regex used to validate filenames that are being added to the queue.
    The filenameFilter string is set to stay in sync with the regex.
*/
- (void)setFilenameFilterRegex:(RegExp)regex
{
    if (filenameFilterRegex.toString() === regex.toString())
        return;

    filenameFilterRegex = regex;

    [self willChangeValueForKey:@"filenameFilter"];

    if (regex)
        filenameFilter = regex.toString().replace(/^\/(.*)\/(\w*)?$/, "$1");
    else
        filenameFilter = @"";

    [self didChangeValueForKey:@"filenameFilter"];
}

/*!
    Set the list of allowed filename extensions when adding.
    This is just a convenience method that generates a filename filter.
    Any existing filename filter will be replaced.
*/
- (void)setAllowedExtensions:(CPArray)extensions
{
    var filter = @"";

    if ([extensions count])
        filter = [CPString stringWithFormat:@"^.+\\.(%@)$", extensions.join("|")];

    [self setFilenameFilter:filter caseSensitive:NO];
}

- (CPArrayController)queueController
{
    if (!queueController)
    {
        if (queue === nil)
            queue = [];

        queueController = [[CPArrayController alloc] initWithContent:queue];
        [queueController setObjectClass:[fileClass class]];
        [queueController addObserver:self forKeyPath:@"content" options:0 context:nil];
    }

    return queueController;
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
- (@action)start:(id)sender
{
    [self fileUpload:@"option", [self makeOptions]];

    [queue makeObjectsPerformSelector:@selector(submit)];

    if (delegateImplementsFlags & delegateStartQueue)
        [delegate fileUploadDidStartQueue:self];
}

/*!
    Abort all uploads. Can be used as an action method.
*/
- (@action)stop:(id)sender
{
    [queue makeObjectsPerformSelector:@selector(stop)];

    if (delegateImplementsFlags & delegateStopQueue)
        [delegate fileUploadDidStopQueue:self];

    [self setUploading:NO];
}

/*!
    Clears the queue of files to be uploaded.
    If an upload is in progress, nothing happens.
    Can be used as an action method.
*/
- (@action)clearQueue:(id)sender
{
    if (uploading)
        return;

    [queue removeAllObjects];
    [[self queueController] setContent:queue];
    [self resetOverallProgressZeroingTotal:YES];

    if (delegateImplementsFlags & delegateClearQueue)
        [delegate fileUploadDidClearQueue:self];
}

#pragma mark Methods

- (void)abortUploadWithUID:(CPString)aUID
{
    var file = [queue objectAtIndex:[queue indexOfObjectPassingTest:function(file)
                    {
                        return [file UID] === aUID;
                    }]];

    [file abort];
}

#pragma mark Overrides

- (void)awakeFromCib
{
    [queueController addObserver:self forKeyPath:@"content" options:0 context:nil];
}

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)anObject change:(CPDictionary)changeDict context:(JSObject)context
{
    if (aKeyPath === @"content")
    {
        // If a file is added or removed from the content, reset the overall progress to zero.
        [self resetOverallProgressZeroingTotal:NO];
    }
}

#pragma mark Delegate (private)

- (void)addFile:(JSFile)aFile
{
    var canAdd = YES;

    if (filenameFilter)
        canAdd = filenameFilterRegex.test(aFile.name);

    var file = [[fileClass alloc] initWithUploader:self file:aFile data:currentData];

    // Tag the JS File object with the JQueryFileUploadFile UID so we can locate
    // the JQueryFileUploadFile object later from a File object.
    aFile.CPUID = [file UID];

    if (canAdd)
    {
        if (delegateImplementsFlags & delegateWillAdd)
            canAdd = [delegate fileUpload:self willAddFile:file];
    }
    else if (delegateImplementsFlags & delegateFilter)
        [delegate fileUpload:self didFilterFile:file];

    if (canAdd)
    {
        [[self queueController] addObject:file];

        if (delegateImplementsFlags & delegateAdd)
            [delegate fileUpload:self didAddFile:file];
    }
}

- (void)uploadDidStart
{
    [[self queueController] setSelectionIndexes:[CPIndexSet indexSet]];
    [self setUploading:YES];

    if (delegateImplementsFlags & delegateStart)
        [delegate fileUploadDidStart:self];
}

- (BOOL)submitFile:(JQueryFileUploadFile)aFile
{
    if (delegateImplementsFlags & delegateSubmit)
        return [delegate fileUpload:self willSubmitFile:aFile];

    return YES;
}

- (BOOL)willSendFile:(JQueryFileUploadFile)aFile
{
    var canSend = YES;

    if (delegateImplementsFlags & delegateSend)
        canSend = [delegate fileUpload:self willSendFile:aFile];

    if (canSend)
        [aFile start];

    return canSend;
}

- (BOOL)chunkWillSendForFile:(JQueryFileUploadFile)aFile
{
    if (delegateImplementsFlags & delegateChunkWillSend)
        return [delegate fileUpload:self willSendChunkForFile:aFile];

    return YES;
}

- (void)chunkDidSucceedForFile:(JQueryFileUploadFile)aFile
{
    [aFile setUploadedBytes:currentData.loaded];

    if (delegateImplementsFlags & delegateChunkSucceed)
        [delegate fileUpload:self chunkDidSucceedForFile:aFile];
}

- (void)chunkDidFailForFile:(JQueryFileUploadFile)aFile
{
    if (delegateImplementsFlags & delegateChunkFail)
        [delegate fileUpload:self chunkDidFailForFile:aFile];
}

- (void)chunkDidCompleteForFile:(JQueryFileUploadFile)aFile
{
    if (delegateImplementsFlags & delegateChunkComplete)
        [delegate fileUpload:self chunkDidCompleteForFile:aFile];
}

- (void)uploadForFile:(JQueryFileUploadFile)aFile didProgress:(JSObject)progress
{
    if (progress.uploadedBytes)
        [aFile setUploadedBytes:progress.uploadedBytes];

    [aFile setBitrate:progress.bitrate];

    if (delegateImplementsFlags & delegateProgress)
        [delegate fileUpload:self uploadForFile:aFile didProgress:progress];
}

- (void)overallUploadDidProgress:(JSObject)progress
{
    [self updateOverallProgressWithUploadedBytes:progress.uploadedBytes
                                           total:progress.total
                                 percentComplete:progress.uploadedBytes / progress.total * 100
                                         bitrate:progress.bitrate];

    if (delegateImplementsFlags & delegateOverallProgress)
        [delegate fileUpload:self uploadsDidProgressOverall:progress];
}

- (void)uploadDidSucceedForFile:(JQueryFileUploadFile)aFile
{
    [aFile setStatus:JQueryFileUploadFileStatus_Complete];

    // If a file upload is chunked and had one or more chunks,
    // the final progress was already set and when we get here
    // the loaded and bitrate values are zero, so ignore them.
    if (currentData.loaded)
        [aFile setUploadedBytes:currentData.loaded];

    if (currentData.bitrate)
        [aFile setBitrate:currentData.bitrate];

    if (delegateImplementsFlags & delegateSucceed)
        [delegate fileUpload:self uploadDidSucceedForFile:aFile];
}

- (void)uploadDidFailForFile:(JQueryFileUploadFile)aFile
{
    [aFile setStatus:JQueryFileUploadFileStatus_Pending];

    if (delegateImplementsFlags & delegateFail)
        [delegate fileUpload:self uploadDidFailForFile:aFile];
}

- (void)uploadDidCompleteForFile:(JQueryFileUploadFile)aFile
{
    [aFile setUploading:NO];

    if (delegateImplementsFlags & delegateComplete)
        [delegate fileUpload:self uploadDidCompleteForFile:aFile];
}

- (void)uploadWasAbortedForFile:(JQueryFileUploadFile)aFile
{
    if (delegateImplementsFlags & delegateAbort)
        [delegate fileUpload:self uploadWasAbortedForFile:aFile];
}

- (void)uploadDidStop
{
    [self setUploading:NO];

    if (delegateImplementsFlags & delegateStop)
        [delegate fileUploadDidStop:self];

    // Remove complete files
    if (removeCompletedFiles)
    {
        var indexes = [queue indexesOfObjectsPassingTest:function(file)
                        {
                            return [file status] === JQueryFileUploadFileStatus_Complete;
                        }];

        [queue removeObjectsAtIndexes:indexes];
        [[self queueController] setContent:queue];
    }
}

- (void)fileInputDidSelectFiles:(CPArray)files
{
    if (delegateImplementsFlags & delegateChange)
        [delegate fileUpload:self fileInputDidSelectFiles:files];
}

- (void)filesWerePasted:(CPArray)files
{
    if (delegateImplementsFlags & delegatePaste)
        [delegate fileUpload:self didPasteFiles:files];
}

- (void)filesWereDropped:(CPArray)files
{
    if (delegateImplementsFlags & delegateDrop)
        [delegate fileUpload:self didDropFiles:files];
}

- (void)filesWereDraggedOverWithEvent:(jQueryEvent)anEvent
{
    if (delegateImplementsFlags & delegateDrag)
        [delegate fileUpload:self wasDraggedOverWithEvent:anEvent];
}

#pragma mark Private helpers

- (void)_init
{
    [self makeFileInput];

    fileUploadOptions = {};
    delegateImplementsFlags = 0;

    if (queue === nil)
        queue = [];

    URL = URL || @"";
    redirectURL = @"";
    sequential = YES;
    maxConcurrentUploads = 0;
    overallProgress = [CPMutableDictionary dictionary];
    dropTarget = [CPPlatformWindow primaryPlatformWindow];
    jQueryDropTarget = jQuery(document);
    removeCompletedFiles = NO;

    [self resetOverallProgressZeroingTotal:YES];
    [self setUploading:NO];
    [self setIndeterminate:!CPFeatureIsCompatible(CPFileAPIFeature)];

    // We have to wait till the next time through the run loop
    // so the display server has a chance to update the dom.
    [CPTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(finishInit) userInfo:nil repeats:NO];
}

/*! @ignore */
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

/*! @ignore */
- (void)finishInit
{
    jQuery("#" + widgetId).fileupload([self makeOptions]);
}

/*! @ignore */
- (void)setCallbacks:(JSObject)options
{
    if (!callbacks)
    {
        callbacks =
        {
            add: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self addFile:data.files[0]];
                [self pumpRunLoop];
            },

            submit: function(e, data)
            {
                currentEvent = e;
                currentData = data;

                var canSubmit = [self submitFile:[self fileFromJSFile:data.files[0]]];

                [self pumpRunLoop];
                return canSubmit;
            },

            send: function(e, data)
            {
                currentEvent = e;
                currentData = data;

                var canSend = [self willSendFile:[self fileFromJSFile:data.files[0]]];

                [self pumpRunLoop];
                return canSend;
            },

            done: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self uploadDidSucceedForFile:[self fileFromJSFile:data.files[0]]];
                [self pumpRunLoop];
            },

            fail: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self uploadDidFailForFile:[self fileFromJSFile:data.files[0]]];
                [self pumpRunLoop];
            },

            always: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self uploadDidCompleteForFile:[self fileFromJSFile:data.files[0]]];
                [self pumpRunLoop];
            },

            progress: function(e, data)
            {
                currentEvent = e;
                currentData = data;

                var progress = {
                    uploadedBytes:  data.uploadedBytes,
                    total:          data.total,
                    bitrate:        data.bitrate
                };

                [self uploadForFile:[self fileFromJSFile:data.files[0]] didProgress:progress];
                [self pumpRunLoop];
            },

            progressall: function(e, data)
            {
                currentEvent = e;
                currentData = data;

                var progress = {
                    uploadedBytes:  data.loaded,
                    total:          data.total,
                    bitrate:        data.bitrate
                };

                [self overallUploadDidProgress:progress];
                [self pumpRunLoop];
            },

            start: function(e)
            {
                currentEvent = e;
                currentData = nil;
                [self uploadDidStart];
                [self pumpRunLoop];
            },

            stop: function(e)
            {
                currentEvent = e;
                currentData = nil;
                [self uploadDidStop];
                [self pumpRunLoop];
            },

            change: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self fileInputDidSelectFiles:data.files];
                [self pumpRunLoop];
            },

            paste: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self filesWerePasted:data.files];
                [self pumpRunLoop];
            },

            drop: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self filesWereDropped:data.files];
                [self pumpRunLoop];
            },

            dragover: function(e)
            {
                currentEvent = e;
                currentData = nil;
                [self filesWereDraggedOverWithEvent:e];
                [self pumpRunLoop];
            },

            chunksend: function(e, data)
            {
                currentEvent = e;
                currentData = data;

                var canSend = [self chunkWillSendForFile:[self fileFromJSFile:data.files[0]]];

                [self pumpRunLoop];
                return canSend;
            },

            chunkdone: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self chunkDidSucceedForFile:[self fileFromJSFile:data.files[0]]];
                [self pumpRunLoop];
            },

            chunkfail: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self chunkDidFailForFile:[self fileFromJSFile:data.files[0]]];
                [self pumpRunLoop];
            },

            chunkalways: function(e, data)
            {
                currentEvent = e;
                currentData = data;
                [self chunkDidCompleteForFile:[self fileFromJSFile:data.files[0]]];
                [self pumpRunLoop];
            }
        };
    }

    for (var key in callbacks)
        if (callbacks.hasOwnProperty(key))
            options[key] = callbacks[key];
}

- (void)_setFilenameFilter:(CPString)aFilter caseSensitive:(BOOL)caseSensitive
{
    filenameFilter = aFilter;

    [self willChangeValueForKey:@"filenameFilterRegex"];

    filenameFilterRegex = aFilter ? new RegExp(aFilter, caseSensitive ? "" : "i") : nil;

    [self didChangeValueForKey:@"filenameFilterRegex"];
}

/*! @ignore */
- (void)pumpRunLoop
{
    // Pump the run loop, jQuery-File-Upload event handlers are called outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

/*! @ignore */
- (JQueryFileUploadFile)fileFromJSFile:(JSFile)aFile
{
    return [self fileWithUID:aFile.CPUID];
}

- (JQueryFileUploadFile)fileWithUID:(CPString)aUID
{
    return [queue objectAtIndex:[queue indexOfObjectPassingTest:function(file)
                {
                    return [file UID] === aUID;
                }]];
}

/*! @ignore */
- (id)fileUpload:(id)firstObject, ...
{
    // The arguments array contains self and _cmd, so the first object is at position 2.
    var args = Array.prototype.slice.apply(arguments, [2]),
        widget = jQuery("#" + widgetId);

    if (args[0] !== nil)
        return widget.fileupload.apply(widget, args);
    else
        return widget.fileupload();
}

/*! @ignore */
- (JSObject)makeOptions
{
    fileUploadOptions["dataType"] = "json";
    fileUploadOptions["url"] = URL;
    fileUploadOptions["redirect"] = redirectURL;
    fileUploadOptions["sequentialUploads"] = sequential;
    fileUploadOptions["singleFileUploads"] = true;
    fileUploadOptions["maxChunkSize"] = maximumChunkSize;
    fileUploadOptions["limitConcurrentUploads"] = maxConcurrentUploads;
    fileUploadOptions["dropZone"] = jQueryDropTarget;

    [self setCallbacks:fileUploadOptions];

    return fileUploadOptions;
}

/*! @ignore */
- (void)updateOverallProgressWithUploadedBytes:(int)uploadedBytes total:(int)total percentComplete:(float)percentComplete bitrate:(int)bitrate
{
    // Allow bindings to see the change in the dictionary values
    [self willChangeValueForKey:@"overallProgress"];

    [overallProgress setValue:uploadedBytes forKey:@"uploadedBytes"];
    [overallProgress setValue:total forKey:@"total"];
    [overallProgress setValue:percentComplete forKey:@"percentComplete"];
    [overallProgress setValue:bitrate forKey:@"bitrate"];

    [self didChangeValueForKey:@"overallProgress"];
}

/*! @ignore */
- (void)resetOverallProgressZeroingTotal:(BOOL)zeroTotal
{
    var total = zeroTotal ? 0 : [overallProgress valueForKey:@"total"];
    [self updateOverallProgressWithUploadedBytes:0 total:total percentComplete:0.0 bitrate:0];
}

@end


/*! @ignore */
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
