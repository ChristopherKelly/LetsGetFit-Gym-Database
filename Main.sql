/*SQL CODE for the LetsGetFit Database Solution
	Version 18
	Author: Christopher Kelly
	Last Update 09/06/2020
*/

/*----------------------------------------------------------------------------------------*/
/*--------------------------------CREATE TABLES-------------------------------------------*/
/*----------------------------------------------------------------------------------------*/

CREATE TABLE [Members] (
  [MembershipID] int Identity (1,1),
  [MemFirstName] varchar(55) NOT NULL,
  [MemSurName] varchar(60) NOT NULL,
  [MemGender] char(1),
  [MemDOB] date,
  [MemJoinDate] date NOT NULL, --value is from getdate()
  [MemPhoto] image,
  [IsInactive] bit NOT NULL DEFAULT 0,
  [IsDeleted] bit NOT NULL DEFAULT 0,
 -- PRIMARY KEY ([MembershipID]) 
);

ALTER TABLE [Members] 
ADD PRIMARY KEY ([MembershipID]);

DROP TABLE [Members]

CREATE TABLE [Member Contact Details] (
  [MembershipID] int,
  [MemPhone] varchar(15) NOT NULL,
  [MemEmail] varchar(155) NOT NULL, 
  [MemAddressLine1] varchar(100) NOT NULL,
  [MemAddressLine2] varchar(100),
  [MemCity] varchar(55) NOT NULL,
  [MemPostcode] char(7),      --Not everyone has a valid postcode
  [MemEmergencyPhone] varchar(15) NOT NULL,
  PRIMARY KEY ([MembershipID]),
  --FOREIGN KEY ([MembershipID]) REFERENCES Members([MembershipID])
										--ON UPDATE CASCADE
);

ALTER TABLE [Member Contact Details]
ADD FOREIGN KEY([MembershipID]) REFERENCES members([MembershipID]);



CREATE TABLE [Member Medical Details] (
  [MembershipID] int,
  [MemIsSmoking] bit NOT NULL,
  [MemMedicationDescription] varchar(1023),
  [MemInjuryDescription] varchar(1023),
  [MemDisabilityDescription] varchar(1023),
  PRIMARY KEY ([MembershipID]),
  FOREIGN KEY ([MembershipID]) REFERENCES Members([MembershipID])
													ON UPDATE CASCADE
);

CREATE TABLE [Member Fitness History] (
  [MemFitnessHistoryID] int identity(1,1),
  [MembershipID] int,
  [MemBMI] decimal(5,2) NOT NULL,
  [MemFatPercent] decimal(3,1) NOT NULL,
  [Mem2.4kmSprintSeconds] decimal(7,3) NOT NULL,
  [MemMaximumPushups] tinyint NOT NULL,
  [MemMeasurementDate] date NOT NULL,
  PRIMARY KEY ([MemFitnessHistoryID]),
  FOREIGN KEY ([MembershipID]) REFERENCES Members([MembershipID])
													ON UPDATE CASCADE
);

CREATE TABLE [GDPR Settings] (
  [MembershipID] int,
  [SendNotifications] bit NOT NULL,
  [RetainInfo] bit NOT NULL,
  PRIMARY KEY ([MembershipID]),
  FOREIGN KEY ([MembershipID]) REFERENCES Members([MembershipID])
													ON UPDATE CASCADE
);

CREATE TABLE [Cards] (
  [CardID] int identity(1,1),
  [MembershipID] int,
  [IssueDate] date NOT NULL,
  [IsInactive] bit NOT NULL DEFAULT 0,
  PRIMARY KEY ([CardID]),
  FOREIGN KEY ([MembershipID]) REFERENCES Members([MembershipID])
													ON UPDATE CASCADE
);

CREATE TABLE [Logins] (
  [LoginTime] datetime2,
  [CardID] int,
  [LoginValid] bit NOT NULL DEFAULT 1
  PRIMARY KEY ([LoginTime]),
  FOREIGN KEY ([CardID]) REFERENCES Cards([CardID])
											ON UPDATE CASCADE
);

CREATE TABLE [Subscriptions] (
  [SubscriptionID] char(8),
  [PaymentFrequency] varchar(10) NOT NULL,
  [SubscriptionPrice] decimal(18,2) NOT NULL,
  PRIMARY KEY ([SubscriptionID])
);

CREATE TABLE [Payments] (
  [PaymentID] int identity(1,1),
  [MembershipID] int NOT NULL,
  [SubscriptionID] char(8) NOT NULL,
  [PaymentMethod] varchar(15) NOT NULL,
  [PaymentDate] datetime NOT NULL,
  [SubscriptionEndDate] datetime NOT NULL,
  [FinalPayment] bit DEFAULT 0, 
  PRIMARY KEY ([PaymentID]),
  FOREIGN KEY ([MembershipID]) REFERENCES Members ([MembershipID])
											ON UPDATE CASCADE,
  FOREIGN KEY ([SubscriptionID]) REFERENCES Subscriptions([SubscriptionID])
											ON UPDATE CASCADE
);

CREATE TABLE [Trainers] (
  [TrainerID] int identity(1,1),
  [TrainerFirstName] varchar(55) NOT NULL,
  [TrainerSurName] varchar(60) NOT NULL,
  [TrainerGender] char(1) NOT NULL,
  [TrainerDOB] date NOT NULL,
  [TrainerStartDate] date NOT NULL,
  [TrainerPPSN] char(8) NOT NULL UNIQUE,
  PRIMARY KEY ([TrainerID])
);

CREATE TABLE [Trainer Contact Details] (
  [TrainerID] int,
  [TrainerPhone] varchar(15) NOT NULL UNIQUE,
  [TrainerEmail] varchar(155) NOT NULL UNIQUE,
  [TrainerAddressLine1] varchar(100) NOT NULL,
  [TrainerAddressLine2] varchar(100) NOT NULL,
  [TrainerCity] varchar(55) NOT NULL,
  [TrainerPostcode] char(7) NOT NULL,
  PRIMARY KEY ([TrainerID]),
  FOREIGN KEY ([TrainerID]) REFERENCES Trainers([TrainerID])
										ON UPDATE CASCADE
);

CREATE TABLE [Programs] (
  [ProgramID] int identity(1,1),
  [MembershipID] int,
  [TrainerID] int,
  [ProgramStartDate] date NOT NULL,
  [ProgramDuration] int NOT NULL,
  [ProgramGoal] varchar(255),
  PRIMARY KEY ([ProgramID]),
  FOREIGN KEY ([MembershipID]) REFERENCES Members ([MembershipID]),
  FOREIGN KEY ([TrainerID]) REFERENCES Trainers ([TrainerID])
										ON UPDATE CASCADE
);

CREATE TABLE [Exercises] (
  [ExerciseID] char(8),
  [ExerciseName] varchar(25) NOT NULL,
  [ExerciseDescription] varchar(1023),
  [MuscleGroup] varchar(30),
  [NeedsAssistance] bit NOT NULL,
  PRIMARY KEY ([ExerciseID])
);

CREATE TABLE [Workout Session] (
  [SessionID] int identity(1,1),
  [ProgramID] int,
  [WorkoutDay] tinyint NOT NULL,
  [WorkoutDuration] smallint NOT NULL,
  PRIMARY KEY ([SessionID]),
  FOREIGN KEY ([ProgramID]) REFERENCES Programs([ProgramID])
									ON UPDATE CASCADE
);

CREATE TABLE [Session Exercises] (
  [SessionID] int NOT NULL,
  [ExerciseID] char(8) NOT NULL,
  [Repetitions] tinyint,
  [Sets] tinyint,
  [WeightUsed] decimal(5,2),
  [Duration] smallint,
  [RestTime] smallint,
  PRIMARY KEY ([SessionID], [ExerciseID]),
  FOREIGN KEY ([SessionID]) REFERENCES [Workout Session] ([SessionID])
												ON UPDATE CASCADE,
  FOREIGN KEY ([ExerciseID]) REFERENCES Exercises([ExerciseID])
											ON UPDATE CASCADE
);

