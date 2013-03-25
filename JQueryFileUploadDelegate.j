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
    It can either be subclassed, or be used as a template for your
    own delegates. If you subclass, be sure to provide the appropriate
    functionality for those callbacks that expect something to be done.
    If you are only using this as a template, you only need to implement
    the methods that you intend to add some functionality to.

    There are several Javascript object types passed as parameters to these methods:

    jQueryEvent - A standard jQuery event object.
    progress - Tracks the progress of an individual or overall upload. Contains three properties:
        uploadedBytes - Total bytes uploaded so far
        total         - The total to be uploaded
        bitrate       - The average bitrate so far

    If the delegate wants access to the underlying jQuery event or
    jQuery-File-Upload data object that is current, it can use the methods
    [fileUpload currentEvent] or [fileUpload currentData].
*/
@implementation JQueryFileUploadDelegate : CPObject

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willAddFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didAddFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUploadDidStart:(JQueryFileUpload)aFileUpload
{
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSubmitFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendChunkForFile:(JQueryFileUploadFile)aFile
{
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidSucceedForFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidFailForFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidCompleteForFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadForFile:(JQueryFileUploadFile)aFile didProgress:(JSObject)progress
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadsDidProgressOverall:(JSObject)progress
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidSucceedForFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidFailForFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidCompleteForFile:(JQueryFileUploadFile)aFile
{
}

- (void)fileUploadDidStop:(JQueryFileUpload)aFileUpload
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload fileInputDidSelectFiles:(CPArray)files
{
}

- (void)fileUploadDidStartQueue:(JQueryFileUpload)aFileUpload
{
}

- (void)fileUploadDidClearQueue:(JQueryFileUpload)aFileUpload
{
}

- (void)fileUploadDidStopQueue:(JQueryFileUpload)aFileUpload
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didPasteFiles:(CPArray)files
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didDropFiles:(CPArray)files
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload wasDraggedOverWithEvent:(jQueryEvent)anEvent
{
}

@end
