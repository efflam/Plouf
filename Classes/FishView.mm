//
//  FishView.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 04/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "FishView.h"
#import "Box2D.h"

@implementation FishView
@synthesize fishBody, fishSprite, world, delegate;

-(id)initWithFishName:(NSString*)fishName andWorld:(b2World*)aWorld andPosition:(CGPoint)position
{
    self = [super init];
    
    if(self)
    {
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        
        self.world = aWorld;
        self.fishSprite = [FishAnimated fishWithName:@"clown"];
        //
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.angularDamping = 40.0f;
        bodyDef.linearDamping = 5.0f;
        bodyDef.position.Set(position.x/PTM_RATIO,  position.y/PTM_RATIO);
        bodyDef.userData = fishSprite;
        self.fishBody = self.world->CreateBody(&bodyDef);
        b2CircleShape circle;
        // circle.m_p.Set(1.0f, 2.0f, 3.0f);
        circle.m_radius = 1.0f;
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &circle;	
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.1f;
        fixtureDef.restitution = 0.1f;
        fishBody->CreateFixture(&fixtureDef);
        
        [self addChild:fishSprite];
        [self scheduleUpdate];
    }
    
    return self;
}

+(id)fishWithName:(NSString*)fishName andWorld:(b2World*)aWorld andPosition:(CGPoint)position
{
    return [[[FishView alloc] initWithFishName:fishName andWorld:aWorld andPosition:position] autorelease];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if([self containsTouchLocation:touch]) [self.delegate setSelectedFish:self];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	if (![self visible]) return NO;
        
    CGPoint fishOrigin = self.fishSprite.position;
    CGRect rect = CGRectMake(fishOrigin.x - 60, fishOrigin.y - 60, 120, 120);
	Boolean isTouch = CGRectContainsPoint(rect, [self convertTouchToNodeSpaceAR:touch]);
	return isTouch;
}

-(void)setPosition:(CGPoint)position
{
    b2Vec2 tchPos = b2Vec2(position.x / PTM_RATIO, position.y / PTM_RATIO);
    b2Vec2 fishPos = fishBody->GetPosition();
    b2Vec2 fishToTch = tchPos - fishPos;
    fishToTch.Normalize();
    float maxSpeed = 700;
    
    b2Vec2 desiredVelocity = b2Vec2(fishToTch.x, fishToTch.y);
    desiredVelocity *=  maxSpeed;
    b2Vec2 steeringForce = desiredVelocity - fishBody->GetLinearVelocity();
    steeringForce *= 1/fishBody->GetMass();
    
    b2Vec2 appPtOffset = b2Vec2(15, 0);
    fishBody->ApplyForce(steeringForce, fishBody->GetWorldPoint(appPtOffset));
        
    float angleInRad = fishBody->GetAngle();
    float angleInDeg = -1 * CC_RADIANS_TO_DEGREES(angleInRad);
    BOOL flip = YES;
    if(cosf(angleInRad) < 0)
    {
        angleInDeg -= 180;
        flip = NO;
    }
    
    [fishSprite setFlipX:flip];
    [fishSprite setRotation:angleInDeg];
}

-(void)update:(ccTime) dt
{        
    // ANTI GRAVITY
    b2Vec2 gravity = world->GetGravity();
    b2Vec2 antiGravity = b2Vec2(-gravity.x, -gravity.y);
    
    b2Vec2 f = b2Vec2(antiGravity.x, antiGravity.y);
    f*= fishBody->GetMass();
    fishBody->ApplyForce(f, fishBody->GetWorldCenter());
    
    //
    [fishSprite setPosition:CGPointMake(fishBody->GetPosition().x * PTM_RATIO, fishBody->GetPosition().y * PTM_RATIO)];

}

@end
