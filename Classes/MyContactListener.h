//
//  MyContactListener.h
//  ProtoMesh2
//
//  Created by Efflam on 19/05/11.
//  Copyright 2011 Plouf. All rights reserved.
//

#import "Box2D.h"
#import "b2Contact.h"
class MyContactListener : public b2ContactListener
{
public:
	MyContactListener();
    
    void BeginContact(b2Contact* contact);
	void EndContact(b2Contact* contact);
};