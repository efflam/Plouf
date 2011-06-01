//
//  EnvironmentMenu.m
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 26/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "EnvironmentMenu.h"
#import "globals.h"
#import "FishMenu.h"

@implementation EnvironmentMenu
@synthesize environments;
@synthesize bubblesHolder;
@synthesize currentBubbleIndex;
@synthesize origin;
@synthesize changed, moved;
@synthesize backButton;
@synthesize legendes;
@synthesize currentLegend;
@synthesize collectionButton;
@synthesize terminatedLevels;
@synthesize terminatedStripes;

-(void)dealloc
{
    [terminatedStripes release];
    [terminatedLevels release];
    [collectionButton release];
    [currentLegend release];
    [legendes release];
    [bubblesHolder release];
    [environments release];
    [backButton release];
    [super dealloc];
}

-(void)onExit
{
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
}

-(void)onEnter
{
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:1];
}

- (id)init 
{
    self = [super init];
    
    if (self) 
    {
        
        [self setAnchorPoint:ccp(0,0)];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"backgroundMenu.png"];
        [self addChild:bg];
        [bg setPosition:SCREEN_CENTER];
        self.environments = [NSMutableArray arrayWithCapacity:4];
        
        [environments addObject:[CCSprite spriteWithFile:@"tropicEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"oceanEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"arcticEnvironment.png"]];
        [environments addObject:[CCSprite spriteWithFile:@"abyssalEnvironment.png"]];
                
        self.terminatedLevels = [NSArray arrayWithObjects:
                                     [CCLabelBMFont labelWithString:@"Niveaux\nRésolus\n4/35" fntFile:@"childsplay.fnt"],
                                     [CCLabelBMFont labelWithString:@"Niveaux\nRésolus\n0/35" fntFile:@"childsplay.fnt"],
                                     [CCLabelBMFont labelWithString:@"Niveaux\nRésolus\n0/35" fntFile:@"childsplay.fnt"],
                                     [CCLabelBMFont labelWithString:@"Niveaux\nRésolus\n0/35" fntFile:@"childsplay.fnt"],
                                     nil];
        
        self.terminatedStripes = [NSArray arrayWithObjects:
                                      [CCSprite spriteWithFile:@"stripeHabitat.png"],
                                      [CCSprite spriteWithFile:@"stripeHabitat.png"],
                                      [CCSprite spriteWithFile:@"stripeHabitat.png"],
                                      [CCSprite spriteWithFile:@"stripeHabitat.png"],
                                      nil];
        
        self.origin = ccpSub(SCREEN_CENTER, ccp(256, 200));
        
        self.bubblesHolder = [CCNode node];
        [self addChild:self.bubblesHolder];
        [[self bubblesHolder] setPosition:origin];
        
        pageWidth = 650;
        
        lastIndex = 0;
        
        for(int i = 0 ; i < 4 ; i++)
        {
            CCSprite *bubble = [environments objectAtIndex:i];
            [bubble setAnchorPoint:CGPointZero];
            [bubble setPosition:ccp(i*pageWidth,0)];
            
            CCSprite *stripe = [terminatedStripes objectAtIndex:i];
            [stripe setAnchorPoint:CGPointZero];
            [stripe setPosition:ccpAdd(bubble.position, ccp(400,390))];
            
            CCSprite *level = [terminatedLevels objectAtIndex:i];
            [level setAnchorPoint:CGPointZero];
            [level setPosition:ccpAdd(bubble.position, ccp(480,380))];
            [level setScale:0.8];
            
            [[self bubblesHolder] addChild:bubble];
            [[self bubblesHolder] addChild:stripe];
            [[self bubblesHolder] addChild:level];
            
            [level setOpacity:0];
            [stripe setOpacity:0];
        }
        
        self.currentBubbleIndex = 0;
        
        [(CCSprite*)[terminatedLevels objectAtIndex:0] setOpacity:255.0];
        [(CCSprite*)[terminatedStripes objectAtIndex:0] setOpacity:255.0];
        
        self.backButton = [CCSprite spriteWithFile:@"backButton.png"];
        [backButton setAnchorPoint:ccp(0.5,0.5)];
        [backButton setPosition:ccp(73,74)];
        
        self.collectionButton = [CCSprite spriteWithFile:@"collectionButton.png"];
        [collectionButton setAnchorPoint:ccp(0.5,0.5)];
        [collectionButton setPosition:ccp(SCREEN_CENTER.x*2 - 105,74)];
        
        [self addChild:backButton];
        [self addChild:collectionButton];
               
        self.currentLegend = [CCLabelBMFont labelWithString:@"Les massifs coraliens habritent\n93000 espèces différentes" fntFile:@"childsplay.fnt"];
        [currentLegend setAnchorPoint:ccp(0,0)];
        [currentLegend setPosition:ccp(SCREEN_CENTER.x - 200,50)];
        [currentLegend setScale:.8];
        
        self.legendes = [NSArray arrayWithObjects: 
                    @"Les récifs coralliens habritent\n93 000 espèces différentes !" ,  
                    @"Ici vivent les plus gros poissons !\nIls peuvent voyager très loin..." ,  
                    @"Ici, il fait très froid !\nDe nombreux animaux y sont adapté ..." ,  
                    @"Le soleil ne parvient pas\njusqu'à ces mystérieuses créatures..." , nil];
        
        [self addChild:currentLegend];
        
        CCSprite *info = [CCSprite spriteWithFile:@"habitatInformation.png"];
        [info setAnchorPoint:ccp(1,0)];
        [info setPosition:ccp(SCREEN_CENTER.x - 200,35)];
        
        [self addChild:info];
    }
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{        
    diff = ccp(0.0f, 0.0f);
    self.changed = NO;
    self.moved = NO;
    [self unscheduleUpdate];
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if(!moved)
    {
        UITouch *touch = [touches anyObject];
        CGPoint touchPos = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        CCSprite *item = [[bubblesHolder children] objectAtIndex:currentBubbleIndex];
        CGPoint itemPos = ccpAdd([bubblesHolder position], [item position]);
        itemPos = ccpAdd(itemPos, ccp(256,256));
                        
        float dist = ccpDistance(itemPos, touchPos);
            
        if(dist < 256.0)
        {      
            if(currentBubbleIndex == 0)
            {
                CCScene *scene = [CCScene node];
                LevelMenu *levelMenu = [LevelMenu node];
                
                [scene addChild:levelMenu];
                
                [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
                
                return;
            }
            else
            {
                NSLog(@"finish precedent habitat");
            }
            
        }
        
        dist = ccpDistance(touchPos, backButton.position);
        
        if(dist < 74.0)
        {
            [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:0.5];
            return;
        }
        
        dist = ccpDistance(touchPos, collectionButton.position);
        
        if(dist < 100)
        {
            CCScene *scene = [CCScene node];
            LevelMenu *levelMenu = [FishMenu node];
            
            [scene addChild:levelMenu];
            
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:.5 scene:scene]];
            
            return;
        }
        
        return;
    }
    
    float limit;
    if(self.changed)
    {
        limit = 50.0f;
    }
        
    else
        limit = 5.0f;

    if(fabs(diff.x) >= limit)
    {
        if(diff.x < 0)
        {
            self.currentBubbleIndex--;
        }
        else
        {
            self.currentBubbleIndex++;
        }       
    }
    self.currentBubbleIndex = max(0, min(3, self.currentBubbleIndex));
    
    desiredX = -self.currentBubbleIndex * 650 + origin.x;
    
    [self setTerminatedLevelAndInfo];
    [self scheduleUpdate];
}

