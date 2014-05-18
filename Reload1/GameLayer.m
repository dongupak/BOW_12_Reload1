//
//  GameLayer.m
//  Reload1 - 총알이 떨어지면 재장전되도록 하는 기능
//
//  Created by 영록 이 on 11. 8. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

#define FRONT_CLOUD_SIZE 563 
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  310
#define BACK_CLOUD_TOP   230
#define MAX_BULLET_COUNT 7

@implementation GameLayer

-(void)dealloc
{
    [sitAnimate release];
    [tailAnimate release];
    [smokeAnimate release];
    
    [gunSmoke release];
    [birdArray release];
       
    [super dealloc];
}

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

- (void)createCloudWithSize:(int)imgSize top:(int)imgTop fileName:(NSString*)fileName interval:(int)interval z:(int)z {
    id enterRight	= [CCMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id enterRight2	= [CCMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id exitLeft		= [CCMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id exitLeft2	= [CCMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id reset		= [CCMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id reset2		= [CCMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id seq1			= [CCSequence actions: exitLeft, reset, enterRight, nil];
    id seq2			= [CCSequence actions: enterRight2, exitLeft2, reset2, nil];
    
    CCSprite *spCloud1 = [CCSprite spriteWithFile:fileName];
    [spCloud1 setAnchorPoint:ccp(0,1)];
    [spCloud1.texture setAliasTexParameters];
    [spCloud1 setPosition:ccp(0, imgTop)];
    [spCloud1 runAction:[CCRepeatForever actionWithAction:seq1]];
    [self addChild:spCloud1 z:z ];
    
    CCSprite *spCloud2 = [CCSprite spriteWithFile:fileName];
    [spCloud2 setAnchorPoint:ccp(0,1)];
    [spCloud2.texture setAliasTexParameters];
    [spCloud2 setPosition:ccp(imgSize, imgTop)];
    [spCloud2 runAction:[CCRepeatForever actionWithAction:seq2]];
    [self addChild:spCloud2 z:z ];
}

- (void)createGun {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gun.plist"];
    
    gunSmoke = [[CCSprite alloc] init];
    [self addChild:gunSmoke z:7];    
    
    
    NSMutableArray *smokeFrames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 10; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"shotgun_smoke2_%04d.png",idx]];
        [smokeFrames addObject:frame];
    }
    CCAnimation *smokeAnimation = [CCAnimation animationWithFrames:smokeFrames delay:0.05f];
    smokeAnimate = [[CCAnimate alloc] initWithAnimation:smokeAnimation restoreOriginalFrame:NO];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"gun.plist"];
}

-(CGPoint)getStartPosition {
	int starty=0;
    int startx = arc4random()%540-30;
    if (startx>0 && startx<480) {
        starty=400;
    } else {
        starty = arc4random()%200+100;
    }
	return ccp(startx, starty);
}


-(void)createBird {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bluebird.plist"];
    
    CCSprite *bird = [[CCSprite alloc] init];
    [bird setPosition:[self getStartPosition]];
        
    [self addChild:bird z:5];   
    [birdArray addObject:bird];
    [bird release];
    
    NSMutableArray *flyFrames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 17; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"blue_fly%04d.png",idx]];
        [flyFrames addObject:frame];
    }
    CCAnimation *flyAnimation = [CCAnimation animationWithFrames:flyFrames delay:0.05f];
    CCAnimate *flyAnimate = [[[CCAnimate alloc] initWithAnimation:flyAnimation restoreOriginalFrame:NO] autorelease];
    
    NSMutableArray *sitFrames = [NSMutableArray array];
    for (NSInteger idx = 1; idx <61; idx++)  {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"blue_sit_%04d.png",idx]];
        [sitFrames addObject:frame];
    }
    CCAnimation *sitAnimation = [CCAnimation animationWithFrames:sitFrames delay:0.05f];
    sitAnimate = [[CCAnimate alloc] initWithAnimation:sitAnimation restoreOriginalFrame:NO];
    
    NSMutableArray *tailFrames = [NSMutableArray array];
    for (NSInteger idx = 1; idx <16; idx++)  {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"blue_tail_%04d.png",idx]];
        [tailFrames addObject:frame];
    }
    CCAnimation *tailAnimation = [CCAnimation animationWithFrames:tailFrames delay:0.05f];
    tailAnimate = [[CCAnimate alloc] initWithAnimation:tailAnimation restoreOriginalFrame:NO];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"bluebird.plist"];

    
    
    id actionFlyRepeat  = [CCRepeatForever actionWithAction:flyAnimate];
    [bird runAction:actionFlyRepeat];
    
    NSValue *value = [sitPositions objectAtIndex:arc4random()%10]; 
    CGPoint sitPoint = [value CGPointValue]; 
    id actionMoveTo = [CCMoveTo actionWithDuration:2 position:sitPoint];
    id moveComplete = [CCCallFuncN actionWithTarget:self selector:@selector(moveComplete:)];
    id actionSeqence= [CCSequence actions:actionMoveTo, moveComplete, nil];
    [bird runAction:actionSeqence];
}

