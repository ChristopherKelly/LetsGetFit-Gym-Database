-- =============================================
-- Author:      Christopher Kelly
-- Create date: 30/05/2020
-- Description: Query that contains Code for (Soft) Deleted Member Data View
-- =============================================

CREATE VIEW InactiveRetainedMemberContacts

AS
--Select Name, Phone Number, Email, and Address
SELECT CONCAT(m.MemFirstName,' ',m.MemSurName) as [Former Member Fullname],
	   mcd.MemPhone as [Phone Number],
	   mcd.MemEmail as [Email Address],
	   CONCAT(mcd.MemAddressLine1,', ',mcd.MemAddressLine2,', ',mcd.MemCity,', ', mcd.MemPostcode) as [Full Address] 
FROM Members as m
INNER JOIN [Member Contact Details] as mcd on m.MembershipID = mcd.MembershipID
INNER JOIN [GDPR Settings] as gs on m.MembershipID = gs.MembershipID
--Select Members who want notifications and who are inactive
WHERE (gs.SendNotifications =1) AND (m.IsInactive = 1)
GO


select*from InactiveRetainedMemberContacts



-- =============================================
-- Author:      Christopher Kelly
-- Create date: 30/05/2020
-- Description: Query that contains Codes for two MI Extract versions, one simple and one verbose
-- =============================================


CREATE VIEW MI_Extract_Simple

AS

SELECT 
		-- Select data from Members table
		CONCAT(m.MemFirstName,' ',m.MemSurName) as [Active Member Fullname],

		-- Select data from Programs table
		p.ProgramStartDate as [Program Start Date], p.ProgramDuration as [Program Duration (weeks)], p.ProgramGoal as [Progran Goal],
		
		-- Select data from Trainers table
		CONCAT(t.TrainerFirstName,' ',t.TrainerSurName) as [Trainer Fullname], t.TrainerGender, t.TrainerDOB, t.TrainerStartDate, t.TrainerPPSN,

FROM Members as m
INNER JOIN Programs as p on m.MembershipID = p.MembershipID
INNER JOIN [Workout Session] as ws on p.ProgramID = ws.ProgramID
INNER JOIN Trainers as t on p.TrainerID = t.TrainerID

-- Where the member is not inactive (active)
WHERE (m.IsInactive = 0)





CREATE VIEW MI_Extract_Verbose

AS

SELECT DISTINCT 
		-- Select data from Members table
		CONCAT(m.MemFirstName,' ',m.MemSurName) as [Active Member Fullname], m.MemGender as [Member Gender], m.MemDOB as [Member DOB], m.MemJoinDate as [Member Join Date], 

		-- Select data from Member Contact Details  table
		mcd.MemPhone as [Member Phone Number], mcd.MemEmail as [Member Email Address], CONCAT(mcd.MemAddressLine1,', ',mcd.MemAddressLine2,', ',mcd.MemCity,', ', mcd.MemPostcode) as [Member Full Address], mcd.MemEmergencyPhone as [Member Emergency Contact],

		-- Select data from Members Medical Details table
		mmd.MemIsSmoking as [Member Smoking Status], mmd.MemMedicationDescription as [Member Medication Description], mmd.MemInjuryDescription as [Member Injury Description], mmd.MemDisabilityDescription as [Member Disability Description],

		-- Select data from Member Fitness History table
		mfh.MemBMI as [Member BMI], mfh.MemFatPercent as [Member Body Fat Percentage], mfh.[Mem2.4kmSprintSeconds] as [Member Sprint Test Time (Seconds)], mfh.MemMaximumPushups as [Member Pushup Maximum], mfh.MemMeasurementDate as [Fitness Test Measurement Date],

		-- Select data from GDPR Settings table
		g.SendNotifications as [Allowed Notifications], g.RetainInfo as [Retain info?], 

		-- Select data from Programs table
		p.ProgramStartDate as [Program Start Date], p.ProgramDuration as [Program Duration (weeks)], p.ProgramGoal as [Progran Goal],

		-- Select data from Workout Session table
		ws.WorkoutDay as [Day Number], ws.WorkoutDuration as [Workout Duration],

		-- Select data from Exercises table
		e.ExerciseName as [Exercise Type], se.Repetitions as [Exercise Repetitions], se.[Sets] as [Exercise Sets], se.WeightUsed as [Weight Used], se.Duration as [Exercise Duration], se.RestTime as [Rest Time between Sets],

		-- Select data from Trainers table
		CONCAT(t.TrainerFirstName,' ',t.TrainerSurName) as [Trainer Fullname], t.TrainerGender, t.TrainerDOB, t.TrainerStartDate, t.TrainerPPSN,

		-- Select data from Trainer Contact Details table
		tcd.TrainerPhone, tcd.TrainerEmail, CONCAT(tcd.TrainerAddressLine1,', ',tcd.TrainerAddressLine2,', ',tcd.TrainerCity,', ', tcd.TrainerPostcode) as [Trainer Full Address]

		----Join on all tables
FROM Members as m
INNER JOIN [Member Contact Details] as mcd on m.MembershipID = mcd.MembershipID
INNER JOIN [Member Medical Details] as mmd on m.MembershipID = mmd.MembershipID
INNER JOIN [Member Fitness History] as mfh on m.MembershipID = mfh.MembershipID
INNER JOIN [GDPR Settings] as g on m.MembershipId = g.MembershipID
INNER JOIN Programs as p on m.MembershipID = p.MembershipID
INNER JOIN [Workout Session] as ws on p.ProgramID = ws.ProgramID
INNER JOIN [Session Exercises] as se on ws.SessionID = se.SessionID
INNER JOIN Exercises as e on se.ExerciseID = e.ExerciseID
INNER JOIN Trainers as t on p.TrainerID = t.TrainerID
INNER JOIN [Trainer Contact Details] as tcd on t.TrainerID = tcd.TrainerID

-- Where the member is not inactive (active)
WHERE (m.IsInactive = 0)












