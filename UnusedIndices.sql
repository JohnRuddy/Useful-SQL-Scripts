SELECT count (database_id) * 8/1024, AS 'Cache Used (MB)'
FROM sys.dm_os_buffer_descriptors 
GROUP BY db_name (database_id), database_id