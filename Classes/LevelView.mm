//
//  LevelView.m
//  ProtoSV-GL
//
//  Created by Clément RUCHETON on 19/04/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "LevelView.h"
#import "ScrollLevelView.h"
#import "BackgroundView.h"
#import "WinMenu.h"
#import "LoseMenu.h"
#import "IndiceSprite.h"

@implementation LevelView
@synthesize menu,pause,scrollView,bubbleView,indice,fishName,stripeName,timer,indiceString,nameString;

-(void)dealloc
{
    NSLog(@"dealloc level");
    
    [[Camera standardCamera] setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unscheduleUpdate];
    [self unschedule:@selector(updateTimer:)];
    
    [[CCTouchDispatcher sharedDispatcher]removeDelegate:scrollView];
    
    [nameString release];
    [indiceString release];
    [fishName release];
    [stripeName release];
    [timer release];
    [indice release];
    [bubbleView release];    
    [menu release];
    [pause release];
    [scrollView release];
    
    [super dealloc];
}

-(void)onExit
{
    [self setIndiceString:nil];
    [self setNameString:nil];
    [self unscheduleUpdate];
    [self unscheduleAllSelectors];
    for(CCNode *node in [self children])
    {
        [node stopAllActions];
    }
    [super onExit];
}

-(id)initWithLevelName:(NSString *)levelName
{
    self = [super init];
    
    if(self)
    {
        CCSpriteFrameCache *frames = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        [frames addSpriteFramesWithFile:@"backgroundGame.plist" 
                                texture:[[CCTextureCache sharedTextureCache] addImage:@"backgroundGame.png"]];
        
        self.pause = [PauseMenu node];
        
        CCSprite *background = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"backgroundGame.png"]];
        [background setAnchorPoint:ccp(0,0)];
        
        CCSprite *pauseSprite = [CCSprite spriteWithSpriteFrame:[frames spriteFrameByName:@"pauseButton.png"]];
        CCMenuItemImage *pauseButton = [CCMenuItemImage itemFromNormalSprite:pauseSprite 
                                                              selectedSprite:nil 
                                                                      target:self 
                                                                    selector:@selector(pauseGame)];
        
        [pauseButton setPosition:ccp(-450,320)];
        
        self.menu = [CCMenu menuWithItems:pauseButton, nil];
        self.scrollView = [ScrollLevelView levelWithName:levelName];
        self.bubbleView = [BubbleView node];
        self.indice = [CCLabelBMFont labelWithString:@"indice test" fntFile:@"ChildsplayShadowed.fnt"];
        [indice setOpacity:0];
        [indice setAnchorPoint:ccp(0.5,0)];
        [indice setPosition:ccp(SCREEN_CENTER.x,100)];
        
        self.timer = [CCLabelBMFont labelWithString:@"00:00" fntFile:@"ChildsplayShadowed.fnt"];
        [timer setAnchorPoint:ccp(0,0)];
        [timer setPosition:ccpSub(ccpMult(SCREEN_CENTER, 2),ccp(110,50))];
        
        secondTimer = 0;
        
        self.stripeName = [CCSprite spriteWithFile:@"fishNameStripe.png"];
        self.fishName = [CCLabelBMFont labelWithString:@"poisson clown" fntFile:@"ChildsplayShadowed.fnt"];
        [self.stripeName setPosition:ccpSub(SCREEN_CENTER, ccp(0,70))];
        [self.fishName setPosition:ccpSub(SCREEN_CENTER, ccp(0,107))];
        [stripeName setOpacity:0];
        [fishName setOpacity:0];
        
        [self addChild:background];
        [self addChild:scrollView];
        [self addChild:bubbleView];
        [self addChild:menu];
        [self addChild:indice];
        [self addChild:stripeName];
        [self addChild:fishName];
        [self addChild:pause];
        [self addChild:timer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(winHandler:) 
                                                     name:@"win" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(looseHandler:) 
                                                     name:@"loose" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(indiceHandler:) 
                                                     name:@"indiceTouched" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(showName:) 
                                                     name:@"showName" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(hideName:) 
                                                     name:@"hideName" 
                                                   object:nil];
        
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)updateTimer:(ccTime)dt
{
    secondTimer++;
    
    int minutes = floor(secondTimer/60);
    int secondes = secondTimer%60;
    
    NSString *minuteString = (minutes < 10) ? 
    [NSString stringWithFormat:@"0%d",minutes] : [NSString stringWithFormat:@"%d",minutes];
    NSString *secondeString = (secondes < 10) ?
    [NSString stringWithFormat:@"0%d",secondes] : [NSString stringWithFormat:@"%d",secondes];
    
    NSString *timeString = [NSString stringWithFormat:@"%@:%@",minuteString,secondeString];
    
    [self.timer setString:timeString];
}

