#import "Actor.h"


@interface Actor ()


#pragma mark Contact Properties

@property (nonatomic, retain) NSMutableArray *contactArray;
@property (nonatomic, retain) NSMutableArray *instanceOperationArray;


@end





@implementation Actor


#pragma mark Object Methods

- (void)dealloc {
	[self setContactArray:nil];
	[self setWorld:nil];
    [self setScene:nil];
	[super dealloc];
}

- (id)init {
	if((self = [super init]))
    {
		[self setContactArray:[[[NSMutableArray alloc] init] autorelease]];
        [self setInstanceOperationArray:[[[NSMutableArray alloc] init] autorelease]];

	}
        return self;
}


#pragma mark Contact Accessors

@synthesize contactArray;
@synthesize instanceOperationArray;

- (NSSet *)contactSet {
	return [NSSet setWithArray:[self contactArray]];
}


#pragma mark Contact Methods

- (void)addContact:(Actor *)aContact {
	[[self contactArray] addObject:aContact];
    int count = [[self instanceOperationArray] count];
    InstanceContactOperation *op;
    for(int i = 0; i < count; i++)
    {
        op = [[self instanceOperationArray] objectAtIndex:i];
        if(op.actor == aContact && (op.whenTag == 0 || op.whenTag == 1))
        {
            [op execute];
            if(op.fireOnce)
                [self removeInstanceOperation:op];
        }
    }
}

- (void)removeContact:(Actor *)aContact {
	NSUInteger anIndex = [[self contactArray] indexOfObject:aContact];
	if(anIndex != NSNotFound) {
		[[self contactArray] removeObjectAtIndex:anIndex];
	}
    int count = [[self instanceOperationArray] count];
    InstanceContactOperation *op;
    for(int i = 0; i < count; i++)
    {
        op = [[self instanceOperationArray] objectAtIndex:i];
        if(op.actor == aContact && (op.whenTag == 0 || op.whenTag == 2))
        {
            [op execute];
            if(op.fireOnce)
                [self removeInstanceOperation:op];
        }
    }

}

- (void)removeAllContacts {
	[[self contactArray] removeAllObjects];
}


- (void)addInstanceOperation:(InstanceContactOperation *)aOperation
{
    [[self instanceOperationArray] addObject:aOperation];
}

- (void)removeInstanceOperation:(InstanceContactOperation *)aOperation
{
    NSUInteger anIndex = [[self instanceOperationArray] indexOfObject:aOperation];
	if(anIndex != NSNotFound) {
		[[self instanceOperationArray] removeObjectAtIndex:anIndex];
	}

}
- (void)removeAllInstanceOperations
{
    [[self instanceOperationArray] removeAllObjects];
}

#pragma mark Event Methods

- (void)actorDidAppear {
	
}

- (void)actorWillDisappear {
	
}

- (void)worldDidStep {
	
}


#pragma mark Game Accessors

@synthesize world;
@synthesize scene;


@end
