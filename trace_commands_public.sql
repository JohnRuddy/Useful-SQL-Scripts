/** 
File Name    : trace_commands_public.sql
Author       : Dane L. Rudy
Purpose      : Contains various commands to query and load trace files.
Change Log   :
07/08/11 - DLR - Make a few minor improvements and notes.
08/03/11 - DLR - Make a few minor improvements.
**/

-- List traces.
SELECT
	id,
 	status, 
 	path, 
 	max_size, 
 	buffer_count, 
 	buffer_size, 
 	event_count, 
 	dropped_event_count 
FROM sys.traces 


-- Get trace event information for a trace
-- Note, replace (2) with appropriate trace id.

SELECT 
 	e.name AS Event_Name, 
 	c.name AS Column_Name
FROM fn_trace_geteventinfo(2) ei
JOIN sys.trace_events e ON ei.eventid = e.trace_event_id 
JOIN sys.trace_columns c ON ei.columnid = c.trace_column_id

-- Get information on filter used in the trace.

SELECT 
 	columnid, 
 	logical_operator, 
 	comparison_operator, 
 	value 
FROM fn_trace_getfilterinfo(2)


-- To query directly from the trace file (replace c:\... with location of your trace file).
select 
TextData
, HostName
, LoginName
, convert(Dec(20,1),convert(Dec(20,1),duration)/1000000) as DurSeconds  -- Base values is in MicroSeconds, divide by 1000 to get Milliseconds.
, CPU
, reads
, writes
, ObjectName
, starttime
, endtime 
, e.name as EventName
, EventSequence
, SPID
FROM fn_trace_gettable('c:\sqlout\ListDetail.trc', 1) f
inner join sys.trace_events e on f.eventclass=e.trace_event_id
order by 
duration desc


-- To load this to a table (replace c:\... with location of your trace file).
SELECT *
INTO TraceListDetailTable
FROM fn_trace_gettable('c:\sqlout\ListDetail.trc', 1)

-- To stop trace. The first #, in this example 2 is the # of the trace.
EXEC sp_trace_setstatus 2, 0

-- To start trace. 
EXEC sp_trace_setstatus 2, 1


-- To remove the trace definition.
EXEC sp_trace_setstatus 2, 2

-- Once loaded to a table, queries can be run to sort and find longest duration statements.  Examples follow.


-- Summary type queries - Totals
select 
(sum(duration)/1000) as Sum_Dur_MS
, sum(reads) as SUM_Reads
, sum(writes) as SUM_Writes
,COUNT(*)
from TraceListDetailTable 

-- Summary type queries - Group like statements and sort by summed duration
select 
convert(varchar(500),TextData)
,(sum(duration)/1000) as Sum_Dur_MS
, sum(reads) as SUM_Reads
, sum(writes) as SUM_Writes
,COUNT(*)
from TraceListDetailTable
group by
convert(varchar(500),TextData)
order by 
(sum(duration)/1000) desc



-- Sorted by duration
select 
TextData
, duration as DurMicrS
--, duration/1000 as DurMillS  -- Base values is in MicroSeconds, divide by 1000 to get Milliseconds.
, CPU
, reads
, writes
, starttime
, endtime 
, e.name as EventName
, EventSequence
from 
TraceListDetailTable f
inner join sys.trace_events e on f.eventclass=e.trace_event_id
order by 
duration desc


-- Where duration exceeds 5 seconds
select 
TextData
, duration as DurMicrS
--, duration/1000 as DurMillS  -- Base values is in MicroSeconds, divide by 1000 to get Milliseconds.
, CPU
, reads
, writes
, starttime
, endtime 
, e.name as EventName
, EventSequence
from 
TraceListDetailTable f
inner join sys.trace_events e on f.eventclass=e.trace_event_id
where 
duration/1000 > 3000
order by 
duration desc


-- Searching for specific data in the SQL syntax ordered by the EventSequence # which will put it in the order the query ran.
select 
TextData
, duration as DurMicrS
--, duration/1000 as DurMillS  -- Base values is in MicroSeconds, divide by 1000 to get Milliseconds.
, CPU
, reads
, writes
, starttime
, endtime 
, e.name as EventName
, EventSequence
from 
TraceListDetailTable f
inner join sys.trace_events e on f.eventclass=e.trace_event_id
where 
TextData like 'APTIFY.dbo.spMaintainEntityMostRecentlyUsedList%'
order by 
EventSequence


-- Dane favorite for copying to Excel.
select 
TextData
, HostName
, LoginName
, convert(Dec(20,1),convert(Dec(20,1),duration)/1000000) as DurSeconds  -- Base values is in MicroSeconds, divide by 1000 to get Milliseconds.
, CPU
, reads
, writes
, ObjectName
, starttime
, endtime 
, e.name as EventName
, EventSequence
, SPID
FROM 
fn_trace_gettable('c:\sqlout\ListDetail.trc', 1) f  /** use this to trace directly from the file **/
-- TraceListDetailTable f                           /** use this if the trace was loaded to a table **/
inner join sys.trace_events e on f.eventclass=e.trace_event_id
order by 
duration desc
--StartTime
--f.EventSequence
--convert(varchar,TextData)  -- Needed this due to a large TexData value



