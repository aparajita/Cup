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
@import <AppKit/CPTableView.j>

@global jQuery

JQueryFileUploadFileStatus_Pending   = 0;
JQueryFileUploadFileStatus_Uploading = 1;
JQueryFileUploadFileStatus_Complete  = 2;

/*
    These constants are bit flags passed to the fileUpload:didFilterFile:because:
    delegate method, indicating why the file was rejected.
*/
JQueryFileUploadFilteredName = 1 << 0;
JQueryFileUploadFilteredSize = 1 << 1;

var FileStatuses = [];

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
    delegateStop = 1 << 8,
    delegateFileProgress = 1 << 9,
    delegateProgress = 1 << 10,
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

    A wrapper for jQuery File Upload. The main configuration options
    are available as accessor methods in this class. If other options
    need to be set, use the options and setOptions: methods.

    NOTE: The singleFileUpload option is not supported, it is always set to true.

    The full set of callbacks supported by jQuery File Upload are provided as delegate methods.
    See the jQueryFileUploadDelegate class for more info.

    This class exposes many KVO compliant properties, outlets and actions that are useful when
    creating interfaces that use this class. If you plan to create an interface using JQueryFileUpload
    in Xcode, you will get the most out of it by doing the following:

    - In the controller class that will use JQueryFileUpload, create a JQueryFileUpload outlet.
    - In Xcode, edit the xib that will contain the JQueryFileUpload interface.
    - Add an NSObject to the xib and set its class to JQueryFileUpload.
    - Connect the JQueryFileUpload instance to your controller's JQueryFileUpload outlet.
    - Add an NSArrayController to the xib.
    - Connect the queueController outlet of the JQueryFileUpload object to the array controller.

    Once you have done this, you can bind directly to properties in the JQueryFileUpload object
    and to the arrangedObjects and selection of the array controller.

    ----------
    Properties
    ----------
    Where noted, the properties in this class mirror the options in jQuery File Upload, which are
    documented here: https://github.com/blueimp/jQuery File Upload/wiki/Options. Except where
    noted, the properties are read-write, and where the type is suitable, can be used with bindings.

    Most of the read-write properties can be set in Xcode:

    - Select the JQueryFileUpload object.
    - Select the Identity Inspector.
    - In the User Defined Runtime Attributes pane, click + to add an attribute.
    - Set the Key Path to the property's name.
    - Set the Type to the property's type or the parameter type its setter takes.
    - Set the value to whatever you want.

    For example, you can set the URL of the upload server by adding this User Defined
    Runtime Attribute:

    Key Path: URL
    Type:     String
    Value:    http://myserver.com/upload

    Name                    Description
    ---------------------   -----------------------------------------------------------------------------
    uploading               A BOOL set to YES during uploading. (read-only)

    indeterminate           A BOOL that indicates whether the total size of the upload queue is known.
                            This affects what is reported in the progress callbacks. This will be YES
                            if the browser does not support the File API. (read-only)

    progress                A dictionary which contains info on the overall progress of the upload.
                            The dictionary contains the following items:

                                uploadedBytes   Number of bytes uploaded so far.
                                total           Total number of bytes to be uploaded. If indeterminate
                                                is YES, this is zero.
                                percentComplete Integer percentage of the total (0-100) uploaded so far.
                                                If indeterminate is YES, this is zero.
                                bitrate         The overall bitrate of the upload so far.

                            As usual, you can bind to items within the dictionary.
                            (read-only)

    URL                     A string representing the URL to which files will be uploaded.
                            jQuery File Upload option: url.

    redirectURL             A string. jQuery File Upload option: redirect.

    sequential              A BOOL indicating whether multiple uploads will be performed sequentially
                            or concurrently. YES by default. jQuery File Upload option: sequentialUploads.

    maxChunkSize            If non-zero, uploads will be chunked. This is definitely preferable
                            if you plan on supporting large files. jQuery File Upload option: maxChunkSize.

    maxConcurrentUploads    An int which limits the number of concurrent uploads when sequential is NO.
                            jQuery File Upload option: limitConcurrentUploads.

    progressInterval        The minimum time interval in milliseconds to calculate and trigger progress events.
                            jQuery File Upload option: progressInterval.

    filenameFilter          A string regular expression suitable for use with the Javascript RegExp constructor.
                            When adding files to the queue, filenames that do not match regex are rejected.
                            Setting this property updates the filenameFilterRegex property.

    filenameFilterRegex     A Javascript regular expression. When adding files, filenames that do not match
                            are rejected. Setting this property updates the filenameFilter property.

    allowedExtensions       This write-only property should be a space-delimited string (e.g. "jpg png gif")
                            with one or more filename extensions (with or without dots). Setting this property
                            constructs a RegExp which allows filenames that end with the given extensions and
                            sets the filenameFilter and filenameFilterRegex properties accordingly.

    maxFileSize             An int representing the maximum size of a file that can be added to the queue.
                            Only supported on browsers that support the File API.

    autoUpload              A BOOL that indicates whether files added to the queue should immediately
                            start uploading. Defaults to NO.

    removeCompletedFiles    A BOOL that indicates whether files that have successfully uploaded should be
                            removed from the queue. Defaults to NO.

    currentEvent            The most recent jQuery event (NOT Cappuccino event) which triggered a method.
                            Usually this is of no interest, but if for some reason delegates want it,
                            they can retrieve it through this property. (read-only)

    currentData             When a jQuery File Upload callback is triggered (which eventually calls a JQueryFileUpload
                            delegate method), in most cases a data object is passed that reflects the current state.
                            The most relevant fields within that object are copied to the Cappuccino state, so usually
                            you will have no need for this. Delegates may use this method to retrieve the data passed
                            from the most recent callback. (read-only)

    queue                   The array of JQueryFileUploadFile objects used to represent the queue. In most cases
                            you should consider this read-only and manipulate the queue through its array controller.

    fileClass               The class of the objects stored in the queue. May be set either with a class or a string
                            class name, which allows you to set the class in Xcode either through User Defined Runtime
                            Attributes or bindings. This is useful if you want to add custom properties or methods to
                            the file objects. Must be JQueryFileUploadFile or a subclass thereof.

    -------
    Outlets
    -------
    dropTarget          Files can be added to the queue by dragging and dropping.
                        By default the entire browser window is the drop target for files.
                        You can connect this outlet to any view (including Cappuccino windows)
                        to specify the drop target.

    delegate            JQueryFileUpload communicates with its delegate extensively. You can
                        connect this outlet to the object that acts as the delegate.

    queueController     The array controller used to manage the upload queue.

    -------
    Actions
    -------
    addFiles:           Presents an open file dialog to add one or more files to the upload queue.

    start:              Starts all files in the upload queue.

    stop:               Stops all files in the upload queue.

    clearQueue:         Clears all files from the upload queue. If an upload is in progress, does nothing.
