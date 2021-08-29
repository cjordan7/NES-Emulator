//
//  Queue.m
//  NESEmulator
//
//  Created by Cosme Jordan on 28.08.21.
//

#import "Queue.h"

typedef struct Node {
    struct Node* next;
    int element;
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
        tail = NULL;
        head = NULL;
    }

    return self;
}

- (void)dealloc {
    Node* temp = head;
    while(!temp) {
        Node* next = temp->next;
        free(temp);
        temp = next;
    }
}

- (void)push:(uint32_t)element {
    Node* next = malloc(sizeof(Node));
    fprintf(stderr, "HereBefore\n");
    next->element = element;
    fprintf(stderr, "HereAfter\n");
    if(size) {
        tail->next = next;
    } else {
        head = next;
        tail = next;
    }

    ++size;
}

- (uint32_t)pop {
    if(size == 0) {
        NSLog(@"Problem");
        exit(1);
    }

    --size;
    int element = head->element;
    Node* oldHead = head;
    head = head->next;

    free(oldHead);

    return element;
}

- (uint32_t)size {
    return size;
}

@end
