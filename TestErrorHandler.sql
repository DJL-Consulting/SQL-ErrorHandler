BEGIN TRY
	declare @x int, @y int, @z int;

	set @x = 5;
	set @y = 0;
	set @z = @x/@y;
END TRY
BEGIN CATCH
	exec Utils.dbo.HandleError;
	throw;
END CATCH