*/
@implementation JQueryFileUpload : CPObject
{
    // jQuery File Upload options
    JSObject            fileUploadOptions;
    CPString            URL @accessors;
    CPString            redirectURL @accessors;
    BOOL                sequential @accessors;
    int                 maxChunkSize @accessors;
    int                 maxConcurrentUploads @accessors;
    int                 progressInterval @accessors;
    @outlet CPView      dropTarget @accessors(readonly);
    JSObject            jQueryDropTarget;

    CPString            filenameFilter @accessors;
    RegExp              filenameFilterRegex @accessors;

    int                 maxFileSize @accessors;
    BOOL                autoUpload @accessors;
    BOOL                removeCompletedFiles @accessors;

    jQueryEvent         currentEvent @accessors(readonly);
    JSObject            currentData @accessors(readonly);

    BOOL                uploading @accessors;
    BOOL                indeterminate @accessors;
    CPMutableDictionary progress @accessors;

    @outlet id          delegate @accessors(readonly);
    int                 delegateImplementsFlags;

    Class               fileClass @accessors;

    CPMutableArray            queue @accessors(readonly);
    @outlet CPArrayController queueController @accessors(readonly);
}

+ (BOOL)automaticallyNotifiesObserversForKey:(CPString)key
{
    if (key === @"filenameFilter" || key === @"filenameFilterRegex")
        return NO;
    else
        return [super automaticallyNotifiesObserversForKey:key];
}

