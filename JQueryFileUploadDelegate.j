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
*/
@implementation JQueryFileUploadDelegate : CPObject

- (void)fileUpload:(JQueryFileUpload)aFileUpload didAddFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUploadDidClearQueue:(JQueryFileUpload)aFileUpload
{
}

- (void)fileUploadDidStopQueue:(JQueryFileUpload)aFileUpload
{
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSubmitFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    return YES;
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidSucceedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidFailWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidProgressWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadsDidProgressOverallWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidStartWithEvent:(jQueryEvent)anEvent
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidStopWithEvent:(jQueryEvent)anEvent
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload fileInputDidChangeWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didPasteFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didDropFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didDragOverFilesWithEvent:(jQueryEvent)anEvent
{
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendChunkWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidSucceedWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidFailWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
}

@end
