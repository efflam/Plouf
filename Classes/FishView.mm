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
@synthesize fishBody, fishSprite, world, delegate, bubblePoint, bubbleSprite;

-(id)initWithFishName:(NSString*)fishName andWorld:(b2World*)aWorld andPosition:(CGPoint)position
{
    self = [super init];
    
    if(self)
    {
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
        
        self.world = aWorld;
        self.fishSprite = [FishAnimated fishWithName:fishName];
        self.bubbleSprite = [BubbleSprite spriteWithFile:[NSString stringWithFormat:@"%@Bubble.png",fishName]];
        self.bubbleSprite.target = self;
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
    
    [fishSprite setPosition:CGPointMake(fishBody->GetPosition().x * PTM_RATIO, fishBody->GetPosition().y * PTM_RATIO)];
    
    //NSLog(@"Camera Position : %@",NSStringFromCGPoint([[Camera standardCamera] position]));
    CGPoint posForLevel = fishSprite.position;
    posForLevel.x = 2000 - posForLevel.x + SCREEN_CENTER.x;
    posForLevel.y = 2000 - posForLevel.y + SCREEN_CENTER.y;
    
    CGPoint posForCamera = ccpSub([[Camera standardCamera] position], posForLevel);
    float bubbleHalfSize = self.bubbleSprite.contentSize.width * 0.5;
    //bubbleHalfSize = 0;
    float bubblePadding = 13;
    float bubbleOffset = bubbleHalfSize - bubblePadding;
    
       //float anchorX =  
    
    
    if(fabsf(posForCamera.x)-60 > SCREEN_CENTER.x || fabsf(posForCamera.y)-60 > SCREEN_CENTER.y)
    {
        float angle = atan2f(posForCamera.y, posForCamera.x);
        
       // CCLOG(@"angle = %f", angle);
        
        CGPoint circlePoint = ccp(CAM_RADIUS*cosf(angle),CAM_RADIUS*sinf(angle));
        CGPoint bubblePointForCam = ccp(fminf(SCREEN_CENTER.x - bubbleOffset, fmaxf(-SCREEN_CENTER.x + bubbleOffset, circlePoint.x)),fminf(SCREEN_CENTER.y - bubbleOffset, fmaxf(-SCREEN_CENTER.y + bubbleOffset, circlePoint.y)));
        
//        NSLog(@"Bubble Point For Cam : %@",NSStringFromCGPoint(bubblePointForCam));
        
        self.bubblePoint = ccp(SCREEN_CENTER.x + bubblePointForCam.x, SCREEN_CENTER.y + bubblePointForCam.y);
        
        if(self.visible) 
        {
            self.visible = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showMe" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"trackMe" object:self];
        }
        
        //NSLog(@"radius : %f / angle : %f / bubble point : %@",radius,angle,NSStringFromCGPoint(bubblePoint));
        
    }
    else if(!self.visible)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unTrackMe" object:self];
        self.visible = YES;
    }
}

@end