/*!
    Returns the current version of the framework as a string.
*/
+ (CPString)version
{
    var bundle = [CPBundle bundleForClass:[self class]];

    return [bundle objectForInfoDictionaryKey:@"CPBundleVersion"];
}

#pragma mark Initialization

/*!
    Initializes and returns a JQueryFileUpload object which uploads to the given URL.
*/
- (id)initWithURL:(CPString)aURL
{
    self = [self init];

    if (self)
        [self setURL:aURL];

    return self;
}

/*!
    The designated initializer.
*/
- (id)init
{
    self = [super init];

    if (self)
        [self _init];

    return self;
}

#pragma mark Attributes

/*!
    Returns a copy of the options passed to jQuery File Upload.
    To set the options from your copy, use setOptions:.
*/
- (JSObject)options
{
    return [CPObject copyJSObject:[self makeOptions]];
}

/*!
    Sets the options to a copy of the passed in options.
    Callbacks and dropZone are ignored. Options that are mirrored in this class
    will be set in a KVO compliant way.
*/
- (void)setOptions:(JSObject)options
{
    fileUploadOptions = cloneOptions(options);

    [self setURL:options["url"] || @""];
    [self setRedirectURL:options["redirect"] || @""];
    [self setSequential:options["sequential"] || YES];
    [self setMaxChunkSize:options["maxChunkSize"] || 0];
    [self setMaxConcurrentUploads:options["limitConcurrentUploads"] || NO];
    [self setProgressInterval:options["progressInterval"] || 100];
}

/*!
    Sets the view that will be the drop target for files dragged into
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

/*!
    Sets the delegate. For information on delegate methods, see the JQueryFileUploadDelegate class.
*/
- (void)setDelegate:(id)aDelegate
{
    if (aDelegate === delegate)
        return;

    delegateImplementsFlags = 0;
    delegate = aDelegate;

    if (!delegate)
        return;

    if ([delegate respondsToSelector:@selector(fileUpload:didFilterFile:because:)])
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
        delegateImplementsFlags |= delegateFileProgress;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadsDidProgress:)])
        delegateImplementsFlags |= delegateProgress;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidSucceedForFile:)])
        delegateImplementsFlags |= delegateSucceed;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidFailForFile:)])
        delegateImplementsFlags |= delegateFail;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadDidCompleteForFile:)])
        delegateImplementsFlags |= delegateComplete;

    if ([delegate respondsToSelector:@selector(fileUpload:uploadWasStoppedForFile:)])
        delegateImplementsFlags |= delegateStop;

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

/*!
    Sets the class for the objects stored in the upload queue.
    The class must be JQueryFileUploadFile or a subclass thereof.

    @param aClass Either a class object or a string name of a class
*/
- (void)setFileClass:(id)aClass
{
    if ([aClass isKindOfClass:[CPString class]])
        aClass = CPClassFromString(aClass);

    if ([aClass isKindOfClass:[JQueryFileUploadFile class]])
    {
        fileClass = aClass;
        [queueController setObjectClass:fileClass];
    }
    else
        CPLog.warn("%s: %s the file class must be a subclass of JQueryFileUploadFile.", [self className], [aClass className]);
}

/*!
    Sets the filter used to validate filenames that are being added to the queue.
    The string is passed to `new RegExp()`, so no delimiters should be included in the string.
*/
- (void)setFilenameFilter:(CPString)aFilter
{
    [self _setFilenameFilter:aFilter caseSensitive:YES];
}

/*!
    Sets the filter used to validate filenames that are being added to the queue.
    The string is passed to `new RegExp()`, so no delimiters should be included in the string.
    The filenameFilterRegex property stays in sync with this property.
*/
- (void)setFilenameFilter:(CPString)aFilter caseSensitive:(BOOL)caseSensitive
{
    [self _setFilenameFilter:aFilter caseSensitive:caseSensitive];
}

/*!
    Sets the filter regex used to validate filenames that are being added to the queue.
    The filenameFilter property stays in sync with this property.
*/
- (void)setFilenameFilterRegex:(RegExp)regex
{
    if ((filenameFilterRegex || "").toString() === (regex || "").toString())
        return;

    [self willChangeValueForKey:@"filenameFilterRegex"];
    [self willChangeValueForKey:@"filenameFilter"];

    filenameFilterRegex = regex;

    if (regex)
    {
        // RegExp.toString() includes leading/trailing "/" and possible flags, remove those
        filenameFilter = regex.toString().replace(/^\/(.*)\/\w*$/, "$1");
    }
    else
        filenameFilter = @"";

    [self didChangeValueForKey:@"filenameFilter"];
    [self didChangeValueForKey:@"filenameFilterRegex"];
}

