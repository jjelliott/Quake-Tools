#import "Clipper.h"
#import "qedefs.h"

id clipper_i;

@implementation Clipper

- (instancetype)init
{
    self = [super init];
    if (self) {
        clipper_i = self;
        num = 0;
    }
    return self;
}

- (BOOL)hide
{
    int oldnum = num;
    num = 0;
    return (oldnum > 0);
}

- (void)flipNormal
{
    vec3_t temp;

    if (num == 2)
    {
        VectorCopy(pos[0], temp);
        VectorCopy(pos[1], pos[0]);
        VectorCopy(temp, pos[1]);
    }
    else if (num == 3)
    {
        VectorCopy(pos[0], temp);
        VectorCopy(pos[2], pos[0]);
        VectorCopy(temp, pos[2]);
    }
    else
    {
        NSLog(@"No clip plane");
        NSBeep();
    }
}

- (BOOL)getFace:(face_t *)f
{
    vec3_t v1, v2, norm;
    int i;

    VectorCopy(vec3_origin, plane.normal);
    plane.dist = 0;
    if (num < 2) return NO;

    if (num == 2)
    {
        VectorCopy(pos[0], pos[2]);
        pos[2][2] += 16;
    }

    for (i = 0; i < 3; i++)
        VectorCopy(pos[i], f->planepts[i]);

    VectorSubtract(pos[2], pos[0], v1);
    VectorSubtract(pos[1], pos[0], v2);

    CrossProduct(v1, v2, norm);
    VectorNormalize(norm);

    if (!norm[0] && !norm[1] && !norm[2])
        return NO;

    [texturepalette_i getTextureDef:&f->texture];
    return YES;
}

/*
================
XYClick
================
*/
- (void)XYClick:(NSPoint)pt
{
    int i;
    vec3_t new;

    new[0] = [xyview_i snapToGrid:pt.x];
    new[1] = [xyview_i snapToGrid:pt.y];
    new[2] = [map_i currentMinZ];

    // Check if a point is already there
    for (i = 0; i < num; i++)
    {
        if (new[0] == pos[i][0] && new[1] == pos[i][1])
        {
            if
