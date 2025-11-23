-- =============================================
-- Author:      Christopher Kelly
-- Create date: 27/05/2020
-- Description: Stored procedure that adds a new member with details and earmarks a workout program entry to be 
--				filled with exercise days and exercises in its child tables. To be used in conjunction
--				with, uspAddWorkoutSession and uspAddSessionExercise
-- =============================================	

	SET XACT_ABORT ON /*if a Transact-SQL statement raises a run-time error, 
					the entire transaction is terminated and rolled back */
	GO

	SET ANSI_NULLS ON /*Select statements that use where column_name = NULL 
				   will return zero rows. Prevents errors*/
	GO
	
	SET QUOTED_IDENTIFIER ON

	GO

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


drop procedure uspNewMemberWithProgram
----------------------------------------------------------------------------------------------------
----EXECUTE COMMAND

/* EXEC uspNewMemberWithProgram 'William', 'Bond', 'M', '04/02/2004', 'C:\Users\Admin\Desktop\Gym Files\Image007', 
								'0148953','williambond@bigmail.com', '136 Fake Lane', 'Rubbish Place', 'Smallville', 'H038884', '018649203',  
								3, '06/08/2020', 4, 'Beginner Weight Training'
*/
EXEC uspNewMemberWithProgram 
'James', 'Bond', 'M', '04/02/2004', 'C:\Users\Admin\Desktop\Gym Files\Image007',							 --Members Table
'01485953','Jamesbond@bigmail.com', '136 Fake Lane', 'Rubbish Place', 'Smallville', 'H038884', '018449203', --Members Contact
0, 'Doing Fine', 'Doing Fine','Doing Fine',																	--Members Medical
'22.45', '25.5', '514.259', '21', '04/04/2020',															    --Members Fitness
0, 0,																										 --Members GDPR
3, '07/20/2021', 4, 'Beginner Weight Training'																 --New Program

EXEC uspNewMemberWithProgram 
'Susie', 'Blond', 'F', '04/02/2004', 'C:\Users\Admin\Desktop\Gym Files\Image008',							 --Members Table
'01488953','SusieBlond@bigmail.com', '136 Fake Lane', 'Rubbish Place', 'Smallville', 'H038884', '044559203', --Members Contact
0, 'Doing Fine', 'Doing Fine','Doing Fine',																	--Members Medical
'22.45', '25.5', '514.259', '21', '04/04/2020',															    --Members Fitness
0, 0,																										 --Members GDPR
3, '07/20/2021', 4, 'Beginner Weight Training'	


Select*From [Member Contact Details]
Select*From [Member Fitness History]
Select*From [GDPR Settings]
select*from programs






-- Create date: 27/05/2020
-- Description: Stored procedure that Updates a  member and a with details 
-- =============================================	

	SET XACT_ABORT ON /*if a Transact-SQL statement raises a run-time error, 
					the entire transaction is terminated and rolled back */
	GO

	SET ANSI_NULLS ON /*Select statements that use where column_name = NULL 
				   will return zero rows. Prevents errors*/
	GO
	
	SET QUOTED_IDENTIFIER ON

	GO

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
			         INSERT INTO  MEMBERS TABLE
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

drop proc uspUpdateMemberWithProgram

EXEC uspUpdateMemberWithProgram 
17,'James', 'Bond', 'M', '04/02/2004', '06/04/2020', 'C:\Users\Admin\Desktop\Gym Files\Image007',				 --Members Table
'01485953','Jamesbond@bigmail.com', '136 Fake Lane', 'Rubbish Place', 'Smallville', 'H038884', '018449203', --Members Contact
0, 'Doing Fine', 'Doing Fine','Doing Fine',																	--Members Medical
'22.45', '25.5', '514.259', '21', '04/04/2020',															    --Members Fitness
0, 0,																										 --Members GDPR
19, 3, '07/20/2021', 4, 'Intermediate weight training'															--Members GDPR

select*from members
select*from programs
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