CREATE TABLE [Class Types] (
  [ClassTypeID] char(8),
  [ClassName] varchar(30) NOT NULL,
  [ClassDescription] varchar(1023),
  [ClassDuration] int NOT NULL,
  PRIMARY KEY ([ClassTypeID])
);

CREATE TABLE [Classes] (
  [ClassID] int identity(1,1),
  [ClassTypeID] char(8),
  [ClassDay] char(10) NOT NULL,
  [ClassTime] time NOT NULL,
  [TrainerID] int,
  PRIMARY KEY ([ClassID]),
  FOREIGN KEY ([ClassTypeID]) REFERENCES [Class Types] ([ClassTypeID])
										ON UPDATE CASCADE,
  FOREIGN KEY([TrainerID]) REFERENCES [Trainers]([TrainerID])
										ON UPDATE CASCADE
);

CREATE TABLE [Class Participation] (
  [ClassID] Int,
  [MembershipID] int
  PRIMARY KEY ([ClassID],[MembershipID]),
  FOREIGN KEY ([ClassID]) REFERENCES [Classes] ([ClassID])
									ON UPDATE CASCADE,
  FOREIGN KEY ([MembershipID]) REFERENCES Members([MembershipID])
									ON UPDATE CASCADE
);

/*----------------------------------------------------------------------------------------*/
/*--------------------------------INSERT TEST DATA----------------------------------------*/
/*----------------------------------------------------------------------------------------*/

INSERT INTO Members  VALUES ('Frederick','Gunderson','M','05/24/1984','04/22/2018','C:\Users\Admin\Desktop\Gym Files\Image001','0','0'),
							('Manny','Calzone','M','03/06/1988','12/24/2018','C:\Users\Admin\Desktop\Gym Files\Image002','0','0'),
							('Joel','Young','M','12/01/1999','12/31/2018','C:\Users\Admin\Desktop\Gym Files\Image003','0','0'),
							('Marian','Singer','F','11/27/1989','01/20/2019','C:\Users\Admin\Desktop\Gym Files\Image004','0','0'),
							('Bill','Sharp','M','05/02/2000','06/14/2019','C:\Users\Admin\Desktop\Gym Files\Image005','0','0'),
							('Jonathan','Kelly','M','04/23/1986','06/20/2019','C:\Users\Admin\Desktop\Gym Files\Image006','0','0'),
							('John','Smith','M','05/06/1994','08/18/2019','C:\Users\Admin\Desktop\Gym Files\Image007','0','0'),
							('Hazel','Blunt','F','10/10/1995','09/27/2019','C:\Users\Admin\Desktop\Gym Files\Image008','0','0'),
							('Jane','Wojak','F','06/07/1997','11/23/2019','C:\\Users\\Admin\\Desktop\\Gym Files\\Image009','0','0'),
							('Arnold','Holmstrom','M','07/19/1990','02/13/2020','C:\Users\Admin\Desktop\Gym Files\Image010','0','0')

INSERT INTO [Member Contact Details] VALUES ('1','087205938','fredhead@bigmail.com','123 Bad Street','Worse Lane','Bad City','H08539f','0851287673'),
											('2','016198147','manny@bigmail.com','66 House Lawn','Grass Street','Grenwich','P29338F','0772932829'),
											('3','016099252','joelyoung@bigmail.com','111 Big House','Large Street','New York','G109091','0851041291'),
											('4','981489284','mariansinger@bigmail.com','77 Block A','Way Lawn','Bristol','O205293','0105246792'),
											('5','086103980','billsharp@bigmail.com','87 Fake Street','False Lane','Non City','D520F23','089313418'),
											('6','016290481','jonathankelly@bigmail.com','111 Apartment Block','City Centre','Manchester','F101339','0851381311'),
											('7','087376837','johnsmith@bigmail.com','123 Fake Street','False Lane','Non City','D05H773','0879872535'),
											('8','015835701','hazelblunt@bigmail.com','12 House','Laning Lane','Utopia','P301300','0193857815'),
											('9','083984592','janegund@bigmail.com','APT 94 Bad Block','Rubbish Lane','City of Tears','G085937','0873746823'),
											('10','013920583','arnoldholm@bigmail.com','95 Wayward Street','Donnybrook','Dublin','D045014','105204938')

INSERT INTO [Member Medical Details] VALUES ('1','0','','Tendinitus in left arm. Trouble moving it without restriction.',''),
										('2','0','','Sprained Ankle, need therapy approach','Cannot move well'),
										('3','','','','Vasovagal response to unexpected impacts. Avoid crowded weight rooms.'),
										('4','0','','',''),
										('5','1','','',''),
										('6','1','','',''),
										('7','','Aspirin for pain','',''),
										('8','0','Anti cancer medication','',''),
										('9','1','Niquitin for smoking habit','','Breathing problems from smoking'),
										('10','1','','','')

INSERT INTO [Member Fitness History] VALUES ('1','38.11','20.9','1644.954','14','01/01/2020'),
											('2','39.66','24.8','1866.467','12','01/02/2020'),
											('2','35.55','22.8','1788.415','18','03/02/2020'), --second recording at later date
											('2','33.98','19.6','1714.433','22','05/02/2020'), --third recording at later date
											('3','29.65','22.4','1745.986','24','01/01/2019'),
											('4','24.99','23.3','1844.747','23','12/24/2019'),
											('5','41.44','30.4','2045.255','5','07/15/2019'),
											('6','30.01','20.4','2000.4','19','08/24/2019'),
											('6','29','14','1904.642','30','09/30/2019'),    --second recording at later date
											('7','22.44','10.5','1215.567','25','09/19/2019'),
											('7','19.5','5.4','1050.414','40','04/20/2020'),  --second recording at later date
											('8','35.77','25.3','2034.551','20','08/29/2019'),
											('9','40.44','25.9','1988.578','9','02/01/2020'),
											('10','45.45','27.2','1855.778','21','06/03/2020')

INSERT INTO [GDPR Settings]  VALUES ('1','0','0'),
									('2','0','1'),
									('3','0','1'),
									('4','0','0'),
									('5','1','1'), --Will show up in inactive soft delete
									('6','1','1'),
									('7','0','1'),
									('8','1','0'),
									('9','1','1'), --Would show up, but she still has a subscription
									('10','0','0')


INSERT INTO Cards VALUES ('1','04/22/2018','1'),
						('2','12/24/2018','0'),
						('3','12/31/2018','1'),
						('4','01/20/2019','1'),
						('5','06/14/2019','0'),
						('6','06/20/2019','0'),
						('1','08/17/2019','0'),
						('7','08/18/2019','0'),
						('4','09/23/2019','0'),
						('3','01/14/2020','0'),
						('8','09/27/2019','0'),
						('9','11/23/2019','0'),
						('10','02/13/2020','0')

-- This data insert covers the first time logins and logouts, when the member first joins. Logins for day to day sessions are excluded.
INSERT INTO Logins  VALUES ('04/22/2018 18:44:25.8176','1','1'),
							('04/26/2018 20:11:54.1843','1','1'),
							('12/24/2018 15:32:14.7583','2','1'),
							('12/28/2018 17:14:32.7474','2','1'),
							('12/31/2018 19:44:21.6112','3','1'),
							('01/5/2019 21:15:51.2267','3','1'),
							('01/20/2019 16:43:33.7473','4','1'),
							('02/23/2019 17:55:42.9933','4','1'),
							('06/14/2019 16:25:35.6132','5','1'),
							('07/17/2019 17:43:21.7447','5','1'),
							('06/20/2019 18:12:42.4622','6','1'),
							('07/23/2019 19:11:43.4572','6','1'),
							('08/17/2019 14:55:44.4132','7','1'),
							('09/19/2019 15:53:21.4323','7','1'),
							('08/18/2019 13:23:44.4426','8','1'),
							('02/13/2019 14:25:46.8183','8','1'),
							('09/23/2019 13:22:21.5174','9','1'),
							('07/25/2019 14:45:22.5272','9','1'),
							('01/13/2020 14:52:33.330','1','0'),   --Bad Login from inactive card
							('01/14/2020 15:32:38.4647','10','1'),
							('01/14/2020 16:54:44.9687','10','1'),
							('09/27/2019 18:14:22.4262','11','1'),
							('09/25/2019 19:22:52.4213','11','1'),
							('11/23/2019 13:46:53.1143','12','1'),
							('10/22/2019 14:55:12.8583','12','1'),
							('02/13/2020 16:42:42.8249','13','1'),
							('01/10/2020 18:42:21.5243','13','1')

