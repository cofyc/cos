#import <Cocoa/Cocoa.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/mach_init.h>
#import <mach/mach_interface.h>
#import <mach/mach_port.h>
#import <mach/mach_traps.h>
#import <mach/mach_types.h>
#import <mach/machine.h>
#import <mach/processor_info.h>
#import <mach/shared_region.h>
#import <mach/task.h>
#import <mach/thread_act.h>
#import <mach/time_value.h>
#import <mach/vm_map.h>

@interface COMemoryStats : NSObject {
}

+ (CGFloat)getPercent;

@end