-(void)hideName:(NSNotification*)notification
{
    [stripeName stopAllActions];
    [fishName stopAllActions];
    
    [stripeName setOpacity:0];
    [fishName setOpacity:0];
}

-(void)showName:(NSNotification*)notification
{
    self.nameString = [(Fish*)[notification object] displayName];
    
    [self hideName:nil];
    
    [stripeName runAction:
     [CCSequence actions:
      [CCFadeIn actionWithDuration:.3],
      [CCDelayTime actionWithDuration:5],
      [CCFadeTo actionWithDuration:.5 opacity:0],nil]];
    
    [fishName runAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:^(void) {
         [fishName setString:self.nameString];
      }],
      [CCFadeIn actionWithDuration:.3],
      [CCDelayTime actionWithDuration:5],
      [CCFadeTo actionWithDuration:.5 opacity:0],
      nil]];
}

-(void)indiceHandler:(NSNotification*)notification
{
    self.indiceString = [(IndiceSprite*)[notification object] indiceDescription];
    
    [indice runAction:
        [CCSequence actions:
            [CCFadeTo actionWithDuration:.2 opacity:0],
            [CCCallBlock actionWithBlock:^(void) {
                [indice setString:self.indiceString];
            }],
            [CCFadeIn actionWithDuration:.3],
            [CCScaleTo actionWithDuration:.1 scale:1.2],
            [CCScaleTo actionWithDuration:.2 scale:1],
            [CCScaleTo actionWithDuration:.1 scale:1.2],
            [CCScaleTo actionWithDuration:.2 scale:1],
            [CCDelayTime actionWithDuration:10.0],
            [CCFadeOut actionWithDuration:.5],nil]];
}

-(void)update:(ccTime)dt
{
    if([self.stripeName opacity] > 0)
    {
        [self.stripeName setPosition:ccpSub([self.scrollView.corridor currentFishPosition], ccp(0,70))];
        [self.fishName setPosition:ccpSub([self.scrollView.corridor currentFishPosition], ccp(0,107))];
    }
    
    [self.scrollView update:dt];
    [self.bubbleView update:dt];
}

-(void)pauseGame
{
    [self unscheduleUpdate];
    [self unschedule:@selector(updateTimer:)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseLevel" object:nil];
    
    [pause setVisible:YES];
    [pause pause:YES];
    [menu setIsTouchEnabled:NO];
    
    [menu runAction:[CCFadeOut actionWithDuration:.5]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(restartHandler) 
                                                 name:@"restartButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(levelMenuHandler) 
                                                 name:@"levelButtonTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(continueHandler) 
                                                 name:@"continueButtonTouched" 
                                               object:nil];
}

-(void)continueHandler
{
    [self scheduleUpdate];
    [self schedule:@selector(updateTimer:) interval:1.0];
    
    [menu setIsTouchEnabled:YES];
    [menu runAction:[CCFadeIn actionWithDuration:.5]];
    [pause pause:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(winHandler:) 
                                                 name:@"win" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(looseHandler:) 
                                                 name:@"loose" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(indiceHandler:) 
                                                 name:@"indiceTouched" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showName:) 
                                                 name:@"showName" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hideName:) 
                                                 name:@"hideName" 
                                               object:nil];
}

-(void)levelMenuHandler
{
    [self unscheduleUpdate];
    [self unschedule:@selector(updateTimer:)];
    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[LevelMenu node]];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
}

-(void)restartHandler
{
    [self unscheduleUpdate];
    [self unschedule:@selector(updateTimer:)];
    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[Loader node]];
        
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void)onEnterTransitionDidFinish
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCDirector sharedDirector] purgeCachedData];
    
    [stripeName stopAllActions];
    [fishName stopAllActions];
    
    [stripeName runAction:
     [CCSequence actions:
      [CCFadeIn actionWithDuration:.3],
      [CCDelayTime actionWithDuration:5],
      [CCFadeTo actionWithDuration:.5 opacity:0],nil]];
    
    [fishName runAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:^(void) {
         [fishName setString:@"Poisson Clown"];
      }],
      [CCFadeIn actionWithDuration:.3],
      [CCDelayTime actionWithDuration:5],
      [CCFadeTo actionWithDuration:.5 opacity:0],
      nil]];
    
    [pause setOpacity:0];
    
    [self schedule:@selector(updateTimer:) interval:1.0];
    
    [super onEnterTransitionDidFinish];
}

+(id)levelWithName:(NSString *)levelName
{
    return [[[LevelView alloc] initWithLevelName:levelName] autorelease];
}

-(void)winHandler:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseLevel" object:nil];
    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[WinMenu winWithTime:180 sacrifices:0 indices:1]];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}


-(void)looseHandler:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseLevel" object:nil];
    
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    CCScene *scene = [CCScene node];
    [scene addChild:[LoseMenu node]];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}


@end
