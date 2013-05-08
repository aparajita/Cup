/*
 * JQueryFileUploadDelegate.j
 * JQueryFileUpload
 *
 * Created by Aparajita Fishman on February 7, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPObject.j>

@import "JQueryFileUpload.j"


/*!
    This class is the protocol for JQueryFileUploadDelegate objects.
    The methods in this class for the most part correspond to jQuery File Upload
    callbacks (https://github.com/blueimp/jQuery File Upload/wiki/Options#callback-options).

    This class can either be subclassed, or can be used as a template for your
    own delegates. If you subclass, be sure to provide the appropriate
    functionality for those methods that expect something to be done.
    If you are only using this as a template, you only need to implement
    the methods that you intend to add some functionality to.

    All of the methods receive as their first parameter the JQueryFileUpload
    object of which the receiver is a delegate. The methods that are related
    to a file also receive the JQueryFileUploadFile object that is being operated on.

    If the delegate wants access to the underlying jQuery event or
    jQuery File Upload data object that is current, it can use the methods
    [fileUpload currentEvent] or [fileUpload currentData].
*/
@implementation JQueryFileUploadDelegate : CPObject

/*!
    An attempt was made to add a file to the queue but it was rejected.
    The reasons for being rejected are given in filterFlags, which is a bitwise OR
    of the JQueryFileUploadFiltered flags.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload didFilterFile:(JQueryFileUploadFile)aFile because:(int)filterFlags
{
}

/*!
    A file is about to be added to the queue. If you want to reject the file for some reason,
    return NO. Otherwise return YES.
*/
- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willAddFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

/*!
    A file was added to the queue.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload didAddFile:(JQueryFileUploadFile)aFile
{
}

/*!
    The queue was started. All files in the queue will be submitted for uploading.
*/
- (void)fileUploadDidStart:(JQueryFileUpload)aFileUpload
{
}

/*!
    A file is about to be submitted for uploading. To prevent the file from being submitted,
    return NO, otherwise return YES.
*/
- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSubmitFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

/*!
    A submitted file is about to begin uploading. To abort the upload, return NO, otherwise
    return YES.
*/
- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

/*!
    A file chunk is about to begin uploading. To abort the upload, return NO, otherwise
    return YES.
*/
- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendChunkForFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

/*!
    A chunk was successfully uploaded.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidSucceedForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    A chunk failed to upload, either because of a connection error or because the upload was stopped.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidFailForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    Processing of a chunk completed. This is called after fileUpload:chunkDidSucceedForFile: or
    fileUpload:chunkDidFailForFile:.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidCompleteForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    Called periodically to update the progress a single file. The progress object contains the following
    properties:

        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadForFile:(JQueryFileUploadFile)aFile didProgress:(JSObject)progress
{
}

/*!
    Called periodically to update the overall progress of the queue. The progress object contains the following
    properties:

        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadsDidProgress:(JSObject)progress
{
}

/*!
    A file was successfully uploaded.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidSucceedForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    A file failed to upload, either because of a connection error or because the upload was stopped.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidFailForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    A file upload has completed, either through success or failure. This method is called after
    fileUpload:uploadDidSucceedForFile: or fileUpload:uploadDidFailForFile:.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidCompleteForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    A file upload was stopped, either individually or because the entire queue was stopped.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadWasStoppedForFile:(JQueryFileUploadFile)aFile
{
}

/*!
    The queue stopped uploading, either because all files in the queue completed or because
    the stop: action was triggered.
*/
- (void)fileUploadDidStop:(JQueryFileUpload)aFileUpload
{
}

/*!
    The user selected files to add to the queue through a file selection dialog.
    An array of Javascript File objects (not JQueryFileUploadFile objects) is passed
    in the files parameter.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload fileInputDidSelectFiles:(CPArray)files
{
}

/*!
    The JQueryFileUpload -start: action method was triggered.
*/
- (void)fileUploadDidStartQueue:(JQueryFileUpload)aFileUpload
{
}

/*!
    The JQueryFileUpload -clearQueue: action method was triggered.
*/
- (void)fileUploadDidClearQueue:(JQueryFileUpload)aFileUpload
{
}

/*!
    The JQueryFileUpload -stop: action method was triggered. This method is called
    before the individual files are stopped, so you can determine why a file was stopped.
*/
- (void)fileUploadDidStopQueue:(JQueryFileUpload)aFileUpload
{
}

/*!
    One or more files were pasted into the JQueryFileUpload window.
    An array of Javascript File objects (not JQueryFileUploadFile objects) is passed
    in the files parameter.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload didPasteFiles:(CPArray)files
{
}

/*!
    One or more files were dropped onto the JQueryFileUpload drop target.
    An array of Javascript File objects (not JQueryFileUploadFile objects) is passed
    in the files parameter.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload didDropFiles:(CPArray)files
{
}

/*!
    Called periodically while files are being dragged over the JQueryFileUpload drop target.
*/
- (void)fileUpload:(JQueryFileUpload)aFileUpload wasDraggedOverWithEvent:(jQueryEvent)anEvent
{
}

@end