/*!
    Sets the list of allowed filename extensions (with or without dots) when adding files.
    This is just a convenience method that generates a filename filter regex.
    Any existing filename filter will be replaced.

    @param extensions   May be either an array of extensions or a whitespace-delimited list
                        in a single string.
*/
- (void)setAllowedExtensions:(id)extensions
{
    var filter = @"";

    if (extensions)
    {
        if ([extensions isKindOfClass:[CPString class]])
            extensions = extensions.split(/\s+/);

        [extensions enumerateObjectsUsingBlock:function(extension)
            {
                extension = extension.replace(/^\./, "");
            }];

        filter = [CPString stringWithFormat:@"^.+\\.(%@)$", extensions.join("|")];
    }

    [self setFilenameFilter:filter caseSensitive:NO];
}

/*!
    Returns the array controller for the queue, instantiating it (and the queue) if necessary
    and setting its content to the queue array.
*/
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
    Upload all of the files in the queue.
    Can be used as an action method.
*/
- (@action)start:(id)sender
{
    [self fileUpload:@"option", [self makeOptions]];

    if (!URL)
    {
        CPLog.error("%s: The URL has not been set.", [self className]);
        return;
    }

    [queue makeObjectsPerformSelector:@selector(submit)];

    if (delegateImplementsFlags & delegateStartQueue)
        [delegate fileUploadDidStartQueue:self];
}

/*!
    Stop all uploads. Can be used as an action method.
*/
- (@action)stop:(id)sender
{
    if (delegateImplementsFlags & delegateStopQueue)
        [delegate fileUploadDidStopQueue:self];

    [queue makeObjectsPerformSelector:@selector(stop)];

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
    [self resetProgress];

    if (delegateImplementsFlags & delegateClearQueue)
        [delegate fileUploadDidClearQueue:self];
}

#pragma mark Methods

/*!
    Returns the file in the queue with the given UID, or nil if none match.
*/
- (JQueryFileUploadFile)fileWithUID:(CPString)aUID
{
    var file = [queue objectAtIndex:[queue indexOfObjectPassingTest:function(file)
                    {
                        return [file UID] === aUID;
                    }]];

    return file;
}

#pragma mark Overrides

- (void)awakeFromCib
{
    [queueController setContent:queue];
    [queueController addObserver:self forKeyPath:@"content" options:0 context:nil];
}

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)anObject change:(CPDictionary)changeDict context:(JSObject)context
{
    if (aKeyPath === @"content")
    {
        // If a file is added or removed from the content, reset the overall progress to zero.
        [self resetProgress];
    }
}

#pragma mark Delegate (private)

/// @cond IGNORE

