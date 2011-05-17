#import "Actor.h"
#import "CorridorView.h"


@interface Actor ()


#pragma mark Contact Properties

@property (nonatomic, retain) NSMutableArray *contactArray;


@end





@implementation Actor


#pragma mark Object Methods

- (void)dealloc {
	[self setContactArray:nil];
	[self setGame:nil];
	[super dealloc];
}

- (id)init {
    
	if((self = [super init]))
    {
		[self setContactArray:[[[NSMutableArray alloc] init] autorelease]];
	}
	return self;
}


#pragma mark Contact Accessors

@synthesize contactArray;

- (NSSet *)contactSet {
	return [NSSet setWithArray:[self contactArray]];
}


#pragma mark Contact Methods

- (void)addContact:(Actor *)aContact {
	[[self contactArray] addObject:aContact];
}

- (void)removeContact:(Actor *)aContact {
	NSUInteger anIndex = [[self contactArray] indexOfObject:aContact];
	if(anIndex != NSNotFound) {
		[[self contactArray] removeObjectAtIndex:anIndex];
	}
}

- (void)removeAllContacts {
	[[self contactArray] removeAllObjects];
}


#pragma mark Event Methods

- (void)actorDidAppear {
	
}

- (void)actorWillDisappear {
	
}

- (void)worldDidStep {
	
}


#pragma mark Game Accessors

@synthesize game;


@end
