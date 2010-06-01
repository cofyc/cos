#import "COUtility.h"


@implementation COUtility

+ (double)round:(double)number withPrecision:(unsigned int)precision
{
    unsigned int _helper_num = pow(10, precision);
    return round(number * _helper_num) / _helper_num;
}

@end