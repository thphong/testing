USE [master]
GO
/****** Object:  Database [StoreManagement]    Script Date: 3/30/2016 11:23:45 PM ******/
CREATE DATABASE [StoreManagement]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'StoreManagement', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\StoreManagement.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'StoreManagement_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\StoreManagement_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [StoreManagement] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [StoreManagement].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [StoreManagement] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [StoreManagement] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [StoreManagement] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [StoreManagement] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [StoreManagement] SET ARITHABORT OFF 
GO
ALTER DATABASE [StoreManagement] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [StoreManagement] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [StoreManagement] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [StoreManagement] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [StoreManagement] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [StoreManagement] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [StoreManagement] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [StoreManagement] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [StoreManagement] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [StoreManagement] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [StoreManagement] SET  DISABLE_BROKER 
GO
ALTER DATABASE [StoreManagement] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [StoreManagement] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [StoreManagement] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [StoreManagement] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [StoreManagement] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [StoreManagement] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [StoreManagement] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [StoreManagement] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [StoreManagement] SET  MULTI_USER 
GO
ALTER DATABASE [StoreManagement] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [StoreManagement] SET DB_CHAINING OFF 
GO
ALTER DATABASE [StoreManagement] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [StoreManagement] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [StoreManagement]
GO
/****** Object:  User [storer]    Script Date: 3/30/2016 11:23:45 PM ******/
CREATE USER [storer] FOR LOGIN [storer] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [storer]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [storer]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [storer]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [storer]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [storer]
GO
ALTER ROLE [db_datareader] ADD MEMBER [storer]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [storer]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [storer]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [storer]
GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_BulkUpdate]    Script Date: 3/30/2016 11:23:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-19
-- Description:	Update bulk data
--				exec [dbo].[USP_System_Data_Update]
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_BulkUpdate] 
	@TableName varchar(100) ,-- 'T_Trans_Orders',
	--@Data can't contain :: and ,, and <<>>
	@Data nvarchar(max), -- N'OrderId::1,,OrderCode::EX_0001<<>>OrderId::2,,OrderCode::EX_0002'
	@UserId int 
AS
BEGIN

BEGIN TRANSACTION;

BEGIN TRY
	declare @ObjectDetail nvarchar(max);

	declare object_cursor cursor for 
	select Data 
	from [dbo].[Split](@Data, '<<>>');

	open object_cursor

	fetch next from object_cursor 
	into @ObjectDetail

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		EXEC [dbo].[USP_System_Data_Update]	@TableName, @ObjectDetail, @UserId

		fetch next from object_cursor 
		into @ObjectDetail
	END

	close object_cursor;
	deallocate  object_cursor;

END TRY
BEGIN CATCH


    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	declare @ErrorNumber int = ERROR_NUMBER()
			,@Errormessage nvarchar(2048) = ERROR_MESSAGE()
			,@ErrorState int = ERROR_STATE();
    THROW  @ErrorNumber, @Errormessage, @ErrorState

END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Function_Get]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 12-Dec-15
-- Description:	Get List Data from funtion
-- exec [dbo].[USP_System_Data_Function_Get] @EndRow  = 10, @TextFilter = N'Đơn hàng'
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_Function_Get]
	@UserId int = 0,
	@FunctionName varchar(100) = 'dbo.UFN_System_Get_Menu', --must have dbo.
	@Parameter nvarchar(1000) = N'1',
	@TextFilter nvarchar(1000) = N'',
	@ColumSum varchar(1000) = '',
	@Action varchar(10) = 'get',
	@GlobalOrder varchar(1000) = null,
	@GlobalOrderDirection int = 1,
	@StartRow int = 1,
	@EndRow int = 10
AS
BEGIN
	
	declare @FunctionId int = object_id(@FunctionName);
	declare @Statement nvarchar(max), @WhereStatement nvarchar(max) = '',  @SumStatement varchar(max) = '';
	declare @dataType varchar(20), @columName varchar(100);
	declare @DateFormat varchar (20) = dbo.UFN_System_GetRule('DATE_FORMAT'),
			@DateTimeFormat varchar (20) = dbo.UFN_System_GetRule('DATETIME_FORMAT'),
			@TimeFormat varchar (20) = dbo.UFN_System_GetRule('TIME_FORMAT');

	--build condition statement
	if(len(@TextFilter) > 0)
	begin
		declare @FilterDate datetime, @FilterTime time;
		begin try
		set @FilterDate = dbo.UFN_System_GetDateTime(@TextFilter, @DateTimeFormat);
		set @FilterTime = dbo.UFN_System_GetDateTime(@TextFilter, @TimeFormat);
		end try begin catch 
			--set @FilterDate = NULL; 
		end catch

		declare colums_cursor cursor for 
		select name, TYPE_NAME (user_type_id) as typename
		from sys.columns
		where object_id = @FunctionId

		open colums_cursor

		fetch next from colums_cursor 
		into @columName, @dataType

		while @@FETCH_STATUS = 0
		begin	
			If(@dataType = 'varchar' or @dataType = 'nvarchar')
			begin
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + @columName + ' like '
										+ 'N''%' + @TextFilter + '%''';
			end				
			else If(@dataType = 'datetime' and @FilterDate is not null)
			begin
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + 'convert(date, ' + @columName + ') = '
										+ '''' + convert(varchar(10), @FilterDate, 121) + ''''; 
			end
			else If(@dataType = 'date' and @FilterDate is not null)
			begin
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + @columName + ' = '
										+ '''' + convert(varchar(10), @FilterDate, 121) + ''''; 
			end
			else If(( @dataType = 'time') and @FilterTime is not null)
			begin
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + @columName + ' = '
										+ '''' + convert(varchar(8), @FilterTime) + ''''; 
			end
			else If(@dataType = 'int' and TRY_CAST(@TextFilter as int) is not null)
			begin 
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + @columName + ' = '
										 + @TextFilter ; 
			end
			else If((@dataType = 'float' or @dataType = 'real') and TRY_CAST(@TextFilter as float) is not null)
			begin 
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + @columName + ' = '
										 + @TextFilter ;
			end
			else If((@dataType = 'money') and TRY_CAST(@TextFilter as money) is not null)
			begin 
				set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' or ', ' ') + @columName + ' = '
										 + @TextFilter ;
			end

			fetch next from colums_cursor 
			into @columName, @dataType
		end

		close colums_cursor;
		deallocate  colums_cursor;

	end

	if(@Action = 'count')
	begin
		set @Statement = ' select count(1) as Result ' + 
					   + ' from ' + @FunctionName + '(' + @Parameter + ')'
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
	end
	else if(@Action = 'getall')
	begin
		set @Statement = ' select * ' +
		               + ' from ' + @FunctionName + '(' + @Parameter + ')'
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
					   + iif(len(@GlobalOrder) > 0, ' order by ' + @GlobalOrder + iif(@GlobalOrderDirection < 0, ' DESC ', ' ASC '), '') ;
	end
	
	else if(@Action = 'sum')
	begin

		declare @sumdetail varchar(200);

		declare sumcolums_cursor cursor for 
		select Data 
		from [dbo].[Split](@ColumSum, ';');

		open sumcolums_cursor

		fetch next from sumcolums_cursor 
		into @sumdetail

		WHILE @@FETCH_STATUS = 0
		BEGIN

			set @SumStatement = @SumStatement + iif(len(@SumStatement) > 0, ', ', '') + 'isnull(sum (' + @sumdetail + '),0) as ' + @sumdetail;

			fetch next from sumcolums_cursor 
			into @sumdetail
		END
	
		close sumcolums_cursor;
		deallocate  sumcolums_cursor;

		set @Statement = ' select ' + @SumStatement + ' '
					   + ' from ' + @FunctionName + '(' + @Parameter + ')'
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
	end
	else begin	

		if( @GlobalOrder is null or len(@GlobalOrder) = 0)
		begin
			select top (1) @columName = name
			from sys.columns
			where object_id = @FunctionId

			set @GlobalOrder = @columName;
		end

		set @GlobalOrder = @GlobalOrder + iif(@GlobalOrderDirection < 0, ' DESC ', ' ASC ');

		set @Statement = ' select * from ( select * ' + ', row_number() over (order by ' + @GlobalOrder + ' ) AS RowNum '
		               + ' from ' + @FunctionName + '(' + @Parameter + ')'
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
					   + ') AS Tmp'
					   + ' where [RowNum] between ' + CAST(@StartRow AS varchar(10)) + ' and ' + CAST(@EndRow AS varchar(10));

	end
	
	exec(@Statement);

