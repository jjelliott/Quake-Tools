
#import "qedefs.h"

id	keypairview_i;

@implementation KeypairView

/*
==================
initFrame:
==================
*/
- initFrame:(const NSRect *)frameRect
{
	[super initWithFrame:*frameRect];
	keypairview_i = self;
	return self;
}


- calcViewSize
{
	CGFloat	w;
	CGFloat	h;
	NSRect	b;
	NSPoint	pt;
	int		count;
	id		ent;
	
	ent = [map_i currentEntity];
	count = [ent numPairs];

	NSView *superview = [self superview];
	if (superview) {
    	NSRect frame = [self frame];
    	frame.origin.y = NSMaxY([superview bounds]) - frame.size.height;
    	[self setFrame:frame];
	}
	
	b = [superview bounds];
	w = b.size.width;
	h = LINEHEIGHT*count + SPACING;
	[self setFrameSize:NSMakeSize(w, h)];
	pt.x = pt.y = 0;
	[self scrollPoint: pt];
	return self;
}

- drawSelf:(const NSRect *)rects :(int)rectCount {
    epair_t *pair;
    int y;

    // Set the background color to light gray
    [[NSColor lightGrayColor] setFill];
    NSRectFill(self.bounds);
    
    // Set the font and text color manually
    NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:FONTSIZE];
    NSColor *color = [NSColor blackColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        font, NSFontAttributeName,
        color, NSForegroundColorAttributeName,
        nil];

    y = self.bounds.size.height - LINEHEIGHT;

    pair = [[map_i currentEntity] epairs];
    while (pair) {
        // Convert char array (C string) to NSString
        NSString *keyString = [NSString stringWithUTF8String:pair->key];
        NSPoint keyPoint = NSMakePoint(SPACING, y);
        [keyString drawAtPoint:keyPoint withAttributes:attributes];
        
        NSString *valueString = [NSString stringWithUTF8String:pair->value];
        NSPoint valuePoint = NSMakePoint(100, y);
        [valueString drawAtPoint:valuePoint withAttributes:attributes];
        
        y -= LINEHEIGHT;
        
        pair = pair->next;
    }

    [[NSColor blackColor] setStroke];
    NSFrameRect(self.bounds);
    
    return self;
}

- mouseDown:(NSEvent *)theEvent
{
	NSPoint	loc;
	int		i;
	epair_t	*p;

	loc = [theEvent locationInWindow];
	[self convertPoint:loc	fromView:NULL];
	
	i = ([self bounds].size.height - loc.y - 4) / LINEHEIGHT;

	p = [[map_i currentEntity] epairs];
	while (	i )
	{
		p=p->next;
		if (!p)
			return self;
		i--;
	}
	if (p)
		[things_i setSelectedKey: p];
	
	return self;
}

@end
