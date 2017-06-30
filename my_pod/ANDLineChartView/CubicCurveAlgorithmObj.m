//
//  CubicCurveAlgorithmObj.m
//  Pods
//
//  Created by Чингиз Б on 30.06.17.
//
//


#import "CubicCurveAlgorithmObj.h"


@interface CubicCurveAlgorithmObj()
  @property (nonatomic, weak) CubicCurveAlgorithmObj *chartContainer;

   
@end


@implementation CubicCurveAlgorithmObj

    NSMutableArray *firstControlPoints;
    NSMutableArray *secondControlPoints;



//    NSMutableArray *myCGPointArray = @[[NSValue valueWithCGPoint:CGPointMake(30.0, 150.0)],[NSValue valueWithCGPoint:CGPointMake(41.67, 145.19)]];


-(struct CubicCurveSegment)controlPointsFromPoints{
    CubicCurveAlgorithmObj *alg = [[CubicCurveAlgorithmObj alloc] init];
    
    CGPoint point1={100 , 200};
    CGPoint point2={100 , 200};

    
    
    alg.segment = (struct CubicCurveSegment){&point1, &point2};
                   
    return alg.segment;
}


@end
