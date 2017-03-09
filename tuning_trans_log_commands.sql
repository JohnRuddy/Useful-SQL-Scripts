/**
File Name    : tuning_trans_log_commands.sql

This script has some log file commands.  
Highlight and execute the section you want to use.
Source: http://www.mssqltips.com/tip.asp?tip=1225
**/

/** dbcc loginfo
This will give you information about your virtual logs inside your transaction log.  
The primary thing to look at here is the Status column.  
Since this file is written sequentially and then looped back to the beginning, 
you want to take a look at where the value of "2" is in the output.  
This will tell you what portions of the log are in use and which are not in use Status = 0.  
Another thing to keep an eye on is the FSeqNo column. 
This is the virtual log sequence number and the latest is the last log.  
If you keep running this command as you are issuing transactions you will see these numbers keep changing.
**/
USE APTIFY;
dbcc loginfo


-- DBCC SQLPERF
-- This one command will give you details about the current size of all of your 
-- database transaction logs as well as the percent currently in use.
DBCC SQLPERF(logspace)

-- This will show you if you have any open transactions in your transaction log 
-- that have not completed or have not been committed.  
USE APTIFY
DBCC OPENTRAN

-- This will flush buffers to disk. Can be used prior to shrink on a simple recovery setting
-- checkpoint

-- Sample shrink command and increasing size to 1GB for Aptify DB.
-- DBCC SHRINKFILE('APTIFY_Log.ldf', 1)
-- ALTER DATABASE APTIFY MODIFY FILE (NAME = 'APTIFY_Log.ldf' , SIZE = 500MB);
-- ALTER DATABASE APTIFY MODIFY FILE (NAME = 'APTIFY_Log.ldf' , SIZE = 1000MB);


-- 