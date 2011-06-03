//
//  WinMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 31/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "WinMenu.h"
#import "LevelMenu.h"
#import "Loader.h"
#import "FishMenu.h"

@implementation WinMenu
@synthesize animatedObjects;

-(void)dealloc
{
    for(CCNode *child in animatedObjects)
    {
        [child stopAllActions];
    }
    
    [animatedObjects release];
    [super dealloc];
}

-(void)onExit
{
    for(CCNode *child in animatedObjects)
    {
        [child stopAllActions];
    }
    
    [super onExit];
}

+(id)winWithTime:(int)t sacrifices:(int)s indices:(int)i
{
    return [[[WinMenu alloc] initWithTime:t sacrifices:s indices:i] autorelease];
}

-(id)initWithTime:(int)t sacrifices:(int)s indices:(int)i
{
    self = [super init];
    
    if(self)
    {
        // ASSETS
        self.animatedObjects = [NSMutableArray array];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"winScreen.plist" 
                                                                 textureFile:@"winScreen.png"];
        
        // MENU
        
        CCMenuItemImage *levelButton = [CCMenuItemImage itemFromNormalSprite:
                                        [CCSprite spriteWithSpriteFrameName:@"levelButton.png"]
                                                              selectedSprite:nil
                                                                      target:self 
                                                                   selector:@selector(levelHandler)];
        
        CCMenuItemImage *restartButton = [CCMenuItemImage itemFromNormalSprite:
                                          [CCSprite spriteWithSpriteFrameName:@"restartButton.png"]
                                                              selectedSprite:nil target:self 
                                                                   selector:@selector(restartHandler)];
        
        CCMenuItemImage *fishButton = [CCMenuItemImage itemFromNormalSprite:
                                       [CCSprite spriteWithSpriteFrameName:@"winNewFish.png"]
                                                              selectedSprite:nil target:self 
                                                                   selector:@selector(fishHandler)];
        
        CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalSprite:
                                       [CCSprite spriteWithSpriteFrameName:@"playButton.png"]
                                                              selectedSprite:nil target:self 
                                                                   selector:@selector(playHandler)];
        
        CCMenu *menu = [CCMenu menuWithItems:levelButton,restartButton,fishButton,playButton, nil];
        [menu setAnchorPoint:CGPointZero];
        [levelButton setAnchorPoint:CGPointZero];
        [restartButton setAnchorPoint:CGPointZero];
        [fishButton setAnchorPoint:ccp(1,1)];
        [playButton setAnchorPoint:ccp(1,0)];
        
        [menu setPosition:CGPointZero];
        [restartButton setPosition:ccp(120,0)];
        [fishButton setPosition:ccp(1024,700)];
        [playButton setPosition:ccp(SCREEN_CENTER.x*2,10)];
        
        // NON INTERACTIVE ITEMS
        
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"winBackground.png"];
        CCSprite *time = [CCSprite spriteWithSpriteFrameName:@"winTime.png"];
        CCSprite *sacrifice = [CCSprite spriteWithSpriteFrameName:@"winSacrifice.png"];
        CCSprite *indice = [CCSprite spriteWithSpriteFrameName:@"winIndice.png"];
        
        [background setAnchorPoint:CGPointZero];
        [time setAnchorPoint:CGPointZero];
        [sacrifice setAnchorPoint:CGPointZero];
        [indice setAnchorPoint:CGPointZero];
        
        [time setPosition:ccp(20,580)];
        [sacrifice setPosition:ccp(20,460)];
        [indice setPosition:ccp(20,320)];
        
        // LEGENDES
        
        int minutes = floor(t/60);
        int secondes = t%60;
        
        NSString *minuteString = (minutes < 10) ? 
            [NSString stringWithFormat:@"0%d",minutes] : [NSString stringWithFormat:@"%d",minutes];
        NSString *secondeString = (secondes < 10) ?
            [NSString stringWithFormat:@"0%d",secondes] : [NSString stringWithFormat:@"%d",secondes];
        
        NSString *timeString = [NSString stringWithFormat:@"%@:%@",minuteString,secondeString];
        NSString *sacString = [NSString stringWithFormat:@"x %d",s];
        NSString *indiceString = [NSString stringWithFormat:@"x %d",i];
        
        CCLabelBMFont *timeLabel = [CCLabelBMFont labelWithString:timeString fntFile:@"ChildsplayDarkBlue.fnt"];
        CCLabelBMFont *sacLabel = [CCLabelBMFont labelWithString:sacString fntFile:@"ChildsplayDarkBlue.fnt"];
        CCLabelBMFont *indiceLabel = [CCLabelBMFont labelWithString:indiceString fntFile:@"ChildsplayDarkBlue.fnt"];
        
        [timeLabel setAnchorPoint:CGPointZero];
        [sacLabel setAnchorPoint:CGPointZero];
        [indiceLabel setAnchorPoint:CGPointZero];
        
        [timeLabel setPosition:ccpAdd(time.position,ccp(75,15))];
        [sacLabel setPosition:ccpAdd(sacrifice.position,ccp(100,15))];
        [indiceLabel setPosition:ccpAdd(indice.position,ccp(100,40))];
        
        // DESCRIPTIONS
        
        CCLabelBMFont *timeDesc = [CCLabelBMFont labelWithString:@"Temps de livraison" 
                                                         fntFile:@"childsplay.fnt"];
        CCLabelBMFont *sacDesc = [CCLabelBMFont labelWithString:@"Livreurs perdus" 
                                                        fntFile:@"childsplay.fnt"];
        CCLabelBMFont *indiceDesc = [CCLabelBMFont labelWithString:@"Indices utilisés" 
                                                           fntFile:@"childsplay.fnt"];
        
        [timeDesc setAnchorPoint:CGPointZero];
        [sacDesc setAnchorPoint:CGPointZero];
        [indiceDesc setAnchorPoint:CGPointZero];
        
        [timeDesc setScale:.7];
        [sacDesc setScale:.7];
        [indiceDesc setScale:.7];
        
        [timeDesc setPosition:ccpAdd(time.position,ccp(0,-30))];
        [sacDesc setPosition:ccpAdd(sacrifice.position,ccp(0,-25))];
        [indiceDesc setPosition:ccpAdd(indice.position,ccp(0,-5))];
        
        CCLabelBMFont *levelDesc = [CCLabelBMFont labelWithString:@"Le colis a été livré\nen un temps record !" 
                                                          fntFile:@"childsplay.fnt"];
        
        NSString *cheerString = @"Essaie de ménager\nton équipe\nla prochaine fois !";
        
        if(i == 0 & s == 0)
        {
            cheerString = @"Essaie de le battre\nla prochaine fois !";
        }
        else if(i > s)
        {
            cheerString = @"Essaie d'utiliser\nmoins d'indices\nla prochaine fois !";
        }
        
        [levelDesc setString:[NSString stringWithFormat:@"%@\n%@",[levelDesc string],cheerString]]; 
        
        [levelDesc setAnchorPoint:ccp(1,1)];
        [levelDesc setScale:.8];
        [levelDesc setPosition:ccp(1010,480)];
        
        // ADDCHILDREN
        
        [self addChild:background];
        
        [self addChild:menu];
        
        [self addChild:time];
        [self addChild:sacrifice];
        [self addChild:indice];
        
        [self addChild:timeLabel];
        [self addChild:sacLabel];
        [self addChild:indiceLabel];
        
        [self addChild:timeDesc];
        [self addChild:sacDesc];
        [self addChild:indiceDesc];
        
        [self addChild:levelDesc];
        
        // ACTIONS
        [self.animatedObjects addObject:fishButton];
        [self loopAnimation];
    }
    
    return self;
}

-(void)loopAnimation
{
    for(CCNode *object in self.animatedObjects)
    {
        [object runAction:
         [CCSequence actions:
          [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.7 scale:.97]],
          [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.7 scale:1]],
          [CCCallBlock actionWithBlock:^(void) {
             [self loopAnimation];
         }], nil]];
    }
}

-(void)levelHandler
{    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[LevelMenu node]];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
}

-(void)restartHandler
{    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[Loader node]];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)fishHandler
{
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[FishMenu node]];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
}

-(void)playHandler
{
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[Loader node]];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}

@end
