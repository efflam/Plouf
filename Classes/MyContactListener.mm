//
//  MyContactListener.cpp
//  ProtoMesh2
//
//  Created by Efflam on 19/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#include "MyContactListener.h"


#import "Box2D.h"
#import "b2Contact.h"
#import "Actor.h"

// Implement contact listener.
MyContactListener::MyContactListener(){};

void MyContactListener::BeginContact(b2Contact* contact)
{
    //NSLog(@"begin contact");
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    id userDataA = (id)fixtureA->GetBody()->GetUserData();
	id userDataB = (id)fixtureB->GetBody()->GetUserData();
    
    
    if(userDataA && userDataB && [userDataA isKindOfClass:[Actor class]] && [userDataB isKindOfClass:[Actor class]]) 
    {
        Actor *actorA = (Actor *)userDataA; 
        Actor *actorB = (Actor *)userDataB;

        [actorA addContact:actorB];
        [actorB addContact:actorA];
    }

}

// Implement contact listener.
void MyContactListener::EndContact(b2Contact* contact)
{
    //NSLog(@"end contact");
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    Actor *actorA = (Actor *)fixtureA->GetBody()->GetUserData(); 
    Actor *actorB = (Actor *)fixtureB->GetBody()->GetUserData();
    if(actorA && actorB) 
    {
        [actorA removeContact:actorB];
        [actorB removeContact:actorA];
    }

}