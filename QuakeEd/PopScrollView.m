
#import "qedefs.h"

@implementation PopScrollView

/*
====================
initFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- initFrame:(const NSRect *)frameRect button1:b1 button2:b2
{
	[super  initWithFrame: *frameRect];	

	[self addSubview: b1];
	[self addSubview: b2];

	button1 = b1;
	button2 = b2;

	[self setHasHorizontalScroller: YES];
	[self setHasVerticalScroller: YES];

	[self setBorderType: NSBezelBorder];
		
	return self;
}


/*
================
tile

Adjust the size for the pop up scale menu
=================
*/

- tile
{
	NSRect	scrollerframe;
	NSRect	buttonframe, buttonframe2;
	NSRect	newframe;
	NSScroller *hScroller = [[self horizontalScroller] retain];
	NSRect frame = [self frame];  
	[super tile];
	buttonframe = [button1 frame];
	buttonframe2 = [button2 frame];
	scrollerframe = [hScroller frame];
	
	newframe.origin.y = scrollerframe.origin.y;
	newframe.origin.x = frame.size.width - buttonframe.size.width;
	newframe.size.width = buttonframe.size.width;
	newframe.size.height = scrollerframe.size.height;
	scrollerframe.size.width -= newframe.size.width;
	[button1 setFrame: newframe];
	newframe.size.width = buttonframe2.size.width;
	newframe.origin.x -= newframe.size.width;
	[button2 setFrame: newframe];
	scrollerframe.size.width -= newframe.size.width;

	[hScroller setFrame: scrollerframe];

	return self;
}


- resizeSubviewsWithOldSize:(const NSSize *)oldSize
{
	[super resizeSubviewsWithOldSize: *oldSize];
	
	[[self documentView] newSuperBounds];
	
	return self;
}


-(BOOL) acceptsFirstResponder
{
    return YES;
}



@end

