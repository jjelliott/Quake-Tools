/* 
 * UserPath.m by Bruce Blumberg, NeXT Computer, Inc.
 *
 * You may freely copy,distribute and re-use the code in this example. NeXT
 * disclaims any warranty of any kind, expressed or implied, as to its fitness
 * for any particular purpose
 *
 */

#import "UserPath.h"
#import <Foundation/Foundation.h>

// Static variables
static cairo_surface_t *surface = NULL;  // Cairo surface to draw on
static cairo_t *cr = NULL;               // Cairo context for drawing

// Helper function for Cairo context creation
static void createCairoContext(int width, int height) {
    if (!surface) {
        surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
        cr = cairo_create(surface);
    }
}

@implementation UserPath

// UserPath class initialization
+ (instancetype)userPath {
    UserPath *userPath = [[UserPath alloc] init];
    userPath.points = [NSMutableArray array];
    userPath.ops = [NSMutableArray array];
    userPath.numberOfPoints = 0;
    userPath.numberOfOps = 0;
    userPath.max = 8192;
    userPath.ping = NO;
    userPath.bbox[0] = userPath.bbox[1] = 1.0e6;
    userPath.bbox[2] = userPath.bbox[3] = -1.0e6;
    return userPath;
}

// Grow UserPath
- (void)growUserPath {
    // Double the size of the internal buffers
    self.max *= 2;
    NSLog(@"growUserPath: Increasing size to %d", self.max);
    [self.points addObject:[NSValue valueWithCGPoint:CGPointZero]];  // Example to grow
}

// Begin a user path
- (void)beginUserPathWithCache:(BOOL)cache {
    self.numberOfPoints = self.numberOfOps = 0;
    self.cp = CGPointZero;
    self.bbox[0] = self.bbox[1] = 1.0e6;
    self.bbox[2] = self.bbox[3] = -1.0e6;

    if (cache) {
        [self.ops addObject:@"dps_ucache"];
    }
    [self.ops addObject:@"dps_setbbox"];
}

// End user path
- (void)endUserPathWithOp:(int)op {
    self.opForUserPath = op;
}

// Debugging (setting ping)
- (void)debugUserPathWithPing:(BOOL)shouldPing {
    self.ping = shouldPing;
}

// Send user path (replaced DPS with Cairo)
- (int)sendUserPath {
    if (self.opForUserPath == 0) {
        return -2;  // No path to send
    }

    // Create Cairo context (for example, 500x500 canvas)
    createCairoContext(500, 500);

    // Apply Cairo drawing operations
    for (int i = 0; i < self.numberOfOps; i++) {
        NSString *operation = self.ops[i];
        if ([operation isEqualToString:@"dps_moveto"]) {
            CGPoint point = [self.points[i] CGPointValue];
            cairo_move_to(cr, point.x, point.y);
        }
        // Add more operations (lineto, curveto, etc.)
    }

    cairo_stroke(cr);  // Apply stroke (draw the path)

    // Write the result to a PNG file for demonstration
    cairo_surface_write_to_png(surface, "userpath_output.png");

    return 0;  // Success
}

// Add a "moveto" operation
- (void)movetoWithX:(float)x Y:(float)y {
    [self.ops addObject:@"dps_moveto"];
    [self.points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    [self updateBBoxWithX:x Y:y];
}

// Add a "lineto" operation
- (void)linetoWithX:(float)x Y:(float)y {
    [self.ops addObject:@"dps_lineto"];
    [self.points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    [self updateBBoxWithX:x Y:y];
}

// Update bounding box
- (void)updateBBoxWithX:(float)x Y:(float)y {
    if (x < self.bbox[0]) self.bbox[0] = x;
    if (y < self.bbox[1]) self.bbox[1] = y;
    if (x > self.bbox[2]) self.bbox[2] = x;
    if (y > self.bbox[3]) self.bbox[3] = y;
}

// Close the path (finish drawing)
- (void)closePath {
    cairo_close_path(cr);  // Close the path in Cairo
    cairo_stroke(cr);      // Apply stroke (render the path)
}

@end

