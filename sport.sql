drop view if exists player_list;
drop view if exists team_list;

drop table if exists transfers;
drop table if exists players;
drop table if exists teams;
drop table if exists managers;
drop table if exists leagues;
drop table if exists countries;

drop type if exists gender;
drop function if exists clubHistory(player_id bigint);
drop type if exists player_transfers;

create type gender as enum ('male', 'female');


create table managers(
  user_id bigserial primary key not null,
  email varchar(255) not null ,
  pass_salt varchar(255) not null,
  pass_hash varchar(255),
  first_name varchar(255),
  last_name varchar(255),
  created timestamp not null default now()
);

create table countries(
  country_id bigserial primary key not null,
  code varchar(2) not null,
  country_name varchar(255) not null
);

create table leagues(
  league_id bigserial primary key not null,
  league_name varchar(255) not null,
  rank int,
  country int references countries(country_id)
);

create table teams(
  team_id bigserial primary key not null,
  short_name varchar(7) not null,
  full_name varchar(255),
  league int references leagues(league_id)

);

create table players(
  player_id bigserial primary key not null ,
  last_name varchar(255) not null ,
  first_name varchar(255),
  nick_name varchar(255),
  birth_date date not null,
  sex gender not null,
  injured boolean default false ,
  position varchar(255),
  origin int references countries(country_id),
  team int references teams(team_id),
  manager int references managers(user_id)
);

create table transfers (
  transfer_id bigserial primary key not null ,
  player bigint references players(player_id),
  old_team bigint references teams(team_id),
  new_team bigint references teams(team_id),
  transfer_date date not null
);


create view team_list as
select t.full_name as team_name,
       l.league_name as league_name,
       c.country_name as country_name
  from teams t left join leagues l on t.league = l.league_id
  left join countries c on l.country = c.country_id;

create view player_list as
select p.first_name,
       p.nick_name,
       p.last_name,
       p.sex,
       p.birth_date,
       p.injured,
       p.position,
       t.short_name as team,
       c.country_name as country
       from players p left join teams t on p.team = t.team_id
  left join countries c on p.origin = c.country_id;


create type player_transfers as (
  tr_date date,
  old_team bigint,
  new_team bigint
);

create or replace function clubHistory(player_id bigint)
  returns player_transfers as $$
  select transfer_date, old_team, new_team from transfers where player = $1;
$$ LANGUAGE SQL;

select clubHistory(2)