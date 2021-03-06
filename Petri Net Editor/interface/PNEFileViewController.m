//
//  PNEFileViewController.m
//  Petri Net Editor
//
//  Created by Mathijs Saey on 12/05/12.
//  Copyright (c) 2012 Vrije Universiteit Brussel. All rights reserved.
//

#import "PNEFileViewController.h"

@implementation PNEFileViewController

@synthesize doneButton, saveButton, mailButton, parseButton, addFileButton; 
@synthesize fileView, folderView, navBar, addFolderButton;

#pragma mark - View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        fileManager = [[PNEFileManager alloc] init];
        files = [[fileManager getFilesInFolder] retain];
        folders = [[fileManager getFoldersInFolder] retain];
    }
    return self;
}

- (void) dealloc {
    [fileManager release];
    [folders release];
    [files release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Help functions

/**
 This method reloads the 
 files and folders arrays
 afterwards is asks the folderview
 to repopulate itself
 */
- (void) reloadData {
    [files release];
    [folders release];
    
    files = [[fileManager getFilesInFolder] retain];
    folders = [[fileManager getFoldersInFolder] retain];
    [folderView reloadData];
}

/**
 This method closes the current file
 */
- (void) closeFile {
    fileView.text = @"";
    currentFileName = nil;
}

/**
 This method shows a method to the user
 */
- (void) printError: (NSString*) errorMessage {
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_TITLE", nil) message:errorMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK_BUTTON", nil) otherButtonTitles: nil];
    [error show];
    [error release];
}

/**
 This method presents the user an option
 sheet where he can enter a name.
 */
- (void) printAskNameField: (NSString*) title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON", nil) otherButtonTitles:NSLocalizedString(@"OK_BUTTON", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    [alert release];
}

#pragma mark - File handling

/**
 Opens a context declaration file. And puts the
 contents in the file viewer.
 */
- (void) openContextDeclaration: (NSString*) name {
    currentFileName = name;
    fileView.text = [fileManager getContextDeclaration:name];
}

/**
 Saves the current file
 */
- (void) saveContextDeclaration {
    if (currentFileName != nil)
        [fileManager putContextDeclaration:currentFileName withContents:fileView.text];
}

/**
 Parses the current file
 */
- (void) parseContextDeclaration {
    if (currentFileName != nil && [fileManager parseFile:currentFileName]) {
        [self returnToMainViewController];
    }
}

/**
 Opens a folder, the subclasses
 also change the navigation bar contents
 */
- (void) changeFolder: (NSString*) name {
    [self closeFile];
    [fileManager changeFolder:name];
    [self reloadData];
}

#pragma mark UITableView delegate methods

/**
 This method is called by the system when the user
 selects a field of a tableview.
 Depending on what we selected we either open a file
 or a folder.
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellLabel = [folderView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    //Folders
    if (indexPath.row < [folders count]) [self changeFolder:cellLabel];
    //Files
    else [self openContextDeclaration:cellLabel];
}

/**
 This method is called by the system when the tableView is 
 loading it's data. It asks a UItableViewCell for each "open slot" it has.
 We provide the table view with a UITableViewCell for each folder and file.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *newCell = [[UITableViewCell alloc] init];
    
    //Folders
    if (indexPath.row < [folders count]) {
        newCell.textLabel.text = [folders objectAtIndex:indexPath.row];
        newCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //Files
    else {
        newCell.textLabel.text = [files objectAtIndex:indexPath.row - [folders count]];
    }
    [newCell autorelease];
    return newCell;
}

/**
 This method is called by the system to determine how many
 elements a tableview should contain.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [files count] + [folders count];
}
 
/**
 This method is called by the system when the user
 tries to use a certain editing method on a UITableViewCell.
 We only use it to delete files and folders.
 */
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *cellLabel = [[folderView cellForRowAtIndexPath:indexPath].textLabel.text retain];
        
        if ([cellLabel isEqualToString:currentFileName]) [self closeFile];
        
        [fileManager eraseElement:cellLabel];
        [self reloadData];
        [cellLabel release];
    }
}

