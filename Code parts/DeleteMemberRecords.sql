-- =============================================
-- Author:      Christopher Kelly
-- Create date: 01/06/2020
-- Description: uspDeleteMemberRecords passes the membershipID and performs 
-- several updates on records that are considered subject to GDPR. Sensitive private information is changed to 'GDPR' or Null when possible

-- The Business use of this procedure will be for a secretary to double check with the gym clients of their GDPR options and their Final Payment
-- and to call the command for that individual. This allows any last minute changes to be made and neccessitates human judgement in its execution.
-- A trigger based procedure or a routine may not screen clients who interprets 'Final Payment' as 'Final for now'. An in person double check can achieve this.
 
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
								MemDOB = NULL,		-- Date of birth can be inner joined with disparate data, delete it
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







--- TESTING COMMANDS---

drop procedure uspDeleteMemberRecords
select*from Members
select*from [Member Contact Details] 
select*from [Member Medical Details] 
select*from [GDPR Settings] 
select*from Payments 
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

