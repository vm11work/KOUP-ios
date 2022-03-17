//
//  AlloData.m
//

#import "AlloData.h"

@implementation AlloData

@synthesize name;
@synthesize version;
@synthesize receivedData;
@synthesize receivedDone;

- (id) init
{
    @try
    {
        if (self = [super init])
        {
            [self setName: CUSERAGENT];
            [self setVersion: CVERSION];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

	return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    [Allo i: @"connection / willSendRequest / redirectResponse @%@", [[self class] description]];

    return request;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [Allo i: @"connection / didSendBodyData / totalBytesWritten / totalBytesExpectedToWrite @%@", [[self class] description]];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [Allo i: @"connection / didReceiveResponse @%@", [[self class] description]];

    @try
    {
        [receivedData setLength: 0];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [Allo i: @"connection / didReceiveData @%@", [[self class] description]];

    @try
    {
        [receivedData appendData:data];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [Allo i: @"connection / didFailWithError @%@", [[self class] description]];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [Allo i: @"connectionDidFinishLoading @%@", [[self class] description]];

    @try
    {
        receivedDone = YES;
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (NSData*) get: (NSString*) url
{
    [Allo i: @"get [%@] @%@", url, [[self class] description]];

    @try
    {
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
        [request setValue: [self name] forHTTPHeaderField: @"User-Agent"];

        NSURLConnection* client = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
        if (client)
        {
            receivedDone = NO;
            receivedData = [NSMutableData data];
            do
            {
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
                [NSThread sleepForTimeInterval: (NSTimeInterval) CSLEEPINTERVAL];
            }
            while (!receivedDone);
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
    
    return receivedData;
}

// json posting
- (NSData*) post: (NSString*) url json: (NSString*) json;
{
    [Allo i: @"post [%@] @%@", url, [[self class] description]];

    @try
    {
        NSData* data = [json dataUsingEncoding: NSUTF8StringEncoding];
        NSString* contentLength = [NSString stringWithFormat: @"%lu", (unsigned long) [data length]];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
        [request setHTTPMethod :@"POST"];
        [request setValue: [self name] forHTTPHeaderField: @"User-Agent"];
        [request setValue: contentLength forHTTPHeaderField: @"Content-Length"];
        [request setHTTPBody: data];

        NSURLConnection* client = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
        if (client)
        {
            receivedDone = NO;
            receivedData = [NSMutableData data];
            do
            {
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
                [NSThread sleepForTimeInterval: (NSTimeInterval) CSLEEPINTERVAL];
            }
            while (!receivedDone);
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

    return receivedData;
}

// data posting
- (NSData*) post: (NSString*) url data: (NSMutableData*) data;
{
    [Allo i: @"post [%@] @%@", url, [[self class] description]];

    @try
    {
        NSString* BOUNDARY = FORMDATA_BOUNDARY;

        NSString* contentType = [NSString stringWithFormat: @"multipart/form-data; boundary=%@",BOUNDARY];

        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: url]];
        [request setHTTPMethod : @"POST"];
        [request setValue: [self name] forHTTPHeaderField: @"User-Agent"];
        [request addValue: contentType forHTTPHeaderField: @"Content-Type"];

        [request setHTTPBody: data];
        
        NSURLConnection* client = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
        if (client)
        {
            receivedDone = NO;
            receivedData = [NSMutableData data];
            do
            {
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
                [NSThread sleepForTimeInterval: (NSTimeInterval) CSLEEPINTERVAL];
            }
            while (!receivedDone);
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

    return receivedData;
}

@end
