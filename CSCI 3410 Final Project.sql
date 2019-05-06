/**********************************************************************

 ██████╗███████╗ ██████╗██╗    ██████╗ ██╗  ██╗ ██╗ ██████╗ 
██╔════╝██╔════╝██╔════╝██║    ╚════██╗██║  ██║███║██╔═████╗
██║     ███████╗██║     ██║     █████╔╝███████║╚██║██║██╔██║
██║     ╚════██║██║     ██║     ╚═══██╗╚════██║ ██║████╔╝██║
╚██████╗███████║╚██████╗██║    ██████╔╝     ██║ ██║╚██████╔╝
 ╚═════╝╚══════╝ ╚═════╝╚═╝    ╚═════╝      ╚═╝ ╚═╝ ╚═════╝                                                          
 ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
||F |||i |||n |||a |||l |||       |||P |||r |||o |||j |||e |||c |||t ||
||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|

**********************************************************************/

/**********************************************************************

 Database Developer Name: Daniel Haugen
           Project Title: Soccer Clubs Database
      Script Create Date: 4/20/2019

**********************************************************************/

/**********************************************************************
	CREATE TABLE SECTION
**********************************************************************/

create table dlhaug7343.Leagues
(
	LeagueID int not null primary key identity(1,1),
	LeagueName varchar(75) not null,
	Country varchar(75) not null,
	NumTeams int not null,
    FoundedOn date not null default(getdate())
);

create table dlhaug7343.Stadiums
(
	StadiumID int not null primary key identity(1,1),
	StadiumName varchar(75) not null,
	StreetAddress varchar(100) not null,
	Capacity int not null,
    BuiltOn date not null default(getdate())
);

create table dlhaug7343.SoccerClubs
(
	ClubID int not null primary key identity(1,1),
	LeagueID int null foreign key references dlhaug7343.Leagues(LeagueID),
	StadiumID int null foreign key references dlhaug7343.Stadiums(StadiumID) unique,
	ClubName varchar(100) not null,
	ClubNickName varchar(100) not null,
    FoundedDate date not null default(getdate())
);

create table dlhaug7343.SeasonStats_Club
(
	SeasonID int not null primary key identity(1,1),
	ClubID int null foreign key references dlhaug7343.SoccerClubs(ClubID),
	SeasonYear int not null default(2019),
	TablePosition int not null default(1) check (TablePosition >= 1),
	TotalMatches int not null default(0) check (TotalMatches >= 0),
	GoalsScored int not null default(0) check (GoalsScored >= 0),
	GoalsAllowed int not null default(0) check (GoalsAllowed >= 0)
);

create table dlhaug7343.StaffRoles
(
	StaffRoleID int not null primary key identity(1,1),
	DirectSuperiorID int null foreign key references dlhaug7343.StaffRoles(StaffRoleID), --Foreign key to the role that is directly above it, within the same table
	JobTitle varchar(100) not null,
	JobDescription varchar(500) not null,
    HoursPerWeek int not null default(40)
);

create table dlhaug7343.StaffMembers
(
	StaffID int not null primary key identity(1,1),
	StaffRoleID int null foreign key references dlhaug7343.StaffRoles(StaffRoleID),
	ClubID int null foreign key references dlhaug7343.SoccerClubs(ClubID),
	FirstName varchar(50) not null,
	LastName varchar(50) not null,
    DateOfBirth date not null
);

create table dlhaug7343.Fans
(
	FanID int not null primary key identity(1,1),
	FirstName varchar(50) not null,
	LastName varchar(50) not null,
	Nationality varchar(100) not null,
	DateOfBirth date not null
);

create table dlhaug7343.FanList
(
	ListID int not null primary key identity(1,1),
	FanID int null foreign key references dlhaug7343.Fans(FanID),
	ClubID int null foreign key references dlhaug7343.SoccerClubs(ClubID),
	HasSeasonTicket bit not null,
    SeasonTicketSeat int null default(null) -- Should be null if HasSeasonTicket is false
);

create table dlhaug7343.PlayerPosition
(
	PositionID int not null primary key identity(1,1),
	PositionName varchar(50) not null unique, -- Only want one record for each position
	PositionDescription varchar(200) not null,
	AreaOnField varchar(75) not null,
	PositionAbbreviation varchar(10) not null
);

create table dlhaug7343.Players
(
	PlayerID int not null primary key identity(1,1),
	ClubID int null foreign key references dlhaug7343.SoccerClubs(ClubID),
	PositionID int null foreign key references dlhaug7343.PlayerPosition(PositionID),
	FirstName varchar(50) not null,
	LastName varchar(50) not null,
	Nationality varchar(100) not null,
	DateOfBirth date not null
);

