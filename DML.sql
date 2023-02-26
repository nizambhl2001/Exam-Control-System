insert into Teacher values (1, 'Jack'),
							(2, 'John'),
							(3, 'Mac'),
							(4, 'Steven'),
							(5, 'Rick'),
							(6, 'Frank'),
							(7, 'Hobs');

insert into Student values  (1, 'Rafi'),
							(2, 'Arafat'),
							(3, 'Nahid'),
							(4, 'Tahmin'),
							(5, 'Alif'),
							(6, 'Sujad'),
							(7, 'Jakir');

insert into Venue values (1, 'Building-A'),
						(2, 'Building-B'),
						(3, 'Building-C'),
						(4, 'Building-D'),
						(5, 'Building-E'),
						(6, 'Building-F'),
						(7, 'Building-G');

insert into [Subject] values (1, 'Bangla'),
							(2, 'Math'),
							(3, 'English'),
							(4, 'Physics'),
							(5, 'ICT'),
							(6, 'Higher Math'),
							(7, 'Chemistry');

insert into ExamSchedule values (1, '7:00 AM', '2022/09/01'),
								(2, '8:00 AM', '2022/09/02'),
								(3, '1:00 PM', '2022/06/09'),
								(4, '2:00 PM', '2022/09/09'),
								(5, '5:00 PM', '2022/09/11'),
								(6, '4:00 PM', '2022/09/13'),
								(7, '3:00 PM', '2022/09/16');
insert into Question values (1, 'Poetry', 1),
							(2, 'Trigonometry', 2),
							(3, 'Paragraph', 3),
							(4, 'Vector', 4),
							(5, 'Programming', 5),
							(6, 'Calculus', 6),
							(7, 'Nuclear Fusion', 7);

insert into Result(ResultID, GPA, StudentID) values							
								(1, 4.50, 1),
								(2, 5.00, 2),
								(3, 4.60, 3),
								(4, 3.50, 4),
								(5, 3.70, 5),
								(6, 4.00, 6),
								(7, 4.70, 7);

insert into Room values (1, 101),
						(2, 107),
						(3, 302),
						(4, 405),
						(5, 505),
						(6, 901),
						(7, 219);

insert into ScheduleDetails values (1, 1, 1 ,1, 1, 1),
									(2, 5, 1, 1, 2, 2),
									(3, 2, 2, 2, 3, 3),
									(4, 3, 3, 3, 4, 4),
									(5, 4, 4, 4, 5, 5),
									(6, 5, 5, 5, 6, 6),
									(7, 6, 6, 6, 7, 7);

insert into demoResult values (1, 5.00, 'Passed', 1),
							(2, 5.00, 'Passed', 2),
							(3, 5.00, 'Passed', 3),
							(4, 5.00, 'Passed', 4),
							(5, 5.00, 'Passed', 5),
							(6, 5.00, 'Passed', 6),
							(7, 5.00, 'Passed', 7);

--Exam Schedule--

select e.ExamDate, e.ExamTime, s.SubjectName
from ScheduleDetails sd join ExamSchedule e on sd.ExamID = e.ExamID
join [Subject] s on sd.SubjectID = s.SubjectID

--Student Seat Plan--

select st.StudentID, e.ExamTime, v.VenueName, r.RoomNumber
from ScheduleDetails sd join ExamSchedule e on sd.ExamID = e.ExamID
join Venue v on sd.VenueID = v.VenueID
join Room r on sd.RoomID = r.RoomID
join Student st on sd.StudentID = st.StudentID
order by e.ExamID;

--Teacher Duty Schedule--

select t.TeacherName, s.SubjectName, e.ExamDate, e.ExamTime, v.VenueName, r.RoomNumber
from ScheduleDetails sd join Teacher t on sd.TeacherID = t.TeacherID
join ExamSchedule e on sd.ExamID = e.ExamID
join Venue v on sd.VenueID = v.VenueID
join Room r on sd.RoomID = r.RoomID
join [Subject] s on sd.SubjectID = s.SubjectID;

--Summary Query--
go
select s.StudentID, s.StudentName, r.GPA, r.ResultStatus, avg(r.GPA) as AverageGPA
from ScheduleDetails sd join Student s on sd.StudentID = s.StudentID
join Result r on sd.ResultID = r.ResultID
group by s.StudentID, s.StudentName, r.GPA, r.ResultStatus
having r.GPA < 5.00
go

--merge--
merge into demoResult using Result on demoResult.ResultID = Result.ResultID
	when matched then
		update set demoResult.GPA = Result.GPA,
					demoResult.ResultStatus = Result.ResultStatus
	when not matched then
	insert values (9, 5.00, 'Passed',9);
	
	select * from demoResult

--sub query--

select s.StudentName, sb.SubjectName, e.ExamDate, e.ExamTime
from ScheduleDetails sd join Student s on sd.StudentID = s.StudentID
join [Subject] sb on sd.SubjectID = sb.SubjectID
join ExamSchedule e on sd.ExamID = e.ExamID
where e.ExamID = any(select ExamID from ExamSchedule where ExamID = 1)
