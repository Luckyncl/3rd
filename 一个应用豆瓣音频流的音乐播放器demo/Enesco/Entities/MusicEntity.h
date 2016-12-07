//
//  MusicEntity.h
//  Ting
//
//  Created by Aufree on 11/13/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "BaseEntity.h"

@interface MusicEntity : BaseEntity
@property (nonatomic, copy) NSNumber *musicId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *musicUrl;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *fileName;  // 文件名
@property (nonatomic, assign) BOOL isFavorited;
@end
