//
//  PodArray.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/27/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "PodArray.h"

const size_t PodArrayInitialCapacity = 50;

@interface PodArray ()
{
    void *_data;
    size_t _elementSize;
    size_t _capacity;
    size_t _count;
}

@end

@implementation PodArray

- (id)initWithElementSize:(size_t)elementSize
{
    if (self = [super init]) {
        _elementSize = elementSize;
        _capacity = PodArrayInitialCapacity;
        _data = calloc(_elementSize, _capacity);
    }
    return self;
}

- (void)addElement:(const void *)data
{
    if (_count >= _capacity) {
        size_t newCapacity = _capacity * 2;
        _data = realloc(_data, _elementSize * newCapacity);
        _capacity = newCapacity;
    }
    void *target = _data + _count * _elementSize;
    memcpy(target, data, _elementSize);
    _count++;
}

- (void)addElements:(void *)data count:(size_t)count
{
    if (_count >= _capacity - count) {
        size_t newCapacity = _capacity * 2;
        while (_count >= newCapacity - count) {
            newCapacity *= 2;
        }
        _data = realloc(_data, _elementSize * newCapacity);
        _capacity = newCapacity;
    }
    void *target = _data + _count * _elementSize;
    memcpy(target, data, _elementSize * count);
    _count += count;
}

- (void *)elementAt:(size_t)index
{
    return _data + index * _elementSize;
}

- (const void *)elements
{
    return _data;
}

- (void)removeAllElements
{
    _capacity = PodArrayInitialCapacity;
    _data = realloc(_data, _elementSize * _capacity);
    _count = 0;
}

- (void)replaceElementAt:(size_t)index withElement:(const void *)data
{
    void *target = [self elementAt:index];
    memcpy(target, data, _elementSize);
}

- (void)removeElementAt:(size_t)index
{
    if (index != _count - 1) {
        void *target = [self elementAt:index];
        void *source = [self elementAt:index+1];
        size_t numElementsToCopy = _count - 1 - index;
        memcpy(target, source, _elementSize * numElementsToCopy);
    }
    _count--;
}

@end
