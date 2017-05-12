#import "SQLite3Wrapper.h"
#import <sqlite3.h>

static NSString *errorDomain = @"SQLite3ErrorDomain";

@implementation SQLite3Wrapper
{
    const char *path;
    NSMutableArray *rowsResult;
}

-(instancetype) initWithDatabase:(NSURL *) fileURLIn anyError:(NSError **)errorIn
{
    //
    // check if file exists; if not return nil and populate errorIn if given
    //
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL fileExists = [defaultManager fileExistsAtPath:fileURLIn.absoluteString];
    
    if (!fileExists)
    {
        NSURL *fileURLDeleteLastPathComponent = fileURLIn.URLByDeletingLastPathComponent;
        
        NSString *localizedDescription = [[NSString alloc] initWithFormat:@"FILE %@ DOES NOT EXIST AT PATH %@", fileURLIn.lastPathComponent, fileURLDeleteLastPathComponent.absoluteString];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : localizedDescription};
        
        (*errorIn) = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:userInfo];
        
        [self doError:errorIn withDomain:NSCocoaErrorDomain withCode:NSFileNoSuchFileError withUserInfo:userInfo];
        
        return nil;
    }
    
    //
    // init if file exists
    //
    return [self initWithDatabase:fileURLIn.absoluteString];
}

-(instancetype) initWithDatabase:(NSString *)filePathIn
{
    const char *filePathAsCString = filePathIn.UTF8String;
    
    self = [super init];
    
    if (self)
    {
        path = filePathAsCString;
    }
    
    return self;
}

-(void) executeQuery:(NSString *)queryIn anyError:(NSError **)errorIn
{
    sqlite3 *sqlite3Database;
    int open = sqlite3_open(path, &sqlite3Database);

    //
    // ran if connection to database if established
    //
    if (open == SQLITE_OK)
    {
        sqlite3_stmt *compiledStatement;
        int prepare = sqlite3_prepare_v2(sqlite3Database, [queryIn UTF8String], -1, &compiledStatement, NULL);
        
        //
        // ran if query is good to go
        //
        if (prepare == SQLITE_OK)
        {
            int step = sqlite3_step(compiledStatement);
            
            rowsResult = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *dict;
            NSString *columnName;
            NSString *columnValue;
            
            //
            // Block ran for SELECT queries
            //
            while (step == SQLITE_ROW)
            {
                int totalColumns = sqlite3_column_count(compiledStatement);
                
                dict = [[NSMutableDictionary alloc] init];

                for (int i = 0; i < totalColumns; i++)
                {
                    columnName = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_name(compiledStatement, i)];
                    
                    columnValue = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(compiledStatement, i)];
                    
                    [dict setValue:columnValue forKey:columnName];
                }
                
                [rowsResult addObject:dict];

                step = sqlite3_step(compiledStatement);
            }
            
            if (step != SQLITE_DONE && step != SQLITE_OK)
            {
                //error running query
                
                NSString *localizedDescription = [[NSString alloc] initWithFormat:@"ERROR COMPLETING QUERY - SQL ERROR CODE : %i", step];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : localizedDescription};
                
                [self doError:errorIn withDomain:errorDomain withCode:step withUserInfo:userInfo];
            }
        }
        else
        {
            //can't run query
            
            NSString *localizedDescription = [[NSString alloc] initWithFormat:@"ERROR PREPARING QUERY - SQL ERROR CODE : %i", prepare];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : localizedDescription};
            
            [self doError:errorIn withDomain:errorDomain withCode:prepare withUserInfo:userInfo];
        }
    }
    else
    {
        //can't open db

        NSString *localizedDescription = [[NSString alloc] initWithFormat:@"ERROR OPENING DATABASE - SQL ERROR CODE : %i", open];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : localizedDescription};
        
        [self doError:errorIn withDomain:errorDomain withCode:open withUserInfo:userInfo];
    }
    
    sqlite3_close(sqlite3Database);
}

-(NSArray *) getLastSelectResult
{
    return rowsResult;
}

-(void) doError: (NSError **)errorIn withDomain: (NSString *) domainIn withCode: (int) errorCodeIn withUserInfo: (NSDictionary *) userInfoIn
{
    if (errorIn)
    {
        (*errorIn) = [[NSError alloc] initWithDomain:domainIn code:errorCodeIn userInfo:userInfoIn];
    }
    
    rowsResult = nil;
}

@end
