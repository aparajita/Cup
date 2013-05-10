/*
 * CUControllerDelegate.j
 * Cup
 *
 * Created by Aparajita Fishman on February 7, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPObject.j>

@import "CUController.j"


/*!
    This class is the protocol for CUControllerDelegate objects.
    The methods in this class for the most part correspond to jQuery File Upload
    callbacks (https://github.com/blueimp/jQuery File Upload/wiki/Options#callback-options).

    This class can either be subclassed, or can be used as a template for your
    own delegates. If you subclass, be sure to provide the appropriate
    functionality for those methods that expect something to be done.
    If you are only using this as a template, you only need to implement
    the methods that you intend to add some functionality to.

    All of the methods receive as their first parameter the CUController
    object of which the receiver is a delegate. The methods that are related
    to a file also receive the CUFile object that is being operated on.

    If the delegate wants access to the underlying jQuery event or
    jQuery File Upload data object that is current, it can use the methods
    [uploader currentEvent] or [uploader currentData].
*/
@implementation CUControllerDelegate : CPObject

/*!
    An attempt was made to add a file to the queue but it was rejected.
    The reasons for being rejected are given in filterFlags, which is a bitwise OR
    of the CupFiltered flags.
*/
- (void)uploader:(CUController)anUploader didFilterFile:(CUFile)aFile because:(int)filterFlags
{
}

/*!
    A file is about to be added to the queue. If you want to reject the file for some reason,
    return NO. Otherwise return YES.
*/
- (BOOL)uploader:(CUController)anUploader willAddFile:(CUFile)aFile
{
    return YES;
}

/*!
    A file was added to the queue.
*/
- (void)uploader:(CUController)anUploader didAddFile:(CUFile)aFile
{
}

/*!
    The queue was started. All files in the queue will be submitted for uploading.
*/
- (void)uploaderDidStart:(CUController)anUploader
{
}

/*!
    A file is about to be submitted for uploading. To prevent the file from being submitted,
    return NO, otherwise return YES.
*/
- (BOOL)uploader:(CUController)anUploader willSubmitFile:(CUFile)aFile
{
    return YES;
}

/*!
    A submitted file is about to begin uploading. To abort the upload, return NO, otherwise
    return YES.
*/
- (BOOL)uploader:(CUController)anUploader willSendFile:(CUFile)aFile
{
    return YES;
}

/*!
    A file chunk is about to begin uploading. To abort the upload, return NO, otherwise
    return YES.
*/
- (BOOL)uploader:(CUController)anUploader willSendChunkForFile:(CUFile)aFile
{
    return YES;
}

/*!
    A chunk was successfully uploaded.
*/
- (void)uploader:(CUController)anUploader chunkDidSucceedForFile:(CUFile)aFile
{
}

/*!
    A chunk failed to upload, either because of a connection error or because the upload was stopped.
*/
- (void)uploader:(CUController)anUploader chunkDidFailForFile:(CUFile)aFile
{
}

/*!
    Processing of a chunk completed. This is called after uploader:chunkDidSucceedForFile: or
    uploader:chunkDidFailForFile:.
*/
- (void)uploader:(CUController)anUploader chunkDidCompleteForFile:(CUFile)aFile
{
}

/*!
    Called periodically to update the progress a single file. The progress object contains the following
    properties:

        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far
*/
- (void)uploader:(CUController)anUploader uploadForFile:(CUFile)aFile didProgress:(JSObject)progress
{
}

/*!
    Called periodically to update the overall progress of the queue. The progress object contains the following
    properties:

        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far
*/
- (void)uploader:(CUController)anUploader uploadsDidProgress:(JSObject)progress
{
}

/*!
    A file was successfully uploaded.
*/
- (void)uploader:(CUController)anUploader uploadDidSucceedForFile:(CUFile)aFile
{
}

/*!
    A file failed to upload, either because of a connection error or because the upload was stopped.
*/
- (void)uploader:(CUController)anUploader uploadDidFailForFile:(CUFile)aFile
{
}

/*!
    A file upload has completed, either through success or failure. This method is called after
    uploader:uploadDidSucceedForFile: or uploader:uploadDidFailForFile:.
*/
- (void)uploader:(CUController)anUploader uploadDidCompleteForFile:(CUFile)aFile
{
}

/*!
    A file upload was stopped, either individually or because the entire queue was stopped.
*/
- (void)uploader:(CUController)anUploader uploadWasStoppedForFile:(CUFile)aFile
{
}

/*!
    The queue stopped uploading, either because all files in the queue completed or because
    the stop: action was triggered.
*/
- (void)uploaderDidStop:(CUController)anUploader
{
}

/*!
    The user selected files to add to the queue through a file selection dialog.
    An array of Javascript File objects (not CUFile objects) is passed
    in the files parameter.
*/
- (void)uploader:(CUController)anUploader fileInputDidSelectFiles:(CPArray)files
{
}

/*!
    The CUController -start: action method was triggered.
*/
- (void)uploaderDidStartQueue:(CUController)anUploader
{
}

/*!
    The CUController -clearQueue: action method was triggered.
*/
- (void)uploaderDidClearQueue:(CUController)anUploader
{
}

/*!
    The CUController -stop: action method was triggered. This method is called
    before the individual files are stopped, so you can determine why a file was stopped.
*/
- (void)uploaderDidStopQueue:(CUController)anUploader
{
}

/*!
    One or more files were pasted into the CUController window.
    An array of Javascript File objects (not CUFile objects) is passed
    in the files parameter.
*/
- (void)uploader:(CUController)anUploader didPasteFiles:(CPArray)files
{
}

/*!
    One or more files were dropped onto the CUController drop target.
    An array of Javascript File objects (not CUFile objects) is passed
    in the files parameter.
*/
- (void)uploader:(CUController)anUploader didDropFiles:(CPArray)files
{
}

/*!
    Called periodically while files are being dragged over the CUController drop target.
*/
- (void)uploader:(CUController)anUploader wasDraggedOverWithEvent:(jQueryEvent)anEvent
{
}

@end
