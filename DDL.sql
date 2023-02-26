go

create database ExamRoutineDB

on primary( name = 'ExamRoutineDB_Data_1', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\ExamRoutineDB_Data_1.mdf',
size = 25mb, maxsize = 100mb, filegrowth = 5%)

log on
(name = 'ExamRoutineDB_Log_1', filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\ExamRoutineDB_Log_1.ldf',
size = 2mb, maxsize = 25mb, filegrowth = 1%)

go

use ExamRoutineDB

create table Teacher(
	TeacherID int primary key not null,
	TeacherName varchar(30)
	);

create table Student(
	StudentID int primary key not null,
	StudentName varchar(30)
	);

create table Venue(
	VenueID int primary key not null,
	VenueName varchar(30)
	);

create table [Subject](
	SubjectID int primary key not null,
	SubjectName varchar(30)
	);

create table ExamSchedule(
	ExamID int,
	ExamTime time,
	ExamDate date,
	XI_ExamSchedule int primary key clustered(ExamID)
	);

create table Question(
	QuestionID int primary key not null,
	QuestionTitle varchar(20),
	SubjectID int references [Subject](SubjectID)
	);

create table Result(
	ResultID int primary key not null,
	GPA numeric(8, 2),
	ResultStatus varchar(10),
	StudentID int references Student(StudentID)
	);

create table Room(
	RoomID int primary key not null,
	RoomNumber int
	);

create table ScheduleDetails (
	TeacherID int references Teacher(TeacherID),
	RoomID int references Room(RoomID),
	VenueID int references Venue(VenueID),
	ExamID int references ExamSchedule(ExamID),
	StudentID int references Student(StudentID),
	SubjectID int references [Subject](SubjectID)
	);

create table demoResult(
	ResultID int primary key not null,
	GPA numeric(8,2),
	ResultStatus varchar(10),
	StudentID int references Student(StudentID)
	)

--stored procedure--
go
create proc sp_Student @id int, @name varchar(30) as
	insert into Student values (@id, @name)
go

exec sp_Student 8, 'Shaymol';

go
create proc sp_DeleteStudent @id int as
	delete from Student where Student.StudentID = @id;
go
exec sp_DeleteStudent 8;

go
create proc sp_setResultStatus  as
	update Result set Result.ResultStatus = 'Passed' where Result.GPA > 0.00;
go
exec sp_setResultStatus;

--cte--

go
with CTE_Result as (
	select S.StudentName, r.ResultStatus, r.GPA 
	from Result r join Student s on r.StudentID = s.StudentID
	)
	select * from CTE_Result;
	

--delete record using trancate--

truncate table ScheduleDetails;

--Error Raise using after trigger--

go
create trigger tr_check_total_vanue on Venue after insert, update as
	begin
		if(select VenueID from Venue) > 7
			begin
				raiserror('Error: number of Venue is greater than 7', 16, 1)
				rollback transaction
			end
			delete from Venue where VenueID > 7;
	end
go

--Instead Trigger--

create trigger  updateResultStatus on Result instead of insert
	as
	select s.StudentID, s.StudentName, r.GPA, r.ResultStatus
	from ScheduleDetails sd join Result r on sd.ResultID = r.ResultID
	join Student s on r.StudentID = s.StudentID
go

--table value functoion--
go
create function courseDetails() 
	returns table as
	return
	select s.StudentName, sb.SubjectName, r.GPA, r.ResultStatus
	from ScheduleDetails sd join Student s on sd.StudentID = s.StudentID
	join Result r on sd.StudentID = r.StudentID
	join [Subject] sb on sd.SubjectID = sb.SubjectID
go

--scalar value function--

create function showStudentgpa(@id int)
	returns numeric(8,2) as
	begin
		declare @gpa numeric(8,2)
		select @gpa = GPA from Result
		where Result.StudentID = @id
		return @gpa
	end
go

--multi statement function--
go
create function showStudentDetails(@id int)
	returns @details table (StudentID int, StudentName varchar(30), SubjectName varchar(30), GPA numeric(8,2))
	as
		begin
			insert @details
				select s.StudentID, s.StudentName, sb.SubjectName, r.GPA
				from ScheduleDetails sd join Student s on sd.StudentID = s.StudentID
				join Result r on sd.ResultID = r.ResultID
				join [Subject] sb on sd.SubjectID = sb.SubjectID
				where s.StudentID = @id
		return;
		end
	go

--view with encryption--
go
create view TeachersInfo (ID, TeacherName, SubjectName) with encryption as (
	select t.TeacherID, t.TeacherName, s.SubjectName
	from Teacher t join [Subject] s on t.TeacherID = s.SubjectID
	)
go

--view with schemabinding--

go

create view ResultInfo (StudentName, StudentGPA, [Status])
	with Schemabinding as 
		select s.StudentName, r.GPA, r.ResultStatus
		from Student s join Result r on s.StudentID = r.StudentID
	
go

--non-clustered-index--

create nonclustered index XI_Student on Student(StudentName)