create table dlhaug7343.SeasonStats_Player
(
	SeasonID int not null primary key identity(1,1),
	PlayerID int null foreign key references dlhaug7343.Players(PlayerID),
	SeasonYear int not null default(2019),
	Appearances int not null default(0) check (Appearances >= 0),
	Goals int not null default(0) check (Goals >= 0),
	Assists int not null default(0) check (Assists >= 0),
	Saves int null default(null) check ((Saves >= 0) or (Saves is null))
);

/*
drop table dlhaug7343.SeasonStats_Player
drop table dlhaug7343.Players
drop table dlhaug7343.PlayerPosition
drop table dlhaug7343.FanList
drop table dlhaug7343.Fans
drop table dlhaug7343.StaffMembers
drop table dlhaug7343.StaffRoles
drop table dlhaug7343.SeasonStats_Club
drop table dlhaug7343.SoccerClubs
drop table dlhaug7343.Stadiums
drop table dlhaug7343.Leagues

drop procedure dlhaug7343.ExpandStadiumCapacity
drop procedure dlhaug7343.FireStaffMember
*/

/**********************************************************************
	CREATE STORED PROCEDURE SECTION
**********************************************************************/

go

create procedure dlhaug7343.ExpandStadiumCapacity (
	@StadiumID int,
	@NumberOfAddedSeats int
)
as
begin
	update dlhaug7343.Stadiums
	set Capacity = Capacity + @NumberOfAddedSeats
	where StadiumID = @StadiumID;
end

go

create procedure dlhaug7343.FireStaffMember (
	@StaffID int
)
as
begin
	delete 
		from dlhaug7343.StaffMembers
	where 
		StaffID = @StaffID;
end

go

/**********************************************************************
	DATA POPULATION SECTION
**********************************************************************/
--Only two reference variables are generally needed since each table has at most 2 FKs
declare @FKReference1 int -- Mainly used to hold the reference to the PK of the SoccerClub
declare @FKReference2 int

insert into dlhaug7343.StaffRoles
values (null, 'Owner', 'Responible for the financial stability of the club and for maintaining standards set forth by the league', 15);
set @FKReference2 = @@Identity; --Holds reference to the PK of StaffRoles

insert into dlhaug7343.StaffRoles
values (@FKReference2, 'CEO', 'Responible for development and accreditation of the club and for governing the status of the club as a whole', 50);
set @FKReference2 = @@Identity; --Holds reference to the PK of StaffRoles

insert into dlhaug7343.StaffRoles
values (@FKReference2, 'Manager', 'Responible for coaching the players while also managing matters off-the-field', 55);
set @FKReference2 = @@Identity; --Holds reference to the PK of StaffRoles

insert into dlhaug7343.StaffRoles
values (@FKReference2, 'Assistant Manager', 'Responible for helping coach the players and giving more 1-on-1 assistance', 45),
	   (@FKReference2, 'Medical Staff', 'Responible for performing necessary physical treatment to players and helping to prevent further injuries', 40);

insert into dlhaug7343.PlayerPosition
values ('Striker', 'Plays generally as the main goalscorer for the team', 'Attacking Third', 'ST'),
	   ('Right Winger', 'Plays as a winger on the right side of the field', 'Attacking Third', 'RW'),
	   ('Left Winger', 'Plays as a winger on the left side of the field', 'Attacking Third', 'LW'),
	   ('Central Midfielder', 'Plays in the middle of the field and acts as the connection between the defense and the attack', 'Middle Third', 'CM'),
	   ('Center-Back', 'Plays right in front of the goal keeper as the last line of defense', 'Defensive Third', 'CB'),
	   ('Left-Back', 'Plays on the left side of the field along the sideline and can either take up a more attacking or defensive role', 'Defensive Third', 'LB'),
	   ('Right-Back', 'Plays on the right side of the field along the sideline and can either take up a more attacking or defensive role', 'Defensive Third', 'RB'),
	   ('Goal Keeper', 'The only position on the field where the player can touch the ball with their hands', 'Defensive Third', 'GK');

/*********************************************************************************************************************/

insert into dlhaug7343.Leagues 
values ('Major League Soccer', 'United States', 24, '1993-12-17');
set @FKReference1 = @@Identity; --Holds reference to the PK of Leagues

insert into dlhaug7343.Stadiums
values ('Mercedes-Benz Stadium', '1 AMB Drive Northwest', 71000, '2017-08-26');
set @FKReference2 = @@Identity; --Holds reference to the PK of Stadiums

insert into dlhaug7343.SoccerClubs
values (@FKReference1, @FKReference2, 'Atlanta United', 'The Five Stripes', '2014-04-16');
set @FKReference1 = @@Identity; --Holds reference to the PK of SoccerClubs

insert into dlhaug7343.SeasonStats_Club
values (@FKReference1, 2018, 2, 34, 70, 44);

