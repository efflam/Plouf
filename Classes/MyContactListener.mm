#import "MyContactListener.h"


    int32 m_pointCount;
    ContactPoint m_points[k_maxContactPoints];

    void BeginContact(b2Contact* contact)
    {
        b2Fixture* fixtureA = contact->GetFixtureA();
        b2Fixture* fixtureB = contact->GetFixtureB();
       /* if (contact->IsSolid()) {
            NSLog(@"Contact is solid");
        }*/
    }
    
    void EndContact(b2Contact* contact)
    {
        NSLog(@"end contact");
    }
    
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
    {
        const b2Manifold* manifold = contact->GetManifold();
    }
    
    void PostSolve(b2Contact* contact)
    {
        const b2ContactImpulse* impulse;
    }
