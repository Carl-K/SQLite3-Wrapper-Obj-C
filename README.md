# SQLite3-Wrapper-Obj-C
An SQLite wrapper for running SELECT, INSERT, DELETE, and UPDATE queries on an already constructed database.  Written in Objective-C.  You will need to add an appropriate SQLite3 Library through Build Phase -> Link Binary With Libraries.

Example usage:

-----Initializing Example-----

NSString *pathName = @"/Example/SQL/Database/File.sql";
NSURL *pathURL = [[NSURL alloc] initWithString:pathName];
NSError *error;
        
SQLite3Wrapper *db = [[SQLite3Wrapper alloc] initWithDatabase:pathURL anyError:&error];

if (error) {
  //db is nil, error is populated
}
else
{
  //db is ready for queries
}

-----Executing Queries Examples-----

Assume we are connected to a database that has the following table:

testTable(first text, last text);

--SELECT--

NSError *error;
NSArray *arr;
       
[db executeQuery:@"SELECT * FROM testTable;" anyError:&error];
        
if (error)
{
     //an error occurred, error is populated
}
        
arr = [db getLastSelectResult];

for (id entry in arr)
{
    //do something for entry
}


--Not SELECT--

NSError *error;

[db executeQuery:@"DELETE FROM testTable WHERE first = 'Jane' AND last = 'Doe';" anyError:&error];
        
if (error)
{
     //an error occurred, error is populated
}
