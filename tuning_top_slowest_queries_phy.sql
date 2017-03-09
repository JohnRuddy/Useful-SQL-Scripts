/**
File name  : adm_dmv_top_slowest_queries_phy.sql
Author     : Dane L. Rudy.  Origin began from:
			 http://blogs.msdn.com/b/sqlazure/archive/2010/07/27/10043069.aspx
Change Log:
09/01/10 - DLR - Add additional fields such as Individual Query and totals.
11/05/10 - DLR - Clean up column as names to shorten column widths.
**/
SELECT TOP 25
SUBSTRING (q.text, (er.statement_start_offset/2) + 1, 
	((CASE WHEN er.statement_end_offset = -1
	THEN LEN(CONVERT(NVARCHAR(MAX), q.text)) * 2
	ELSE er.statement_end_offset
	END - er.statement_start_offset)/2) + 1) AS [IndividualQuery]
, q.[text]
, total_logical_reads as tot_logl_reads
, total_logical_writes as tot_logl_writes
, total_physical_reads as tot_phys_reads
, (total_logical_reads/execution_count) AS avg_logl_reads 
, (total_logical_writes/execution_count) AS avg_logl_writes 
, (total_physical_reads/execution_count) AS avg_phys_reads 
, Execution_count as exec_count
, (total_worker_time/1000) as TotCPUTime_ms
, (total_elapsed_time/1000) as TotElapTime_ms
, creation_time
, last_execution_time as last_exec_time
, DB_NAME(q.dbid) as DBName
FROM sys.dm_exec_query_stats er  
    cross apply sys.dm_exec_sql_text(plan_handle) AS q 
ORDER BY
 total_physical_reads DESC
 
 