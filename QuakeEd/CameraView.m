#import "CameraView.h"
#import "qedefs.h"

id cameraview_i;
BOOL timedrawing = NO;

@implementation CameraView

/*
==================
initWithFrame:
==================
*/
- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        cameraview_i = self;
        xa = ya = za = 0;

        [self matrixFromAngles];

        origin[0] = 64;
        origin[1] = 64;
        origin[2] = 48;
        move = 16;

        NSUInteger size = frameRect.size.width * frameRect.size.height;
        zbuffer = malloc(size * sizeof(float));
        imagebuffer = malloc(size * sizeof(unsigned));

        if (!zbuffer || !imagebuffer) {
            NSLog(@"Error: Failed to allocate memory for buffers.");
        }
    }
    return self;
}

- (void)dealloc
{
    free(zbuffer);
    free(imagebuffer);
    [super dealloc];
}

- (void)setXYOrigin:(NSPoint *)pt
{
    origin[0] = pt.x;
    origin[1] = pt.y;
}

- (void)setZOrigin:(float)pt
{
    origin[2] = pt;
}

- (void)setOrigin:(vec3_t)org angle:(float)angle
{
    VectorCopy(org, origin);
    ya = angle;
    [self matrixFromAngles];
}

- (void)getOrigin:(vec3_t)org
{
    VectorCopy(origin, org);
}

- (float)yawAngle
{
    return ya;
}

- (void)upFloor:(id)sender
{
    sb_floor_dir = 1;
    sb_floor_dist = 99999;
    [map_i makeAllPerform:@selector(feetToFloor)];

    if (sb_floor_dist == 99999) {
        NSLog(@"Already on top floor");
        return;
    }

    NSLog(@"Moving up one floor");
    origin[2] += sb_floor_dist;
    [quakeed_i updateCamera];
}

- (void)downFloor:(id)sender
{
    sb_floor_dir = -1;
    sb_floor_dist = -99999;
    [map_i makeAllPerform:@selector(feetToFloor)];

    if (sb_floor_dist == -99999) {
        NSLog(@"Already on bottom floor");
        return;
    }

    NSLog(@"Moving down one floor");
    origin[2] += sb_floor_dist;
    [quakeed_i updateCamera];
}

/*
===============================================================================

UI TARGETS

===============================================================================
*/

- (void)homeView:(id)sender
{
    xa = za = 0;
    [self matrixFromAngles];
    [quakeed_i updateAll];
    NSLog(@"View reset to home position.");
}

- (void)drawMode:(id)sender
{
    drawmode = [sender selectedColumn];
    [quakeed_i updateCamera];
}

- (void)setDrawMode:(drawmode_t)mode
{
    drawmode = mode;
    [modeRadio selectCellAtRow:0 column:mode];
    [quakeed_i updateCamera];
}

/*
===============================================================================

TRANSFORMATION METHODS

===============================================================================
*/

- (void)matrixFromAngles
{
    if (xa > M_PI * 0.4)
        xa = M_PI * 0.4;
    if (xa < -M_PI * 0.4)
        xa = -M_PI * 0.4;

    // vpn
    matrix[2][0] = cos(xa) * cos(ya);
    matrix[2][1] = cos(xa) * sin(ya);
    matrix[2][2] = sin(xa);

    // vup
    matrix[1][0] = cos(xa + M_PI / 2) * cos(ya);
    matrix[1][1] = cos(xa + M_PI / 2) * sin(ya);
    matrix[1][2] = sin(xa + M_PI / 2);

    // vright
    CrossProduct(matrix[2], matrix[1], matrix[0]);
}

/*
===============================================================================

DRAWING METHODS

===============================================================================
*/

- (void)drawRect:(NSRect)rect
{
    NSLog(@"Drawing CameraView");
    if (drawmode == dr_texture || drawmode == dr_flat)
        [self drawSolid];
    else
        [self drawWire];

    if (timedrawing)
        NSLog(@"CameraView drawtime: %5.3f", I_FloatTime());
}

- (void)drawSolid
{
    NSLog(@"Rendering solid camera view");
    // Replace NSDrawBitmap() with GNUstep-compatible bitmap rendering.
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:(unsigned char **)&imagebuffer
                      pixelsWide:self.frame.size.width
                      pixelsHigh:self.frame.size.height
                   bitsPerSample:8
                 samplesPerPixel:4
                        hasAlpha:NO
                        isPlanar:NO
                  colorSpaceName:NSDeviceRGBColorSpace
                     bytesPerRow:self.frame.size.width * 4
                    bitsPerPixel:32];

    [[NSGraphicsContext currentContext] drawImage:imageRep atPoint:NSZeroPoint];
    [imageRep release];
}

- (void)drawWire
{
    NSLog(@"Rendering wireframe camera view");
    [[NSColor whiteColor] set];
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(origin[0] - 16, origin[1])];
    [path relativeLineToPoint:NSMakePoint(16, 8)];
    [path relativeLineToPoint:NSMakePoint(16, -8)];
    [path relativeLineToPoint:NSMakePoint(-16, -8)];
    [path relativeLineToPoint:NSMakePoint(-16, 8)];
    [path relativeLineToPoint:NSMakePoint(32, 0)];

    [path stroke];
}

/*
===============================================================================

EVENT HANDLING

===============================================================================
*/

- (void)mouseDown:(NSEvent *)event
{
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
    NSLog(@"Mouse clicked at: (%.2f, %.2f)", location.x, location.y);

    if ([event modifierFlags] & NSEventModifierFlags.shift) {
        NSLog(@"Shift-click: Selecting entity");
        [map_i selectRay:origin :location :NO];
    } else {
        NSLog(@"Default click behavior");
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    NSLog(@"Right mouse button clicked: Dragging camera view");
    [self viewDrag:event];
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];

    switch (key) {
        case NSRightArrowFunctionKey:
            ya -= M_PI * move / (64 * 2);
            break;
        case NSLeftArrowFunctionKey:
            ya += M_PI * move / (64 * 2);
            break;
        case NSUpArrowFunctionKey:
            origin[0] += move * cos(ya);
            origin[1] += move * sin(ya);
            break;
        case NSDownArrowFunctionKey:
            origin[0] -= move * cos(ya);
            origin[1] -= move * sin(ya);
            break;
        default:
            NSLog(@"Unhandled key: %c", key);
            break;
    }

    [self matrixFromAngles];
    [quakeed_i updateCamera];
}

@end
