//
//  SVGNode.m
//  Proto4
//
//  Created by Clément RUCHETON on 02/03/11.
//  Copyright 2011 Gobelins. All rights reserved.
//

#import "BackrockView.h"
#import "nanosvg.h"

@implementation BackrockView

void* poolAlloc( void* userData, unsigned int size )
{
	struct MemPool* pool = (struct MemPool*)userData;
	if (pool->size + size < pool->cap)
	{
		unsigned char* ptr = pool->buf + pool->size;
		pool->size += size;
		return ptr;
	}
	return 0;
}

void poolFree( void* userData, void* ptr )
{
	// empty
}

+(id)backrockWithName:(NSString *)levelName
{
	return [[[self alloc] initWithLevelName:levelName] autorelease];
}

-(id)initWithLevelName:(NSString *)levelName
{
	if((self = [super init]))
	{			
		// Load
		svgLevel = 0;
		
		t = 0.0f;
		tess = 0;
		nvp = 3;
				
		// Load assets
        
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-rocks",levelName] ofType:@"svg"];
        
		fg = svgParseFromFile([path UTF8String]);
		
		pool.size = 0;
		pool.cap = sizeof(mem);
		pool.buf = mem;
		memset(&ma, 0, sizeof(ma));
		ma.memalloc = poolAlloc;
		ma.memfree = poolFree;
		ma.userData = (void*)&pool;
		ma.extraVertices = 256; // realloc not provided, allow 256 extra vertices.	
		
		pool.size = 0; // reset pool
		tess = tessNewTess(&ma);
		
		if (tess)
		{
			for (it = fg; it != NULL; it = it->next)
				tessAddContour(tess, 2, it->pts, sizeof(float)*2, it->npts);
                        
            tessTesselate(tess, TESS_WINDING_ODD, TESS_POLYGONS, nvp, 2, 0);
            
            [self fixedArrays];
		}
    }
    
	return self;
}

-(void)fixedArrays
{
    verticesFixed = NULL;
    counterFixed = 0;
    
    if (tess)
	{
		const float* verts = tessGetVertices(tess);
		const int* elems = tessGetElements(tess);
		const int nelems = tessGetElementCount(tess);
                
		for (i = 0; i < nelems; ++i)
		{
			const int* p = &elems[i*nvp];
			
			for (j = 0; j < nvp && p[j] != TESS_UNDEF; ++j)
            {
                /* add ONE element to the array */
                verticesFixed = (struct CGPoint *)realloc(verticesFixed, (counterFixed + 1) * sizeof(struct CGPoint));
                
                /* allocate memory for one `struct node` */
                verticesFixed[counterFixed] = *(struct CGPoint *)malloc(sizeof(struct CGPoint));
                
                CGPoint temp = [[CCDirector sharedDirector] convertToGL:ccp(verts[p[j]*2],verts[p[j]*2+1])];
                
                verticesFixed[counterFixed].x = temp.x;
                verticesFixed[counterFixed].y = temp.y;
                                
                counterFixed++;
                
                
            }
        }
        
	}
}

-(void)draw
{		
	glPushMatrix();
	glTranslatef(-MAP_WIDTH/2, (MAP_HEIGHT/2)-768, 0);
    
    glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
    glColor4f(0.4f, 0.0f, 0.69f, 0.23f);
	
    for(int initi = 0 ; initi < counterFixed ; initi += 3)
    {
        glVertexPointer(2, GL_FLOAT, 0, verticesFixed);
        glDrawArrays(GL_TRIANGLE_STRIP, initi, 3);
    }
    
    glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
    
	glPopMatrix();
	
}

// C CLASSES

void* stdAlloc(void* userData, unsigned int size)
{
	int* allocated = ( int*)userData;
	*allocated += (int)size;
	return malloc(size);
}

void stdFree(void* userData, void* ptr)
{
	free(ptr);
}


-(void)dealloc 
{
	svgDelete(svgLevel);
	[super dealloc];
}

@end