-(void)moveComplete:(id)bird {
    CCSprite *sprite = (CCSprite *)bird;
    [sprite stopAllActions];
    id actionSitRepeat = [CCRepeatForever actionWithAction:sitAnimate];
    [sprite runAction:actionSitRepeat];
}

- (BOOL)isHitWithTarget:(CCSprite *)target touchPoint:(CGPoint)touchPoint {
	if(ccpDistance(target.position, touchPoint) < target.contentSize.width /2) return YES;
	return NO;
}

- (BOOL)isTouchInside:(CCSprite*)sprite touchPoint:(CGPoint)touchPoint {
	CGFloat halfWidth   = sprite.contentSize.width /2.0;
	CGFloat halfHeight  = sprite.contentSize.height /2.0;
	if (touchPoint.x>(sprite.position.x+halfWidth) ||
		touchPoint.x<(sprite.position.x-halfWidth) ||
		touchPoint.y<(sprite.position.y-halfHeight)||
		touchPoint.y>(sprite.position.y+halfHeight) )		{
		return NO;
	}
	return YES;
}


-(void)birdisDead:(CCSprite*)bird {
    [bird stopAllActions];
    
    id tailComplete = [CCCallFuncN actionWithTarget:self selector:@selector(removeBird:)];
    id actionSeq = [CCSequence actions:tailAnimate, tailComplete, nil];
    [bird runAction:actionSeq];
}
 
-(void)removeBird:(CCSprite*)bird {
    [self removeChild:bird cleanup:YES];
}
                    
-(id) init
{
	if( (self=[super init])) {
        self.isTouchEnabled = YES;
        
        bulletCount = MAX_BULLET_COUNT;
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"handgun_fire.wav"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"bird.m4a"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bird.m4a" loop:YES];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5f];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.5f];

        birdArray = [[CCArray alloc] init];
        
        CCSprite *back = [CCSprite spriteWithFile:@"back.png"];
        [back setPosition:ccp(240, 160)];
        [self addChild:back z:0];
      
        CCSprite *setting = [CCSprite spriteWithFile:@"setting.png"];
        [setting setPosition:ccp(240, 160)];
        [self addChild:setting z:2];
        
        CCSprite *pole = [CCSprite spriteWithFile:@"pole.png"];
        [pole setAnchorPoint:ccp(0.5f, 0.0f)];
        [pole setPosition:ccp(240, 0)];
        [self addChild:pole z:2];
        
        CCSprite *spGun = [CCSprite spriteWithFile:@"ui_handgun.png"];
        spGun.anchorPoint = ccp(0.5, 0.5);
        spGun.position = ccp(40,280);
        [self addChild:spGun z:6];
        
        ptBullet = [CCProgressTimer progressWithFile:@"bullet_handgun.png"];
        ptBullet.type = kCCProgressTimerTypeHorizontalBarLR;
        ptBullet.anchorPoint = ccp(0, 0.5f);
        ptBullet.position = ccp(80, 285);
        ptBullet.percentage=100;
        [self addChild:ptBullet z:21];
        
        
        [self createCloudWithSize:FRONT_CLOUD_SIZE top:FRONT_CLOUD_TOP fileName:@"cloud_front.png" interval:15 z:2];
        [self createCloudWithSize:BACK_CLOUD_SIZE  top:BACK_CLOUD_TOP  fileName:@"cloud_back.png"  interval:30 z:1];
        
        [self createGun];
        
        sitPositions = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:ccp(70,  193)], 
                        [NSValue valueWithCGPoint:ccp(107, 178)], 
                        [NSValue valueWithCGPoint:ccp(144, 167)], 
                        [NSValue valueWithCGPoint:ccp(181, 158)], 
                        [NSValue valueWithCGPoint:ccp(218, 155)], 
                        [NSValue valueWithCGPoint:ccp(255, 156)], 
                        [NSValue valueWithCGPoint:ccp(292, 161)], 
                        [NSValue valueWithCGPoint:ccp(329, 168)], 
                        [NSValue valueWithCGPoint:ccp(366, 180)], 
                        [NSValue valueWithCGPoint:ccp(403, 195)],
                        nil];
        [sitPositions retain]; 
        
        [self schedule:@selector(createBird) interval:2.0f];	
    }
	return self;
}

#pragma mark -
#pragma mark TouchHandler

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch");
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint glLocation = [[CCDirector sharedDirector] convertToGL:location];
	[gunSmoke setPosition:glLocation];
    
    if (bulletCount>0) {
        bulletCount -= 1;
        ptBullet.percentage = bulletCount *100 / MAX_BULLET_COUNT;
        
        if (![smokeAnimate isDone]) [gunSmoke stopAction:smokeAnimate];    
        [gunSmoke runAction:smokeAnimate];
        [[SimpleAudioEngine sharedEngine] playEffect:@"handgun_fire.wav"];
        
        for (CCSprite *sprite in birdArray)  
        {  
            if ([self isHitWithTarget:sprite touchPoint:glLocation]) [self birdisDead:sprite];  
        } 
    }
    else {
        bulletCount = MAX_BULLET_COUNT;
        ptBullet.percentage = bulletCount *100 / MAX_BULLET_COUNT;
    }
}	

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
