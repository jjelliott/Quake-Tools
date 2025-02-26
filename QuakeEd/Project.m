//======================================
//
// QuakeEd Project Management
//
//======================================

#import "qedefs.h"


id	project_i;

@implementation Project

- init
{
	project_i = self;

	return self;
}

//===========================================================
//
//	Project code
//
//===========================================================
- initVars
{
	char		*s;
	
	s = [preferences_i getProjectPath];
	StripFilename(s);
	strcpy(path_basepath,s);
	
	strcpy(path_progdir,s);
	strcat(path_progdir,"/"SUBDIR_ENT);
	
	strcpy(path_mapdirectory,s);
	strcat(path_mapdirectory,"/"SUBDIR_MAPS);	// source dir

	strcpy(path_finalmapdir,s);
	strcat(path_finalmapdir,"/"SUBDIR_MAPS);	// dest dir
	
	[basepathinfo_i	setStringValue:[NSString stringWithUTF8String:s]];		// in Project Inspector
	
	#if 0
	if ((s = [projectInfo getStringFor:BASEPATHKEY]))
	{
		strcpy(path_basepath,s);
		
		strcpy(path_progdir,s);
		strcat(path_progdir,"/"SUBDIR_ENT);
		
		strcpy(path_mapdirectory,s);
		strcat(path_mapdirectory,"/"SUBDIR_MAPS);	// source dir

		strcpy(path_finalmapdir,s);
		strcat(path_finalmapdir,"/"SUBDIR_MAPS);	// dest dir
		
		[basepathinfo_i	setStringValue:s];		// in Project Inspector
	}
	#endif
		
	if ((s = [projectInfo getStringFor:BSPFULLVIS]))
	{
		strcpy(string_fullvis,s);
		changeString('@','\"',string_fullvis);
	}
		
	if ((s = [projectInfo getStringFor:BSPFASTVIS]))
	{
		strcpy(string_fastvis,s);
		changeString('@','\"',string_fastvis);
	}
		
	if ((s = [projectInfo getStringFor:BSPNOVIS]))
	{
		strcpy(string_novis,s);
		changeString('@','\"',string_novis);
	}
		
	if ((s = [projectInfo getStringFor:BSPRELIGHT]))
	{
		strcpy(string_relight,s);
		changeString('@','\"',string_relight);
	}
		
	if ((s = [projectInfo getStringFor:BSPLEAKTEST]))
	{
		strcpy(string_leaktest,s);
		changeString('@','\"',string_leaktest);
	}

	if ((s = [projectInfo getStringFor:BSPENTITIES]))
	{
		strcpy(string_entities,s);
		changeString('@','\"', string_entities);
	}

	// Build list of wads	
	wadList = [projectInfo parseMultipleFrom:WADSKEY];

	//	Build list of maps & descriptions
	mapList = [projectInfo parseMultipleFrom:MAPNAMESKEY];
	descList = [projectInfo parseMultipleFrom:DESCKEY];
	[self changeChar:'_' to:' ' in:descList];
	
	[self initProjSettings];

	return self;
}

//
//	Init Project Settings fields
//
- initProjSettings
{
	[pis_basepath_i	setStringValue:[NSString stringWithUTF8String:path_basepath]];
	[pis_fullvis_i	setStringValue:[NSString stringWithUTF8String:string_fullvis]];
	[pis_fastvis_i	setStringValue:[NSString stringWithUTF8String:string_fastvis]];
	[pis_novis_i	setStringValue:[NSString stringWithUTF8String:string_novis]];
	[pis_relight_i	setStringValue:[NSString stringWithUTF8String:string_relight]];
	[pis_leaktest_i	setStringValue:[NSString stringWithUTF8String:string_leaktest]];
	
	return self;
}

//
//	Add text to the BSP Output window
//
- addToOutput:(const char *)string {
    NSString *newText = [NSString stringWithUTF8String:string];
    NSTextView *textView = (NSTextView *)BSPoutput_i; // Ensure BSPoutput_i is an NSTextView

    // Get the current length of the text
    NSUInteger end = [[textView string] length];

    // Move cursor to the end of the text
    NSRange endRange = NSMakeRange(end, 0);
    [textView setSelectedRange:endRange];

    // Insert the new string
    [[textView textStorage] replaceCharactersInRange:endRange withString:newText];

    // Scroll to make sure new text is visible
    [textView scrollRangeToVisible:NSMakeRange([[textView string] length], 0)];
	return self;
}


- clearBspOutput:sender
{
	[BSPoutput_i setString:@""];
	
	return self;
}

- print
{
	NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:BSPoutput_i];
	[printOp runOperation];
	return self;
}