INSERT INTO Subscriptions VALUES ('SUB00001','Monthly','50'),
								('SUB00002','Quarterly','150'),
								('SUB00003','Annually','600')

INSERT INTO Payments VALUES ('1','SUB00001','Cash','04/22/2018','05/22/2018','0'),
							('1','SUB00003','Cash','05/22/2018','05/22/2019','0'),
							('1','SUB00003','Cash','05/22/2019','05/22/2020','1'),
							('2','SUB00002','Cash','12/24/2018','03/24/2018','0'),
							('2','SUB00003','Cash','03/24/2018','03/24/2019','0'),
							('2','SUB00003','Cash','03/24/2019','03/24/2020','0'),
							('2','SUB00002','Cheque','03/24/2020','06/24/2020','0'),
							('3','SUB00003','Cash','12/31/2018','12/31/2019','0'),
							('3','SUB00002','Cash','12/31/2019','03/31/2020','1'),    --Final Payment
							('4','SUB00001','Standing Order','01/20/2019','02/20/2019','0'),
							('4','SUB00001','Standing Order','02/20/2019','03/20/2019','1'), --Final Payment
							('5','SUB00001','Standing Order','06/14/2019','07/14/2019','0'),
							('5','SUB00001','Standing Order','07/14/2019','08/14/2019','0'),
							('5','SUB00001','Standing Order','08/14/2019','09/14/2019','1'), --Final Payment
							('6','SUB00002','Standing Order','06/20/2019','09/20/2019','0'),
							('6','SUB00002','Standing ORder','09/20/2019','12/20/2019','0'),
							('6','SUB00002','Standing ORder','12/20/2019','03/20/2020','0'),
							('6','SUB00002','Standing ORder','03/20/2020','06/20/2020','0'),
							('7','SUB00002','Cash','08/18/2019','11/18/2019','0'),
							('7','SUB00002','Cash','11/18/2019','02/18/2020','0'),
							('7','SUB00003','Cash','02/18/2020','02/18/2021','1'), --Final Payment
							('8','SUB00003','Cheque','09/27/2019','09/27/2020','0'),
							('9','SUB00001','Cash','11/23/2019','12/23/2020','0'),
							('10','SUB00003','Cheque','02/13/2020','02/13/2020','0')

INSERT INTO Trainers
VALUES ('Bill','Whelan','M','09/12/1990','05/05/2019','7394842A'),
		('Samantha','Sharp','F','06/11/1984','06/03/2019','1497346B'),
		('Marcus','Frederickson','M','12/24/1989','11/11/2019','6273673C'),
		('Holly','Caldwin','F','04/11/1983','02/01/2018','9823741A'),
		('Pontius','Holmstrom','M','08/09/1994','01/04/2020','8376345D')

INSERT INTO [Trainer Contact Details] VALUES ('1','087419839','billwhelan@bigmail.com','123 Fake Drive','Seseme Street','London','P124F12'),
											('2','085012249','samalthasharp@bigmail.com','124 Big House','Great Place','Elvisland','P104092'),
											('3','029582512','marcusfred@bigmail.com','777 Lucky House','Lucky Lane','Casino','H129874'),
											('4','019588914','hollycaldwin@bigmail.com','1 Perfect House','Perfect Lane','Perfect City','J192481'),
											('5','086129841','pontiusholm@bigmail.com','3 Lapland way','Swedenville','Swedencity','K591833')

INSERT INTO Exercises 
		VALUES ('EXR00001','Squat','Weight held on upper back under the neck. Bend the knees while keeping a straight back and stand up straight after reaching a consistent threshold','Upper Legs ','0'),
				('EXR00002','Leg Press','Pushing a weight away from the body with the feet. Achieved using a weight sled.','Upper Legs','0'),
				('EXR00003','Deadlift','Squat down and lift a weight off the floor with the hand ','Upper Legs','0'),
				('EXR00004','Leg Extension','While seated, raise a weight in front of the body with the feet.','Quadriceps','0'),
				('EXR00005','Leg Curl','While lying face down on a bench, raise a weight with the feet towards the buttocks','Hamstrings','0'),
				('EXR00006','Leg Press','While sitting in the leg press machine, push a heavy weight at a 45 degree angle.','Gluteus Maximus','1'),
				('EXR00007','Bench Press','While lying face up on a bench, push weight away from the chest. Heavy weights require spotting in case of overload.','Upper Chest','1'),
				('EXR00008','Incline Bench Press','While lying at an angle on a bench, push weight away from the chest. Heavy weights require spotting in case of','Upper Chest','1'),
				('EXR00009','Chest Fly','While lying face up on a bench, spread the arms holding weights and bring the arms toegther above the  cehst.','Lower Pectorals','0'),
				('EXR00010','Lateral Pulldown','While seated, pull a wide bar down towards the upper chest or behind the neck.','Arms and Shoulders','0'),
				('EXR00011','Pull Up','Hang from a chin-up bar above the head with the palms facing forward. Pull the body up so the chin reaches the bar.','Arms and Shoulders','0'),
				('EXR00012','Bent Over Row','While leaning over, holld a weight hanging down in one/two hands and pull it up towards the abdomen','Arms and Shoulders','0'),
				('EXR00013','Ab Crunches','While lying face up on the floor with knees bent, curl the shoulders up twoards the pelvis.','Abdominal ','0'),
				('EXR00014','2.4km Sprint','Sprint for 2.4 kilometers to achieve a fast time','','0'),
				('EXR00015','Jogging','Extended jogging session to train endurance','','0')


INSERT INTO Programs  VALUES ('1','1','04/22/2018','6','Weight lifting for bulk mass'),
							('2','4','12/24/2018','8','Weight lifting for shredding body fat'),
							('3','3','12/31/2018','7','Cardio endurance training'),
							('4','2','01/20/2019','6','Weight lifting for bulk mass'),
							('4','2','05/22/2019','7','General Strength training'),  --second training program with same trainer
							('5','4','06/14/2019','8','Fatloss program'),
							('6','3','06/20/2019','6','Weight lifting for bulk mass'),
							('7','3','08/18/2019','7','General Strength training'),
							('7','1','10/23/2019','8','Powerlifting'),				--second training program with different trainer
							('8','2','09/27/2019','8','Weight lifting for shredding body fat'),
							('9','4','11/23/2019','6','Fatloss program'),
							('10','1','02/13/2020','7','Cardio endurance training')

INSERT INTO [Workout Session]  VALUES ('1','1','50'),
									('1','4','30'),   --Second day
									('2','3','20'),
									('3','6','70'),
									('4','1','80'),
									('5','7','40'),
									('6','1','30'),
									('7','4','100'),
									('8','3','110'),
									('8','4','90'),		--Second day
									('9','2','40'),
									('10','6','60'),
									('11','1','70')

INSERT INTO [Session Exercises] VALUES ('1','EXR00001','5','3','60','0','60'),
										('1','EXR00002','12','2','60','0','60'),
										('1','EXR00003','6','3','40','0','90'),
										('2','EXR00007','5','3','80','0','20'),
										('2','EXR00011','12','4','50','0','0'),
										('3','EXR00012','8','3','55','0','90'),
										('4','EXR00001','8','3','55','0','60'),
										('6','EXR00003','8','4','58.75','0','30'),
										('6','EXR00005','2','3','70','0','60'),
										('7','EXR00004','3','3','40','0','45'),
										('8','EXR00010','2','2','20','0','30'),
										('8','EXR00011','4','3','30','0','90'),
										('9','EXR00007','6','3','40','0','0'),
										('10','EXR00002','2','4','50','0','0'),
										('11','EXR00001','6','3','10','0','40'),
										('12','EXR00004','8','4','20','0','45'),
										('13','EXR00007','3','3','60','0','5'),
										('13','EXR00015','0','0','0','30','0')


