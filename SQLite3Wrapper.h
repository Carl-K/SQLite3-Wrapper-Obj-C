#ifndef SQLite3Wrapper_h
#define SQLite3Wrapper_h

#import <Foundation/Foundation.h>

@interface SQLite3Wrapper : NSObject

//
// Init when file may not exist
// Populates errorIn input if given if file does not exist
//
-(instancetype) initWithDatabase:(NSURL *) fileURLIn anyError:(NSError **)errorIn;

//
// Init when file is known to exist
//
-(instancetype) initWithDatabase:(NSString *) filePathIn;


//
// Runs SELECT, INSERT, DELETE, and MODIFY queries on database set in the init methods
// Populates errorIn input if given if file does not exist
//
-(void) executeQuery:(NSString *)queryIn anyError:(NSError **)errorIn;

//
// Get the affected rows from the last SELECT query, regardless if it was successful or not, in an array of dictionaries
//
-(NSArray *) getLastSelectResult;

@end

#endif /* SQLite3Wrapper_h */
