//
//  MerciScreen.h
//  ProtoMesh2
//
//  Created by Clément RUCHETON on 01/06/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "globals.h"
#import "AnimationHelper.h"

@interface MerciScreen : CCLayer {
    CCSprite *background;
    CCSprite *logo;
    CCSprite *merci;
    CCSprite *realisation;
    CCSprite *partenaires;
    CCSprite *acteurs;
    CCSprite *classe;
    CCSprite *gobelins;
        
    AnimationHelper *papillon;
    AnimationHelper *labre;
    
    int merciTouched;
}
@property(nonatomic,retain) AnimationHelper *labre;
@property(nonatomic,retain) AnimationHelper *papillon;
@property(nonatomic,retain) CCSprite *background;
@property(nonatomic,retain) CCSprite *logo;
@property(nonatomic,retain) CCSprite *merci;
@property(nonatomic,retain) CCSprite *realisation;
@property(nonatomic,retain) CCSprite *partenaires;
@property(nonatomic,retain) CCSprite *acteurs;
@property(nonatomic,retain) CCSprite *classe;
@property(nonatomic,retain) CCSprite *gobelins;

-(void)moveFish;
-(void)webHandler;
-(void)backHandler;

@end
