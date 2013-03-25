/*
 * AppController.j
 * upload
 *
 * Created by You on February 3, 2013.
 * Copyright 2013, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPAlert.j>

@import "JQueryFileUpload.j"


@implementation AppController : CPObject
{
    @outlet CPWindow            testWindow;
    @outlet JQueryFileUpload    upload;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
}

- (void)awakeFromCib
{
    [upload setURL:@"http://dev.upload.com/index.php"];
    [upload setDropTarget:[testWindow contentView]];
    [upload setMaximumChunkSize:50000];
    [upload setDelegate:self];
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willAddFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didAddFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSubmitFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
    return YES;
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidSucceedForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidFailForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidCompleteForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadWasAbortedForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);

    [[CPAlert alertWithMessageText:[CPString stringWithFormat:@"Transfer of “%@” has been aborted.", [aFile name]]
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:@""] runModal];

}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadForFile:(JQueryFileUploadFile)aFile didProgress:(JSObject)progress
{
    console.log("%s %s: %s", _cmd, [aFile description], CPDescriptionOfObject(progress));
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadsDidProgressOverall:(JSObject)progress
{
    console.log("%s %s", _cmd, CPDescriptionOfObject(progress));
}

- (void)fileUploadDidStart:(JQueryFileUpload)aFileUpload
{
    console.log("%s", _cmd);
}

- (void)fileUploadDidStop:(JQueryFileUpload)aFileUpload
{
    console.log("%s", _cmd);
}

- (void)fileUploadDidStartQueue:(JQueryFileUpload)aFileUpload
{
    console.log("%s", _cmd);
}

- (void)fileUploadDidClearQueue:(JQueryFileUpload)aFileUpload
{
    console.log("%s", _cmd);
}

- (void)fileUploadDidStopQueue:(JQueryFileUpload)aFileUpload
{
    console.log("%s", _cmd);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload fileInputDidSelectFiles:(CPArray)files
{
    console.log("%s %s", _cmd, [files description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didPasteFiles:(CPArray)files
{
    console.log("%s %s", _cmd, [files description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload didDropFiles:(CPArray)files
{
    console.log("%s %s", _cmd, [files description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload wasDraggedOverWithEvent:(jQueryEvent)anEvent
{
    console.log("%s %o", _cmd, anEvent);
}

- (BOOL)fileUpload:(JQueryFileUpload)aFileUpload willSendChunkForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
    return YES;
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidSucceedForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidFailForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload chunkDidCompleteForFile:(JQueryFileUploadFile)aFile
{
    console.log("%s %s", _cmd, [aFile description]);
}

@end
