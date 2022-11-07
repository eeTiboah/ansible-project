
create role admin with login;
create role psqluser with login;

create database admin with owner admin;
create database altschool with owner psqluser;

\c altschool;
