/** 
File Name    : tuning_io_file_stats.sql
Author       : Dane L. Rudy
Purpose      : List fragmentation stats on indexes.
Change Log   :
07/07/10 - DLR - Create.
**/

select
DB_NAME(s.database_id) as db_name 
, f.name as file_logical_name
, f.physical_name as file_physical_name
, s.database_id
, s.file_id
, s.sample_ms
, s.num_of_reads
, s.num_of_bytes_read
, s.io_stall_read_ms
, s.num_of_writes 
, s.num_of_bytes_written
, s.io_stall_write_ms
, s.io_stall
, s.size_on_disk_bytes
, GETDATE() as coldate
from sys.dm_io_virtual_file_stats(null,null) s
, sys.master_files f
where s.database_id=f.database_id
and s.file_id=f.file_id
order by io_stall desc


-- Repeated or records staying for a long time means disk bottleneck.
-- select * from sys.dm_io_pending_io_requests