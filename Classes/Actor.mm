#import "Actor.h"


@interface Actor ()


#pragma mark Contact Properties

@property (nonatomic, retain) NSMutableArray *contactArray;
@property (nonatomic, retain) NSMutableArray *instanceOperationArray;
@property (nonatomic, retain) NSMutableArray *classOperationArray;


@end


@implementation Actor

@synthesize destroyable;

#pragma mark Object Methods

- (void)dealloc {
	[self setContactArray:nil];
    [self setInstanceOperationArray:nil];
    [self setClassOperationArray:nil];
	[self setWorld:nil];
    [scene release];
    [self setScene:nil];
	[super dealloc];
}

- (id)init {
	if((self = [super init]))
    {
        self.destroyable = NO;
		[self setContactArray:[[[NSMutableArray alloc] init] autorelease]];
        [self setInstanceOperationArray:[[[NSMutableArray alloc] init] autorelease]];
        [self setClassOperationArray:[[[NSMutableArray alloc] init] autorelease]];

	}
        return self;
}


#pragma mark Contact Accessors

@synthesize contactArray;
@synthesize instanceOperationArray;
@synthesize classOperationArray;

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
    
    ClassContactOperation *cop;
    count = [[self classOperationArray] count];
    //CCLOG(@"NumClassOP = %d", count);
    for(int i = 0; i < count; i++)
    {
        cop = [[self classOperationArray] objectAtIndex:i];
        //CCLOG( @"class : %@", [cop.actorClass class]);
        if([aContact isKindOfClass:[cop.actorClass class]] && (cop.whenTag == 0 || cop.whenTag == 1))
        { 
            [cop execute];
            if(cop.fireOnce)
                [self removeClassOperation:cop];
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

- (void)addClassOperation:(ClassContactOperation *)aOperation
{
    [[self classOperationArray] addObject:aOperation];
}

- (void)removeClassOperation:(ClassContactOperation *)aOperation
{
    NSUInteger anIndex = [[self classOperationArray] indexOfObject:aOperation];
	if(anIndex != NSNotFound) {
		[[self classOperationArray] removeObjectAtIndex:anIndex];
	}
    
}
- (void)removeAllClassOperations
{
    [[self classOperationArray] removeAllObjects];
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
