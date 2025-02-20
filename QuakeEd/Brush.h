#import <AppKit/AppKit.h>
#import "SetBrush.h"
#import "EditWindow.h"

extern id brush_i;
extern BOOL brushdraw;  // YES when drawing cut brushes and entities

@interface Brush : SetBrush

@property (nonatomic, strong) id cutbrushes;
@property (nonatomic, strong) id cutentities;
@property (nonatomic, assign) BOOL dontdraw;   // For modal instance loops
@property (nonatomic, assign) BOOL deleted;    // When not visible at all
@property (nonatomic, assign) BOOL updatemask[MAXBRUSHVERTEX];

// Initializers
- (instancetype)init;
- (instancetype)initFromSetBrush:(Brush *)br;

// Selection
- (void)deselect;
- (BOOL)isSelected;

// Mouse Event Handling
- (BOOL)XYmouseDown:(NSPoint *)pt;  // Return YES if brush handled
- (BOOL)ZmouseDown:(NSPoint *)pt;   // Return YES if brush handled

// Keyboard Event Handling
- (void)keyDown:(NSEvent *)theEvent;

// Brush Operations
- (NSPoint)centerPoint;  // For camera flyby mode

- (void)instanceSize;
- (void)XYDrawSelf;
- (void)ZDrawSelf;
- (void)CameraDrawSelf;

// Transformations
- (void)flipHorizontal:(id)sender;
- (void)flipVertical:(id)sender;
- (void)rotate90:(id)sender;

- (void)makeTall:(id)sender;
- (void)makeShort:(id)sender;
- (void)makeWide:(id)sender;
- (void)makeNarrow:(id)sender;

// Entity and Clipboard Operations
- (void)placeEntity:(id)sender;
- (void)cut:(id)sender;
- (void)copy:(id)sender;

- (void)addBrush;

@end