INSERT INTO [Class Types]
VALUES ('CLA00001','Boxfit','A cardio workout based on the training used for boxing, focusing on toning and fitness','60'),
	    ('CLA00002','Burn','A high-intensity class using a mixture of treadmills and weights for a full-body workout','50'),
		('CLA00003','Dancefit','A fun class to music that improves coordination and cardio fitness','60'),
		('CLA00004','Combo','Boost metabolism, tone and strengthen with a mix of intesnse cardio and resistance training','90'),
		('CLA00005','Fitball','Improve core stability, range of motion, coordination and balance with the use of a fitball and weights','45'),
		('CLA00006','HIIT','An effective workout that goes further to boost strength and metabolism with high intensity interval training','50')

INSERT INTO Classes VALUES ('CLA00001 ','Monday','13:30','1'),
							('CLA00001','Tuesday','14:30','2'),
							('CLA00003','Wednesday','13:00','4'),
							('CLA00004','Thursday','15:30','4'),
							('CLA00005','Friday','16:30','2'),
							('CLA00006','Monday','16:30','1'),
							('CLA00006','Tuesday','17:40','5')

INSERT INTO [Class Participation] VALUES ('1','1'),
										('1','3'),
										('1','5'),
										('1','6'),
										('1','7'),
										('1','8'),
										('2','4'),
										('2','5'),
										('2','6'),
										('4','5'),
										('4','9'),
										('4','10'),
										('5','4'),
										('5','6'),
										('5','7'),
										('6','1'),
										('7','8'),
										('7','9')
GO

/*----------------------------------------------------------------------------------------*/
/*--------------------------------CREATE PROCEDURES----------------------------------------*/
/*----------------------------------------------------------------------------------------*/

-- =============================================
-- GDPR DELETES
--
-- Author:      Christopher Kelly
-- Create date: 01/06/2020
-- Description: uspDeleteMemberRecords passes the membershipID and checks the GDPR boxes. If the membership has an expired subscription the member will be set to inactive. 
-- If the member has indicated their final payment AND they wish their data delete the proc performs several updates on records that are considered subject to GDPR.  
-- Sensitive private information is changed to 'GDPR' or Null when possible

-- The Business use of this procedure will be for a secretary to double check with the gym clients of their GDPR options and their Final Payment
-- and to call the command for that individual. This allows any last minute changes to be made and neccessitates human judgement in its execution.
-- A trigger based procedure or a routine may not screen clients who interprets 'Final Payment' as 'Final for now'. An in person double check can achieve this.

-- As such, the procedure is called for individual memberid's
 
-- =============================================	


	SET XACT_ABORT ON /*if a Transact-SQL statement raises a run-time error, 
					the entire transaction is terminated and rolled back */
	GO

	SET ANSI_NULLS ON /*Select statements that use where column_name = NULL 
				   will return zero rows. Prevents errors*/
	GO
	
	SET QUOTED_IDENTIFIER ON

	GO

CREATE PROC uspDeleteMemberRecords
@MembershipID as int

AS
	BEGIN TRY --Pass to Catch if an error occurs
		BEGIN TRAN --Set 'checkpoint' to reverse to if data insert encounters an error

			--Check if input membership id exists

			IF NOT EXISTS(
				SELECT 1 FROM Members as m 
				WHERE m.MembershipID = @MembershipID
				)
				BEGIN
					RAISERROR('Membership ID does not exist', 13,0)
				END
			ELSE
			
			-- ONLY UPDATE WHEN CURRENT DATE IS PAST FINAL SUBSCRIPTION
			
			DECLARE @SubscriptionEndDate	datetime
			
			-- Get the latest subscription endate, which is calculated from subscription frequency

			SET @SubscriptionEndDate = (
				Select MAX (p.SubscriptionEndDate)
				From Payments as p 
				Where p.MembershipID = @MembershipID
				)

			DECLARE @FinalPayment	bit

			-- Get the latest final payment value using latest sub end date
			SET @FinalPayment = (
				Select p.FinalPayment
				From Payments as p 
				Where p.SubscriptionEndDate = @SubscriptionEndDate AND p.MembershipID = @MembershipID
				)

			--Check if the Member has run out of subscription time
			IF (CONVERT(DATETIME, @SubscriptionEndDate) >= CONVERT(DATETIME, GETDATE()) )
				BEGIN
					RAISERROR('Cannot Delete member data when they still subscribed', 13,0)
				END
			ELSE

			--MEMBER IS PAST PAYMENT DATE, SOFT DELETE
			-----------------------------------------------
			Print 'Subscription has expired, Updating records to Inactive'
			UPDATE Members 
			Set IsInactive = 1 -- SOFT DELETE, set IsDelete to positive value to show its “Deleted” 
			Where MembershipID = @MembershipID
	


			--IF MEMBER SPECIFIED FINAL PAYMENT AND DID NOT TICK GDPR BOX
			----------------------------------------------------------------
			IF (@FinalPayment = 1) AND (Select gs.RetainInfo
										From [GDPR Settings] as gs
										Where gs.MembershipID = @MembershipID)
										 = 0
				
				BEGIN
					--HARD DELETE MEMBER PRIVATE DATA
					----------------------------------------
						UPDATE Members
							SET MemFirstName = 'GDPR',  --Under GDPR compliance, names must be removed.
								MemSurName = 'GDPR',
								MemDOB =   NULL,		-- Date of birth can be inner joined with disparate data, delete it
								MemPhoto = NULL,   --Images can act as identifiers, especially when used with machine learning, must be deleted		
								IsDeleted = 1    --Mark it as deleted to distinguish between an inactive with records 
													--and an inactive with deleted records

							WHERE MembershipID = @MembershipID

						UPDATE [Member Contact Details]
							SET MemPhone = 'GDPR',		--Phone can be cross referenced with online databases, must be deleted
								MemEmail = 'GDPR',		--Email must be deleted
								MemAddressLine1 = 'GDPR',   --Tennancy records can identify client, delete it
								MemAddressLine2 = 'GDPR',
								MemCity = 'GDPR',
								MemPostcode = 'GDPR',
								MemEmergencyPhone = 'GDPR' --Can potentially identify client, emergency contacts are often family
								WHERE MembershipID = @MembershipID

						UPDATE [Member Medical Details]
							SET MemMedicationDescription = 'GDPR',  --Sensitive information, MUST be deleted
								MemInjuryDescription = 'GDPR',		--Sensitive information, MUST be deleted
								MemDisabilityDescription = 'GDPR'   --Sensitive information, MUST be deleted
							WHERE MembershipID = @MembershipID
					END
				ELSE

				
			PRINT 'Transaction Finished'
			COMMIT   --Finish the transaction
	END TRY
	BEGIN CATCH
		--Print error statements to investigate the error that was caught
		PRINT 'Error occured, all changes reversed. Cancelling insert proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO

-- =============================================
-- INSERT TRAINER

-- Author:      Christopher Kelly
-- Create date: 29/05/2020
-- Description: Stored Procedure to insert new Trainers as they are employed by the Gym
--				and fill in their contact details in an associated child table
-- =============================================	

CREATE PROC uspNewTrainer
	--For Trainer table
	@TrainerFirstName	varchar(55),
	@TrainerSurName		varchar(60),
	@TrainerGender		char(1),
	@TrainerDOB			date,
	@TrainerStartDate	date,
	@TrainerPPSN		char(8),
	--For Trainer Contact Details table
	@TrainerPhone	varchar(15),
	@TrainerEmail	varchar(155),
	@TrainerAddressLine1   varchar(100),
	@TrainerAddressLine2   varchar(100),
	@TrainerCity		varchar(55),
	@TrainerPostCode	char(7)

