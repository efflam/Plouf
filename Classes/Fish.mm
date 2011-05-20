//
//  Fish.m
//  ProtoMesh2
//
//  Created by Efflam on 19/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Fish.h"
#import "RectSensor.h"

@implementation Fish

#pragma mark Physics Accessors

@synthesize body;
@synthesize bodyDef;
@synthesize shapeDef;
@synthesize fixtureDef;

#pragma mark View Accessors

@synthesize sprite;
@synthesize  delegate, bubblePoint, bubbleSprite, name;

#pragma mark Object Methods

- (void)dealloc
{
	delete bodyDef;
	delete shapeDef;
    delete fixtureDef;
	[self setBody:nil];
	[self setBodyDef:nil];
	[self setShapeDef:nil];
    [self setFixtureDef:nil];
	[self setSprite:nil];
	[super dealloc];
}

-(id)initWithFishName:(NSString*)fishName andPosition:(CGPoint)position
{
    self = [super init];
    
    if(self)
    {
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        
        self.name = fishName;
        
        self.bodyDef = new b2BodyDef;
        self.bodyDef->type = b2_dynamicBody;
        self.bodyDef->angularDamping = 40.0f;
        self.bodyDef->linearDamping = 5.0f;
        self.bodyDef->position.Set(position.x/PTM_RATIO,  position.y/PTM_RATIO);
            
        self.shapeDef = new b2CircleShape;
        self.shapeDef->m_radius = 1.0f;
        
        self.fixtureDef = new b2FixtureDef;
        self.fixtureDef->shape = self.shapeDef;	
        self.fixtureDef->density = 1.0f;
        self.fixtureDef->friction = 0.1f;
        self.fixtureDef->restitution = 0.1f;
        //[self scheduleUpdate];
    }
    
    return self;
}

+(id)fishWithName:(NSString*)fishName andPosition:(CGPoint)position
{
    return [[[Fish alloc] initWithFishName:fishName andPosition:position] autorelease];
}


#pragma mark Event Methods

- (void)actorDidAppear 
{	
	[super actorDidAppear];
    
    self.bubbleSprite = [BubbleSprite spriteWithFile:[NSString stringWithFormat:@"%@Bubble.png",self.name]];
    self.bubbleSprite.target = self;
    [self bodyDef]->userData = self;
	[self setBody:[self world]->CreateBody([self bodyDef])];
	[self fixtureDef]->shape = [self shapeDef];
    [self body]->CreateFixture([self fixtureDef]);

    self.sprite = [FishAnimated fishWithName:self.name];
	[[self scene] addChild:self.sprite];
}


- (void)actorWillDisappear 
{
	[self body]->SetUserData(nil);
	[self world]->DestroyBody([self body]);
	[self setBody:nil];
	[[self scene] removeChild:[self sprite] cleanup:NO];
    [self setSprite:nil];
	[super actorWillDisappear]; 
}


