SELECT local_net_address, local_tcp_port
FROM sys.dm_exec_connections
WHERE session_id = @@SPID;


SELECT net_transport, local_net_address, local_tcp_port 
FROM sys.dm_exec_connections 
WHERE session_id = @@SPID;


EXEC sp_helpsubscription;