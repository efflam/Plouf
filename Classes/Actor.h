#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"
#import "InstanceContactOperation.h"
#import "ClassContactOperation.h"

@class InstanceContactOperation;

@interface Actor : NSObject 
{
	NSMutableArray *contactArray;
    NSMutableArray *instanceOperationArray;
    NSMutableArray *classOperationArray;
	b2World *world;
    CCNode *scene;
}


#pragma mark Contact Properties

@property (nonatomic, readonly) NSSet *contactSet;


#pragma mark Contact Methods

- (void)addContact:(Actor *)aContact;

- (void)removeContact:(Actor *)aContact;

- (void)removeAllContacts;

- (void)addInstanceOperation:(InstanceContactOperation *)aOperation;

- (void)removeInstanceOperation:(InstanceContactOperation *)aOperation;

- (void)removeAllInstanceOperations;

- (void)addClassOperation:(ClassContactOperation *)aOperation;

- (void)removeClassOperation:(ClassContactOperation *)aOperation;

- (void)removeAllClassOperations;


#pragma mark Event Methods

- (void)actorDidAppear;

- (void)actorWillDisappear;

- (void)worldDidStep;


#pragma mark Game Properties

@property (nonatomic, assign) b2World *world;
@property (nonatomic, retain) CCNode *scene;


@end
