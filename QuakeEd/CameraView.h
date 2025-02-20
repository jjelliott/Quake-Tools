#import <AppKit/AppKit.h>  // GNUstep uses AppKit for GUI components
#import "mathlib.h"
#import "SetBrush.h"
#import "TexturePalette.h"

extern id cameraview_i;
extern uint8_t renderlist[1024 * 1024 * 4];

void CameraMoveto(vec3_t p);
void CameraLineto(vec3_t p);

extern BOOL timedrawing;

@interface CameraView : NSView

@property (nonatomic, assign) float xa, ya, za;
@property (nonatomic, assign) float move;

@property (nonatomic, assign) float *zbuffer;
@property (nonatomic, assign) unsigned *imagebuffer;

@property (nonatomic, assign) BOOL angleChange;  // JR 6.8.95

@property (nonatomic, assign) vec3_t origin;
@property (nonatomic, assign) vec3_t matrix[3];

@property (nonatomic, assign) NSPoint dragspot;
@property (nonatomic, assign) drawmode_t drawmode;

// UI links
@property (nonatomic, strong) id modeRadio;  // Renamed mode_radio_i to follow Obj-C naming conventions

// Methods
- (void)setXYOrigin:(NSPoint *)pt;
- (void)setZOrigin:(float)pt;

- (void)setOrigin:(vec3_t)org angle:(float)angle;
- (void)getOrigin:(vec3_t)org;

- (float)yawAngle;

- (void)matrixFromAngles;
- (void)keyDown:(NSEvent *)theEvent;

- (void)drawMode:(id)sender;
- (void)setDrawMode:(drawmode_t)mode;

- (void)homeView:(id)sender;

- (void)XYDrawSelf;  // For drawing viewpoint in XY view
- (void)ZDrawSelf;   // For drawing viewpoint in Z view

- (BOOL)XYmouseDown:(NSPoint *)pt flags:(int)flags;  // Return YES if brush handled
- (BOOL)ZmouseDown:(NSPoint *)pt flags:(int)flags;  // Return YES if brush handled

- (void)upFloor:(id)sender;
- (void)downFloor:(id)sender;

@end
