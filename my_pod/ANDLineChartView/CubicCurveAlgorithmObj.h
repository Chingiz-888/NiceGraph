//
//  CubicCurveAlgorithmObj.h
//  Pods
//
//  Created by Чингиз Б on 30.06.17.
//
//

#ifndef CubicCurveAlgorithmObj_h
#define CubicCurveAlgorithmObj_h


#endif /* CubicCurveAlgorithmObj_h */


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class CubicCurveAlgorithmObj;





@interface CubicCurveAlgorithmObj : NSObject
    struct CubicCurveSegment{
        CGPoint *controlPoint1;
        CGPoint *controlPoint2;
    };

    @property (nonatomic) struct CubicCurveSegment segment;
@end

