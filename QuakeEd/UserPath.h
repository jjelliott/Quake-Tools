/* 
 * UserPath.h by Bruce Blumberg, NeXT Computer, Inc.
 *
 * You may freely copy,distribute and re-use the code in this example. NeXT
 * disclaims any warranty of any kind, expressed or implied, as to its fitness
 * for any particular purpose
 *
 * This file and its associated .m file define a data structure and set of
 * functions aimed at facilitating the use of user paths. Here is a simple
 * example:
 *
 * UserPath *arect;
 * arect = newUserPath(); // creates an empty user path
 * beginUserPath(arect,YES);  // initialize user path and cache
 *   UPmoveto(arect,0.0,0.0); // add moveto to userpath; update bounding box
 *   UPrlineto(arect,0.0,100.0); // add rlineto to path; update bounding box
 *   UPrlineto(arect,100.0,0.0); // add rlineto to path; update bounding box
 *   UPrlineto(arect,0.0,-100.0); // add rlineto to path; update bounding box
 *   closePath(arect); // close path
 * endUserPath(arect,dps_stroke); // close user path and specify operator
 * sendUserPath(arect);
 *
 * As you will note, the set of routines manage the allocation and growth of
 * the operator and operand arrays, as well as the calculation of the bounding
 * box. A user path created via these functions may be optionally cached down
 * at the window server, or repeatedly sent down.  The user paths created by
 * this set of functions are all allocated in a unique zone.
 *
 * Note: the associated file is a .m file because it pulls in some .h files
 * which reference objective C methods. 
 */
#import <Foundation/Foundation.h>
#include <cairo/cairo.h>  // For Cairo drawing

// Use a class instead of a struct for better memory management and encapsulation
@interface UserPath : NSObject

@property (nonatomic, strong) NSMutableArray<NSValue *> *points;  // Store points as NSValue (Cairo uses x, y)
@property (nonatomic, assign) int numberOfPoints;
@property (nonatomic, strong) NSString *ops;  // NSString for ops
@property (nonatomic, assign) CGPoint cp;    // Use CGPoint instead of NSPoint
@property (nonatomic, assign) int numberOfOps;
@property (nonatomic, assign) int max;
@property (nonatomic, assign) float bbox[4];  // Still use a C array for bbox
@property (nonatomic, assign) int opForUserPath;
@property (nonatomic, assign) BOOL ping;

// Cairo context for drawing
@property (nonatomic, assign) cairo_t *cr;  // Cairo context for the path

// UserPath methods
+ (instancetype)userPath;  // Factory method for creating new UserPath
- (void)debugUserPathWithPing:(BOOL)shouldPing;
- (void)growUserPath;
- (void)beginUserPathWithCache:(BOOL)cache;
- (void)endUserPathWithOp:(int)op;
- (int)sendUserPath;
- (void)movetoWithX:(float)x Y:(float)y;
- (void)rmovetoWithX:(float)x Y:(float)y;
- (void)linetoWithX:(float)x Y:(float)y;
- (void)rlinetoWithX:(float)x Y:(float)y;
- (void)curvetoWithX1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2 X3:(float)x3 Y3:(float)y3;
- (void)rcurvetoWithDX1:(float)dx1 DY1:(float)dy1 DX2:(float)dx2 DY2:(float)dy2 DX3:(float)dx3 DY3:(float)dy3;
- (void)arcWithX:(float)x Y:(float)y Radius:(float)r Angle1:(float)ang1 Angle2:(float)ang2;
- (void)arcnWithX:(float)x Y:(float)y Radius:(float)r Angle1:(float)ang1 Angle2:(float)ang2;
- (void)arctWithX1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2 Radius:(float)r;
- (void)closePath;
- (void)addPointWithX:(float)x Y:(float)y;
- (void)addOperation:(int)op;
- (void)addOperation:(int)op X:(float)x Y:(float)y;
- (void)checkBBoxWithX:(float)x Y:(float)y;

@end