- (void)addFile:(JSFile)aFile
{
    var filterFlags = [self validateFile:aFile],
        canAdd = filterFlags === 0,
        file = [[fileClass alloc] initWithUploader:self file:aFile data:currentData];

    // Tag the JS File object with the JQueryFileUploadFile UID so we can locate
    // the JQueryFileUploadFile object later from a File object.
    aFile.CPUID = [file UID];

    if (canAdd)
    {
        if (delegateImplementsFlags & delegateWillAdd)
            canAdd = [delegate fileUpload:self willAddFile:file];
    }
    else if (delegateImplementsFlags & delegateFilter)
        [delegate fileUpload:self didFilterFile:file because:filterFlags];

    if (canAdd)
    {
        [[self queueController] addObject:file];

        if (delegateImplementsFlags & delegateAdd)
            [delegate fileUpload:self didAddFile:file];

        if (autoUpload)
            [file submit];
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
    if (!URL)
    {
        CPLog.error("%s: The URL has not been set.", [self className]);
        return NO;
    }

    var canSubmit = YES;

    if (delegateImplementsFlags & delegateSubmit)
        canSubmit = [delegate fileUpload:self willSubmitFile:aFile];

    return canSubmit;
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

- (void)uploadForFile:(JQueryFileUploadFile)aFile didProgress:(JSObject)fileProgress
{
    if (fileProgress.uploadedBytes)
        [aFile setUploadedBytes:fileProgress.uploadedBytes];

    [aFile setBitrate:fileProgress.bitrate];

    if (delegateImplementsFlags & delegateFileProgress)
        [delegate fileUpload:self uploadForFile:aFile didProgress:fileProgress];
}

- (void)uploadsDidProgress:(JSObject)overallProgress
{
    [self updateProgressWithUploadedBytes:overallProgress.uploadedBytes
                                           total:overallProgress.total
                                 percentComplete:overallProgress.uploadedBytes / overallProgress.total * 100
                                         bitrate:overallProgress.bitrate];

    if (delegateImplementsFlags & delegateProgress)
        [delegate fileUpload:self uploadsDidProgress:overallProgress];
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

- (void)uploadWasStoppedForFile:(JQueryFileUploadFile)aFile
{
    if (delegateImplementsFlags & delegateStop)
        [delegate fileUpload:self uploadWasStoppedForFile:aFile];
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

    fileClass = [JQueryFileUploadFile class];

    URL = URL || @"";
    redirectURL = @"";
    sequential = YES;
    maxConcurrentUploads = 0;
    maxChunkSize = 0;
    progressInterval = 100;
    progress = [CPMutableDictionary dictionary];
    dropTarget = [CPPlatformWindow primaryPlatformWindow];
    jQueryDropTarget = jQuery(document);
    removeCompletedFiles = NO;

    [self resetProgress];
    [self setUploading:NO];
    [self setIndeterminate:!CPFeatureIsCompatible(CPFileAPIFeature)];

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

                var fileProgress = {
                    uploadedBytes:  data.uploadedBytes,
                    total:          data.total,
                    bitrate:        data.bitrate
                };

                [self uploadForFile:[self fileFromJSFile:data.files[0]] didProgress:fileProgress];
                [self pumpRunLoop];
            },

            progressall: function(e, data)
            {
                currentEvent = e;
                currentData = data;

                var overallProgress = {
                    uploadedBytes:  data.loaded,
                    total:          data.total,
                    bitrate:        data.bitrate
                };

                [self uploadsDidProgress:overallProgress];
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
    var regex = new RegExp(aFilter, caseSensitive ? "" : "i");

    if (regex.toString() === (filenameFilterRegex || "").toString())
        return;

    [self willChangeValueForKey:@"filenameFilter"];
    [self willChangeValueForKey:@"filenameFilterRegex"];

    filenameFilter = aFilter;
    filenameFilterRegex = aFilter ? regex : nil;

    [self didChangeValueForKey:@"filenameFilterRegex"];
    [self didChangeValueForKey:@"filenameFilter"];
}

- (void)pumpRunLoop
{
    // Pump the run loop, jQuery File Upload event handlers are called outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

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

- (JSObject)makeOptions
{
    fileUploadOptions["dataType"] = "json";
    fileUploadOptions["url"] = URL;
    fileUploadOptions["redirect"] = redirectURL;
    fileUploadOptions["sequentialUploads"] = sequential;
    fileUploadOptions["singleFileUploads"] = true;
    fileUploadOptions["maxChunkSize"] = maxChunkSize;
    fileUploadOptions["limitConcurrentUploads"] = maxConcurrentUploads;
    fileUploadOptions["progressInterval"] = progressInterval;
    fileUploadOptions["dropZone"] = jQueryDropTarget;

    [self setCallbacks:fileUploadOptions];

    return fileUploadOptions;
}

- (void)updateProgressWithUploadedBytes:(CPNumber)uploadedBytes total:(CPNumber)total percentComplete:(CPNumber)percentComplete bitrate:(CPNumber)bitrate
{
    if (uploadedBytes !== nil)
        [progress setValue:uploadedBytes forKey:@"uploadedBytes"];

    if (total !== nil)
        [progress setValue:total forKey:@"total"];

    if (percentComplete !== nil)
        [progress setValue:FLOOR(percentComplete) forKey:@"percentComplete"];

    if (bitrate !== nil)
        [progress setValue:bitrate forKey:@"bitrate"];
}

- (void)resetProgress
{
    [self updateProgressWithUploadedBytes:0 total:[self totalSizeOfQueue] percentComplete:0 bitrate:0];
}

- (int)validateFile:(JSFile)aFile
{
    var flags = 0;

    if (filenameFilterRegex && !filenameFilterRegex.test(aFile.name))
        flags |= JQueryFileUploadFilteredName;

    if (aFile.hasOwnProperty("size") && maxFileSize && aFile.size > maxFileSize)
        flags |= JQueryFileUploadFilteredSize;

    return flags;
}

- (int)totalSizeOfQueue
{
    var total = 0,
        count = [queue count];

    while (count--)
        total += [queue[count] size];

    return total;
}

/// @endcond

@end


/*!
    @class JQueryFileUploadFile

    A wrapper for the File API (https://developer.mozilla.org/en/DOM/file)
    that allows the values to be used in bindings. Note that if the browser
    does not support the File API, the size, type, and percentComplete
    properties will be zero/empty.

    These objects are stored in the JQueryFileUpload queue controller,
    thus you can bind through the queue controller's arrangedObjects or
    selection to properties of this class.

    This class exposes the following KVO compliant read-only properties:

    name            The filename of the file
    size            The file's size in bytes
    type            The file's mime type
    status          One of the JQueryFileUploadStatus constants above
    uploading       A BOOL set to YES during uploading
    uploadedBytes   The number of bytes uploaded so far for this file
    bitrate         The upload bitrate for this file
    percentComplete An integer from 0-100 representing the percentage of the file
                    that has been uploaded so far
    indeterminate   A BOOL that indicates whether the total size of the file
                    is known. This affects what is reported in the progress callbacks.
    data            The Javascript data object used by jQuery File Upload
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
    if (self !== [JQueryFileUploadFile class])
        return;

    FileStatuses[JQueryFileUploadFileStatus_Pending]   = @"Pending";
    FileStatuses[JQueryFileUploadFileStatus_Uploading] = @"Uploading";
    FileStatuses[JQueryFileUploadFileStatus_Complete]  = @"Complete";
}

+ (CPSet)keyPathsForValuesAffectingPercentComplete
{
    return [CPSet setWithObjects:@"uploadedBytes"];
}

/*!
    Designated initializer.

    Init with a Javascript File object and jQuery File Upload data.
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

/*!
    Return the upload percentage as a number from 0-100.
    Returns zero if indeterminate == YES.
*/
- (int)percentComplete
{
    return indeterminate ? 0 : FLOOR(uploadedBytes / size * 100);
}

/*!
    Submit this file for uploading. This will in turn trigger the relevant
    methods in JQueryFileUploader and its delegate.
*/
- (void)submit
{
    [self setStatus:JQueryFileUploadFileStatus_Uploading];
    [self setUploadedBytes:0];

    data.submit();
}

/*!
    Notifies the file that it has actually started uploading.
    Normally you would not need to call this method, it is called
    by JQueryFileUploader when necessary.
*/
- (void)start
{
    [self setUploading:YES];
}

/*!
    Stops the upload for the file and notifies the delegate. Use this method
    to stop a single file within the queue without stopping the entire queue.
*/
- (void)stop
{
    [self setStatus:JQueryFileUploadFileStatus_Pending];
    [self setUploading:NO];

    data.abort();

    [uploader uploadWasStoppedForFile:self];
}

- (CPString)description
{
    return [CPString stringWithFormat:@"%@ \"%@\", size=%d, type=%s, uploadedBytes=%d, status=%s", [super description], name, size, type, uploadedBytes, FileStatuses[status]];
}

@end


/*!
    This class is designed to replace the standard NSTableCellView used in a view-based table
    within Xcode. It provides an action method which can be used to stop a single file's upload.

    Usage
    1. Select the table cell view in which you want to place a stop button.
    2. Go to the Identity Inspector and set the class to JQueryFileUploadTableCellView.
    3. Place a button in the cell view.
    4. Connect the selector of the button to the `stopUpload:` method in its own cell view.
*/
@implementation JQueryFileUploadTableCellView : CPTableCellView

- (@action)stopUpload:(id)sender
{
    [[self objectValue] stop];
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
};
