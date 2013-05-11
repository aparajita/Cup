/*
 * CupDelegate.j
 * Cup
 *
 * Created by Aparajita Fishman on February 7, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPObject.j>

@import "Cup.j"


/*!
    This class is the protocol for CupDelegate objects.
    The methods in this class for the most part correspond to jQuery File Upload
    callbacks (https://github.com/blueimp/jQuery File Upload/wiki/Options#callback-options).

    This class can either be subclassed, or can be used as a template for your
    own delegates. If you subclass, be sure to provide the appropriate
    functionality for those methods that expect something to be done.
    If you are only using this as a template, you only need to implement
    the methods that you intend to add some functionality to.

    All of the methods receive as their first parameter the Cup
    object of which the receiver is a delegate. The methods that are related
    to a file also receive the CupFile object that is being operated on.

    If the delegate wants access to the underlying jQuery event or
    jQuery File Upload data object that is current, it can use the methods
    [cup currentEvent] or [cup currentData].
*/
@implementation CupDelegate : CPObject

/*!
    An attempt was made to add a file to the queue but it was rejected.
    The reasons for being rejected are given in filterFlags, which is a bitwise OR
    of the CupFiltered flags.
*/
- (void)cup:(Cup)cup didFilterFile:(CupFile)file because:(int)filterFlags
{
}

/*!
    A file is about to be added to the queue. If you want to reject the file for some reason,
    return NO. Otherwise return YES.
*/
- (BOOL)cup:(Cup)cup willAddFile:(CupFile)file
{
    return YES;
}

/*!
    A file was added to the queue.
*/
- (void)cup:(Cup)cup didAddFile:(CupFile)file
{
}

/*!
    The queue was started. All files in the queue will be submitted for uploading.
*/
- (void)cupDidStart:(Cup)cup
{
}

/*!
    A file is about to be submitted for uploading. To prevent the file from being submitted,
    return NO, otherwise return YES.
*/
- (BOOL)cup:(Cup)cup willSubmitFile:(CupFile)file
{
    return YES;
}

/*!
    A submitted file is about to begin uploading. To abort the upload, return NO, otherwise
    return YES.
*/
- (BOOL)cup:(Cup)cup willSendFile:(CupFile)file
{
    return YES;
}

/*!
    A file chunk is about to begin uploading. To abort the upload, return NO, otherwise
    return YES.
*/
- (BOOL)cup:(Cup)cup willSendChunkForFile:(CupFile)file
{
    return YES;
}

/*!
    A chunk was successfully uploaded.
*/
- (void)cup:(Cup)cup chunkDidSucceedForFile:(CupFile)file
{
}

/*!
    A chunk failed to upload, either because of a connection error or because the upload was stopped.
*/
- (void)cup:(Cup)cup chunkDidFailForFile:(CupFile)file
{
}

/*!
    Processing of a chunk completed. This is called after cup:chunkDidSucceedForFile: or
    cup:chunkDidFailForFile:.
*/
- (void)cup:(Cup)cup chunkDidCompleteForFile:(CupFile)file
{
}

/*!
    Called periodically to update the progress a single file. The progress object contains the following
    properties:

        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far
*/
- (void)cup:(Cup)cup uploadForFile:(CupFile)file didProgress:(JSObject)progress
{
}

/*!
    Called periodically to update the overall progress of the queue. The progress object contains the following
    properties:

        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far
*/
- (void)cup:(Cup)cup uploadsDidProgress:(JSObject)progress
{
}

/*!
    A file was successfully uploaded.
*/
- (void)cup:(Cup)cup uploadDidSucceedForFile:(CupFile)file
{
}

/*!
    A file failed to upload, either because of a connection error or because the upload was stopped.
*/
- (void)cup:(Cup)cup uploadDidFailForFile:(CupFile)file
{
}

/*!
    A file upload has completed, either through success or failure. This method is called after
    cup:uploadDidSucceedForFile: or cup:uploadDidFailForFile:.
*/
- (void)cup:(Cup)cup uploadDidCompleteForFile:(CupFile)file
{
}

/*!
    A file upload was stopped, either individually or because the entire queue was stopped.
*/
- (void)cup:(Cup)cup uploadWasStoppedForFile:(CupFile)file
{
}

/*!
    The queue stopped uploading, either because all files in the queue completed or because
    the stop: action was triggered.
*/
- (void)cupDidStop:(Cup)cup
{
}

/*!
    The user selected files to add to the queue through a file selection dialog.
    An array of Javascript File objects (not CupFile objects) is passed
    in the files parameter.
*/
- (void)cup:(Cup)cup fileInputDidSelectFiles:(CPArray)files
{
}

/*!
    The Cup -start: action method was triggered.
*/
- (void)cupDidStartQueue:(Cup)cup
{
}

/*!
    The Cup -clearQueue: action method was triggered.
*/
- (void)cupDidClearQueue:(Cup)cup
{
}

/*!
    The Cup -stop: action method was triggered. This method is called
    before the individual files are stopped, so you can determine why a file was stopped.
*/
- (void)cupDidStopQueue:(Cup)cup
{
}

/*!
    One or more files were pasted into the Cup window.
    An array of Javascript File objects (not CupFile objects) is passed
    in the files parameter.
*/
- (void)cup:(Cup)cup didPasteFiles:(CPArray)files
{
}

/*!
    One or more files were dropped onto the Cup drop target.
    An array of Javascript File objects (not CupFile objects) is passed
    in the files parameter.
*/
- (void)cup:(Cup)cup didDropFiles:(CPArray)files
{
}

/*!
    Called periodically while files are being dragged over the Cup drop target.
*/
- (void)cup:(Cup)cup wasDraggedOverWithEvent:(jQueryEvent)event
{
}

@end
