/**
File Name  :  tuning_indexes_missing.sql
Purpose    : Generate a list of missing idnexes with a create statement.
             Requires evaluation and changing the index name.
Change Log :
11/05/10 - DLR - Clean up query.
02/09/11 - DLR - Clean up index columns.
05/18/11 - DLR - Change decimal lengths on some of the casts.

References:
http://blogs.msdn.com/b/bartd/archive/2007/07/19/are-you-using-sql-s-missing-index-dmvs.aspx
**/

SELECT 
  cast(migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) as INT) AS improvement_measure
  , mid.statement as TableName
  , ' (' + ISNULL (mid.equality_columns,'') 
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
    + ISNULL (mid.inequality_columns, '')
	+ ')' 
	+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS index_columns
  --, migs.*
  , migs.unique_compiles
  , migs.user_seeks
  , migs.last_user_seek
  , cast(migs.avg_total_user_cost as Decimal(10,4)) as avg_total_user_cost
  , cast(migs.avg_user_impact as Decimal(10,2)) as avg_user_impact
  -- , DB_NAME(mid.database_id)
  -- , mid.[object_id]
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
ORDER BY 
migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC
-- object_id
-- user_seeks desc