AS
	
	BEGIN TRY  --Pass to Catch if an error occurs
		BEGIN TRAN  --Set 'checkpoint' to reverse to if data insert encounters an error

			/*________________________________________
			         INSERT INTO  TRAINERS TABLE
			__________________________________________*/

			PRINT('Attempting to insert values into Trainers')

			/* Check if the input values are valid to their respective 
			correspondances on the data dictionary */

			IF     (@TrainerGender <> 'M') AND (@TrainerGender <> 'F') AND (@TrainerGender <> 'O') 
				BEGIN
					RAISERROR('Cannot have where gender does not equal "M" for male, "F" for female or "O" for other', 13,0)
				END
			ELSE IF (DATEDIFF(yy, @TrainerDOB, getdate()) < 16) AND  (DATEDIFF(yy, @TrainerDOB, getdate()) > 130) --Must be of 18 age or over and have a valid date of birth for a membership
				BEGIN 
					RAISERROR('Date of birth is invalid for a valid trainer entry', 13, 0)
				END
			ELSE IF (  CONVERT(DATE, @TrainerDOB) > CONVERT(DATE, @TrainerStartDate) ) AND (   CONVERT(DATE, @TrainerStartDate) > CONVERT(DATE, GETDATE())  )
				BEGIN 
					RAISERROR('Start date is not valid. It must be between current date and trainer DOB', 13, 0)
				END
			ELSE IF (LEN(@TrainerPPSN) < 8)
				BEGIN 
					RAISERROR('PPSN must have 8 characters', 13, 0)
				END
			ELSE

			/* Check to see if an entry hasn't already been made for a person.
			   While there is already a unique constraint on PPSN, this is to
			   prevent duplication in the rare event of a ppsn mistype*/
			IF EXISTS(
				SELECT 1 FROM Trainers as t 
				WHERE t.TrainerFirstName = @TrainerFirstName
				AND  t.TrainerSurName = @TrainerSurName
				AND	 t.TrainerGender = @TrainerGender
				AND  t.TrainerDOB = @TrainerDOB
				AND  t.TrainerStartDate = @TrainerStartDate
				)
				BEGIN
					RAISERROR('Data already exists for this person', 13, 0)
				END
			ELSE


				Insert into Trainers (TrainerFirstName, TrainerSurName, TrainerGender, TrainerDOB, TrainerStartDate, TrainerPPSN)
				Values (@TrainerFirstName ,@TrainerSurName,@TrainerGender, (CAST(@TrainerDOB as date)), @TrainerStartDate, @TrainerPPSN)

				IF @@rowcount <>1 
					ROLLBACK TRAN 
				ELSE

				/*________________________________________
					INSERT INTO TRAINER CONTACT DETAILS TABLE
				__________________________________________*/
				PRINT('Attempting to insert values into Trainer Contact Details') 
				
				--Handle some bad inputs for postcode
				IF (LEN(@TrainerPostCode) < 7)
				BEGIN 
					RAISERROR('Postcode must have 7 characters', 13, 0)
				END

				--Use Scope_Identity to pass the trainer ID as a foreign key
				Insert into [Trainer Contact Details] (TrainerID, TrainerPhone, TrainerEmail, TrainerAddressLine1, TrainerAddressLine2, TrainerCity, TrainerPostcode)
				Values (SCOPE_IDENTITY(), @TrainerPhone, @TrainerEmail, @TrainerAddressLine1, @TrainerAddressLine2, @TrainerCity, @TrainerPostCode)
				

				IF @@rowcount <>1 
					ROLLBACK TRAN 
				ELSE
					COMMIT 

	END TRY
	BEGIN CATCH
		PRINT 'Error occured, all changes reversed. Cancelling insert proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO
-- =============================================
-- UPDATE TRAINER

-- Author:      Christopher Kelly
-- Create date: 29/05/2020
-- Description: Stored Procedure to update Trainers 
--				and fill in their contact details in an associated child table. Will pass an error if updates are the same
-- =============================================	

CREATE PROC uspUpdateTrainer
	--For Trainer table
	@TrainerID			int,
	@TrainerFirstName	varchar(55),
	@TrainerSurName		varchar(60),
	@TrainerGender		char(1),
	@TrainerDOB			date,
	@TrainerStartDate	date,
	@TrainerPPSN		char(8),
	--For Trainer Contact Details table
	@TrainerPhone	varchar(15),
	@TrainerEmail	varchar(155),
	@TrainerAddressLine1   varchar(100),
	@TrainerAddressLine2   varchar(100),
	@TrainerCity		varchar(55),
	@TrainerPostCode	char(7)

AS
	
	BEGIN TRY  --Pass to Catch if an error occurs
		BEGIN TRAN  --Set 'checkpoint' to reverse to if data insert encounters an error

			/*________________________________________
			         UPDATE TRAINERS TABLE
			__________________________________________*/

			PRINT('Attempting to Update values into Trainers')

			/* Check if the input values are valid to their respective 
			correspondances on the data dictionary */

			IF     (@TrainerGender <> 'M') AND (@TrainerGender <> 'F') AND (@TrainerGender <> 'O') 
				BEGIN
					RAISERROR('Cannot have where gender does not equal "M" for male, "F" for female or "O" for other', 13,0)
				END
			ELSE IF (DATEDIFF(yy, @TrainerDOB, getdate()) < 16) AND  (DATEDIFF(yy, @TrainerDOB, getdate()) > 130) --Must be of 18 age or over and have a valid date of birth for a membership
				BEGIN 
					RAISERROR('Date of birth is invalid for a valid trainer entry', 13, 0)
				END
			ELSE IF (  CONVERT(DATE, @TrainerDOB) > CONVERT(DATE, @TrainerStartDate) ) AND (   CONVERT(DATE, @TrainerStartDate) > CONVERT(DATE, GETDATE())  )
				BEGIN 
					RAISERROR('Start date is not valid. It must be between current date and trainer DOB', 13, 0)
				END
			ELSE IF (LEN(@TrainerPPSN) < 8)
				BEGIN 
					RAISERROR('PPSN must have 8 characters', 13, 0)
				END
			ELSE



				UPDATE Trainers 
					SET TrainerFirstName = @TrainerFirstName, 
						TrainerSurName = @TrainerSurName,
						TrainerGender = @TrainerGender,
						TrainerDOB = @TrainerDOB,
						TrainerStartDate = @TrainerStartDate,
						TrainerPPSN = @TrainerPPSN
						WHERE TrainerID = @TrainerID

				IF @@rowcount <>1 
					ROLLBACK TRAN 
				ELSE

				/*________________________________________
					UPDATE TRAINER CONTACT DETAILS TABLE
				__________________________________________*/
				PRINT('Attempting to update values in Trainer Contact Details') 
				
				--Handle some bad inputs for postcode
				IF (LEN(@TrainerPostCode) < 7)
				BEGIN 
					RAISERROR('Postcode must have 7 characters', 13, 0)
				END

				UPDATE [Trainer Contact Details] 
					SET TrainerPhone = @TrainerPhone,
						TrainerEmail = @TrainerEmail,
						TrainerAddressLine1 = @TrainerAddressLine1,
						TrainerAddressLine2 = @TrainerAddressLine2,
						TrainerCity = @TrainerCity,
						TrainerPostcode = @TrainerPostcode
						WHERE TrainerID = @TrainerID
				
					COMMIT 

	END TRY
	BEGIN CATCH
		PRINT 'Error occured, all changes reversed. Cancelling insert proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO
-- =============================================
-- INSERT PROGRAM
--
-- Author:      Christopher Kelly
-- Create date: 27/05/2020
-- Description: uspInsertProgram inserts a new program into Program tables
-- =============================================	

CREATE PROC uspInsertProgram
	@MembershipID int,
	@TrainerID int, 
	@ProgramStartDate date, 
	@ProgramDuration smallint,
	@ProgramGoal varchar(255)
AS

	BEGIN TRY  --Pass to Catch if an error occurs
		BEGIN TRAN  --Set 'checkpoint' to reverse to if data insert encounters an error

				/*________________________________________
						  INSERT INTO  PROGRAMS TABLE
				__________________________________________*/
				PRINT('Attempting to insert values into Programs')
				
				/* Check if the input values are valid to their as outlined in the data dictionary */

				IF     (CONVERT(DATE, @ProgramStartDate) < CONVERT(DATE, GETDATE())) --Program can't start before membership date
					BEGIN
						RAISERROR('Cannot Insert time for start of program before membership date', 13,0)
					END
				ELSE IF (@ProgramDuration <= 0) --Program Can't last 0 or less weeks
					BEGIN 
						RAISERROR('Cannot Insert Program duration less or equal to 0', 13, 0)
					END
				ELSE

				-- INSERT INTO PROGRAMS COMMAND
				Insert into Programs (MembershipID, TrainerID, ProgramStartDate, ProgramDuration, ProgramGoal)
				Values (@MembershipID, @TrainerID, (CAST(@ProgramStartDate as date)), @ProgramDuration, @ProgramGoal)


				IF @@rowcount <>1 
					ROLLBACK TRAN  
				ELSE
					PRINT 'Transaction Finished'
					COMMIT   --Finish the transaction


	END TRY
	BEGIN CATCH
		PRINT 'Error occured, all changes reversed. Cancelling insert proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO
-- =============================================
-- UPDATE PROGRAM
--
-- Author:      Christopher Kelly
-- Create date: 27/05/2020
-- Description: uspUpdateProgram updates a program in Program tables
-- =============================================	



CREATE PROC uspUpdateProgram
	@ProgramID int,
	@MembershipID int,
	@TrainerID int, 
	@ProgramStartDate date, 
	@ProgramDuration smallint,
	@ProgramGoal varchar(255)
AS

	BEGIN TRY  --Pass to Catch if an error occurs
		BEGIN TRAN  --Set 'checkpoint' to reverse to if data insert encounters an error

				/*________________________________________
						  UPDATE PROGRAMS TABLE
				__________________________________________*/
				PRINT('Attempting to insert values into Programs')
				
				/* Check if the input values are valid to their as outlined in the data dictionary */

				IF     (CONVERT(DATE, @ProgramStartDate) < CONVERT(DATE, GETDATE())) --Program can't start before membership date
					BEGIN
						RAISERROR('Cannot Insert time for start of program before membership date', 13,0)
					END
				ELSE IF (@ProgramDuration <= 0) --Program Can't last 0 or less weeks
					BEGIN 
						RAISERROR('Cannot Insert Program duration less or equal to 0', 13, 0)
					END
				ELSE

				-- UPDATE PROGRAMS COMMAND

					UPDATE Programs 
					SET TrainerID = @TrainerID, 
						ProgramStartDate = (CAST(@ProgramStartDate as date)),
						ProgramDuration = @ProgramDuration,
						ProgramGoal = @ProgramGoal
						WHERE ProgramID = @ProgramID AND MembershipID = @MembershipID


					COMMIT   --Finish the transaction


	END TRY
	BEGIN CATCH
		PRINT 'Error occured, all changes reversed. Cancelling insert proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO

-- =============================================
-- INSERT MEMBER AND PROGRAM

-- Author:      Christopher Kelly
-- Create date: 27/05/2020
-- Description: Stored procedure that adds a new member with details and earmarks a workout program entry to be 
--				filled with exercise days and exercises in its child tables. 
-- =============================================	

CREATE PROC uspNewMemberWithProgram
	--For Member Table insert
	@MemFirstName varchar(55),
	@MemSurName varchar(60),
	@MemGender char(1),
	@MemDOB date,
	@MemPhoto varchar(255),
	--For Member Contact Details insert
	@MemPhone varchar(15),
	@MemEmail varchar(155),
	@MemAddressLine1 varchar(100),
	@MemAddressLine2 varchar(100),
	@MemCity varchar(55),
	@MemPostcode char(7),
	@MemEmergencyPhone varchar(15),
	--For Member Medical Details insert
	@MemIsSmoking bit,
	@MemMedicationDescription varchar(1023),
	@MemInjuryDescription varchar(1023),
	@MemDisabilityDescription varchar(1023),
	--For Member Fitness History insert
	@MemBMI decimal(5,2),
	@MemFatPercent decimal(3,1),
	@Mem2_4kmSprintSeconds decimal(7,3),
	@MemMaximumPushups tinyint,
	@MemMeasurementDate datetime,
	--For GDPR Settings insert
	@SendNotifications bit,
	@RetainInfo bit,
	--For Program Table insert
	@TrainerID int, 
	@ProgramStartDate date, 
	@ProgramDuration smallint,
	@ProgramGoal varchar(255)
AS

	BEGIN TRY --Pass to Catch if an error occurs
		BEGIN TRAN --Set 'checkpoint' to reverse to if data insert encounters an error

			--Convert dates to same format
			/*________________________________________
			         INSERT INTO  MEMBERS TABLE
			__________________________________________*/

			PRINT('Attempting to insert values into Members')

			/* Check if the input values are valid to their respective 
			correspondances on the data dictionary */

			IF     (@MemGender <> 'M') AND (@MemGender <> 'F') AND (@MemGender <> 'O') 
				BEGIN
					RAISERROR('Cannot Insert where gender does not equal "M" for male, "F" for female or "O" for other', 13,0)
				END
			ELSE IF (DATEDIFF(yy, @MemDOB, getdate()) < 16) AND  (DATEDIFF(yy, @MemDOB, getdate()) > 130) --Must be of 18 age or over and have a valid date of birth for a membership
				BEGIN 
					RAISERROR('Date of birth is invalid for a valid membership applicant', 13, 0)
				END

			ELSE IF @MemDOB = ''
				BEGIN 
					RAISERROR('Date of birth must be entered', 13, 0)
				END
			ELSE

			/* Check to see if an entry hasn't already been made for a person.
			   We assume that a persons name and date of birth is sufficient
			   to produce unique records of different people. */
			IF EXISTS(
				SELECT 1 FROM Members as m 
				WHERE m.MemFirstName = @MemFirstName
				AND   m.MemSurName = @MemSurName
				AND	  m.MemGender = @MemGender
				AND   m.MemDOB = @MemDOB
				)
				BEGIN
					RAISERROR('Data already exists for this person', 13, 0)
				END
			ELSE

				--INSERT INTO MEMBERS COMMAND
				Insert into Members (MemFirstName, MemSurName, MemGender, MemDOB, MemJoinDate, MemPhoto)
				Values (@MemFirstName ,@MemSurName,@MemGender, (CAST(@MemDOB as date)), GETDATE(), @MemPhoto)

				IF @@rowcount <>1 
					ROLLBACK TRAN  
				ELSE

				--Save the membership ID for future use
				DECLARE @MembershipID [Int] 
				SET @MembershipID = SCOPE_IDENTITY()
				/*__________________________________________________
				    INSERT INTO  MEMBER CONTACT DETAILS TABLE
				_________________________________________________*/
				PRINT('Attempting to insert values into Members Contact Details')

				--Handle Bad inputs

				IF (@MemEmergencyPhone = Null)
					BEGIN
						RAISERROR('Emergency contact must be listed for the safety of Members', 13, 0)
					END
				ELSE

				IF EXISTS(
				SELECT 1 FROM [Member Contact Details] as mcd 
				WHERE mcd.MemPhone = @MemPhone
				)
				BEGIN
					RAISERROR('Cannot have duplicate phone numbers', 13, 0)
				END

				IF EXISTS(
				SELECT 1 FROM [Member Contact Details] as mcd 
				WHERE mcd.MemEmail = @MemEmail
				)
				BEGIN
					RAISERROR('Cannot have duplicate emails', 13, 0)
				END

				--Main insert statement
				Insert into [Member Contact Details] (MembershipID, MemPhone, MemEmail, MemAddressLine1, MemAddressLine2, MemCity, MemPostcode, MemEmergencyPhone)
				Values(@MembershipID, @MemPhone, @MemEmail, @MemAddressLine1, @MemAddressLine2, @MemCity, @MemPostcode, @MemEmergencyPhone)

				IF @@rowcount <>1
					ROLLBACK TRAN  
				ELSE

				/*__________________________________________________
				    INSERT INTO  MEMBER MEDICAL DETAILS TABLE
				_________________________________________________*/
				PRINT('Attempting to insert values into Members Medical Details')

				Insert into [Member Medical Details] (MembershipID, MemIsSmoking, MemMedicationDescription, MemInjuryDescription, MemDisabilityDescription)
				Values (@MembershipID, @MemIsSmoking, @MemMedicationDescription, @MemInjuryDescription, @MemDisabilityDescription)

				IF @@rowcount <>1 
					ROLLBACK TRAN  
				ELSE

				/*__________________________________________________
				    INSERT INTO  MEMBER FITNESS HISTORY TABLE
				_________________________________________________*/

				
				--EXEC uspAddMemberFitnessRecord @MembershipID, @MemBMI,  @MemFatPercent, @Mem2_4kmSprintSeconds, @MemMaximumPushups, @MemMeasurementDate

					PRINT('Attempting to insert values into Member Fitness History')

					/* Check if the input values are valid to their respective 
					correspondances on the data dictionary */

					--BMI Must be a postive value
					IF(@MemBMI <0)
						BEGIN
							RAISERROR('BMI must be a positive value', 13, 0)
						END
					--FatPercent must be a postive value between 0-100
					ELSE IF(@MemFatPercent <= 0) OR (@MemFatPercent >= 100)
						BEGIN
							RAISERROR('Fat Percent must lie between 0-100', 13, 0)
						END
					--Time must be a postive value
					ELSE IF(@Mem2_4kmSprintSeconds <= 0)
						BEGIN
							RAISERROR('Time must be a positive value', 13, 0)
						END
					--Pushups must be a positve value
					ELSE IF(@MemMaximumPushups < 0)
						BEGIN
							RAISERROR('Pushups are not allowed to be negative', 13, 0)
						END
					ELSE IF(CONVERT(DATE, @MemMeasurementDate) > CONVERT(DATE, GETDATE()) )
						BEGIN
							RAISERROR('Tests are not allow to take place in the future', 13, 0)
						END
					ELSE 

				INSERT INTO [Member Fitness History] (MembershipID, MemBMI, MemFatPercent, 
							[Mem2.4kmSprintSeconds], MemMaximumPushups, MemMeasurementDate)
				VALUES (@MembershipID, @MemBMI, @MemFatPercent, @Mem2_4kmSprintSeconds, @MemMaximumPushups, @MemMeasurementDate)
				
				IF @@rowcount <>1 
					ROLLBACK TRAN 
				ELSE

				/*__________________________________________________
				    INSERT INTO  GDPR SETTINGS TABLE
				_________________________________________________*/
				PRINT('Attempting to insert values into GDPR Settings')
				
				Insert into [GDPR Settings] (MembershipID, SendNotifications, RetainInfo)
				Values (@MembershipID, @SendNotifications, @RetainInfo)

				IF @@rowcount <>1 
					ROLLBACK TRAN  
				ELSE

				/*________________________________________
						  INSERT INTO  PROGRAMS TABLE
				__________________________________________*/
				EXEC uspInsertProgram @MembershipID, @TrainerID, @ProgramStartDate, @ProgramDuration, @ProgramGoal


					COMMIT   --Finish the transaction
	END TRY
	BEGIN CATCH
		--Print error statements to investigate the error that was caught
		PRINT 'Error occured, all changes reversed. Cancelling insert proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO
-- =============================================
-- UPDATE MEMBER AND PROGRAM

-- Author:      Christopher Kelly
-- Create date: 27/05/2020
-- Description: Stored procedure that Updates a  member and a with details 
-- =============================================	

CREATE PROC uspUpdateMemberWithProgram
	--For Member Table update
	@MembershipID int,
	@MemFirstName varchar(55),
	@MemSurName varchar(60),
	@MemGender char(1),
	@MemDOB date,
	@MemJoinDate date,
	@MemPhoto varchar(255),
	--For Member Contact Details update
	@MemPhone varchar(15),
	@MemEmail varchar(155),
	@MemAddressLine1 varchar(100),
	@MemAddressLine2 varchar(100),
	@MemCity varchar(55),
	@MemPostcode char(7),
	@MemEmergencyPhone varchar(15),
	--For Member Medical Details update
	@MemIsSmoking bit,
	@MemMedicationDescription varchar(1023),
	@MemInjuryDescription varchar(1023),
	@MemDisabilityDescription varchar(1023),
	--For Member Fitness History update
	@MemBMI decimal(5,2),
	@MemFatPercent decimal(3,1),
	@Mem2_4kmSprintSeconds decimal(7,3),
	@MemMaximumPushups tinyint,
	@MemMeasurementDate datetime,
	--For GDPR Settings update
	@SendNotifications bit,
	@RetainInfo bit,
	--For Program Table update
	@ProgramID int,
	@TrainerID int, 
	@ProgramStartDate date, 
	@ProgramDuration smallint,
	@ProgramGoal varchar(255)
AS

	BEGIN TRY --Pass to Catch if an error occurs
		BEGIN TRAN --Set 'checkpoint' to reverse to if data insert encounters an error

			--Convert dates to same format
			/*________________________________________
			         UPDATE MEMBERS TABLE
			__________________________________________*/

			PRINT('Attempting to update values into Members')

			/* Check if the input values are valid to their respective 
			correspondances on the data dictionary */

			IF     (@MemGender <> 'M') AND (@MemGender <> 'F') AND (@MemGender <> 'O') 
				BEGIN
					RAISERROR('Cannot Insert where gender does not equal "M" for male, "F" for female or "O" for other', 13,0)
				END
			ELSE IF (DATEDIFF(yy, @MemDOB, getdate()) < 16) AND  (DATEDIFF(yy, @MemDOB, getdate()) > 130) --Must be of 18 age or over and have a valid date of birth for a membership
				BEGIN 
					RAISERROR('Date of birth is invalid for a valid membership applicant', 13, 0)
				END

			ELSE IF @MemDOB = ''
				BEGIN 
					RAISERROR('Date of birth must be entered', 13, 0)
				END
			ELSE

	

				--UPDATE MEMBERS COMMAND

					UPDATE Members 
					SET MemFirstName = @MemFirstName,
						MemSurName = @MemSurName,
						MemGender = @MemGender,
						MemDOB = @MemDOB,
						MemJoinDate = @MemJoinDate,
						MemPhoto = @MemPhoto
						WHERE MembershipID = @MembershipID

				/*__________________________________________________
				    UPDATE  MEMBER CONTACT DETAILS TABLE
				_________________________________________________*/
				PRINT('Attempting to update values into Members Contact Details')

				--Handle Bad inputs

				IF (@MemEmergencyPhone = Null)
					BEGIN
						RAISERROR('Emergency contact must be listed for the safety of Members', 13, 0)
					END
				ELSE


				--UPDATE MEMBER CONTACT DETAILS COMMAND
					UPDATE [Member Contact Details] 
					SET MemPhone = @MemPhone,
						MemEmail = @MemEmail,
						MemAddressLine1 = @MemAddressLine1,
						MemAddressLine2 = @MemAddressLine2,
						MemCity = @MemCity,
						MemPostcode = @MemPostcode,
						MemEmergencyPhone = @MemEmergencyPhone
						WHERE MembershipID = @MembershipID

				/*__________________________________________________
				    UPDATE MEMBER MEDICAL DETAILS TABLE
				_________________________________________________*/
				PRINT('Attempting to update values into Members Medical Details')

				UPDATE [Member Medical Details]
				SET MemIsSmoking = @MemIsSmoking,
					MemMedicationDescription = @MemMedicationDescription,
					MemInjuryDescription = @MemInjuryDescription,
					MemDisabilityDescription = @MemDisabilityDescription
					WHERE MembershipID = @MembershipID

				/*__________________________________________________
				    UPDATE MEMBER FITNESS HISTORY TABLE
				_________________________________________________*/

				
				--EXEC uspAddMemberFitnessRecord @MembershipID, @MemBMI,  @MemFatPercent, @Mem2_4kmSprintSeconds, @MemMaximumPushups, @MemMeasurementDate

					PRINT('Attempting to update values into Member Fitness History')

					/* Check if the input values are valid to their respective 
					correspondances on the data dictionary */

					--BMI Must be a postive value
					IF(@MemBMI <0)
						BEGIN
							RAISERROR('BMI must be a positive value', 13, 0)
						END
					--FatPercent must be a postive value between 0-100
					ELSE IF(@MemFatPercent <= 0) OR (@MemFatPercent >= 100)
						BEGIN
							RAISERROR('Fat Percent must lie between 0-100', 13, 0)
						END
					--Time must be a postive value
					ELSE IF(@Mem2_4kmSprintSeconds <= 0)
						BEGIN
							RAISERROR('Time must be a positive value', 13, 0)
						END
					--Pushups must be a positve value
					ELSE IF(@MemMaximumPushups < 0)
						BEGIN
							RAISERROR('Pushups are not allowed to be negative', 13, 0)
						END
					ELSE IF(CONVERT(DATE, @MemMeasurementDate) > CONVERT(DATE, GETDATE()) )
						BEGIN
							RAISERROR('Tests are not allow to take place in the future', 13, 0)
						END
					ELSE 

					UPDATE [Member Fitness History]
					SET MemBMI = @MemBMI,
						MemFatPercent = @MemFatPercent,
						[Mem2.4kmSprintSeconds] = @Mem2_4kmSprintSeconds,
						MemMaximumPushups = @MemMaximumPushups,
						MemMeasurementDate = @MemMeasurementDate
						WHERE MembershipID = @MembershipID

				/*__________________________________________________
				    UPDATE  GDPR SETTINGS TABLE
				_________________________________________________*/
				PRINT('Attempting to update values in GDPR Details')
				
				UPDATE [GDPR Settings]
				SET SendNotifications = @SendNotifications,
					RetainInfo = @RetainInfo
					WHERE MembershipID = @MembershipID


				/*________________________________________
						 UPDATE PROGRAMS TABLE
				__________________________________________*/

				EXEC uspUpdateProgram @ProgramID, @MembershipID, @TrainerID, @ProgramStartDate, @ProgramDuration, @ProgramGoal

				COMMIT   --Finish the transaction
	END TRY
	BEGIN CATCH
		--Print error statements to investigate the error that was caught
		PRINT 'Error occured, all changes reversed. Cancelling proc.'
		PRINT 'ERROR NUMBER = ' + CAST(ERROR_NUMBER() AS VARCHAR)
		PRINT 'ERROR SEVERITY = ' + CAST(ERROR_SEVERITY() AS VARCHAR)
		PRINT 'ERROR STATE = ' + CAST(ERROR_STATE() AS VARCHAR)
		PRINT 'ERROR LINE = ' + CAST(ERROR_LINE() AS VARCHAR)
		PRINT 'ERROR MESSAGE = ' + ERROR_MESSAGE()

		ROLLBACK TRAN
	END CATCH