insert into dlhaug7343.StaffMembers
values ((select StaffRoleID from dlhaug7343.StaffRoles where JobTitle = 'Owner'), @FKReference1, 'Arthur', 'Blank', '1942-09-27');

insert into dlhaug7343.Fans
values ('John', 'Derval', 'United States of America', '1999-02-20');
set @FKReference2 = @@Identity; --Holds reference to the PK of Fans

insert into dlhaug7343.FanList
values (@FKReference2, @FKReference1, 1, 314);

insert into dlhaug7343.Fans
values ('Eszter', 'Endre', 'Hungary', '1988-08-08');
set @FKReference2 = @@Identity; --Holds reference to the PK of Fans

insert into dlhaug7343.FanList
values (@FKReference2, @FKReference1, 0, null);

insert into dlhaug7343.Players
values (@FKReference1, (select PositionID from dlhaug7343.PlayerPosition where PositionAbbreviation = 'ST'), 'Josef', 'Martinez', 'Venezuela', '1993-05-19');
set @FKReference2 = @@Identity; --Holds reference to the PK of Players

insert into dlhaug7343.SeasonStats_Player
values (@FKReference2, 2018, 34, 31, 6, null);

/*********************************************************************************************************************/

insert into dlhaug7343.Leagues 
values ('La Liga', 'Spain', 20, '1929-04-25');
set @FKReference1 = @@Identity; --Holds reference to the PK of Leagues

insert into dlhaug7343.Stadiums
values ('Camp Nou', 'C. d''Aristides Maillol 12', 99354, '1957-09-24');
set @FKReference2 = @@Identity; --Holds reference to the PK of Stadiums

insert into dlhaug7343.SoccerClubs
values (@FKReference1, @FKReference2, 'FC Barcelona', 'Blaugrana', '1899-11-29');
set @FKReference1 = @@Identity; --Holds reference to the PK of SoccerClubs

insert into dlhaug7343.SeasonStats_Club
values (@FKReference1, 2015, 1, 38, 112, 29);

insert into dlhaug7343.StaffMembers
values ((select StaffRoleID from dlhaug7343.StaffRoles where JobTitle = 'Manager'), @FKReference1, 'Luis', 'Enrique', '1970-05-08');

insert into dlhaug7343.Fans
values ('Ariel', 'Gonzalo', 'Spain', '1994-01-12');
set @FKReference2 = @@Identity; --Holds reference to the PK of Fans

insert into dlhaug7343.FanList
values (@FKReference2, @FKReference1, 1, 1273);

insert into dlhaug7343.Players
values (@FKReference1, (select PositionID from dlhaug7343.PlayerPosition where PositionAbbreviation = 'RW'), 'Lionel', 'Messi', 'Argentina', '1987-06-24');
set @FKReference2 = @@Identity; --Holds reference to the PK of Players

insert into dlhaug7343.SeasonStats_Player
values (@FKReference2, 2011, 37, 50, 16, null);

/*********************************************************************************************************************/

insert into dlhaug7343.Leagues 
values ('Premier League', 'England', 20, '1992-02-20');
set @FKReference1 = @@Identity; --Holds reference to the PK of Leagues

insert into dlhaug7343.Stadiums
values ('Old Trafford', 'Sir Matt Busby Way', 76000, '1910-02-19');
set @FKReference2 = @@Identity; --Holds reference to the PK of Stadiums

insert into dlhaug7343.SoccerClubs
values (@FKReference1, @FKReference2, 'Manchester United FC', 'The Red Devils', '1878-02-12');
set @FKReference1 = @@Identity; --Holds reference to the PK of SoccerClubs

insert into dlhaug7343.SeasonStats_Club
values (@FKReference1, 2007, 1, 38, 80, 22);

insert into dlhaug7343.StaffMembers
values ((select StaffRoleID from dlhaug7343.StaffRoles where JobTitle = 'Manager'), @FKReference1, 'Jose', 'Mourinho', '1963-01-26'),
	   ((select StaffRoleID from dlhaug7343.StaffRoles where JobTitle = 'Assistant Manager'), @FKReference1, 'Rui', 'Faria', '1975-06-14');

insert into dlhaug7343.Fans
values ('Geordie', 'Raymond', 'England', '1979-07-16');
set @FKReference2 = @@Identity; --Holds reference to the PK of Fans

insert into dlhaug7343.FanList
values (@FKReference2, @FKReference1, 1, 100),
	   (@FKReference2, (select ClubID from dlhaug7343.SoccerClubs where ClubName = 'Atlanta United'), 0, null);

insert into dlhaug7343.Players
values (@FKReference1, (select PositionID from dlhaug7343.PlayerPosition where PositionAbbreviation = 'GK'), 'David', 'de Gea', 'Spain', '1990-11-07');
set @FKReference2 = @@Identity; --Holds reference to the PK of Players

insert into dlhaug7343.SeasonStats_Player
values (@FKReference2, 2017, 37, 0, 0, 115);

