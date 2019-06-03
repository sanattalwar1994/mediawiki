CREATE DATABASE mediadb;
CREATE USER 'media'@'localhost' IDENTIFIED BY 'Superb1)(*';
GRANT ALL ON mediadb.* TO 'media'@'localhost' IDENTIFIED BY 'Superb1)(*' WITH GRANT OPTION;
FLUSH PRIVILEGES;
