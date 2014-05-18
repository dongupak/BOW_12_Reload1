//
//  GameLayer.h
//  Action_Move
//
//  Created by 영록 이 on 11. 8. 12..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface GameLayer : CCLayer {
    int bulletCount;
    
    CCAnimate *sitAnimate;
    CCAnimate *smokeAnimate;
    CCAnimate *tailAnimate;
    CCSprite *gunSmoke;
    CCArray *birdArray;
    CCArray *sitPositions;
    
    CCProgressTimer *ptBullet;
}
+(CCScene *) scene;
-(CGPoint)getStartPosition;
@end
