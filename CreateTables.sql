CREATE TABLE [Members] (
  [MembershipID] int Identity (1,1),
  [MemFirstName] varchar(55),
  [MemSurName] varchar(60),
  [Gender] varchar(6),
  [Height] numeric(3),
  [MemJoinDate] date,
  [MemPhoto] varchar(255),
  PRIMARY KEY ([MembershipID])
);

CREATE TABLE [Session Exercises] (
  [SessionID] int,
  [ProgramID] int,
  [Repetitions] tintyint,
  [Sets] tinyint,
  [RestTime] int
);

CREATE INDEX [PK FK] ON  [Session Exercises] ([SessionID], [ProgramID]);

CREATE TABLE [Gym Login] (
  [LoginTime] datetime2,
  [CardID] int,
  [In/Out] bit,
  PRIMARY KEY ([LoginTime])
);

CREATE INDEX [FK] ON  [Gym Login] ([CardID]);

CREATE TABLE [Payments] (
  [PaymentID] int identity(1,1),
  [MembershipID] int,
  [SubscriptionID] int,
  [PaymentMethod] varchar(15),
  [PaymentDate] datetime,
  PRIMARY KEY ([PaymentID])
);

CREATE INDEX [FK] ON  [Payments] ([MembershipID], [SubscriptionID]);

CREATE TABLE [Subscription] (
  [SubsciptionID] int identity(1,1),
  [IncludesClasses] bit,
  [PaymentFrequency] varchar(10),
  [SubscriptionPrice] numeric,
  PRIMARY KEY ([SubsciptionID])
);

CREATE TABLE [Workout Session] (
  [SessionID] int identity(1,1),
  [ProgramID] int,
  [DayOfWeek] tinyint,
  [StartTime] time,
  [WorkoutDuration] int,
  PRIMARY KEY ([SessionID])
);

CREATE INDEX [FK] ON  [Workout Session] ([ProgramID]);

CREATE TABLE [Trainers] (
  [Trainer ID] int identity(1,1),
  [TrainerFirstName] varchar(55),
  [TrainerSurName] varchar(60),
  [TrainerStartDate] date,
  [PPSN] char(8),
  PRIMARY KEY ([Trainer ID])
);

CREATE TABLE [GDPR Settings] (
  [Membership ID] int,
  [SendNotifications] bit,
  [RetainInfo] bit
);

CREATE INDEX [PK FK] ON  [GDPR Settings] ([Membership ID]);

CREATE TABLE [Exercise] (
  [ExerciseID] int identity(1,1),
  [ExerciseName] varchar(25),
  [ExerciseDescription] varchar(255),
  [MuscleGroup] varchar(30),
  [NeedsAssistance] bit,
  PRIMARY KEY ([ExerciseID])
);

CREATE TABLE [Member Medical Details] (
  [Membership ID] int,
  [IsSmoking] bit,
  [MedicationDescription] varchar(255),
  [InjuryDescription] varchar(255),
  [DisabilityDescription] varchar(255)
);

CREATE INDEX [PK FK] ON  [Member Medical Details] ([Membership ID]);

CREATE TABLE [Programs] (
  [ProgramID] int identity(1,1),
  [MembershipID] int,
  [TrainerID] int,
  [ProgramStartDate] date,
  [ProgramDuration] int,
  [ProgramDescription] varchar(255),
  PRIMARY KEY ([ProgramID])
);

CREATE INDEX [FK] ON  [Programs] ([MembershipID], [TrainerID]);

CREATE TABLE [Card] (
  [CardID] int identity(1,1),
  [MembershipID] int,
  [IssueDate] date,
  [IsActive] bit,
  PRIMARY KEY ([CardID])
);

CREATE INDEX [FK] ON  [Card] ([MembershipID]);

CREATE TABLE [Class Type] (
  [ClassTypeID] varchar(15),
  [ClassDescription] varchar(255),
  [ClassDuration] int,
  [TrainerID] int,
  PRIMARY KEY ([ClassTypeID])
);

CREATE INDEX [FK] ON  [Class Type] ([TrainerID]);

CREATE TABLE [Member Contact Details] (
  [Membership ID] int,
  [MemPhone] varchar(15),
  [MemEmail] varchar(155),
  [AddressLine1] varchar(100),
  [AddressLine2] varchar(100),
  [City] varchar(55),
  [Postcode] char(7)
);

CREATE INDEX [PK FK] ON  [Member Contact Details] ([Membership ID]);

CREATE TABLE [Member Fitness History] (
  [MemFitnessHistoryID] int identity(1,1),
  [Membership ID] int,
  [BMI] numeric,
  [FatPercent] numeric,
  [2.4kmSprintTime] numeric,
  [MaximumPushups] tinyint,
  [MeasurementDate] datetime,
  PRIMARY KEY ([MemFitnessHistoryID])
);

CREATE INDEX [FK] ON  [Member Fitness History] ([Membership ID]);

CREATE TABLE [Classes] (
  [ClassID] int indentity(1,1),
  [ClassTypeID] int,
  [Day] varchar(10),
  [Time] time,
  PRIMARY KEY ([ClassID])
);

CREATE INDEX [FK] ON  [Classes] ([ClassTypeID]);

CREATE TABLE [Class Participation] (
  [ClassScheduleID] Int,
  [MembershipID] int
);

CREATE INDEX [PK FK] ON  [Class Participation] ([ClassScheduleID], [MembershipID]);
