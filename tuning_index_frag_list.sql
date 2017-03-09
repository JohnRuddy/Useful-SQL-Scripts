/** 
File Name    : tuning_index_frag_list.sql
Author       : Dane L. Rudy
Purpose      : List fragmentation stats on indexes.
Change Log   :
03/22/10 - DLR - Create.
**/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT 
   a.index_id, 
   b.name index_name, 
   round(a.avg_fragmentation_in_percent,0) as avg_frag_percent,
   a.page_count,
   LTRIM(RTRIM(s.name))+'.'+LTRIM(RTRIM(c.name)) AS table_name
 FROM
   sys.dm_db_index_physical_stats (DB_ID('APTIFY'), NULL, NULL, NULL, NULL) AS a
 JOIN
   sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id
 JOIN
   sys.objects AS c ON c.object_id = a.object_id
 JOIN
    sys.schemas AS s ON s.schema_id = c.schema_id
  WHERE (b.name IS NOT NULL)
  AND (a.avg_fragmentation_in_percent > 10)
  ORDER BY a.avg_fragmentation_in_percent DESC