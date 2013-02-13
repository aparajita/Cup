/*
 * JQueryFileUploadQueueController.j
 * JQueryFileUpload
 *
 * Created by Aparajita Fishman on February 12, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <Foundation/CPRunLoop.j>

@import <AppKit/CPTableView.j>
@import <AppKit/CPViewController.j>

@import "JQueryFileUpload.j"

var JQueryFileUploadQueueControllerInstance = nil,

    FileStatus_Pending   = 0,
    FileStatus_Uploading = 1,
    FileStatus_Complete  = 2,

    FileStatuses = [];

/*!
    This class provides a table view with one row for each
    file in the upload queue.
*/
@implementation JQueryFileUploadQueueController : CPViewController
{
    @outlet CPTableView         tableView;
    @outlet QueueDataView       dataView;
    @outlet CPArrayController   queueController;
    CPArray                     queue;
    JQueryFileUpload            fileUpload
}

#pragma mark Initialization

+ (void)initialize
{
    FileStatuses[FileStatus_Pending]   = @"Pending";
    FileStatuses[FileStatus_Uploading] = @"Uploading...";
    FileStatuses[FileStatus_Complete]  = @"Complete";
}

+ (JQueryFileUploadQueueController)sharedInstance
{
    return JQueryFileUploadQueueControllerInstance;
}

- (id)initWithFileUpload:(JQueryFileUpload)aFileUpload
{
    self = [super initWithCibName:@"JQueryFileUploadQueue" bundle:nil owner:self];

    if (self)
    {
        JQueryFileUploadQueueControllerInstance = self;
        queue = [];

        [self setRepresentedObject:aFileUpload];
        fileUpload = aFileUpload;
        [fileUpload setDelegate:self];
    }

    return self;
}


#pragma mark TableView Delegate

// Don't allow files to be selected during an upload
- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)index
{
    return ![fileUpload uploading];
}


#pragma mark JQueryFileUploadDelegate

- (void)fileUpload:(JQueryFileUpload)aFileUpload didAddFilesWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    var indexes = [queue indexesOfObjectsPassingTest:function(object)
                        {
                            return [object valueForKey:@"status"] === FileStatus_Complete;
                        }];

    [queueController removeObjectsAtArrangedObjectIndexes:indexes];

    for (var i = 0; i < data.files.length; ++i)
    {
        var file = data.files[i],
            dict = [CPDictionary dictionaryWithObjectsAndKeys:
                        data.CPUID,         @"id",
                        self,               @"controller",
                        file.name,          @"filename",
                        file.size,          @"size",
                        file.type,          @"type",
                        FileStatus_Pending, @"status",
                        0,                  @"progress",
                        data,               @"data"];

        [queueController addObject:dict];
    }
}

- (void)fileUploadDidClearQueue:(JQueryFileUpload)aFileUpload
{
    [self updateQueueWithBlock:function() { [queue removeAllObjects]; }];
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidStartWithEvent:(jQueryEvent)anEvent
{
    [queueController setSelectionIndexes:[CPIndexSet indexSet]];

    [self updateQueueWithBlock:function()
        {
            [queue setValue:FileStatus_Uploading forKey:@"status"];
            [queue setValue:0 forKey:@"progress"];
        }];
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidProgressWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    [self updateProgressForFileWithId:data.CPUID uploaded:data.uploadedBytes total:data.total];
}

- (void)fileUpload:(JQueryFileUpload)aFileUpload uploadDidCompleteWithEvent:(jQueryEvent)anEvent data:(JSObject)data
{
    [self updateProgressForFileWithId:data.CPUID uploaded:data.uploadedBytes total:data.total];

    var file = [self fileWithId:data.CPUID];

    [self updateQueueWithBlock:function() { [file setValue:FileStatus_Complete forKey:@"status"]; } ];
}

- (void)fileUploadDidStopQueue:(JQueryFileUpload)aFileUpload
{
    [self updateQueueWithBlock:function()
        {
            [queue setValue:FileStatus_Pending forKey:@"status"];
            [queue setValue:0 forKey:@"progress"];
        }];
}


#pragma mark Methods

- (@action)removeSelectedFiles:(id)sender
{
    [queueController removeObjectsAtArrangedObjectIndexes:[queueController selectionIndexes]];
}


#pragma mark Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[tableView tableColumns][0] setDataView:dataView];
}


