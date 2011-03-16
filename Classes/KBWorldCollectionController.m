//
//  KBWorldCollectionController.m
//  InsideJob
//
//  Created by Ben K on 2011/03/14.
//  Copyright 2011 Ben K. All rights reserved.
//

#import "KBWorldCollectionController.h"
#import "IJInventoryWindowController.h"


@implementation KBWorldCollectionController
@synthesize worldArray;

-(void)awakeFromNib
{
	worldArray = [[NSMutableArray alloc] init];
	//Add a new observer to the array controller of the collection view
	[worldArrayController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:nil];
	
	NSString *path = [@"~/library/application support/minecraft/saves/" stringByExpandingTildeInPath];
	NSArray *folderArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
	
	int index;
	for (index = 0; index < [folderArray count]; index++) {
		NSString *fileName = [folderArray objectAtIndex:index];
		NSString *filePath = [path stringByAppendingPathComponent:[folderArray objectAtIndex:index]];
		if ([fileName hasPrefix:@"."])
			continue;
		
		NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
		
		if (![[fileAttr valueForKey:NSFileType] isEqualToString:NSFileTypeDirectory])
			continue;
		
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:@"'Created:' MMM d yyyy 'at' h:m:s a"];
		NSString *fileMeta = [formatter stringFromDate:[fileAttr valueForKey:NSFileCreationDate]];
		
		
		int index = [[worldArrayController arrangedObjects] count];
		[worldArrayController insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
																				fileName, @"Name",
																				fileMeta, @"Meta",
																				[NSImage imageNamed:@"World"], @"Icon",
																				self, @"Delegate",
																				filePath, @"Path",
																				nil] 
								 atArrangedObjectIndex:index];
		[worldArrayController	setSelectionIndex:0];
		
	}
	
	if ([[worldArrayController arrangedObjects] count] == 0) {
		[InventoryWindowController.contentView selectTabViewItemAtIndex:2];
		[chooseButton setEnabled:NO];
	}
}

//Observer for the collection view array controller selection: "selectionIndexes"
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualTo:@"selectionIndexes"]) {
		//True if in the array controller of the collection view really exists at least a selected object
		if ([[worldArrayController selectedObjects] count] > 0) {
			[chooseButton setEnabled:YES];
		}
		else {
			[chooseButton setEnabled:NO];
		}
	}
}

- (void)openWorldAtPath:(NSString *)path
{
	[InventoryWindowController loadWorldAtPath:path];
}

- (IBAction)openSelectedWorld:(id)sender
{
	int index = [worldArrayController selectionIndex];
	NSString *path = [[worldArray objectAtIndex:index] valueForKey:@"Path"];
	[InventoryWindowController loadWorldAtPath:path];
}


- (void)dealloc
{
	//Remove the collection view array controller selectionIndexes observer
	[worldArrayController removeObserver:self forKeyPath:@"selectionIndexes"];
	[super dealloc];
}

@end
