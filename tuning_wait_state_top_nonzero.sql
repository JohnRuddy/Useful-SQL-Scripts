-- Isolate top waits for server instance since last restart or statistics clear
/**
This query is used to help determine what type of resource that SQL Server is spending 
the most time waiting on. This can help you figure out what the biggest bottleneck is 
at the instance level, which will then guide your efforts to focus on a particular type of problem. 
For example, if the top cumulative wait types are disk I/O related, then you would want to 
start looking at disk related DMV queries and PerfMon counters to narrow down the issue. 
Source: http://www.mssqltips.com/tip.asp?tip=1949
See following docs for an explanation of wait types :
 SQLDocs\SQLServerWaitTypes.pdf - taken from http://www.sqldev.net/articles/waittypes2000/default.html
 SQLDocs\SQLServerWaitTypes_msdn.pdf - taken from http://technet.microsoft.com/en-us/library/ms179984.aspx


You should also remember that these wait stats are cumulative since SQL Server was last 
restarted or since the wait statistics were cleared with this command:

Clear Wait Stats 
**/
--DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);


WITH Waits AS
(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN')
)
SELECT W1.wait_type, 
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING W1.wait_time_s > 0

