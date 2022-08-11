USE [Utils]
GO

/****** Object:  StoredProcedure [dbo].[HandleError]    Script Date: 11/08/2022 10:52:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[HandleError]
	@Message		nvarchar(max) = N'', -- Custom, additional error message
	@RaiseError		bit = false,  -- If true, will raise error with message code below (suggest to use THROW instead)
	@SendEmail		bit = true,   -- If true, will send an email of exception details using params below
	@ErrorMsg		int = 15600,
	@RecipientEmail	nvarchar(max) = N'DBA@mycompany.org',
	@FromEmail		nvarchar(max) = N'Sender Name <sender@mycompany.org>',
	@EmailSubject	nvarchar(max) = N'A SQL Exception Occurred'
AS
BEGIN
    DECLARE @CallingDB	nvarchar(128) = DB_NAME(),
			@SQL		nvarchar(max),
			@HTML		nvarchar(max),
			@Email		nvarchar(max),
			@Proc		nvarchar(200),
			@EXDate		datetime2;

	SET NOCOUNT ON;

	SET @EXDate = GETDATE();

    SELECT TOP 1 @CallingDB = DB_NAME(resource_database_id) 
        FROM sys.dm_tran_locks 
        WHERE request_session_id = @@SPID 
            AND resource_type = 'DATABASE' 
            AND request_owner_type = 'SHARED_TRANSACTION_WORKSPACE' 
        ORDER BY IIF(resource_database_id != DB_ID(), 0, 1);
  
    INSERT INTO SQL_Errors ( [DatabaseName], [Object], [UserName], [ErrorNumber], [ErrorState], [ErrorSeverity], [ErrorLine], [ErrorProcedure], [ErrorMessage], [ErrorDateTime])
    VALUES
	  (@CallingDB,
	   ERROR_PROCEDURE(),
	   SUSER_SNAME(),
	   ERROR_NUMBER(),
	   ERROR_STATE(),
	   ERROR_SEVERITY(),
	   ERROR_LINE(),
	   ERROR_PROCEDURE(),
	   ERROR_MESSAGE() + CASE WHEN ISNULL(@Message, '') <> '' THEN ' Addtional Info: '+@Message END,
	   @EXDate);

	print 'SQL exception occurred in ' + ERROR_PROCEDURE() + CHAR(13) + 
		  '   Line: ' + cast(ERROR_LINE() as varchar) + CHAR(13) + 
		  '   Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR) + CHAR(13) +  
		  '   State: ' + CAST(ERROR_STATE() AS VARCHAR) + CHAR(13) + 
		  '   Error Number: ' + CAST(ERROR_NUMBER() as varchar) + CHAR(13) + 
		  '   Error Message: ' + ERROR_MESSAGE() + CHAR(13);
	
	if ISNULL(@Message, '') <> ''
		print '   Additional Message: '+@Message + CHAR(13);


	if @SendEmail = 1
	BEGIN
		SET @Email = 'A SQL exception has occurred on Server <b>' + @@SERVERNAME + '</b> in Database <b>' + @CallingDB + '</b> Procedure <b>' + ERROR_PROCEDURE() + '</b> at <b>' + cast(@EXDate as varchar) + '</b>.  Additional information below: ';
	
		if @Message is NOT NULL
			SET @Email = @Email + ' Additional Message ' + @Message;

		SET @sql = 'Select top 1 * FROM SQL_Errors where ErrorID = '+CAST(SCOPE_IDENTITY() as varchar);
		exec QueryToHTML 
			@query = @SQL, 
			@HTML=@HTML OUTPUT;

		SET @Email = @Email + '<br><br>' + @HTML

		EXEC msdb.dbo.sp_send_dbmail  
			@recipients=@RecipientEmail,
			@subject=@EmailSubject,
			@body=@Email,
			@body_format='HTML',
			@from_address=@FromEmail
	END

	if @RaiseError = 1
	BEGIN
		SET @Proc = ERROR_PROCEDURE();
		RAISERROR(@ErrorMsg, -1, -1, @Proc);
	END
END
GO

