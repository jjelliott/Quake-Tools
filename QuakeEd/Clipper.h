#import <Foundation/Foundation.h>
#import "mathlib.h"  // Assuming mathlib provides vec3_t, plane_t
#import "map.h"      // Assuming map.h provides face_t

extern id clipper_i;

@interface Clipper : NSObject

@property (nonatomic, assign) int num;
@property (nonatomic, assign) vec3_t pos[3];
@property (nonatomic, assign) plane_t plane;

// Visibility and Interaction
- (BOOL)hide;
- (void)XYClick:(NSPoint)pt;
- (BOOL)XYDrag:(NSPoint *)pt;
- (void)ZClick:(NSPoint)pt;

// Clipping Operations
- (void)carve;
- (void)flipNormal;
- (BOOL)getFace:(face_t *)pl;

// Drawing Methods
- (void)cameraDrawSelf;
- (void)XYDrawSelf;
- (void)ZDrawSelf;

@end