-(void)setTerminatedLevelAndInfo
{
    if(lastIndex == currentBubbleIndex) return;
    
    lastIndex = currentBubbleIndex;
    
    [currentLegend runAction:
     [CCSequence actions:
      [CCFadeOut actionWithDuration:.2],
      [CCCallBlock actionWithBlock:^(void) {
         [currentLegend setString:[legendes objectAtIndex:currentBubbleIndex]];
      }],
      [CCFadeIn actionWithDuration:.2], 
      nil]];
    
    for(CCSprite *s in terminatedStripes)
    {
        [s runAction:[CCFadeOut actionWithDuration:.2]];
    }
    
    for(CCSprite *s in terminatedLevels)
    {
        [s runAction:[CCFadeOut actionWithDuration:.2]];
    }
    
    [(CCSprite*)[terminatedLevels objectAtIndex:currentBubbleIndex] runAction:[CCFadeIn actionWithDuration:.2]];
    [(CCSprite*)[terminatedStripes objectAtIndex:currentBubbleIndex] runAction:[CCFadeIn actionWithDuration:.2]];
}

-(void)update:(ccTime)dt
{
    float newPos = self.bubblesHolder.position.x + (desiredX - self.bubblesHolder.position.x) * .1;
    
    float diffPos = fabsf(desiredX - newPos);
    
    if(diffPos > 1)
    {
        [[self bubblesHolder]setPosition:ccp(newPos,self.bubblesHolder.position.y)];
    }
    else
    {
        [self unscheduleUpdate];
    }
     
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.moved = YES;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    CGPoint prevLocation = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:[touch view]]];
    CGPoint newTouch = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    diff = ccpSub(prevLocation, newTouch);
    //diff.y = self.bubblesHolder.position.y;
    
    CGPoint pos = ccpSub(self.bubblesHolder.position, diff);
    pos.y =  self.bubblesHolder.position.y;
    
    
    [[self bubblesHolder] setPosition:pos];
    
    int newIndex = max(0,min(floor((origin.x-self.bubblesHolder.position.x + 256) / 650),3));

    if(self.currentBubbleIndex != newIndex)
    {
        self.currentBubbleIndex = newIndex;
        self.changed = YES;
    }
}

@end