- initProject
{
	[self parseProjectFile];
	if (projectInfo == NULL)
		return self;
	[self initVars];
	[mapbrowse_i setReusesColumns:YES];
	[mapbrowse_i loadColumnZero];
	[pis_wads_i setReusesColumns:YES];
	[pis_wads_i loadColumnZero];

	[things_i		initEntities];
	
	return self;
}

//
//	Change a character to another in a Storage list of strings
//
- changeChar:(char)f to:(char)t in:(id)obj
{
	int	i;
	int	max;
	char	*string;

	max = [obj count];
	for (i = 0;i < max;i++)
	{
		string = (char *) [obj objectAtIndex:i];
		changeString(f,t,string);
	}
	return self;
}

//
//	Fill the QuakeEd Maps or wads browser
//	(Delegate method - delegated in Interface Builder)
//
- (int)browser:sender fillMatrix:matrix inColumn:(int)column
{
	id		cell, list;
	int		max;
	char	*name;
	int		i;

	if (sender == mapbrowse_i)
		list = mapList;
	else if (sender == pis_wads_i)
		list = wadList;
	else
	{
		list = nil;
		Error ("Project: unknown browser to fill");
	}
	
	max = [list count];
	for (i = 0 ; i<max ; i++)
	{
		name = (char *)[list objectAtIndex:i];
		[matrix addRow];
		cell = [matrix cellAtRow:i column:0];
		[cell setStringValue:[NSString stringWithUTF8String:name]];
		[cell setLeaf:YES];
		[cell setLoaded:YES];
	}
	return i;
}

//
//	Clicked on a map name or description!
//
- clickedOnMap:sender
{
	id	matrix;
	int	row;
	char	fname[1024];
	id	panel;
	
	matrix = [sender matrixInColumn:0];
	row = [matrix selectedRow];
	sprintf(fname,"%s/%s.map",path_mapdirectory,
		(char *)[mapList objectAtIndex:row]);
	
	panel = NSGetAlertPanel([NSString stringWithUTF8String:"Loading..."],
		[NSString stringWithUTF8String:"Loading map. Please wait."],NULL,NULL,NULL);
	[panel orderFront:NULL];

	[quakeed_i doOpen:fname];

	[panel performClose:NULL];
	// NSFreeAlertPanel(panel);
	return self;
}

- (void)selectRowInMatrix:(NSInteger)row {
    if ([pis_wads_i isKindOfClass:[NSMatrix class]]) {
        // NSMatrix: Select cell at given row, first column
        [[pis_wads_i cellAtRow:row column:0] setState:NSControlStateValueOn];
    } else if ([pis_wads_i isKindOfClass:[NSTableView class]]) {
        // NSTableView: Select row in table view
        [(NSTableView *)pis_wads_i selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                             byExtendingSelection:NO];
    } else {
        NSLog(@"Unknown view type: %@", [pis_wads_i class]);
    }
}
- setTextureWad: (char *)wf
{
	int		i, c;
	char	*name;
	
	qprintf ("loading %s", wf);

// set the row in the settings inspector wad browser
	c = [wadList count];
	for (i=0 ; i<c ; i++)
	{
		name = (char *)[wadList objectAtIndex:i];
		if (!strcmp(name, wf))
		{
			[self selectRowInMatrix:i];
			break;
		}
	}

// update the texture inspector
	[texturepalette_i initPaletteFromWadfile:wf ];
	[[map_i objectAtIndex: 0] setKey:"wad" toValue: wf];
//	[inspcontrol_i changeInspectorTo:i_textures];

	[quakeed_i updateAll];

	return self;
}

//
//	Clicked on a wad name
//
- clickedOnWad:sender
{
	id		matrix;
	int		row;
	char	*name;
	
	matrix = [sender matrixInColumn:0];
	row = [matrix selectedRow];

	name = (char *)[wadList objectAtIndex:row];
	[self setTextureWad: name];
	
	return self;
}


//
//	Read in the <name>.QE_Project file
//
- parseProjectFile
{
	char	*path;
	int		rtn;
	
	path = [preferences_i getProjectPath];
	if (!path || !path[0] || access(path,0))
	{
		rtn = NSRunAlertPanel([NSString stringWithUTF8String:"Project Error!"],
			[NSString stringWithUTF8String:"A default project has not been found.\n"]
			, [NSString stringWithUTF8String:"Open Project"], NULL, NULL);
		if ([self openProject] == nil)
			while (1)		// can't run without a project
				[NSApp terminate: self];
		return self;	
	}

	[self openProjectFile:path];
	return self;
}