- (void)worldDidStep 
{
	[super worldDidStep];
    
    [[self sprite] setPosition:ccp(WORLD_TO_SCREEN([self body]->GetPosition().x), WORLD_TO_SCREEN([self body]->GetPosition().y))];
    [[self sprite] setRotation: -1 * RADIANS_TO_DEGREES([self body]->GetAngle())];
    
    b2Vec2 gravity = self.world->GetGravity();
    b2Vec2 antiGravity = b2Vec2(-gravity.x, -gravity.y);
    
    b2Vec2 f = b2Vec2(antiGravity.x, antiGravity.y);
    f*= self.body->GetMass();
    self.body->ApplyForce(f, self.body->GetWorldCenter());
    
    float angleInRad = self.body->GetAngle();
    float angleInDeg = -1 * CC_RADIANS_TO_DEGREES(angleInRad);
    BOOL flip = YES;
    if(cosf(angleInRad) < 0)
    {
        angleInDeg -= 180;
        flip = NO;
    }
    
    [[self sprite] setPosition:ccp(WORLD_TO_SCREEN([self body]->GetPosition().x), WORLD_TO_SCREEN([self body]->GetPosition().y))];
    [[self sprite] setRotation: angleInDeg];
    [[self sprite] setFlipX:flip];
    

    CGPoint posForLevel = self.sprite.position;
    posForLevel.x = 2000 - posForLevel.x + SCREEN_CENTER.x;
    posForLevel.y = 2000 - posForLevel.y + SCREEN_CENTER.y;
    
    CGPoint posForCamera = ccpSub([[Camera standardCamera] position], posForLevel);
    float bubbleHalfSize = self.bubbleSprite.contentSize.width * 0.5;
    //bubbleHalfSize = 0;
    float bubblePadding = 13;
    float bubbleOffset = bubbleHalfSize - bubblePadding;
    
    
    
    if(fabsf(posForCamera.x)-60 > SCREEN_CENTER.x || fabsf(posForCamera.y)-60 > SCREEN_CENTER.y)
    {
        float angle = atan2f(posForCamera.y, posForCamera.x);
        
        // CCLOG(@"angle = %f", angle);
        
        CGPoint circlePoint = ccp(CAM_RADIUS*cosf(angle),CAM_RADIUS*sinf(angle));
        CGPoint bubblePointForCam = ccp(fminf(SCREEN_CENTER.x - bubbleOffset, fmaxf(-SCREEN_CENTER.x + bubbleOffset, circlePoint.x)),fminf(SCREEN_CENTER.y - bubbleOffset, fmaxf(-SCREEN_CENTER.y + bubbleOffset, circlePoint.y)));
        
        //        NSLog(@"Bubble Point For Cam : %@",NSStringFromCGPoint(bubblePointForCam));
        
        self.bubblePoint = ccp(SCREEN_CENTER.x + bubblePointForCam.x, SCREEN_CENTER.y + bubblePointForCam.y);
        
        if(self.sprite.visible) 
        {
            self.sprite.visible = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showMe" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"trackMe" object:self];
        }
        
        //NSLog(@"radius : %f / angle : %f / bubble point : %@",radius,angle,NSStringFromCGPoint(bubblePoint));
        
    }
    else if(!self.sprite.visible)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unTrackMe" object:self];
        self.sprite.visible = YES;
    }

	
}

-(void)swimTo:(CGPoint)destination
{
    b2Vec2 tchPos = b2Vec2(SCREEN_TO_WORLD(destination.x), SCREEN_TO_WORLD(destination.y));
    b2Vec2 fishPos = self.body->GetPosition();
    b2Vec2 fishToTch = tchPos - fishPos;
    fishToTch.Normalize();
    
    float maxSpeed = 700;
    
    b2Vec2 desiredVelocity = b2Vec2(fishToTch.x, fishToTch.y);
    desiredVelocity *=  maxSpeed;
    
    b2Vec2 steeringForce = desiredVelocity - self.body->GetLinearVelocity();
    steeringForce *= 1/self.body->GetMass();
    
    b2Vec2 appPtOffset = b2Vec2(15, 0);
    self.body->ApplyForce(steeringForce, self.body->GetWorldPoint(appPtOffset));
}

#pragma mark Physics Accessors


#pragma mark Transform Accessors

- (CGPoint)position
{
	if([self body]) return ccp(WORLD_TO_SCREEN(body->GetPosition().x), WORLD_TO_SCREEN(body->GetPosition().y));
	else return ccp(WORLD_TO_SCREEN(bodyDef->position.x), WORLD_TO_SCREEN(bodyDef->position.y));
}

- (void)setPosition:(CGPoint)aPosition
{
    //CCLOG(@"body ? %@", ([self body]));
	//NSAssert(![self body], @"Cannot set position");
	[self bodyDef]->position.Set(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y));
    //[self body]->SetTransform(b2Vec2(SCREEN_TO_WORLD(aPosition.x), SCREEN_TO_WORLD(aPosition.y)), [self body]->GetAngle());
    
}

- (CGFloat)rotation
{
	if([self body]) return RADIANS_TO_DEGREES([self body]->GetAngle());
	else return RADIANS_TO_DEGREES([self bodyDef]->angle);
}

- (void)setRotation:(CGFloat)aRotation
{
	NSAssert(![self body], @"Cannot set rotation");
	[self bodyDef]->angle = DEGREES_TO_RADIANS(aRotation);
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	if (!self.sprite.visible) return NO;
    
    CGPoint fishOrigin = self.sprite.position;
    CGRect rect = CGRectMake(fishOrigin.x - 60, fishOrigin.y - 60, 120, 120);
	Boolean isTouch = CGRectContainsPoint(rect, [self.sprite convertTouchToNodeSpaceAR:touch]);
	return isTouch;
}

- (void)addContact:(Actor *)aContact
{
	[super addContact:aContact]; 
}

-(void)hit
{
    CCLOG(@"aie !");
}


@end
