//
//  ExtraInfo.m
//

#import "DeviceInfo.h"

@implementation DeviceInfo

@synthesize apps;
@synthesize type;
@synthesize guid;
@synthesize user;
@synthesize role;
@synthesize token;
@synthesize model;
@synthesize number;
@synthesize carrier;
@synthesize version;
@synthesize osVersion;
@synthesize imei;
@synthesize build;
@synthesize manufacturer;
@synthesize deviceStatus;
@synthesize simpleStatus;

- (id) init
{
    @try
    {
        if (self = [super init])
        {
            [self setDeviceStatus : NO]; // 디바이스 등록 상태 (로그인 정보가 확인되면 한번 등록함, upsert 처리요)
            [self setSimpleStatus : NO]; // 간편 로그인 등록 상태 (로그인 정보가 확인되면 한번 등록함, upsert 처리요)
            [self setApps: APPS_VALUE];
            [self setType: TYPE_VALUE];
            [self setGuid: @""];
            [self setUser: @""];
            [self setRole: @""];
            [self setToken: @""];
            [self setModel: @""];
            [self setNumber: @""];
            [self setCarrier: @""];
            [self setVersion: @""];
            [self setOsVersion: @""];
            [self setImei: @""];
            [self setBuild: @""];
            [self setManufacturer: @"Apple"];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
    
	return self;
}

- (void) dump
{
    [Allo i: @"dump @%@", [[self class] description]];

    @try
    {
        [Allo i: @"info => [%@][%@][%@][%@][%@][%@][%@][%@][%@][%@][%@][%@][%@][%@]",
                [self apps],
                [self type],
                [self guid],
                [self user],
                [self role],
                [self token],
                [self model],
                [self number],
                [self carrier],
                [self version],
                [self osVersion],
                [self imei],
                [self build],
                [self manufacturer]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

@end
