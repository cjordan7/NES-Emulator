//
//  Queue.m
//  NESEmulator
//
//  Created by Cosme Jordan on 28.08.21.
//

#import "Queue.h"


struct Node;

typedef struct {
    struct Node* next;
    id element;

} Node;

@interface Queue() {
    Node* tail;
    Node* head;
    uint32_t size;
}

@end

@implementation Queue

- (instancetype)init {
    if(self = [super init]) {
        tail = malloc(sizeof(Node));
        head = malloc(sizeof(Node));
    }

    return self;
}

- (void)dealloc {
    Node* temp = tail;
    while(!temp) {
        
    }
}

- (void)push:(id)element {

}

- (id)pop {
    return nil;
}

- (uint32_t)size {
    return size;
}

@end