#pragma mark - Action responders

/**
 This method is called by the system when the navigation
 bar pops an item (generally when the back button is pressed).
 We use it to return to the previous folder.
 */
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    [fileManager returnToFolder];
    [self reloadData];
    [self closeFile];
}

/**
 This method is called by the system when the user selects
 an option on the UIAlertView.
 In our case it means we have to create a file
 or folder. We check the title of the UIAlertView
 to find out which one we need to create.
 */
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString* name = [alertView textFieldAtIndex:0].text;  
        
        if ([alertView.title isEqualToString:NSLocalizedString(@"FILE_VIEW_FILE_NAME_TITLE", nil)]) {
            [fileManager putContextDeclaration:name withContents:@""];
            [self openContextDeclaration:name];
        }
        
        else if ([alertView.title isEqualToString:NSLocalizedString(@"FILE_VIEW_FOLDER_NAME_TITLE", nil)]) {
            [fileManager addFolder:name];
        }
        
        [self reloadData];
    }
}

/**
 This method is called by the system when
 the user pushes the add folder button.
 */
- (IBAction)addFolderButtonPressed:(id)sender {
    [self printAskNameField:NSLocalizedString(@"FILE_VIEW_FOLDER_NAME_TITLE", nil)];
}

/**
 This method is called by the system when
 the user pushes the new file button.
 */
- (IBAction)addFileButtonPressed:(id)sender {
    [self printAskNameField:NSLocalizedString(@"FILE_VIEW_FILE_NAME_TITLE", nil)];
}

/**
 This method is called by the system when
 the user pushes the done button.
 */
- (IBAction)doneButtonPressed:(id)sender {
    [self returnToMainViewController];
}

/**
 This method is called by the system when
 the user pushes the save button.
 */
- (IBAction)saveButtonPressed:(id)sender {
    if (currentFileName != nil)
        [self saveContextDeclaration];
    else [self printError:NSLocalizedString(@"FILE_VIEW_NO_OPEN_FILE", nil)];
}

/**
 This method is called by the system when
 the user pushes the mail button.
 This allows the user to mail the current file.
 (if the device supports it).
 */
- (IBAction)mailButtonPressed:(id)sender {
    if (currentFileName != nil && [MFMailComposeViewController canSendMail]) {
        //Store the data and load it into a buffer
        [self saveContextDeclaration];
        NSData *buffer = [fileManager getContextDeclarationBuffer:currentFileName];
        
        //Open a mailcomposer and add the file as an attachement
        MFMailComposeViewController *mailComposer  = [[MFMailComposeViewController alloc] init];
        [mailComposer addAttachmentData:buffer mimeType:nil fileName:currentFileName];
        
        //Set some options and show the mail window
        mailComposer.mailComposeDelegate = self;
        [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentModalViewController:mailComposer animated:YES];
        [mailComposer release];
    }
    
    else if (currentFileName == nil) [self printError:NSLocalizedString(@"FILE_VIEW_NO_OPEN_FILE", nil)];
    else [self printError:NSLocalizedString(@"FILE_VIEW_NO_MAIL", nil)];
}

/**
 This method is called by the system when the user
 presses the send or cancel button on the mailcomposecontroller.
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error { 
    [controller dismissModalViewControllerAnimated:true];
}

/**
 This method is called by the system when
 the user pushes the parse button.
 */
- (IBAction)parseButtonPressed:(id)sender {
    if (currentFileName != nil) {
        [self saveContextDeclaration];
        [self parseContextDeclaration];
    }
    else [self printError:NSLocalizedString(@"FILE_VIEW_NO_OPEN_FILE", nil)];
}

/**
 This method returns to the PNEViewController.
 */
- (void) returnToMainViewController {
    [self dismissModalViewControllerAnimated:true];
}

@end
