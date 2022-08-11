# SQL Error Handler

## About
The SQL Error Handler is designed to create unified logging and notification of SQL execution exceptions.  This product can be used in conjuction with the Messenger product to automatically report SQL exceptions periodically (just set up a Messenger record with the query `SELECT * FROM SQL_Errors WHERE ErrorDateTime > $LASTRUN$`).

## Getting Started
Once you've cloned this repo, installation is a snap:  To install everything, just run the script InstallErrorHandler.sql (change the USE Utils to your database name if needed; Error Handler can reside in any database you wish), this will create the error logging table ($SQL_Errors$)  and create the stored for exception handling ($HandleError$).  Alternatively, you can review and individually run the individual scripts to create the table (Table-SQL_Errors.sql) and stored proc (StoredProc-HandleError.sql) - Just remember to check the USING statement at the top of each script to make sure you're creating objects in the right database.

Once you've created the objects, you'll want to review the parameter default values in the stored procedure $HandleError$ to adjust email settings and other options.  You can test the error handler with the script TestErrorHandler.sql - this has a simple divide by zero error that will be logged and emailed (if enabled).

## Using The Error Handler
When you have everything set up the way you want, just call the stored procedure from all your CATCH blocks and let it do the rest!  Assuming you have the default parameter values set the way you want (although you can always pass params for specific use cases), your call will be this simple:
    `EXEC HandleError`

## Feedback & Improvements
If you discover any bugs or additional feature requests, please send me an email!
