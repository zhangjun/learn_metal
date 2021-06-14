#import "handler_wrapper.h"
#import "handler.h"

@interface HandlerWrapper()
@property Handler *handlerItem;
@end

@implementation HandlerWrapper
- (instancetype) initWithName: (NSString*)name {
	if(self = [super init]) {
		self.handlerItem = new Handler(std::string([name cStringUsingEncoding:NSUTF8StringEncoding]));
	}
	return self;
}
- (NSString *) getName {
    return [NSString
			stringWithUTF8String:self.handlerItem -> name().c_str()];

    // Handler handler;
    // std::string name = handler.name();
    // return [NSString
    //         stringWithCString:name.c_str()
    //         encoding:NSUTF8StringEncoding];
}

- (void)setName:(NSString*)name {
	self.handlerItem->set_name(std::string([name cStringUsingEncoding:NSUTF8StringEncoding]));
}
@end
