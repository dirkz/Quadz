//
//  QuadzTests.m
//  QuadzTests
//
//  Created by Dirk Zimmermann on 10/26/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "PodArrayTests.h"

#import "Quad.h"
#import "PodArray.h"

@implementation PodArrayTests
{
    PodArray *_pods;
}

- (void)setUp
{
    [super setUp];
    _pods = [[PodArray alloc] initWithElementSize:sizeof(Quad)];
    for (int i = 0; i < 100; ++i) {
        STAssertTrue(_pods.count == i, @"wrong pods count %d at step %d", _pods.count, i);
        uint8_t color[] = { i, i, i, i };
        Quad quad = QuadWithColor(i, i, i, i, color);
        [_pods addElement:&quad];
    }
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testPodArrayAddElementAndElementAt
{
    for (int i = 0; i < _pods.count; ++i) {
        Quad *tmpquad = [_pods elementAt:i];
        Quad quad = *tmpquad;
        STAssertTrue(quad.position[0] == i, @"expected quad.position[0] to be %d", i);
        STAssertTrue(quad.color[3] == i, @"expected quad.color[3] to be %d", i);
    }
}

- (void)testPodArrayRemoveElement
{
    size_t count = _pods.count;
    [_pods removeElementAt:2];
    STAssertTrue(_pods.count == count-1, @"wrong pods count %d after remove (9 expected)", _pods.count);
    Quad *quad = [_pods elementAt:1];
    STAssertTrue(quad->position[0] == 1, @"expected element 1 to have all 1, %d instead", quad->position[0]);
    quad = [_pods elementAt:2];
    STAssertTrue(quad->position[0] == 3, @"expected new element 2 to have all 3, %d instead", quad->position[0]);
    quad = [_pods elementAt:3];
    STAssertTrue(quad->position[0] == 4, @"expected new element 3 to have all 4, %d instead", quad->position[0]);
}

- (void)testPodArrayRemoveAllElements
{
    [_pods removeAllElements];
    STAssertTrue(_pods.count == 0, @"wrong pods count %d after remove all (0 expected)", _pods.count);
}

- (void)testPodArrayReplaceElement
{
    uint8_t color[] = { 66, 66, 66, 66 };
    Quad quad = QuadWithColor(66, 66, 66, 66, color);
    [_pods replaceElementAt:5 withElement:&quad];
    Quad *testQuad = [_pods elementAt:5];
    STAssertTrue(testQuad->position[0] == 66, @"expected replaced element to have all 66, %d instead",
                 testQuad->position[0]);
}

@end