/*********************************************************************************************************************/
 
insert into dlhaug7343.Leagues 
values ('Bundesliga', 'Germany', 18, '1962-07-28');
set @FKReference1 = @@Identity; --Holds reference to the PK of Leagues

insert into dlhaug7343.Stadiums
values ('Allianz Arena', 'Werner-Heisenberg-Allee 25', 75000, '2005-05-30');
set @FKReference2 = @@Identity; --Holds reference to the PK of Stadiums

insert into dlhaug7343.SoccerClubs
values (@FKReference1, @FKReference2, 'FC Bayern Munich', 'Der FCB', '1900-02-27');
set @FKReference1 = @@Identity; --Holds reference to the PK of SoccerClubs

insert into dlhaug7343.SeasonStats_Club
values (@FKReference1, 2010, 3, 34, 81, 40);

insert into dlhaug7343.StaffMembers
values ((select StaffRoleID from dlhaug7343.StaffRoles where JobTitle = 'Medical Staff'), @FKReference1, 'Hans-Willhelm', 'Müller-Wohlfahrt', '1942-08-12');

insert into dlhaug7343.Fans
values ('Kendrick', 'Doris', 'German', '1934-03-01');
set @FKReference2 = @@Identity; --Holds reference to the PK of Fans

insert into dlhaug7343.FanList
values (@FKReference2, @FKReference1, 0, null)

insert into dlhaug7343.Players
values (@FKReference1, (select PositionID from dlhaug7343.PlayerPosition where PositionAbbreviation = 'CM'), 'Thiago', 'Alcântara', 'Spain', '1991-04-11');
set @FKReference2 = @@Identity; --Holds reference to the PK of Players

insert into dlhaug7343.SeasonStats_Player
values (@FKReference2, 2016, 27, 6, 5, null);

/*********************************************************************************************************************/

insert into dlhaug7343.Leagues 
values ('Serie A', 'Italy', 20, '1898-01-22');
set @FKReference1 = @@Identity; --Holds reference to the PK of Leagues


insert into dlhaug7343.Stadiums
values ('Allianz Stadium', 'Corso Gaetano Scirea 50', 41507, '2011-09-08');
set @FKReference2 = @@Identity; --Holds reference to the PK of Stadiums

insert into dlhaug7343.SoccerClubs
values (@FKReference1, @FKReference2, 'Juventus F.C.', 'Juve', '1897-11-01');
set @FKReference1 = @@Identity; --Holds reference to the PK of SoccerClubs

insert into dlhaug7343.SeasonStats_Club
values (@FKReference1, 2010, 7, 38, 57, 47);

insert into dlhaug7343.StaffMembers
values ((select StaffRoleID from dlhaug7343.StaffRoles where JobTitle = 'CEO'), @FKReference1, 'Giuseppe', 'Marotta', '1957-03-25');

insert into dlhaug7343.Players
values (@FKReference1, (select PositionID from dlhaug7343.PlayerPosition where PositionAbbreviation = 'LB'), 'Alex', 'Sandro', 'Brazil', '1991-01-26');
set @FKReference2 = @@Identity; --Holds reference to the PK of Players

insert into dlhaug7343.SeasonStats_Player
values (@FKReference2, 2017, 26, 4, 3, null);

insert into dlhaug7343.Players
values (@FKReference1, (select PositionID from dlhaug7343.PlayerPosition where PositionAbbreviation = 'CB'), 'Giorgio', 'Chiellini', 'Italy', '1984-08-14');
set @FKReference2 = @@Identity; --Holds reference to the PK of Players

insert into dlhaug7343.SeasonStats_Player
values (@FKReference2, 2013, 31, 3, 3, null);

/**********************************************************************
	RUN STORED PROCEDURE SECTION
**********************************************************************/

exec dlhaug7343.ExpandStadiumCapacity @StadiumID = 4, @NumberOfAddedSeats = 123;
exec dlhaug7343.FireStaffMember @StaffID = 3;

/*
-- Values prior to executing any Stored Procedures:
select * from dlhaug7343.Leagues					-- 5 Records
select * from dlhaug7343.Stadiums					-- 5 Records
select * from dlhaug7343.SoccerClubs				-- 5 Records
select * from dlhaug7343.SeasonStats_Club			-- 5 Records
select * from dlhaug7343.StaffRoles					-- 5 Records
select * from dlhaug7343.StaffMembers				-- 6 Records
select * from dlhaug7343.Fans						-- 5 Records
select * from dlhaug7343.FanList					-- 6 Records
select * from dlhaug7343.PlayerPosition				-- 8 Records
select * from dlhaug7343.Players					-- 6 Records
select * from dlhaug7343.SeasonStats_Player			-- 6 Records
*/

/**********************************************************************
	END OF SCRIPT
**********************************************************************/