GO


/*----------------------------------------------------------------------------------------*/
/*--------------------------------CREATE VIEWS--------------------------------------------*/
/*----------------------------------------------------------------------------------------*/

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
		CONCAT(t.TrainerFirstName,' ',t.TrainerSurName) as [Trainer Fullname], t.TrainerGender, t.TrainerDOB, t.TrainerStartDate, t.TrainerPPSN

FROM Members as m
INNER JOIN Programs as p on m.MembershipID = p.MembershipID
INNER JOIN [Workout Session] as ws on p.ProgramID = ws.ProgramID
INNER JOIN Trainers as t on p.TrainerID = t.TrainerID

-- Where the member is not inactive (active)
WHERE (m.IsInactive = 0)
GO




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
GO


















/*------------------------------------------------------------------------------------------------------*/

/*--------------------------------CALL PROCEDURES AND VIEWS HERE JENNIFER!-------------------------------*/

/*------------------------------------------------------------------------------------------------------*/

--GDPR SOFT AND/OR HARD DELETE   (This must be done first because of how the test data was arranged)--
-- Input data has expired subscriptions and were left intentionally unprocessed, apply soft and or hard deletes where appropriate
-- Will deliberately encounter errors when subscriptiondate > Current Date
exec uspDeleteMemberRecords 1
exec uspDeleteMemberRecords 2
exec uspDeleteMemberRecords 3
exec uspDeleteMemberRecords 4
exec uspDeleteMemberRecords 5
exec uspDeleteMemberRecords 6
exec uspDeleteMemberRecords 7
exec uspDeleteMemberRecords 8
exec uspDeleteMemberRecords 9
exec uspDeleteMemberRecords 10
-- Quickly Check Answer 
select*from Members
select*from [Member Contact Details]
select*from [Member Medical Details]
select*from [GDPR Settings]

--SOFT DELETE CONTACT INFO VIEW -- 
select*from InactiveRetainedMemberContacts   --Should give a single row for Bill Sharp. Look at input data to see why

--MI EXTRACTS
--Simple version (Contains just active members, programs, trainers)
select*from MI_Extract_Simple
--Verbose version (Contains all data values attached to sister and daughter tables of active members, programs and trainers)
select*from MI_Extract_Verbose


--INSERT TRAINER
EXEC uspNewTrainer 'Paul', 'Salem', 'M', '04/02/1991', '04/04/2020', '4805238F', 
					'0871111114', 'paulsalem@bigmail.com', '123 Fake Street', 'Bad Name Lane', 'Malarchycity', 'B028HDF'
Select*From Trainers --Check Answer


--UPDATE TRAINER
EXEC uspUpdateTrainer '6', 'Pauletta', 'Melas', 'F', '05/03/1992', '05/05/2020', '4805238F', 
				'0871111155', 'paulettasalem@bigmail.com', '123 Real Street', 'Good Name Lane', 'Fantasticity', 'B056GPF'
Select*From Trainers --Check Answer



--INSERT PROGRAM
EXEC uspInsertProgram 3,3, '07/20/2021', 4, 'Beginner Weight Training'
Select*From Programs --Check Answer
--UPDATE PROGRAM
EXEC uspUpdateProgram 13,3,4, '08/21/2022', 9, 'Intermediate Strength Training'
Select*From Programs --Check Answer

--INSERT MEMBER AND PROGRAM
EXEC uspNewMemberWithProgram 
'James', 'Bond', 'M', '04/02/2004', 'C:\Users\Admin\Desktop\Gym Files\Image010',							 --Members Table
'01485953','Jamesbond@bigmail.com', '136 Fake Lane', 'Rubbish Place', 'Smallville', 'H038884', '018449203', --Members Contact
0, 'Doing Fine', 'Doing Fine','Doing Fine',																	--Members Medical
'22.45', '25.5', '514.259', '21', '04/04/2020',															    --Members Fitness
0, 0,																										 --Members GDPR
3, '07/20/2021', 4, 'Beginner Weight Training'																 --New Program

--Check Answer
Select*From Members
Select*From [Member Contact Details]
Select*From [Member Fitness History]
Select*From [GDPR Settings]
select*from Programs

--UPDATE MEMBER AND PROGRAM
EXEC uspUpdateMemberWithProgram 
11,'Jamie', 'Blonde', 'F', '04/02/2005', '06/05/2020', 'C:\Users\Admin\Desktop\Gym Files\Image017',				 --Members Table
'07244621','James007bond@bigmail.com', '136 Real Lane', 'Great Place', 'Bigville', 'H03g884', '34149203', --Members Contact
1, '', '','',																								--Members Medical
'27.45', '26.5', '515.259', '22', '04/05/2020',															    --Members Fitness
1, 1,																										 --Members GDPR
14, 4, '08/21/2021', 5, 'Intermediate weight training'															--New Program

--Check Answers
Select*From Members
Select*From [Member Contact Details]
Select*From [Member Fitness History]
Select*From [GDPR Settings]
select*from Programs










-------------------------DROP TABLES, PROCS AND VIEWS FOR TESTING---------------------------------

Drop Table [Class Participation]
Drop Table [Classes]
Drop Table [Class Types]
Drop Table [Session Exercises]
Drop Table [Workout Session]
Drop table [Exercises]
Drop Table [Programs]
Drop Table [Trainer Contact Details]
Drop Table [Trainers]
Drop Table [Payments]
Drop Table [Subscriptions]
Drop Table [Logins]
Drop Table [Cards]
Drop Table [GDPR Settings]
Drop Table [Member Medical Details]
Drop Table [Member Contact Details]
Drop Table [Member Fitness History]
Drop Table [Members]

drop procedure uspDeleteMemberRecords
drop view InactiveRetainedMemberContacts
drop view MI_Extract_Simple
drop view MI_Extract_Verbose
drop proc uspNewTrainer
drop proc uspUpdateTrainer
drop proc uspInsertProgram
drop proc uspUpdateProgram
drop proc uspNewMemberWithProgram
drop proc uspUpdateMemberWithProgram