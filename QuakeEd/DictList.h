
#import <AppKit/AppKit.h>

@interface DictList:NSMutableArray
{
}

- initListFromFile:(FILE *)fp;
- writeListFile:(char *)filename;
- (id) findDictKeyword:(char *)key;

@end
