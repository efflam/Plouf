//
//  MerciScreen.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 01/06/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "MerciScreen.h"
#import "SimpleAudioEngine.h"

@implementation MerciScreen
@synthesize background;
@synthesize logo;
@synthesize merci;
@synthesize realisation;
@synthesize partenaires;
@synthesize acteurs;
@synthesize classe;
@synthesize gobelins;
@synthesize papillon;
@synthesize labre;

-(void)dealloc
{
    [papillon release];
    [background release];
    [logo release];
    [merci release];
    [realisation release];
    [partenaires release];
    [acteurs release];
    [classe release];
    [gobelins release];
    
    [super dealloc];
}

-(void)onExit
{
    [papillon stopAnimation];
    [labre stopAnimation];
    [super onExit];
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.isTouchEnabled = YES;
        
        // ELEMENTS
        self.background = [CCSprite spriteWithFile:@"merciBackground.png"];
        self.logo = [CCSprite spriteWithFile:@"merciLogo.png"];
        self.merci = [CCSprite spriteWithFile:@"merciMerci.png"];
        self.realisation = [CCSprite spriteWithFile:@"merciRealisation.png"];
        self.partenaires = [CCSprite spriteWithFile:@"merciPartenaires.png"];
        self.acteurs = [CCSprite spriteWithFile:@"merciActeurs.png"];
        self.classe = [CCSprite spriteWithFile:@"merciCRMA.png"];
        self.gobelins = [CCSprite spriteWithFile:@"merciGobelins.png"];
        
        // MENU
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"backButton.png" 
                                                             selectedImage:nil 
                                                                    target:self 
                                                                  selector:@selector(backHandler)];
        CCMenuItemImage *webButton = [CCMenuItemImage itemFromNormalImage:@"webButton.png" 
                                                            selectedImage:nil 
                                                                   target:self 
                                                                 selector:@selector(webHandler)];
        
        CCMenu *menu = [CCMenu menuWithItems:backButton,webButton, nil];
        [backButton setPosition:ccp(-445,-320)];
        [webButton setPosition:ccp(460,-325)];
        
        // ANCHORPOINTS
        [background setAnchorPoint:CGPointZero];
        [logo setAnchorPoint:ccp(0,1)];
        [gobelins setAnchorPoint:ccp(0,0)];
        [realisation setAnchorPoint:ccp(1,1)];
        
        // ANIMATIONS
        self.papillon = [AnimationHelper animationWithName:@"papillon" andOption:@"" frameNumber:9];
        [papillon runAnimation];
        [papillon setPosition:ccp(-100,-100)];
        [papillon setFlipX:YES];
        
        self.labre = [AnimationHelper animationWithName:@"labre" andOption:@"" frameNumber:9];
        [labre runAnimation];
        [labre setPosition:ccp(1200,603)];
        
        merciTouched = 0;
        
        // HIDING
        [merci setOpacity:0];
        
        // INITIAL PLACEMENTS
        [logo setPosition:ccp(0,1000)];
        [merci setPosition:ccp(482,484)];
        [gobelins setPosition:ccp(-10,-400)];
        [realisation setPosition:ccp(1044,1100)];
        [classe setPosition:ccp(545,-400)];
        [acteurs setPosition:ccp(780,-400)];
        [partenaires setPosition:ccp(800,-400)];
        
        // ADD CHILDREN
        [self addChild:background];
        [self addChild:logo];
        [self addChild:papillon];
        [self addChild:realisation];
        [self addChild:labre];
        [self addChild:merci];
        [self addChild:gobelins];
        [self addChild:classe];
        [self addChild:acteurs];
        [self addChild:partenaires];
        [self addChild:menu];
        
        [self moveFish];
                        
    }
    
    return self;
}

-(void)webHandler
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://plouf.gobelins.fr/"]];
}

-(void)backHandler
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];

    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:.5];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPos = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
    float dist = ccpDistance(merci.position, touchPos);
        
    if(dist < 140)
    {      
        merciTouched++;
        if(merciTouched == 3)
        {
            [labre setFlipX:NO];
            [labre runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:4.0 position:ccp(860,603)]]];
        }
        else if(merciTouched == 10)
        {
            [labre setFlipX:YES];
            [labre runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:4.0 position:ccp(1100,603)]]];
            merciTouched = 0;
        }
    }
}

-(void)moveFish
{
    [papillon setPosition:ccp(-100,-100)];
    
    [papillon setRotation:-35];
    [papillon runAction:
     [CCSequence actions:
        [CCDelayTime actionWithDuration:10.0],
        [CCMoveTo actionWithDuration:6.0 position:ccp(1100,700)],
        [CCCallFunc actionWithTarget:self selector:@selector(moveFish)],
      nil]];
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
        
    [logo runAction:
     [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0,768)]]];
    [merci runAction:
     [CCSequence actions:
        [CCDelayTime actionWithDuration:1.0],
        [CCEaseSineInOut actionWithAction:[CCFadeIn actionWithDuration:0.5]],
        nil]];
    [gobelins runAction:
     [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:2.0 position:ccp(-10,80)]]];
    [realisation runAction:
     [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:1.0 position:ccp(1044,798)]]];
    [classe runAction:
     [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:3.0 position:ccp(545,170)]]];
    [acteurs runAction:
     [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:3.0 position:ccp(780,80)]]];
    [partenaires runAction:
     [CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:2.0 position:ccp(800,350)]]];
}

@end