END


GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_List_Get]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 12-Dec-15
-- Description:	Get List Data
--              Colum start with #, it is temp colum and it's not shown
--				Colum format [Full Colum], [Colum to Get Data optional, if null mean get from first], [Alias oprional], [Filter, optional]
--              exec [dbo].[USP_Common_Data_List_Get]
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_List_Get]
	@UserId int=1,
	@TableName varchar(100),--'T_Trans_Orders',
	@Colums varchar(1000),-- 'OrderCode;StoreId.StoreCode;SoldDate;Cashier.UserName,Cashier;Customer.FirstName,CustomerName;OrderStatus.StatusName;SumMoney;DebtMoney',
	@Condition nvarchar(4000),-- N'T_Trans_Orders.IsActive = 1',
	@OrderColums varchar(1000),-- 'SoldDate DESC',
	@ColumSum varchar(1000) = '',-- 'T_Trans_Orders.SumMoney;T_Trans_Orders.DebtMoney',
	@TextFilter nvarchar(1000),-- = N'12',
	@Action varchar(10) = 'get',
	@GlobalOrder varchar(1000) = null,
	@GlobalOrderDirection int = 1,
	@StartRow int = 1,
	@EndRow int = 10
AS
BEGIN
	declare @Statement nvarchar(max) = '',
			@WhereStatement nvarchar(max) = '',
	        @SelectStatement varchar(max) = '',
	        @SumStatement varchar(max) = '',
			@JoinStatement varchar(max) = '',
			@FilterStatement nvarchar(max) = '';

	declare @DateFormat varchar (20) = dbo.UFN_System_GetRule('DATE_FORMAT'),
			@DateTimeFormat varchar (20) = dbo.UFN_System_GetRule('DATETIME_FORMAT'),
			@TimeFormat varchar (20) = dbo.UFN_System_GetRule('TIME_FORMAT');

	declare @colum varchar(200), @columName varchar(200), @columAlias varchar(200)
			, @isShown bit
		  , @specificColum varchar(200)
	      , @TempTableName varchar(10) = 'TempTable'
		  , @tableCount int = 1;

	declare @FilterDate datetime, @FilterTime time;
	begin try
		set @FilterDate = dbo.UFN_System_GetDateTime(@TextFilter, @DateTimeFormat);
		set @FilterTime = dbo.UFN_System_GetDateTime(@TextFilter, @TimeFormat);
	end try begin catch 
		--set @FilterDate = NULL; 
	end catch

	declare @existedColums table (fullName varchar(200), aliasName varchar(200))
	declare @aliasTable table (tablename varchar(200), aliasName varchar(200))

	insert into @aliasTable
	values (@TableName, @TempTableName);

	set @JoinStatement = 'from ' + @TableName + ' as ' + @TempTableName ;
	set @SelectStatement = '';

	if(len(@GlobalOrder) > 0)
	begin		
		if(CHARINDEX('.', @GlobalOrder) = 0)
		begin
			set @GlobalOrder = @TempTableName + '.' + @GlobalOrder;
		end
		set @OrderColums = @GlobalOrder + iif(@GlobalOrderDirection < 0, ' DESC ', ' ASC ')
		                   + iif(@OrderColums is null, '', ', ' + @OrderColums);
	end
	
	declare colums_cursor cursor for 
	select Data 
	from [dbo].[Split](@Colums, ';');

	open colums_cursor

	fetch next from colums_cursor 
	into @colum

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @columName = null;
		set @isShown = 1;
				
		select rowid, data
		into #EachColum 
		from [dbo].[Split](@colum, ',');

		set @columName = null;
		--set @selectedColum = null;
		set @columAlias = null;

		select @columName = data
		from #EachColum
		where RowId = 1
		
		select @columAlias = data
		from #EachColum
		where RowId = 2
		
		if(left(@columName, 1) = '#')
		begin
			set @isShown = 0;
			set @columName = substring(@columName, 2, len(@columName)-1)			
		end
		else 
		begin
			set @isShown = 1;
		end
				
		declare @existedName varchar(200);
		set @existedName = null;

		select top (1) @existedName = aliasName
		from @existedColums
		where fullName = @columName

		if(@existedName is null)
		begin

			declare joincolums_cursor cursor for 
			select Data 
			from [dbo].[Split](@columName, '.');

			open joincolums_cursor

			fetch next from joincolums_cursor 
			into @specificColum

			declare @columStt int = 0;
			declare @LastColumName varchar(200) = '';
			declare @LastTableName varchar(200) = '';
			declare @LastRealTableName varchar(200) = '';

			while @@FETCH_STATUS = 0
			begin
			
				declare @currTable varchar(100);

				if(@columStt = 0)
				begin 
					set @LastColumName = @specificColum;
					set @LastTableName = @TempTableName;
					set @LastRealTableName = @TableName;
				end
				else 
				begin
				
					set @currTable = @TempTableName + convert(varchar, @tableCount);
					set @tableCount = @tableCount + 1;								
					
					--build join statement
					declare @joinTableName varchar(100) = '', @joinColumName varchar(100) = '';
										
					select @joinTableName = RefTable, @joinColumName = RefColum
					from UFN_System_GetForienKey(@LastRealTableName, @LastColumName)
					
					if(@columStt < @@CURSOR_ROWS)
					begin 

						set @JoinStatement = @JoinStatement + ' left join ' + @joinTableName + ' as ' + @currTable
											 + ' on ' + @LastTableName + '.' + @LastColumName 
											 + ' = ' + @currTable + '.' + @joinColumName;

						insert into @aliasTable
						values (@joinTableName, @currTable);

					end	
						
					set @LastColumName = @joinColumName;			
					set @LastTableName = @currTable;
					set @LastRealTableName = @joinTableName;
				end
				set @columStt = @columStt + 1;

				fetch next from joincolums_cursor 
				into @specificColum			
			end

			set @existedName = @LastTableName + '.' + @specificColum;

			if( @columStt > 1)
			begin
											
				insert into @existedColums
				values (@columName, @existedName)

			end

			close joincolums_cursor;
			deallocate  joincolums_cursor;

		end

		if(@isShown = 1)
		begin

			declare @realColum varchar(200);

			set @realColum = @existedName;

			declare @dataType varchar(20), @realSelectTable varchar(100), @realSelectColum varchar(100), @markSelectColum varchar(100);
			set @dataType = NULL;

			select @realSelectTable = data
			from [dbo].[Split](@realColum, '.')
			where RowId = 1

			select @realSelectColum = data
			from [dbo].[Split](@realColum, '.')
			where RowId = 2

			select @dataType = DATA_TYPE 
			from @aliasTable as alias
			join INFORMATION_SCHEMA.COLUMNS as infoSchema
			on alias.tablename = infoSchema.TABLE_NAME
			where alias.aliasName = @realSelectTable and 
				infoSchema.COLUMN_NAME = @realSelectColum

			If(@dataType = 'datetime')
			begin
				set @markSelectColum = 'FORMAT(' + @realColum +', '''+ @DateTimeFormat +''') as '
										+ iif(len(@columAlias) > 0, @columAlias, @realSelectColum) 
			end
			else If(@dataType = 'date')
			begin
				set @markSelectColum = 'FORMAT(' + @realColum +', '''+ @DateFormat +''') as '  
										+ iif(len(@columAlias) > 0, @columAlias, @realSelectColum)
			end
			else If(@dataType = 'time')
			begin
				set @markSelectColum = 'FORMAT(' + @realColum +', '''+ @TimeFormat +''') as ' 
										+ iif(len(@columAlias) > 0, @columAlias, @realSelectColum)
			end
			else If(@dataType = 'bit')
			begin
				set @markSelectColum = 'CONVERT(varchar, '+ @realColum +') as ' 
										+ iif(len(@columAlias) > 0, @columAlias, @realSelectColum)
			end
			else begin
				set @markSelectColum = @realColum + iif(len(@columAlias) > 0, ' as ' + @columAlias, '')
			end

			--build select statement		
			set @SelectStatement = @SelectStatement + iif(len(@SelectStatement) > 0, ', ', '') + @markSelectColum;

			--build condition statement
			if(len(@TextFilter) > 0)
			begin
				
				If(@dataType = 'varchar' or @dataType = 'nvarchar')
				begin
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + @realColum + ' like '
										+ 'N''%' + @TextFilter + '%''';
				end				
				/*else If(@dataType = 'datetime' and @FilterDate is not null)
				begin
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + 'convert(date, ' + @realColum + ') = '
										+ '''' + convert(varchar(10), @FilterDate, 121) + ''''; 
				end
				else If(@dataType = 'date' and @FilterDate is not null)
				begin
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + @realColum + ' = '
										+ '''' + convert(varchar(10), @FilterDate, 121) + ''''; 
				end
				else If(( @dataType = 'time') and @FilterTime is not null)
				begin
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + @realColum + ' = '
										+ '''' + convert(varchar(8), @FilterTime) + ''''; 
				end
				else If(@dataType = 'int' and TRY_CAST(@TextFilter as int) is not null)
				begin 
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + @realColum + ' = '
										 + @TextFilter ; 
				end
				else If((@dataType = 'float' or @dataType = 'real') and TRY_CAST(@TextFilter as float) is not null)
				begin 
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + @realColum + ' = '
										 + @TextFilter ;
				end
				else If((@dataType = 'money') and TRY_CAST(@TextFilter as money) is not null)
				begin 
					set @FilterStatement = @FilterStatement + iif(len(@FilterStatement) > 0, ' or ', ' ') + @realColum + ' = '
										 + @TextFilter ;
				end*/
			end
		end

		drop table #EachColum;
		
		fetch next from colums_cursor 
		into @colum
	END

	close colums_cursor;
	deallocate  colums_cursor;
	
	declare @fullName varchar(200), @aliasName varchar(200);

	declare replace_cursor cursor for 
	select fullName, aliasName
	from @existedColums

	open replace_cursor

	fetch next from replace_cursor 
	into @fullName, @aliasName

	while @@FETCH_STATUS = 0
	begin
		set @OrderColums = replace(@OrderColums, @fullName, @aliasName);
		set @Condition = replace(@Condition, @fullName, @aliasName);
		set @ColumSum = replace(@ColumSum, @fullName, @aliasName);

		fetch next from replace_cursor 
		into @fullName, @aliasName
	end
	
	set @OrderColums = replace(@OrderColums, @TableName, @TempTableName);
	set @Condition = replace(@Condition, @TableName, @TempTableName);
	set @ColumSum = replace(@ColumSum, @TableName, @TempTableName);

	close replace_cursor;
	deallocate  replace_cursor;


	set @WhereStatement = iif(len(@Condition) > 0, '(' + @Condition + ')', '')
					   + iif(len(@Condition) > 0 and len(@FilterStatement) > 0, ' and (', '') + @FilterStatement
					   + iif(len(@Condition) > 0 and len(@FilterStatement) > 0, ' ) ', '');
	
	if(@Action = 'count')
	begin
		set @Statement = ' select count(1) as Result ' + @JoinStatement
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '');
	end
	else if(@Action = 'getall')
	begin
		set @Statement = ' select ' +	@SelectStatement + ' ' +
		               + @JoinStatement
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
					   + iif(len(@OrderColums) > 0, ' order by ' + @OrderColums, '') ;
	end
	else if(@Action = 'get10')
	begin
		set @Statement = ' select top(10) ' +	@SelectStatement + ' ' +
		               + @JoinStatement
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
					   + iif(len(@OrderColums) > 0, ' order by ' + @OrderColums, '') ;
	end
	else if(@Action = 'sum')
	begin

		declare @sumdetail varchar(200), @sumselectcolum varchar(200), @sumalias varchar(200);

		declare sumcolums_cursor cursor for 
		select Data 
		from [dbo].[Split](@ColumSum, ';');

		open sumcolums_cursor

		fetch next from sumcolums_cursor 
		into @sumdetail

		WHILE @@FETCH_STATUS = 0
		BEGIN

			set @sumselectcolum = null;
			set @sumalias = null;

			select @sumselectcolum = Data 
			from [dbo].[Split](@sumdetail, ',')
			where RowId = 1

			select @sumalias = Data 
			from [dbo].[Split](@sumdetail, ',')
			where RowId = 2

			if(@sumalias is null or len(@sumalias) =  0)
			begin
				select @sumalias = Data 
				from [dbo].[Split](@sumselectcolum, '.')
				where RowId = 2
			end

			set @SumStatement = @SumStatement + iif(len(@SumStatement) > 0, ', ', '') + 'isnull(sum (' + @sumselectcolum + '), 0)' + ' as ' + @sumalias;

			fetch next from sumcolums_cursor 
			into @sumdetail
		END
	
		close sumcolums_cursor;
		deallocate  sumcolums_cursor;


		set @Statement = ' select ' + @SumStatement + ' ' + @JoinStatement
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '');
	end
	else begin
	
		if(@OrderColums is null or len(@OrderColums) = 0 )
		begin
			select @OrderColums = COLUMN_NAME
			from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			where OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
			AND TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo'	
		end

		set @Statement = ' select * from (select ' +	@SelectStatement + ', row_number() over (order by ' + @OrderColums + ' ) AS RowNum ' 
		               + @JoinStatement
					   + iif(len(@WhereStatement) > 0, ' where ' + @WhereStatement, '')
					   + ') AS Tmp'
					   + ' where [RowNum] between ' + CAST(@StartRow AS varchar(10)) + ' and ' + CAST(@EndRow AS varchar(10));
	end

	/*select @Statement
	insert into T_System_TestSQL
	values (@Statement, getdate());*/

	EXECUTE(@Statement)

	--select @Statement
	
