-- set up a foreign data wrapper to openclinica
create extension if not exists postgres_fdw;
create server :FDWSERVERNAME
 foreign data wrapper postgres_fdw 
  options (host :FDWSERVERHOST, port :FDWSERVERPORT, dbname :FDWSERVERDBNAME);
create user mapping for public server :FDWSERVERNAME
 options (user :FDWSERVERUSER, password :FDWSERVERPASS);