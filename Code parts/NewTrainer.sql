-- =============================================
-- Author:      Christopher Kelly
-- Create date: 29/05/2020
-- Description: Stored Procedure to insert new Trainers as they are employed by the Gym
--				and fill in their contact details in an associated child table
-- =============================================	

SET XACT_ABORT ON /*if a Transact-SQL statement raises a run-time error, 
				the entire transaction is terminated and rolled back */
GO

SET ANSI_NULLS ON /*Select statements that use where column_name = NULL 
				will return zero rows. Prevents errors*/
GO
	
SET QUOTED_IDENTIFIER ON

GO

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


Drop Procedure uspNewTrainer
----------------------------------------------------------------------------------------------------
----EXECUTE COMMAND
 
EXEC uspNewTrainer 'Paul', 'Salem', 'M', '04/02/1991', '04/04/2020', '4805238F', 
					'0871111114', 'paulsalem@bigmail.com', '123 Fake Street', 'Bad Name Lane', 'Malarchycity', 'B028HDF'





-- =============================================
-- Author:      Christopher Kelly
-- Create date: 29/05/2020
-- Description: Stored Procedure to update Trainers as they are employed by the Gym
--				and fill in their contact details in an associated child table. Will pass an error if updates are the same
-- =============================================	

SET XACT_ABORT ON /*if a Transact-SQL statement raises a run-time error, 
				the entire transaction is terminated and rolled back */
GO

SET ANSI_NULLS ON /*Select statements that use where column_name = NULL 
				will return zero rows. Prevents errors*/
GO
	
SET QUOTED_IDENTIFIER ON

GO

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

drop proc uspUpdateTrainer

EXEC uspUpdateTrainer '6', 'Pauletta', 'Salem', 'F', '04/02/1991', '04/04/2020', '4805238F', 
				'0871111114', 'paulsalem@bigmail.com', '123 Fake Street', 'Bad Name Lane', 'Malarchycity', 'B028HDF'

