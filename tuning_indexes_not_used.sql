/** 
File Name  : adm_indexes_not_used.sql
Author     : Origin from http://www.mssqltips.com/tip.asp?tip=1545
Purpose    : To list indexes that have not been used.
**/

SELECT TABLENAME, INDEXNAME, INDEX_ID, [1] AS COL1, [2] AS COL2, [3] AS COL3, 
       [4] AS COL4, [5] AS COL5, [6] AS COL6, [7] AS COL7 
FROM   (SELECT A.NAME AS TABLENAME, 
               A.OBJECT_ID, 
               B.NAME AS INDEXNAME, 
               B.INDEX_ID, 
               D.NAME AS COLUMNNAME, 
               C.KEY_ORDINAL 
        FROM   SYS.OBJECTS A 
               INNER JOIN SYS.INDEXES B 
                 ON A.OBJECT_ID = B.OBJECT_ID 
               INNER JOIN SYS.INDEX_COLUMNS C 
                 ON B.OBJECT_ID = C.OBJECT_ID 
                    AND B.INDEX_ID = C.INDEX_ID 
               INNER JOIN SYS.COLUMNS D 
                 ON C.OBJECT_ID = D.OBJECT_ID 
                    AND C.COLUMN_ID = D.COLUMN_ID 
        WHERE  A.TYPE <> 'S') P 
       PIVOT 
       (MIN(COLUMNNAME) 
        FOR KEY_ORDINAL IN ( [1],[2],[3],[4],[5],[6],[7] ) ) AS PVT 
WHERE  NOT EXISTS (SELECT OBJECT_ID, 
                          INDEX_ID 
                   FROM   SYS.DM_DB_INDEX_USAGE_STATS B 
                   WHERE  DATABASE_ID = DB_ID(DB_NAME()) 
                          AND PVT.OBJECT_ID = B.OBJECT_ID 
                          AND PVT.INDEX_ID = B.INDEX_ID) 
ORDER BY TABLENAME, INDEX_ID; 