END
GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Object_Delete]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-06
-- Description:	delete Object
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_Object_Delete]
	@UserId int = 0,
	@TableName varchar(100),
	@ColumName varchar(100) = '', --If null or empty, get from primary key
	@Value nvarchar(1000),
	@IsHardDelete bit = 0
AS
BEGIN
	if(@ColumName is null or len(@ColumName) = 0)
	begin
		select @ColumName = COLUMN_NAME
		from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
		where OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
		AND TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo'	
	end

	if(@IsHardDelete = 0)
	begin
		exec ('update ' + @TableName + ' set Isactive = 0 where ' + @ColumName + ' = ' + 'N''' + @Value + '''');
	end
	else begin
		exec ('delete ' + @TableName + ' where ' + @ColumName + ' = ' + 'N''' + @Value + '''');
	end

END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Object_Get]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-05
-- Description:	Get Object Detail
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_Object_Get]
	@UserId int = 0,
	@TableName varchar(100),
	@ColumName varchar(100) = '', --If null or empty, get from primary key
	@Value nvarchar(1000)
AS
BEGIN

	declare @DateFormat varchar (20) = dbo.UFN_System_GetRule('DATE_FORMAT'),
			@DateTimeFormat varchar (20) = dbo.UFN_System_GetRule('DATETIME_FORMAT'),
			@TimeFormat varchar (20) = dbo.UFN_System_GetRule('TIME_FORMAT');

	if(@ColumName is null or len(@ColumName) = 0)
	begin
		select @ColumName = COLUMN_NAME
		from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
		where OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
		AND TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo'	
	end

	declare @listcolums varchar(5000);

	select @listcolums = COALESCE(@listcolums + ', ', '') 
					+ CASE DATA_TYPE WHEN 'bit' THEN 'CONVERT(varchar, ' + COLUMN_NAME +') AS ' + COLUMN_NAME
									 WHEN 'date' THEN 'FORMAT(' + COLUMN_NAME +', '''+ @DateFormat+''') AS ' + COLUMN_NAME
									 WHEN 'datetime' THEN 'FORMAT(' + COLUMN_NAME +', '''+ @DateTimeFormat+''') AS ' + COLUMN_NAME
									 WHEN 'time' THEN 'FORMAT(' + COLUMN_NAME +', '''+ @TimeFormat+''') AS ' + COLUMN_NAME
									 ELSE COLUMN_NAME END
	from INFORMATION_SCHEMA.COLUMNS as infoSchema
	where infoSchema.TABLE_NAME = @TableName 

	exec ('select ' + @listcolums + ' from ' + @TableName + ' where ' + @ColumName + ' = ' + 'N''' + @Value + '''');

END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Update]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 12-Dec-15
-- Description:	Update data
--				exec [dbo].[USP_System_Data_Update]
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_Update]
	@TableName varchar(100), -- 'T_Trans_Orders',
	--@Data can't contain :: and ,,
	@Data nvarchar(max), -- N'OrderId::1,,OrderCode::EX_0001,,StoreId::2,,SoldDate::2016-01-14 18:10:34,,Cashier::3,,Customer::4,,OrderStatus::5,,SumMoney::11100000.0000,,DebtMoney::200000.0000,,IsActive::1,,modifiedby::0,,modifieddate::2016-01-14 18:10:34',
	@UserId int
AS
BEGIN

	declare @PrimaryKey varchar(100), @PrimaryKeyValue varchar(10), @errorMesage varchar(1000);
	declare @DataTable table(colum varchar(100), data nvarchar(max));


	select @PrimaryKey = COLUMN_NAME
	from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	where OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo'	


	if(@PrimaryKey is null) 
	begin
		set @errorMesage = 'The table "' + @TableName + '" dont have primary key. Please define primary key (int) for insert value';
		throw 51000, @errorMesage, 1;
	end


	--Parse data
	declare @columDetail nvarchar(max), @ColumName varchar(100);

	declare data_cursor cursor for 
	select Data 
	from [dbo].[Split](@Data, ',,');

	open data_cursor

	fetch next from data_cursor 
	into @columDetail

	WHILE @@FETCH_STATUS = 0
	BEGIN

		select * 
		into #TempData
		from dbo.Split(@columDetail, '::')

		select @ColumName = Data
		from #TempData
		Where rowid = 1

		insert into @DataTable
		select @ColumName, dbo.UFN_System_StandarlizeData(@TableName, @ColumName, Data)
		from #TempData
		Where rowid = 2 

		drop table #TempData;
		
		fetch next from data_cursor 
		into @columDetail
	END

	close data_cursor;
	deallocate  data_cursor;


	--Determine the object is existed or not
	select top(1) @PrimaryKeyValue = data
	from @DataTable
	where colum = @PrimaryKey

	if(@PrimaryKeyValue is null or len(@PrimaryKeyValue) = 0)
	begin
		set @PrimaryKeyValue = '-1'
	end

	declare @isExistedRecord bit = 0;
	declare @SqlStatement nvarchar(max) = N'SELECT TOP 1 @isExistedRecord = 1 from '+ @TableName +' where ' + @PrimaryKey + ' = ' + @PrimaryKeyValue
	exec sp_executesql @SqlStatement, N'@isExistedRecord int out', @isExistedRecord out
	

	-- Process 
	set @SqlStatement = NULL;
	declare @SqlColumUpdate nvarchar(max), @SqlDataUpdate nvarchar(max)
	Declare @result int = -1;
	if( @isExistedRecord = 1)
	begin
		--Update
		set @SqlColumUpdate = NULL;

		SELECT @SqlStatement = COALESCE(@SqlStatement + ', ', '') + colum + IIF(data IS NOT NULL, '= N''' + data + '''', ' = NULL') 
		FROM @DataTable AS A
		JOIN information_schema.columns AS B 
		ON A.colum = B.COLUMN_NAME		
		where  B.table_name = @TableName and A.colum <> @PrimaryKey

		set @SqlStatement = 'update ' + @TableName + ' set ' +
							+ @SqlStatement
							+ ', modifiedby = ''' + convert(varchar(10), @UserId) + ''''
							+ ' , modifieddate = getdate()' 
							+ ' where ' + @PrimaryKey + ' = ' + @PrimaryKeyValue;

		exec(@SqlStatement);

		
		set @result = @PrimaryKeyValue;
	end
	else begin
		--Insert
		set @SqlColumUpdate = NULL;
		set @SqlDataUpdate = NULL;

		SELECT @SqlColumUpdate = COALESCE(@SqlColumUpdate + ', ', '') + colum,
			   @SqlDataUpdate = COALESCE(@SqlDataUpdate + ', ', '') + + IIF(data IS NOT NULL, 'N''' + data + '''', 'NULL')
		FROM @DataTable  AS A
		JOIN information_schema.columns AS B 
		ON A.colum = B.COLUMN_NAME		
		where B.table_name = @TableName and colum not in( @PrimaryKey, 'modifiedby', 'modifieddate', 'createdby', 'createddate')

		set @SqlStatement = 'insert into ' + @TableName + ' ' +
							+ '('  +  @SqlColumUpdate + ' ,createdby, createddate)'
							+ ' values ( ' + @SqlDataUpdate + ',' + convert(varchar(10), @UserId) + ',getdate())';

		exec(@SqlStatement);

		--select @SqlStatement

		set @result = IDENT_CURRENT( @TableName );
	end

	
	select @result as Result

END

GO
/****** Object:  StoredProcedure [dbo].[USP_TEST_DUMMY_DATA]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_TEST_DUMMY_DATA]
AS
BEGIN
	declare @i int = 1;

while(@i < 1000)
begin

INSERT INTO [dbo].[T_Trans_Products]
           ([ProductName]
           ,[ProductCode]
           ,[Quantity]
           ,[Price]
           ,[ProductGroup]
           ,[Provider]
           ,[CreatedBy]
           ,[CreatedDate])
     VALUES
           ('Product test ' + CONVERT(varchar, @i)
           ,'PD000000' + CONVERT(varchar, @i)
           ,(@i * 5) % 15
           ,(((@i * 515) % 11 ) + 1) * 100000
           ,((@i * 107) % 4) + 1
           ,((@i * 17) % 3) + 1           
           ,1
           ,Getdate())

	set @i = @i + 1;

end;



END

GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split]
(
        @RowData nvarchar(max),
        @SplitOn nvarchar(5)
) 
RETURNS @RtnValue table
(
        RowId int identity(1,1),
        Data nvarchar(2000)
)
AS
BEGIN
        Declare @Cnt int
        Set @Cnt = 1
 
        While (Charindex(@SplitOn,@RowData)>0)
        Begin
                Insert Into @RtnValue (data)
                Select
                        Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))
 
                Set @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+len(@SplitOn),len(@RowData))
                Set @Cnt = @Cnt + 1
        End
       
        Insert Into @RtnValue (data)
        Select Data = ltrim(rtrim(@RowData))
 
        Return
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_Get_Menu]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-01-31
-- Description:	Get Menu
		-- select * from dbo.UFN_System_Get_Menu(1)
			
-- =============================================
--drop FUNCTION [dbo].[UFN_System_Get_Menu]
CREATE FUNCTION [dbo].[UFN_System_Get_Menu]
(	
	@User int
)
RETURNS @RtnValue TABLE 
(
    MenuId int,
	Menu nvarchar (200),
	Url  nvarchar (200),
	Parent int,
	[Level] int,
	DisplayOrder int,
	CssClass [varchar](50)
)
AS
BEGIN 

	insert into @RtnValue
	select distinct Menu.[MenuId], Menu.[Menu], Menu.[Url], Menu.[Parent], Menu.[Level], Menu.[DisplayOrder], Menu.[CssClass]
	from dbo.T_System_Menu as Menu
	join dbo.T_System_Role_Menu_Mapping as MappingMenu
	on Menu.MenuId = MappingMenu.MenuId
	join dbo.T_System_Role_User_Mapping as MappingUser
	on MappingMenu.RoleId = MappingUser.RoleId
	where MappingUser.UserId = @User and MappingMenu.IsActive = 1 and MappingUser.IsActive =1

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetDateTime]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-01-24
-- Description:	Get Datetime value
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_GetDateTime]
(
	@Value varchar(20),
	@Format varchar(20)
)
RETURNS datetime
AS
BEGIN
	DECLARE @Result datetime

	if(@Format = 'dd-MM-yyyy hh:mm:ss' or @Format = 'dd-MM-yyyy')
	begin
		set @Result = convert(datetime, @Value, 105);
	end

	RETURN @Result
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetRule]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-01-24
-- Description:	Get Rule
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_GetRule]
(
	@RuleName varchar(100)
)
RETURNS  nvarchar(100)
AS
BEGIN
	DECLARE @Result nvarchar(100);

	select @Result = Value
	from T_System_Rule
	where [RuleName] = @RuleName

	RETURN ISNULL(@Result, '');
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetTime]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-01-24
-- Description:	Get Datetime value
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_GetTime]
(
	@Value varchar(20),
	@Format varchar(20)
)
RETURNS time
AS
BEGIN
	DECLARE @Result time

	if( @Format = 'hh:mm:ss')
	begin
		set @Result = convert(time, @Value, 114);
	end

	RETURN @Result
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_StandarlizeData]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-05
-- Description:	get standard data before saving
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_StandarlizeData]
(
	@Table varchar(100),
	@Colum varchar(100),
	@Data nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN

		declare @dataType varchar(20)
				,@DateTimeFormat varchar (20) = dbo.UFN_System_GetRule('DATETIME_FORMAT')

		select @dataType = DATA_TYPE 
		from INFORMATION_SCHEMA.COLUMNS as infoSchema
		where infoSchema.TABLE_NAME = @Table and 
		infoSchema.COLUMN_NAME = @Colum

		If(@dataType = 'datetime' or @dataType = 'date')
		begin		
			IF( len(@Data) > 0)
			begin
				set @Data = format([dbo].[UFN_System_GetDateTime](@Data, @DateTimeFormat), 'yyyy-MM-dd hh:mm:ss')
			end
			else begin
				set @Data = NULL
			end
		end
		else If(@dataType = 'int' or @dataType = 'float' or @dataType = 'real' 
			or @dataType = 'money' or @dataType = 'bigint' or @dataType = 'smallint'
			or @dataType = 'bit' )
		begin
			IF( len(@Data) = 0)
				set @Data = NULL;
		end

	return @Data;
END

GO
/****** Object:  Table [dbo].[T_Master_Attibutes]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Attibutes](
	[AttributeId] [int] IDENTITY(1,1) NOT NULL,
	[AttributeName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Attibutes] PRIMARY KEY CLUSTERED 
(
	[AttributeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Master_CostTypes]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_CostTypes](
	[CostTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CostTypeName] [nvarchar](100) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_CostTypes] PRIMARY KEY CLUSTERED 
(
	[CostTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Master_Customers]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_Customers](
	[CustomerId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerCode] [varchar](50) NOT NULL,
	[CustomerName] [nvarchar](300) NOT NULL,
	[Phone] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Address] [nvarchar](500) NULL,
	[Birthday] [date] NULL,
	[Gender] [char](1) NULL,
	[Notes] [nvarchar](500) NULL,
	[IsWholeSale] [bit] NOT NULL,
	[LastTimeVisited] [datetime] NULL,
	[SumMoney] [money] NULL,
	[Debt] [money] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_OrderStatus]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_OrderStatus](
	[StatusId] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) NULL,
	[DisplayClass] [varchar](20) NULL,
	[Description] [nvarchar](100) NULL,
	[IsFinish] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_OrderStatus] PRIMARY KEY CLUSTERED 
(
	[StatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_PaymentType]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_PaymentType](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentName] [nvarchar](100) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_PaymentType] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Master_PrintTemplates]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_PrintTemplates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [nvarchar](200) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_PrintTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Master_Producers]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Producers](
	[ProducerId] [int] IDENTITY(1,1) NOT NULL,
	[ProducerName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Producers] PRIMARY KEY CLUSTERED 
(
	[ProducerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Master_ProductGroups]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_ProductGroups](
	[ProductGroupId] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](200) NOT NULL,
	[IsParent] [bit] NOT NULL,
	[ParentId] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_ProductGroups] PRIMARY KEY CLUSTERED 
(
	[ProductGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Master_PurchaseStatus]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_PurchaseStatus](
	[StatusId] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) NOT NULL,
	[DisplayClass] [varchar](20) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[IsFinish] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_PurchaseStatus] PRIMARY KEY CLUSTERED 
(
	[StatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_Stores]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_Stores](
	[StoreId] [int] IDENTITY(1,1) NOT NULL,
	[StoreCode] [varchar](50) NOT NULL,
	[ProxyName] [nvarchar](100) NULL,
	[PhoneNumber] [varchar](50) NULL,
	[MobileNumber] [varchar](50) NULL,
	[Website] [nvarchar](500) NULL,
	[Address] [nvarchar](500) NULL,
	[Description] [nvarchar](1000) NULL,
	[TaxCode] [varchar](100) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Stores] PRIMARY KEY CLUSTERED 
(
	[StoreId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_Suppliers]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_Suppliers](
	[SupplierId] [int] IDENTITY(1,1) NOT NULL,
	[SupplierCode] [varchar](50) NOT NULL,
	[SupplierName] [nvarchar](300) NOT NULL,
	[Phone] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Address] [nvarchar](500) NULL,
	[TaxCode] [varchar](50) NULL,
	[Notes] [nvarchar](500) NULL,
	[LastTimeProvided] [datetime] NULL,
	[SumMoney] [money] NULL,
	[Debt] [money] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Providers] PRIMARY KEY CLUSTERED 
(
	[SupplierId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_User]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_User](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[LoginId] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[UserName] [nvarchar](100) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[Phone] [varchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_User] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Configuration_Data_List]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Configuration_Data_List](
	[Id] [varchar](50) NOT NULL,
	[Description] [varchar](200) NULL,
	[TableName] [varchar](100) NOT NULL,
	[Colums] [varchar](1000) NOT NULL,
	[Condition] [varchar](1000) NOT NULL,
	[OrderColums] [varchar](1000) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Configuration_Data_List] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Log_Data]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_Log_Data](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[ActionId] [int] NOT NULL,
	[StoreId] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_T_System_Log_Data] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_System_LogChanges]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_LogChanges](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [int] NOT NULL,
	[TableColumn] [int] NOT NULL,
	[OldData] [nvarchar](max) NOT NULL,
	[NewData] [nvarchar](max) NOT NULL,
	[UserId] [int] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[StepName] [nvarchar](100) NULL,
 CONSTRAINT [PK_T_System_LogChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_System_Menu]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Menu](
	[MenuId] [int] IDENTITY(1,1) NOT NULL,
	[Menu] [nvarchar](200) NOT NULL,
	[Url] [nvarchar](200) NOT NULL,
	[Parent] [int] NOT NULL,
	[Level] [int] NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CssClass] [varchar](50) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Menu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Parameters]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Parameters](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ParaCode] [varchar](50) NOT NULL,
	[ParaName] [nvarchar](200) NOT NULL,
	[ParaValue] [nvarchar](200) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Parameters] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Role]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Role](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Role] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Role_Menu_Mapping]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_Role_Menu_Mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MenuId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_T_Master_Role_Menu_Mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_System_Role_SP_Mapping]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Role_SP_Mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SP_Id] [varchar](50) NOT NULL,
	[Role] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_T_Master_Role_SP_Mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Role_User_Mapping]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_Role_User_Mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_T_Master_Role_Mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_System_Rule]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Rule](
	[RuleId] [int] NOT NULL,
	[RuleName] [varchar](100) NOT NULL,
	[Value] [nvarchar](100) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Rule] PRIMARY KEY CLUSTERED 
(
	[RuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_TestSQL]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_TestSQL](
	[Statement] [nvarchar](max) NOT NULL,
	[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Sytem_Columns]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Sytem_Columns](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableId] [int] NOT NULL,
	[ColumnName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_T_Sytem_Columns] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Sytem_Tables]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Sytem_Tables](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[IsTracing] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedBy] [int] NULL,
	[LastModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Sytem_Tables] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Cost]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Cost](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CostName] [nvarchar](200) NULL,
	[CostTypeId] [int] NULL,
	[PaidDate] [datetime] NULL,
	[Amount] [money] NULL,
	[Notes] [nchar](10) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Cost] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_Inventory]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_Inventory](
	[InventoryId] [int] IDENTITY(1,1) NOT NULL,
	[InventoryCode] [varchar](50) NOT NULL,
	[NumProducts] [int] NOT NULL,
	[NumChanges] [int] NULL,
	[NumEmpty] [int] NULL,
	[StoreId] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[BalancerId] [int] NULL,
	[BalancedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Inventory] PRIMARY KEY CLUSTERED 
(
	[InventoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Inventory_Product]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Inventory_Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InventoryId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[RealQuantity] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Inventory_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_MoneyIn]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_MoneyIn](
	[Id] [int] NOT NULL,
	[Cashier] [int] NULL,
	[PaymentTypeId] [int] NULL,
	[SumMoney] [money] NULL,
	[Notes] [nvarchar](500) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_MoneyIn] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_News]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_News](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[Type] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_News] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_Order_Product]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Order_Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Price] [float] NULL,
	[Discount] [float] NULL,
	[IsDiscountPercent] [bit] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [date] NULL,
 CONSTRAINT [PK_T_Trans_Order_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_Orders]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_Orders](
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
	[OrderCode] [varchar](50) NULL,
	[StoreId] [int] NOT NULL,
	[SoldDate] [datetime] NULL,
	[Cashier] [int] NOT NULL,
	[Customer] [int] NULL,
	[Notes] [nvarchar](500) NULL,
	[PaymentType] [int] NOT NULL,
	[OrderStatus] [int] NOT NULL,
	[Discount] [float] NULL,
	[IsDiscountPercent] [bit] NULL,
	[NumOfProduct] [int] NULL,
	[SumMoney] [money] NOT NULL,
	[Paid] [money] NOT NULL,
	[DebtMoney] [money] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Product_Attribute]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Product_Attribute](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AttributeId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Value] [nvarchar](200) NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Product_Attribute] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_ProductPrice_History]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_ProductPrice_History](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[Cost] [money] NULL,
	[Price] [money] NULL,
	[Description] [nvarchar](200) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_T_Trans_ProductPrice_History] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_ProductQuantity_History]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_ProductQuantity_History](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[ReferNo] [varchar](50) NOT NULL,
	[NumIn] [int] NOT NULL,
	[NumOut] [int] NOT NULL,
	[NumRemain] [int] NOT NULL,
	[Description] [nvarchar](200) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_T_Trans_ProductQuantity_History] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Products]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_Products](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](500) NOT NULL,
	[ProductCode] [varchar](32) NOT NULL,
	[Quantity] [int] NULL,
	[Price] [money] NOT NULL,
	[Cost] [money] NULL,
	[ProductGroup] [int] NULL,
	[ProducerId] [int] NULL,
	[Image] [nvarchar](500) NULL,
	[TrackInventory] [bit] NOT NULL,
	[AllowNegative] [bit] NOT NULL,
	[VAT] [int] NULL,
	[AllowMin] [int] NULL,
	[AllowMax] [int] NULL,
	[IsManageAsSerial] [bit] NOT NULL,
	[IsManageAttribute] [bit] NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[IsSelling] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[LastBoughtDate] [datetime] NULL,
	[LastReferNo] [varchar](50) NULL,
	[LastComment] [nvarchar](200) NULL,
 CONSTRAINT [PK_T_Trans_Products] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Purchase]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_Purchase](
	[PurchaseId] [int] IDENTITY(1,1) NOT NULL,
	[PurchaseCode] [varchar](50) NULL,
	[StoreId] [int] NOT NULL,
	[StatusId] [int] NOT NULL,
	[Quantity] [int] NULL,
	[PurchaseDate] [datetime] NULL,
	[Purchaser] [int] NULL,
	[SupplierId] [int] NULL,
	[Notes] [nvarchar](500) NULL,
	[PaymentType] [int] NULL,
	[SumMoney] [money] NULL,
	[SumTax] [money] NULL,
	[Paid] [money] NULL,
	[Debt] [money] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Purchase] PRIMARY KEY CLUSTERED 
(
	[PurchaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Purchase_Product]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Purchase_Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[PurchaseId] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[Cost] [money] NOT NULL,
	[Quantity] [int] NOT NULL,
	[VAT] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Purchase_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_User_Store]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_User_Store](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_User_Store] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetForienKey]    Script Date: 3/30/2016 11:23:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-01-19
-- Description:	Get forein key
--				select * from UFN_System_GetForienKey('T_Trans_Orders', 'Cashier')
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_GetForienKey]
(	
	@TableName varchar(100),
	@ColumName varchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	select object_name (FK.referenced_object_id) AS RefTable,  
	col_name(FK.referenced_object_id, FKC.referenced_column_id) AS RefColum
	from sys.foreign_keys as FK
	join sys.foreign_key_columns as FKC 
	on FKC.constraint_object_id = FK.object_id
	where FK.parent_object_id = object_id(@TableName) 
	and col_name(FK.parent_object_id,FKC.parent_column_id) = @ColumName
)

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Master_Customers]    Script Date: 3/30/2016 11:23:46 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Master_Customers] ON [dbo].[T_Master_Customers]
(
	[CustomerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Master_Suppliers]    Script Date: 3/30/2016 11:23:46 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Master_Suppliers] ON [dbo].[T_Master_Suppliers]
(
	[SupplierCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_Orders]    Script Date: 3/30/2016 11:23:46 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Trans_Orders] ON [dbo].[T_Trans_Orders]
(
	[OrderCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_Products]    Script Date: 3/30/2016 11:23:46 PM ******/
CREATE NONCLUSTERED INDEX [IX_T_Trans_Products] ON [dbo].[T_Trans_Products]
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Master_Customers] ADD  CONSTRAINT [DF_T_Master_Customers_IsWholeSale]  DEFAULT ((0)) FOR [IsWholeSale]
GO
ALTER TABLE [dbo].[T_Master_ProductGroups]  WITH CHECK ADD  CONSTRAINT [FK_T_Master_ProductGroups_T_Master_ProductGroups] FOREIGN KEY([ParentId])
REFERENCES [dbo].[T_Master_ProductGroups] ([ProductGroupId])
GO
ALTER TABLE [dbo].[T_Master_ProductGroups] CHECK CONSTRAINT [FK_T_Master_ProductGroups_T_Master_ProductGroups]
GO
ALTER TABLE [dbo].[T_System_Log_Data]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Log_Data_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_System_Log_Data] CHECK CONSTRAINT [FK_T_System_Log_Data_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_System_Log_Data]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Log_Data_T_Master_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_System_Log_Data] CHECK CONSTRAINT [FK_T_System_Log_Data_T_Master_User]
GO
ALTER TABLE [dbo].[T_System_Role_Menu_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Role_Menu_Mapping_T_System_Menu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[T_System_Menu] ([MenuId])
GO
ALTER TABLE [dbo].[T_System_Role_Menu_Mapping] CHECK CONSTRAINT [FK_T_System_Role_Menu_Mapping_T_System_Menu]
GO
ALTER TABLE [dbo].[T_System_Role_Menu_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Role_Menu_Mapping_T_System_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[T_System_Role] ([RoleId])
GO
ALTER TABLE [dbo].[T_System_Role_Menu_Mapping] CHECK CONSTRAINT [FK_T_System_Role_Menu_Mapping_T_System_Role]
GO
ALTER TABLE [dbo].[T_System_Role_User_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Role_User_Mapping_T_Master_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_System_Role_User_Mapping] CHECK CONSTRAINT [FK_T_System_Role_User_Mapping_T_Master_User]
GO
ALTER TABLE [dbo].[T_System_Role_User_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Role_User_Mapping_T_System_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[T_System_Role] ([RoleId])
GO
ALTER TABLE [dbo].[T_System_Role_User_Mapping] CHECK CONSTRAINT [FK_T_System_Role_User_Mapping_T_System_Role]
GO
ALTER TABLE [dbo].[T_Trans_Cost]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Cost_T_Master_CostTypes] FOREIGN KEY([CostTypeId])
REFERENCES [dbo].[T_Master_CostTypes] ([CostTypeId])
GO
ALTER TABLE [dbo].[T_Trans_Cost] CHECK CONSTRAINT [FK_T_Trans_Cost_T_Master_CostTypes]
GO
ALTER TABLE [dbo].[T_Trans_Inventory]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Inventory_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Inventory] CHECK CONSTRAINT [FK_T_Trans_Inventory_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Inventory]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Inventory_T_Master_User] FOREIGN KEY([BalancerId])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Inventory] CHECK CONSTRAINT [FK_T_Trans_Inventory_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_Inventory]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Inventory_T_Master_User1] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Inventory] CHECK CONSTRAINT [FK_T_Trans_Inventory_T_Master_User1]
GO
ALTER TABLE [dbo].[T_Trans_MoneyIn]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_MoneyIn_T_Master_PaymentType] FOREIGN KEY([PaymentTypeId])
REFERENCES [dbo].[T_Master_PaymentType] ([PaymentId])
GO
ALTER TABLE [dbo].[T_Trans_MoneyIn] CHECK CONSTRAINT [FK_T_Trans_MoneyIn_T_Master_PaymentType]
GO
ALTER TABLE [dbo].[T_Trans_MoneyIn]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_MoneyIn_T_Master_User] FOREIGN KEY([Cashier])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_MoneyIn] CHECK CONSTRAINT [FK_T_Trans_MoneyIn_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_Order_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Order_Product_T_Trans_Orders] FOREIGN KEY([OrderId])
REFERENCES [dbo].[T_Trans_Orders] ([OrderId])
GO
ALTER TABLE [dbo].[T_Trans_Order_Product] CHECK CONSTRAINT [FK_T_Trans_Order_Product_T_Trans_Orders]
GO
ALTER TABLE [dbo].[T_Trans_Order_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Order_Product_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_Order_Product] CHECK CONSTRAINT [FK_T_Trans_Order_Product_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Orders_T_Master_Customers] FOREIGN KEY([Customer])
REFERENCES [dbo].[T_Master_Customers] ([CustomerId])
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [FK_T_Trans_Orders_T_Master_Customers]
GO
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Orders_T_Master_OrderStatus] FOREIGN KEY([OrderStatus])
REFERENCES [dbo].[T_Master_OrderStatus] ([StatusId])
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [FK_T_Trans_Orders_T_Master_OrderStatus]
GO
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Orders_T_Master_PaymentType] FOREIGN KEY([PaymentType])
REFERENCES [dbo].[T_Master_PaymentType] ([PaymentId])
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [FK_T_Trans_Orders_T_Master_PaymentType]
GO
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Orders_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [FK_T_Trans_Orders_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Orders_T_Master_User] FOREIGN KEY([Cashier])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [FK_T_Trans_Orders_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_Product_Attribute]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Product_Attribute_T_Master_Attibutes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[T_Master_Attibutes] ([AttributeId])
GO
ALTER TABLE [dbo].[T_Trans_Product_Attribute] CHECK CONSTRAINT [FK_T_Trans_Product_Attribute_T_Master_Attibutes]
GO
ALTER TABLE [dbo].[T_Trans_Product_Attribute]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Product_Attribute_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_Product_Attribute] CHECK CONSTRAINT [FK_T_Trans_Product_Attribute_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_ProductPrice_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_ProductPrice_History_T_Master_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_ProductPrice_History] CHECK CONSTRAINT [FK_T_Trans_ProductPrice_History_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_ProductPrice_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_ProductPrice_History_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_ProductPrice_History] CHECK CONSTRAINT [FK_T_Trans_ProductPrice_History_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_ProductQuantity_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_ProductQuantity_History_T_Master_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_ProductQuantity_History] CHECK CONSTRAINT [FK_T_Trans_ProductQuantity_History_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_ProductQuantity_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_ProductQuantity_History_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_ProductQuantity_History] CHECK CONSTRAINT [FK_T_Trans_ProductQuantity_History_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_Products]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Products_T_Master_Producers] FOREIGN KEY([ProducerId])
REFERENCES [dbo].[T_Master_Producers] ([ProducerId])
GO
ALTER TABLE [dbo].[T_Trans_Products] CHECK CONSTRAINT [FK_T_Trans_Products_T_Master_Producers]
GO
ALTER TABLE [dbo].[T_Trans_Products]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Products_T_Master_ProductGroups] FOREIGN KEY([ProductGroup])
REFERENCES [dbo].[T_Master_ProductGroups] ([ProductGroupId])
GO
ALTER TABLE [dbo].[T_Trans_Products] CHECK CONSTRAINT [FK_T_Trans_Products_T_Master_ProductGroups]
GO
ALTER TABLE [dbo].[T_Trans_Purchase]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_T_Master_PaymentType] FOREIGN KEY([PaymentType])
REFERENCES [dbo].[T_Master_PaymentType] ([PaymentId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase] CHECK CONSTRAINT [FK_T_Trans_Purchase_T_Master_PaymentType]
GO
ALTER TABLE [dbo].[T_Trans_Purchase]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_T_Master_PurchaseStatus] FOREIGN KEY([StatusId])
REFERENCES [dbo].[T_Master_PurchaseStatus] ([StatusId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase] CHECK CONSTRAINT [FK_T_Trans_Purchase_T_Master_PurchaseStatus]
GO
ALTER TABLE [dbo].[T_Trans_Purchase]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase] CHECK CONSTRAINT [FK_T_Trans_Purchase_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Purchase]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_T_Master_Suppliers] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[T_Master_Suppliers] ([SupplierId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase] CHECK CONSTRAINT [FK_T_Trans_Purchase_T_Master_Suppliers]
GO
ALTER TABLE [dbo].[T_Trans_Purchase]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_T_Master_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase] CHECK CONSTRAINT [FK_T_Trans_Purchase_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_Purchase]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_T_Master_User1] FOREIGN KEY([Purchaser])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase] CHECK CONSTRAINT [FK_T_Trans_Purchase_T_Master_User1]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_Product_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product] CHECK CONSTRAINT [FK_T_Trans_Purchase_Product_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_Product_T_Trans_Purchase] FOREIGN KEY([PurchaseId])
REFERENCES [dbo].[T_Trans_Purchase] ([PurchaseId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product] CHECK CONSTRAINT [FK_T_Trans_Purchase_Product_T_Trans_Purchase]
GO
ALTER TABLE [dbo].[T_Trans_User_Store]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_User_Store_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_User_Store] CHECK CONSTRAINT [FK_T_Trans_User_Store_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_User_Store]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_User_Store_T_Master_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_User_Store] CHECK CONSTRAINT [FK_T_Trans_User_Store_T_Master_User]
GO
ALTER TABLE [dbo].[T_System_Configuration_Data_List]  WITH CHECK ADD  CONSTRAINT [CK_Id_T_System_Configuration_Data_List] CHECK  (([Id] like 'DataList%'))
GO
ALTER TABLE [dbo].[T_System_Configuration_Data_List] CHECK CONSTRAINT [CK_Id_T_System_Configuration_Data_List]
GO
ALTER TABLE [dbo].[T_Trans_Order_Product]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Order_Product] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Order_Product] CHECK CONSTRAINT [CK_T_Trans_Order_Product]
GO
ALTER TABLE [dbo].[T_Trans_Order_Product]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Order_Product_2] CHECK  (([Discount]>=(0) AND ([IsDiscountPercent]=(1) AND [Discount]<=(100) OR [IsDiscountPercent]=(0) AND [Discount]<=[Price])))
GO
ALTER TABLE [dbo].[T_Trans_Order_Product] CHECK CONSTRAINT [CK_T_Trans_Order_Product_2]
GO
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Orders] CHECK  (([Discount]>=(0) AND ([IsDiscountPercent]=(1) AND [Discount]<=(100) OR [IsDiscountPercent]=(0) AND [Discount]<=[SumMoney])))
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [CK_T_Trans_Orders]
GO
ALTER TABLE [dbo].[T_Trans_Products]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Products] CHECK  (([AllowMax]>=[AllowMin]))
GO
ALTER TABLE [dbo].[T_Trans_Products] CHECK CONSTRAINT [CK_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_Products]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Products_1] CHECK  (([AllowNegative]=(1) OR [AllowNegative]=(0) AND [Quantity]>=(0)))
GO
ALTER TABLE [dbo].[T_Trans_Products] CHECK CONSTRAINT [CK_T_Trans_Products_1]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Purchase_Product] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product] CHECK CONSTRAINT [CK_T_Trans_Purchase_Product]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tối thiểu bán 1 sản phẩm' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_Trans_Order_Product', @level2type=N'CONSTRAINT',@level2name=N'CK_T_Trans_Order_Product'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Check discount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_Trans_Order_Product', @level2type=N'CONSTRAINT',@level2name=N'CK_T_Trans_Order_Product_2'
GO
USE [master]
GO
ALTER DATABASE [StoreManagement] SET  READ_WRITE 
GO
