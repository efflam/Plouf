#import <Foundation/Foundation.h>
#import "Box2D.h"

@class CorridorView;

@interface Actor : NSObject {
 @private
	NSMutableArray *contactArray;
	CorridorView *game;
}


#pragma mark Contact Properties

@property (nonatomic, readonly) NSSet *contactSet;


#pragma mark Contact Methods

- (void)addContact:(Actor *)aContact;

- (void)removeContact:(Actor *)aContact;

- (void)removeAllContacts;


#pragma mark Event Methods

- (void)actorDidAppear;

- (void)actorWillDisappear;

- (void)worldDidStep;


#pragma mark Game Properties

@property (nonatomic, retain) CorridorView *game;


@end
