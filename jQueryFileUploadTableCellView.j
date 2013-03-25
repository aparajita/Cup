/*
 * JQueryFileUploadTableCellView.j
 * JQueryFileUpload
 *
 * Created by Aparajita Fishman on March 25, 2013.
 * Copyright 2013, Filmworkers Club. All rights reserved.
 */

@import <AppKit/CPTableView.j>


@implementation JQueryFileUploadTableCellView : CPTableCellView

- (@action)stopUpload:(id)sender
{
    [[self objectValue] abort];
}

@end