//
//	Loads and parses a project file
//
- openProjectFile:(char *)path
{		
	FILE	*fp;
	struct	stat s;

	strcpy(path_projectinfo,path);

	projectInfo = NULL;
	fp = fopen(path,"r+t");
	if (fp == NULL)
		return self;

	stat(path,&s);
	lastModified = s.st_mtime;

	projectInfo = [(Dict *)[Dict alloc] initFromFile:fp];
	fclose(fp);
	
	return self;
}

- (char *)currentProjectFile
{
	return path_projectinfo;
}

//
//	Open a project file
//
- openProject
{
	char	path[128];
	id		openpanel;
	int		rtn;
	char	*projtypes[2] = {"qpr",NULL};
	char	**filenames;
	char	*dir;
	
	openpanel = [NSOpenPanel new];
	[openpanel setAllowsMultipleSelection:NO];
	[openpanel setCanChooseDirectories:NO];
	// Assuming projtypes is a char** (C array of strings), you need to convert it to an NSArray of NSString objects.

NSArray *allowedTypes = [NSMutableArray array]; // Initialize an empty array

// If projtypes is a C array, convert it to an NSArray of NSString
int i;
for ( i = 0; projtypes[i] != NULL; i++) {
    allowedTypes = [allowedTypes arrayByAddingObject:[NSString stringWithUTF8String:projtypes[i]]];
}

// Now you can pass the allowedTypes array to the panel method
[openpanel setAllowedFileTypes:allowedTypes];

// Run the panel
 rtn = [openpanel runModal];

	if (rtn == NSModalResponseOK) {
    // Get the array of URLs (selected files)
    NSArray *filenames = [openpanel URLs];
    
    // Get the directory as a C string
    NSString *directory = [openpanel directory];
    const char *dir = [directory UTF8String]; // Convert NSString to const char *
    
    // Assuming filenames[0] is a valid URL and you want to use the first file name
    NSString *filePath = [[filenames firstObject] path]; // Convert the first URL to a file path
    const char *filename = [filePath UTF8String]; // Convert NSString to const char *
    
    // Combine the directory and filename into the final path
    char path[1024]; // Make sure the path is large enough for your needs
    sprintf(path, "%s/%s", dir, filename);
    
    // Copy the combined path to path_projectinfo
    strcpy(path_projectinfo, path);
    
    // Call your method to open the project file
    [self openProjectFile:path];
    
    return self;
}

	
	return nil;
}


//
//	Search for a string in a List of strings
//
- (int)searchForString:(char *)str in:(id)obj
{
	int	i;
	int	max;
	char	*s;

	max = [obj count];
	for (i = 0;i < max; i++)
	{
		s = (char *)[obj objectAtIndex:i];
		if (!strcmp(s,str))
			return 1;
	}
	return 0;
}

- (char *)getMapDirectory
{
	return path_mapdirectory;
}

- (char *)getFinalMapDirectory
{
	return path_finalmapdir;
}

- (char *)getProgDirectory
{
	return path_progdir;
}


//
//	Return the WAD name for cmd-8
//
- (char *)getWAD8
{
	if (!path_wad8[0])
		return NULL;
	return path_wad8;
}

//
//	Return the WAD name for cmd-9
//
- (char *)getWAD9
{
	if (!path_wad9[0])
		return NULL;
	return path_wad9;
}

//
//	Return the WAD name for cmd-0
//
- (char *)getWAD0
{
	if (!path_wad0[0])
		return NULL;
	return path_wad0;
}

//
//	Return the FULLVIS cmd string
//
- (char *)getFullVisCmd
{
	if (!string_fullvis[0])
		return NULL;
	return string_fullvis;
}

//
//	Return the FASTVIS cmd string
//
- (char *)getFastVisCmd
{
	if (!string_fastvis[0])
		return NULL;
	return string_fastvis;
}

//
//	Return the NOVIS cmd string
//
- (char *)getNoVisCmd
{
	if (!string_novis[0])
		return NULL;
	return string_novis;
}

//
//	Return the RELIGHT cmd string
//
- (char *)getRelightCmd
{
	if (!string_relight[0])
		return NULL;
	return string_relight;
}

//
//	Return the LEAKTEST cmd string
//
- (char *)getLeaktestCmd
{
	if (!string_leaktest[0])
		return NULL;
	return string_leaktest;
}

- (char *)getEntitiesCmd
{
	if (!string_entities[0])
		return NULL;
	return string_entities;
}

@end

//====================================================
// C Functions
//====================================================

//
// Change a character to a different char in a string
//
void changeString(char cf,char ct,char *string)
{
	int	j;

	for (j = 0;j < strlen(string);j++)
		if (string[j] == cf)
			string[j] = ct;
}


