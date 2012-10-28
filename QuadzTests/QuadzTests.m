//
//  QuadzTests.m
//  QuadzTests
//
//  Created by Dirk Zimmermann on 10/26/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadzTests.h"

#import "Quad.h"
#import "PodArray.h"

@implementation QuadzTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSimplePodArray
{
    PodArray *pods = [[PodArray alloc] initWithElementSize:sizeof(Quad)];
    for (int i = 0; i < 100; ++i) {
        STAssertTrue(pods.count == i, @"wrong pods count %d at step %d", pods.count, i);
        uint8_t color[] = { i, i, i, i };
        Quad quad = QuadWithColor(i, i, i, i, color);
        [pods addElement:&quad];
    }
    for (int i = 0; i < 100; ++i) {
        Quad *tmpquad = [pods elementAt:i];
        Quad quad = *tmpquad;
        STAssertTrue(quad.position[0] == i, @"expected quad.position[0] to be %d", i);
        STAssertTrue(quad.color[3] == i, @"expected quad.color[3] to be %d", i);
    }
}

@end
