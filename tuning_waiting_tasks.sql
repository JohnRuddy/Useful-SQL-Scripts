/** Waiting Tasks **/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
select 
* 
from 
sys.dm_os_waiting_tasks
where session_id > 50
order by session_id