#pragma mark Private

- (id)fileWithId:(CPString)anId
{
    return [queue objectAtIndex:[queue indexOfObjectPassingTest:function(object)
                {
                    return [object valueForKey:@"id"] === anId;
                }]];
}

- (void)updateProgressForFileWithId:(CPString)anId uploaded:(int)uploadedBytes total:(int)totalBytes
{
    var file = [self fileWithId:anId];

    [self updateQueueWithBlock:function()
        {
            [file setValue:uploadedBytes / totalBytes * 100 forKey:@"progress"];
        }];
}

- (void)abortFileWithId:(CPString)anId
{
    var file = [self fileWithId:anId];

    if ([file valueForKey:@"status"] !== FileStatus_Uploading)
        return;

    [fileUpload abortUploadWithId:anId];

    [self updateQueueWithBlock:function()
        {
            [file setValue:FileStatus_Pending forKey:@"status"];
            [file setValue:0 forKey:@"progress"];
        }
    ];

    [[CPAlert alertWithMessageText:[CPString stringWithFormat:@"Transfer of “%@” has been aborted.", [file valueForKey:@"filename"]]
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:nil] runModal];
}

- (id)updateQueueWithBlock:(Function)block
{
    /*
        We can't bind directly to the contents of the row array, but we did bind
        the table contents to the row array. By wrapping a change to the array
        with willChange/didChange, we notify observers of the array that a change has occurred.
    */
    [self willChangeValueForKey:@"queue"];

    var result = block();

    [self didChangeValueForKey:@"queue"];

    // Pump the run loop, this is called outside of Cappuccino's run loop
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

    return result;
}

@end


@implementation QueueDataView : CPView
{
    // From row data, but not part of the view
    CPString                        fileId;
    JQueryFileUploadQueueController controller;

    @outlet CPTextField filename;
    @outlet CPTextField size;
    @outlet CPTextField status;
    @outlet CPButton    abortButton;
}

- (void)setObjectValue:(id)aValue
{
    fileId = [aValue valueForKey:@"id"];
    controller = [aValue valueForKey:@"controller"];

    [filename setStringValue:[aValue valueForKey:@"filename"]];

    // Because the size field has a CPByteCountFormatter attached,
    // we can use setObjectValue with a number to set a formatted string.
    [size setObjectValue:[aValue valueForKey:@"size"]];

    [status setStringValue:[FileStatuses objectAtIndex:[aValue valueForKey:@"status"]]];
    [abortButton setEnabled:[aValue valueForKey:@"status"] === FileStatus_Uploading];
    //[progressBar setDoubleValue:[aValue valueForKey:@"progress"]];
}

- (@action)abort:(id)sender
{
    [controller abortFileWithId:fileId];
}

@end

@implementation QueueDataView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        filename = [aCoder decodeObjectForKey:@"filename"];
        size = [aCoder decodeIntForKey:@"size"];
        status = [aCoder decodeObjectForKey:@"status"];
        abortButton = [aCoder decodeObjectForKey:@"abortButton"];
        //progressBar = [aCoder decodeObjectForKey:@"progressBar"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:filename forKey:@"filename"];
    [aCoder encodeInt:size forKey:@"size"];
    [aCoder encodeObject:status forKey:@"status"];
    [aCoder encodeObject:abortButton forKey:@"abortButton"];
    //[aCoder encodeObject:progressBar forKey:@"progressBar"];
}

@end
