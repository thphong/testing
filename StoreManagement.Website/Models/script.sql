USE [master]
GO
/****** Object:  Database [StoreManagement]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE DATABASE [StoreManagement]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'StoreManagement', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\StoreManagement.mdf' , SIZE = 6144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
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
/****** Object:  User [storer]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Trigger_Customer_SetDefaultCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Customer_SetDefaultCode]
	@CustomerId int
AS
BEGIN
	Update A set CustomerCode = 'KH' + IIF(A.IsWholeSale = 1, 'S', '') + REPLICATE('0',6-LEN(A.CustomerId)) + convert(varchar, A.CustomerId)
	from dbo.T_Master_Customers as A
	where A.CustomerId = @CustomerId and (A.CustomerCode IS NULL or LEN(A.CustomerCode) = 0)
END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Inventory_SetBalancedDate]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Inventory_SetBalancedDate]
	@InventoryId int
AS
BEGIN
	
	Update A set A.BalancedDate = getdate(),
				 A.BalancerId = A.ModifiedBy
	from dbo.T_Trans_Inventory as A
	join T_Master_InventoryStatus AS B
	ON A.StatusId = B.StatusId
	where A.InventoryId = @InventoryId AND B.IsFinish = 1
		and A.BalancedDate is null
END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Inventory_SetCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Inventory_SetCode]
	@InventoryId int
AS
BEGIN
	
	Update A set InventoryCode = 'PKK' + REPLICATE('0',6-LEN(A.InventoryId)) + convert(varchar, A.InventoryId)
	from dbo.T_Trans_Inventory as A
	where A.InventoryId = @InventoryId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_InventoryProduct_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_InventoryProduct_CheckContraint]
	@InventoryProductId int
AS
BEGIN
	
	update A
	set A.Quantity = B.Quantity
	from T_Trans_Inventory_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_Inventory AS C
	on A.InventoryId = C.InventoryId and B.StoreId = C.StoreId
	where  A.Id = @InventoryProductId 
			
	update B
	set B.Quantity = B.Quantity + A.RealQuantity - A.Quantity,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Inventory_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId	
	join T_Trans_Inventory as C
	ON A.InventoryId = C.InventoryId
	join T_Master_InventoryStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventoryProductId

	update B
	set B.Quantity = B.Quantity + A.RealQuantity - A.Quantity,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Inventory_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_Inventory as C
	ON A.InventoryId = C.InventoryId and B.StoreId = C.StoreId
	join T_Master_InventoryStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventoryProductId

	--Insert history
	INSERT INTO [dbo].[T_Trans_ProductQuantity_History]
           ([ProductId],
			[StoreId]
		   ,[ReferNo]
           ,[NumIn]
           ,[NumOut]
           ,[NumRemain]
           ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, C.StoreId, C.InventoryCode, 
		   IIF(A.RealQuantity > A.Quantity, A.RealQuantity - A.Quantity, 0 ),
		   IIF(A.RealQuantity > A.Quantity, 0, A.Quantity - A.RealQuantity),
		   B.Quantity, 
		   IIF(A.RealQuantity > A.Quantity,  N'Nhập kiểm kê ',  N'Xuất kiểm kê ' ) + C.InventoryCode,
		   ISNULL(A.ModifiedBy, A.CreatedBy), getdate()
	from T_Trans_Inventory_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_Inventory as C 
	ON A.InventoryId = C.InventoryId and B.StoreId = C.StoreId
	join T_Master_InventoryStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventoryProductId
	and A.RealQuantity <> A.Quantity

	declare @num int;

	select  @num = COUNT(1)
	from T_Trans_Inventory_Product  as A
	join T_Trans_Inventory_Product  as B
	on A.InventoryId = B.InventoryId
	where B.Id = @InventoryProductId

	UPDATE A
	SET NumProducts = @num
	from T_Trans_Inventory  as A
	join T_Trans_Inventory_Product  as B
	on A.InventoryId = B.InventoryId
	where B.Id = @InventoryProductId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_InventTran_SetCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_InventTran_SetCode]
	@InventTranId int
AS
BEGIN
	
	Update A set InventTranCode = 'PCK' + REPLICATE('0',6-LEN(A.InventTranId)) + convert(varchar, A.InventTranId)
	from dbo.T_Trans_InventTran as A
	where A.InventTranId = @InventTranId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_InventTran_SetTranferedDate]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_InventTran_SetTranferedDate]
	@InventTranId int
AS
BEGIN
	
	Update A set A.TransferedDate = getdate(),
				 A.TransferId = A.ModifiedBy
	from dbo.T_Trans_InventTran as A
	join T_Master_InventTranStatus AS B
	ON A.StatusId = B.StatusId
	where A.InventTranId = @InventTranId AND B.IsFinish = 1
		and A.TransferedDate is null
END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_InventTranProduct_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_InventTranProduct_CheckContraint]
	@InventTranProductId int
AS
BEGIN
	
	update A
	set A.Quantity = B.Quantity
	from T_Trans_InventTran_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_InventTran AS C
	on A.InventTranId = C.InventTranId and B.StoreId = C.FromStoreId
	where  A.Id = @InventTranProductId 
			
	update B
	set B.Quantity = B.Quantity - A.TranQuantity,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_InventTran_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_InventTran as C
	ON A.InventTranId = C.InventTranId and B.StoreId = C.FromStoreId
	join T_Master_InventTranStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventTranProductId

	update B
	set B.Quantity = B.Quantity + A.TranQuantity,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_InventTran_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_InventTran as C
	ON A.InventTranId = C.InventTranId and B.StoreId = C.ToStoreId
	join T_Master_InventTranStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventTranProductId

	--Insert history
	INSERT INTO [dbo].[T_Trans_ProductQuantity_History]
           ([ProductId],
			[StoreId]
		   ,[ReferNo]
           ,[NumIn]
           ,[NumOut]
           ,[NumRemain]
           ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, C.FromStoreId, C.InventTranCode, 
		   0, A.TranQuantity ,B.Quantity, 
		   N'Chuyển kho đi ' + C.InventTranCode,
		   A.ModifiedBy, getdate()
	from T_Trans_InventTran_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_InventTran as C 
	ON A.InventTranId = C.InventTranId and B.StoreId = C.FromStoreId
	join T_Master_InventTranStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventTranProductId
	union
	select A.ProductId, C.ToStoreId, C.InventTranCode, 
		   A.TranQuantity, 0 ,B.Quantity, 
		   N'Chuyển kho từ ' + C.InventTranCode,
		   A.ModifiedBy, getdate()
	from T_Trans_InventTran_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_InventTran as C 
	ON A.InventTranId = C.InventTranId and B.StoreId = C.ToStoreId
	join T_Master_InventTranStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @InventTranProductId

	declare @num int;

	select  @num = COUNT(1)
	from T_Trans_InventTran_Product  as A
	join T_Trans_InventTran_Product  as B
	on A.InventTranId = B.InventTranId
	where B.Id = @InventTranProductId

	UPDATE A
	SET NumProducts = @num
	from T_Trans_InventTran  as A
	join T_Trans_InventTran_Product  as B
	on A.InventTranId = B.InventTranId
	where B.Id = @InventTranProductId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Order_Payment]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Order_Payment]
	@OrderId int
AS
BEGIN
	
	--insert new payment
	INSERT INTO [dbo].[T_Trans_Payment]
    ([OrderId], [StoreId], [Amount], [PaymentType], [IsActive], [CreatedBy], [CreatedDate])
	select A.OrderId, A.StoreId ,  A.Paid, A.PaymentType, 1, A.ModifiedBy, getdate()
	from T_Trans_Orders  as A
	join T_Master_OrderStatus AS B
	on A.OrderStatus = B.StatusId
	where A.IsActive = 1 and B.IsFinish = 1 and A.Paid > 0 and A.OrderId = @OrderId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Order_SetCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Order_SetCode]
	@OrderId int
AS
BEGIN
	
	Update A set OrderCode = 'PX' + iif(B.IsWholeSale = 1, 'S', '') + REPLICATE('0',6-LEN(A.OrderId)) + convert(varchar, A.OrderId)
	from dbo.T_Trans_Orders as A
	left join dbo.T_Master_Customers as B
	ON A.Customer = B.CustomerId
	where A.OrderId = @OrderId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Order_SetSoldDate]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Order_SetSoldDate]
	@OrderId int
AS
BEGIN
	
	Update A set A.SoldDate = getdate()
	from dbo.T_Trans_Orders as A
	join T_Master_OrderStatus AS B
	ON A.OrderStatus = B.StatusId
	where A.OrderId = @OrderId AND B.IsFinish = 1
		and A.SoldDate is null
END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Order_UpdateContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Order_UpdateContraint]
	@OrderId int
AS
BEGIN
	
	--Update Product Quantity
	update B
	set B.Quantity = B.Quantity + A.Quantity,
		B.ModifiedBy = C.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Order_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId
	join T_Trans_Orders  as C
	on A.OrderId = C.OrderId	
	join T_Master_OrderStatus AS D
	on C.OrderStatus = D.StatusId
	where C.IsActive = 0 and D.IsFinish = 1 AND C.OrderId = @OrderId

	update B
	set B.Quantity = B.Quantity + A.Quantity,
		B.ModifiedBy = C.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Order_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_Orders  as C
	on A.OrderId = C.OrderId and B.StoreId = C.StoreId
	join T_Master_OrderStatus AS D
	on C.OrderStatus = D.StatusId
	where C.IsActive = 0 and D.IsFinish = 1 AND C.OrderId = @OrderId

	--Insert history
	INSERT INTO [dbo].[T_Trans_ProductQuantity_History]
           ([ProductId],
			[StoreId]
		   ,[ReferNo]
           ,[NumIn]
           ,[NumOut]
           ,[NumRemain]
           ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, C.StoreId, C.OrderCode, A.Quantity, 0, B.Quantity, N'Hủy đơn hàng ' + C.OrderCode, C.ModifiedBy, getdate()
	from T_Trans_Order_Product  as A	
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId 
	join T_Trans_Orders  as C
	on A.OrderId = C.OrderId and B.StoreId = C.StoreId
	join T_Master_OrderStatus AS D
	on C.OrderStatus = D.StatusId
	where C.IsActive = 0 and D.IsFinish = 1 AND C.OrderId = @OrderId

	
	--Update Customer
	update A
	set A.SumMoney = ISNULL(A.SumMoney, 0) -  ISNULL(B.SumMoney, 0),
		A.Debt = ISNULL(A.Debt, 0) -  ISNULL(B.DebtMoney, 0)
	from T_Master_Customers  as A
	join T_Trans_Orders  as B
	on A.CustomerId = B.Customer
	join T_Master_OrderStatus AS C
	on B.OrderStatus = C.StatusId
	where B.IsActive = 0 and C.IsFinish = 1 AND B.OrderId = @OrderId

	
	--Update Customer
	update A
	set A.SumMoney = ISNULL(A.SumMoney, 0) +  ISNULL(B.SumMoney, 0),
		A.Debt = ISNULL(A.Debt, 0) +  ISNULL(B.DebtMoney, 0),
		A.LastTimeVisited = GETDATE()
	from T_Master_Customers  as A
	join T_Trans_Orders  as B
	on A.CustomerId = B.Customer
	join T_Master_OrderStatus AS C
	on B.OrderStatus = C.StatusId
	where B.IsActive = 1 and C.IsFinish = 1 AND B.OrderId = @OrderId


END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Payment_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Payment_CheckContraint]
	@PaymentId int
AS
BEGIN
	
	--update Paid in order
	update B set Paid = B.Paid - A.Amount
						,DebtMoney = B.DebtMoney + A.Amount
						,ModifiedBy = A.ModifiedBy
						,ModifiedDate = getdate()
	from T_Trans_Payment  as A
	join T_Trans_Orders AS B
	on A.OrderId = B.OrderId
	where A.PaymentId = @PaymentId AND A.IsActive = 0

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Payment_PaidDebt]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Payment_PaidDebt]
	@PaymentId int
AS
BEGIN
	
	--update Paid in order
	update B set Paid = B.Paid + A.Amount
						,DebtMoney = B.DebtMoney - A.Amount
						,ModifiedBy = A.ModifiedBy
						,ModifiedDate = getdate()
	from T_Trans_Payment  as A
	join T_Trans_Orders AS B
	on A.OrderId = B.OrderId
	where A.PaymentId = @PaymentId AND A.IsActive = 1

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Payment_SetCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Payment_SetCode]
	@CostId int
AS
BEGIN
	
	Update A set CostCode = 'PC' + REPLICATE('0',6-LEN(A.CostId)) + convert(varchar, A.CostId)
	from dbo.T_Trans_Cost as A
	where A.CostId = @CostId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Product_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Product_CheckContraint]
	@ProductId int
AS
BEGIN
	
	insert into [dbo].[T_Trans_Product_Store]
	([ProductId], [StoreId], [Quantity], [AllowNegative], [CreatedBy], [CreatedDate])
	select A.ProductId, B.StoreId, A.Quantity, A.AllowNegative, A.CreatedBy, getdate()
	from [dbo].[T_Trans_Products] AS A
	join T_Master_Stores AS B
	on 1 = 1
	left join T_Trans_Product_Store AS C
	on  A.ProductId = C.ProductId And B.StoreId = C.StoreId
	where A.ProductId = @ProductId
	And C.Id is null

	update A
	set AllowNegative = B.AllowNegative
	from T_Trans_Product_Store AS A
	join T_Trans_Products AS B
	on A.ProductId = B.ProductId
	where B.ProductId = @ProductId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Product_Price_TrackHistory]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Product_Price_TrackHistory]
	@ProductId int,
	@Description nvarchar(200) = NULL
AS
BEGIN
	
	declare @LastCost money, @LastPrice money;

	select top 1 @LastCost = Cost
	from T_Trans_ProductPrice_History
	where ProductId = @ProductId and Cost is not null
	order by CreatedDate desc

	select top 1 @LastPrice = Price
	from T_Trans_ProductPrice_History
	where ProductId = @ProductId and Price is not null
	order by CreatedDate desc

	INSERT INTO [dbo].[T_Trans_ProductPrice_History]
           ([ProductId]
           ,[Cost]
           ,[Price]
		   ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, 
			iif(A.Cost <> @LastCost or @LastCost is null , A.Cost, NULL),
			iif(A.Price <> @LastPrice or @LastPrice is null, A.Price, NULL),
			isnull(@Description,  iif(A.ModifiedBy is null, N'Khai báo mới hàng hóa', N'Cập nhật giá cho hàng hóa')),
			A.ModifiedBy, 
			getdate()
	from T_Trans_Products  as A
	where ProductId = @ProductId	
		and  (A.Cost <> @LastCost or @LastCost is null
			  or A.Price <> @LastPrice or @LastPrice is null)

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Product_SetCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Product_SetCode]
	@ProductId int
AS
BEGIN
	
	--Update Code
	Update A set ProductCode = 'HH' + REPLICATE('0',6-LEN(A.ProductId)) + convert(varchar, A.ProductId)
	from dbo.T_Trans_Products as A
	where A.ProductId = @ProductId AND (A.ProductCode IS NULL or LEN(A.ProductCode) = 0)

	--Update Last bought date
	Update A set LastBoughtDate = getdate()
	from dbo.T_Trans_Products as A
	where A.ProductId = @ProductId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_ProductOrder_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_ProductOrder_CheckContraint]
	@ProductOrderId int
AS
BEGIN
	update A
	set A.Price = B.Price,
		A.RealPrice = A.Quantity * (B.Price - (iif(A.IsDiscountPercent = 1, A.Discount * B.Price / 100, A.Discount)))
	from T_Trans_Order_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId
	where A.Id = @ProductOrderId

	update A
	set A.RealPrice = A.RealPrice - (iif(B.IsDiscountPercent = 1, B.Discount * A.RealPrice / 100, B.Discount))
	from T_Trans_Order_Product  as A
	join T_Trans_Orders  as B
	on A.OrderId = B.OrderId
	where A.Id = @ProductOrderId

	update B
	set B.Quantity = B.Quantity - A.Quantity,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate(),
		B.LastBoughtDate = getdate()
	from T_Trans_Order_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId
	join T_Trans_Orders as C
	ON A.OrderId = C.OrderId
	join T_Master_OrderStatus AS D
	on C.OrderStatus = D.StatusId
	where C.IsActive = 1 AND  D.IsFinish = 1 AND A.Id = @ProductOrderId 

	update B
	set B.Quantity = B.Quantity - A.Quantity,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Order_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_Orders as C
	ON A.OrderId = C.OrderId and B.StoreId = C.StoreId
	join T_Master_OrderStatus AS D
	on C.OrderStatus = D.StatusId
	where C.IsActive = 1 AND  D.IsFinish = 1 AND A.Id = @ProductOrderId 

	--Insert history
	INSERT INTO [dbo].[T_Trans_ProductQuantity_History]
           ([ProductId],
			[StoreId]
		   ,[ReferNo]
           ,[NumIn]
           ,[NumOut]
           ,[NumRemain]
           ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, C.StoreId, C.OrderCode, 0, A.Quantity, B.Quantity, N'Bán hàng ' + C.OrderCode, A.ModifiedBy, getdate()
	from T_Trans_Order_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_Orders as C
	ON A.OrderId = C.OrderId and B.StoreId = C.StoreId
	join T_Master_OrderStatus AS D
	on C.OrderStatus = D.StatusId
	where C.IsActive = 1 AND  D.IsFinish = 1 AND A.Id = @ProductOrderId 
			
	declare @sum money, @num int, @orginalSum money;

	select  @sum = SUM(A.Quantity * (A.Price - (iif(A.IsDiscountPercent = 1, A.Discount * A.Price / 100, A.Discount)))),
			@num = SUM(A.Quantity),
			@orginalSum = SUM(A.Price * A.Quantity)
	from T_Trans_Order_Product  as A
	join T_Trans_Order_Product  as B
	on A.OrderId = B.OrderId AND B.Id = @ProductOrderId

	UPDATE A
	SET SumMoney = @sum - (iif(A.IsDiscountPercent = 1, A.Discount * @sum / 100, A.Discount)),
		DebtMoney = iif(@sum - (iif(A.IsDiscountPercent = 1, A.Discount * @sum / 100, A.Discount)) > A.Paid,
						@sum - (iif(A.IsDiscountPercent = 1, A.Discount * @sum / 100, A.Discount)) - A.Paid,
						0),
		OrginalMoney = @orginalSum,
		NumOfProduct = @num
	from T_Trans_Orders  as A
	join T_Trans_Order_Product  as B
	on A.OrderId = B.OrderId AND B.Id = @ProductOrderId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Purchase_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Purchase_CheckContraint]
	@PurchaseId int
AS
BEGIN
	
	--Update Product Quantity
	update B
	set B.Quantity = B.Quantity - A.Quantity,
		B.ModifiedBy = C.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Purchase_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId
	join T_Trans_Purchase  as C
	on A.PurchaseId = C.PurchaseId
	join T_Master_PurchaseStatus AS D
	on D.StatusId = C.StatusId
	where C.IsActive = 0 and D.IsFinish = 1 AND C.PurchaseId = @PurchaseId

	update B
	set B.Quantity = B.Quantity - A.Quantity,
		B.ModifiedBy = C.ModifiedBy,
		B.ModifiedDate = getdate()
	from T_Trans_Purchase_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_Purchase  as C
	on A.PurchaseId = C.PurchaseId And B.StoreId = C.StoreId
	join T_Master_PurchaseStatus AS D
	on D.StatusId = C.StatusId
	where C.IsActive = 0 and D.IsFinish = 1 AND C.PurchaseId = @PurchaseId
	
	--Insert history
	INSERT INTO [dbo].[T_Trans_ProductQuantity_History]
           ([ProductId],
			[StoreId]
		   ,[ReferNo]
           ,[NumIn]
           ,[NumOut]
           ,[NumRemain]
           ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, C.StoreId, C.PurchaseCode, 0, A.Quantity, B.Quantity, N'Hủy phiếu nhập kho ' + C.PurchaseCode, C.ModifiedBy, getdate()
	from T_Trans_Purchase_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId
	join T_Trans_Purchase  as C
	on A.PurchaseId = C.PurchaseId and B.StoreId = C.StoreId
	join T_Master_PurchaseStatus AS D
	on D.StatusId = C.StatusId
	where C.IsActive = 0 and D.IsFinish = 1 AND C.PurchaseId = @PurchaseId

	--Update Supplier
	update A
	set A.SumMoney = ISNULL(A.SumMoney, 0) - ISNULL(B.SumMoney, 0),
		A.Debt = ISNULL(A.Debt, 0) - ISNULL(B.Debt, 0)
	from T_Master_Suppliers  as A
	join T_Trans_Purchase  as B
	on A.SupplierId = B.SupplierId
	join T_Master_PurchaseStatus AS C
	on B.StatusId = C.StatusId
	where B.IsActive = 0 and C.IsFinish = 1 AND B.PurchaseId = @PurchaseId

	--Update Supplier
	update A
	set A.SumMoney = ISNULL(A.SumMoney, 0) + ISNULL(B.SumMoney, 0),
		A.Debt = ISNULL(A.Debt, 0) +  ISNULL(B.Debt, 0),
		A.LastTimeProvided = getdate()
	from T_Master_Suppliers  as A
	join T_Trans_Purchase  as B
	on A.SupplierId = B.SupplierId
	join T_Master_PurchaseStatus AS C
	on B.StatusId = C.StatusId
	where B.IsActive = 1 and C.IsFinish = 1 and B.PurchaseId = @PurchaseId


END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Purchase_Payment]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Purchase_Payment]
	@PurchaseId int
AS
BEGIN
	
	--insert new payment
	INSERT INTO [dbo].[T_Trans_Purchase_Payment]
    ([PurchaseId], [StoreId], [Amount], [PaymentType], [IsActive], [CreatedBy], [CreatedDate])
	select A.PurchaseId, A.StoreId ,A.Paid, A.PaymentType, 1, A.ModifiedBy, getdate()
	from T_Trans_Purchase  as A
	join T_Master_PurchaseStatus AS B
	on A.StatusId = B.StatusId
	where A.IsActive = 1 and B.IsFinish = 1 and A.Paid > 0 and A.PurchaseId = @PurchaseId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Purchase_Payment_PaidDebt]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Purchase_Payment_PaidDebt]
	@PaymentId int
AS
BEGIN
	
	--update Paid in order
	update B set Paid = B.Paid + A.Amount
						,Debt = B.Debt - A.Amount
						,ModifiedBy = A.ModifiedBy
						,ModifiedDate = getdate()
	from T_Trans_Purchase_Payment  as A
	join T_Trans_Purchase AS B
	on A.PurchaseId = B.PurchaseId
	where A.PaymentId = @PaymentId AND A.IsActive = 1

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Purchase_SetCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Purchase_SetCode]
	@PurchaseId int
AS
BEGIN
	
	Update A set PurchaseCode = 'PN' + REPLICATE('0',6-LEN(A.PurchaseId)) + convert(varchar, A.PurchaseId)
	from dbo.T_Trans_Purchase as A
	where A.PurchaseId = @PurchaseId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Purchase_SetPurchaseDate]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Purchase_SetPurchaseDate]
	@PurchaseId int
AS
BEGIN
	
	Update A set A.PurchaseDate = getdate(),
				 A.Purchaser = A.ModifiedBy
	from dbo.T_Trans_Purchase as A
	join T_Master_PurchaseStatus AS B
	ON A.StatusId = B.StatusId
	where A.PurchaseId = @PurchaseId AND B.IsFinish = 1
		and A.PurchaseDate is null
END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_PurchaseProduct_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_PurchaseProduct_CheckContraint]
	@PurchaseProductId int
AS
BEGIN
	
	update B
	set B.Price = A.Price,
		B.Cost = A.Cost,
		B.ModifiedBy = A.ModifiedBy,
		B.ModifiedDate = getdate()
		--B.LastReferNo = D.PurchaseCode,
		--B.LastComment = N'Nhập kho'
	from T_Trans_Purchase_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId
	join T_Trans_Purchase_Product  as C
	on A.Id = C.Id		
	join T_Trans_Purchase as D
	ON A.PurchaseId = D.PurchaseId
	join T_Master_PurchaseStatus AS E
	on D.StatusId = E.StatusId
	where E.IsFinish = 1 AND D.IsActive = 1 AND C.Id = @PurchaseProductId

	update A
	set A.VAT = B.VAT
	from T_Trans_Purchase_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId
	where A.Id = @PurchaseProductId
			
	update B
	set B.Quantity = B.Quantity + A.Quantity,
		B.ModifiedBy = ISNULL(A.ModifiedBy, A.CreatedBy),
		B.ModifiedDate = getdate()
		--B.LastReferNo = C.PurchaseCode,
		--B.LastComment = N'Nhập kho'
	from T_Trans_Purchase_Product  as A
	join T_Trans_Products  as B
	on A.ProductId = B.ProductId	
	join T_Trans_Purchase as C
	ON A.PurchaseId = C.PurchaseId
	join T_Master_PurchaseStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @PurchaseProductId

	update B
	set B.Quantity = B.Quantity + A.Quantity,
		B.ModifiedBy = ISNULL(A.ModifiedBy, A.CreatedBy),
		B.ModifiedDate = getdate()
	from T_Trans_Purchase_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_Purchase as C
	ON A.PurchaseId = C.PurchaseId and B.StoreId = C.StoreId
	join T_Master_PurchaseStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @PurchaseProductId

	
	--insert into [dbo].[T_Trans_Product_Store]
	--([ProductId], [StoreId], [Quantity], [AllowNegative], [CreatedBy], [CreatedDate])
	--select A.ProductId, C.StoreId, A.Quantity, ISNULL(A.ModifiedBy, A.CreatedBy), getdate()
	--from T_Trans_Purchase_Product  as A	
	--join T_Trans_Purchase as C
	--ON A.PurchaseId = C.PurchaseId 
	--join T_Master_PurchaseStatus AS D
	--on C.StatusId = D.StatusId
	--left join T_Trans_Product_Store  as B
	--on A.ProductId = B.ProductId and B.StoreId = C.StoreId
	--where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @PurchaseProductId
	--and B.Id is null

	--Insert history
	INSERT INTO [dbo].[T_Trans_ProductQuantity_History]
           ([ProductId],
			[StoreId]
		   ,[ReferNo]
           ,[NumIn]
           ,[NumOut]
           ,[NumRemain]
           ,[Description]
           ,[CreatedBy]
           ,[CreatedDate])
    select A.ProductId, C.StoreId, C.PurchaseCode, A.Quantity, 0, B.Quantity, N'Nhập kho ' + C.PurchaseCode, ISNULL(A.ModifiedBy, A.CreatedBy), getdate()
	from T_Trans_Purchase_Product  as A
	join T_Trans_Product_Store  as B
	on A.ProductId = B.ProductId	
	join T_Trans_Purchase as C 
	ON A.PurchaseId = C.PurchaseId and B.StoreId = C.StoreId
	join T_Master_PurchaseStatus AS D
	on C.StatusId = D.StatusId
	where D.IsFinish = 1 AND C.IsActive = 1 AND A.Id = @PurchaseProductId


	declare @sum money, @num int;

	select  @sum = SUM(A.Quantity * (A.Cost + A.Cost * A.VAT / 100 )),
			@num = SUM(A.Quantity)
	from T_Trans_Purchase_Product  as A
	join T_Trans_Purchase_Product  as B
	on A.PurchaseId = B.PurchaseId
	where B.Id = @PurchaseProductId

	UPDATE A
	SET SumMoney = @sum,
		Debt = iif(@sum > A.Paid, @sum - A.Paid,0),
		Quantity = @num
	from T_Trans_Purchase  as A
	join T_Trans_Purchase_Product  as B
	on A.PurchaseId = B.PurchaseId
	where B.Id = @PurchaseProductId

	--Update History in Product
	declare @ProductId int, @PurchaseCode varchar(50), @Descripttion nvarchar(200);
	select top 1 @ProductId = A.ProductId, @PurchaseCode = B.PurchaseCode
	from T_Trans_Purchase_Product AS A
	join T_Trans_Purchase AS B
	ON A.PurchaseId = B.PurchaseId
	where A.Id = @PurchaseProductId

	set @Descripttion =  N'Nhập kho ' + @PurchaseCode;

	exec [dbo].Trigger_Product_Price_TrackHistory @ProductId, @Descripttion;

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Store_CheckContraint]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Store_CheckContraint]
	@StoreId int
AS
BEGIN
	
	insert into [dbo].[T_Trans_Product_Store]
	([ProductId], [StoreId], [Quantity], [AllowNegative], [CreatedBy], [CreatedDate])
	select A.ProductId, B.StoreId, A.Quantity, A.AllowNegative, A.CreatedBy, getdate()
	from [dbo].[T_Trans_Products] AS A
	join T_Master_Stores AS B
	on 1 = 1
	left join T_Trans_Product_Store AS C
	on  A.ProductId = C.ProductId And B.StoreId = C.StoreId
	where B.StoreId = @StoreId
	And C.Id is null

	update A
	set AllowNegative = B.AllowNegative
	from T_Trans_Product_Store AS A
	join T_Trans_Products AS B
	on A.ProductId = B.ProductId
	where A.StoreId = @StoreId

END

GO
/****** Object:  StoredProcedure [dbo].[Trigger_Supplier_SetDefaultCode]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-02
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Trigger_Supplier_SetDefaultCode]
	@SupplierId int
AS
BEGIN
	Update A set SupplierCode = 'NCC' + REPLICATE('0',6-LEN(A.SupplierId)) + convert(varchar, A.SupplierId)
	from dbo.T_Master_Suppliers as A
	where A.SupplierId = @SupplierId and (A.SupplierCode IS NULL or LEN(A.SupplierCode) = 0)
END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_BulkUpdate]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	
	if(dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'update') = 0)
	begin
		throw 51000, N'Bạn không có quyền chỉnh sữa thông tin này.', 1;
	end
	
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

	INSERT INTO [dbo].[T_System_Exception_Log]
				([ObjectName], [ErrorMessage], [Data], [Source], [IsResolve]
				,[CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate])
	VALUES
				(@TableName, @Errormessage, @Data, 'USP_System_Data_BulkUpdate',0
				,@UserId, getdate(), @UserId, getdate());

    THROW  @ErrorNumber, @Errormessage, @ErrorState

END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Function_Get]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	@UserId int, --= 0,
	@FunctionName varchar(100),-- = 'dbo.UFN_System_Get_Menu', --must have dbo.
	@Parameter nvarchar(1000) ,--= N'1',
	@TextFilter nvarchar(1000) ,--= N'',
	@ColumSum varchar(1000) = '',
	@Action varchar(10) = 'get',
	@GlobalOrder varchar(1000) = null,
	@GlobalOrderDirection int = 1,
	@StartRow int = 1,
	@EndRow int = 10
AS
BEGIN
	
	if(dbo.UFN_System_Check_Role_Object(@UserId, @FunctionName, 'select') = 0)
	begin
		throw 51000, N'Bạn không có quyền xem thông tin này.', 1;
	end

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
			/*else If(@dataType = 'datetime' and @FilterDate is not null)
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
			end*/

			fetch next from colums_cursor 
			into @columName, @dataType
		end

		close colums_cursor;
		deallocate  colums_cursor;

	end

	declare @securityCon varchar(max) = dbo.UFN_System_Check_Role_Condition(@UserId, @FunctionName, 'select', '');
	if(len(@securityCon) > 0)
	begin
		set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' and ( ' + @securityCon + ' )', @securityCon);
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
/****** Object:  StoredProcedure [dbo].[USP_System_Data_List_Get]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	@UserId int,
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
	set @TextFilter = replace(@TextFilter, '''', '''''');

	if(dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'select') = 0)
	begin
		throw 51000, 'Bạn không có quyền xem thông tin này.', 1;
	end

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
		  , @DeleteTableName varchar(10) = 'DeleteTempTable'
		  , @UpdateTableName varchar(10) = 'UpdateTempTable'
		  , @tableCount int = 1
		  , @PKColum varchar(100);

	select Top(1) @PKColum = COLUMN_NAME
	from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	where OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo'	

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
	set @SelectStatement = @TempTableName+'.[Version]' ;

	--Check update
	declare @securityCon varchar(max) = dbo.UFN_System_Check_Role_Condition(@UserId, @TableName, 'update', '');
	declare @canUpdate bit = dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'update');
	if(@canUpdate = 1 and len(@securityCon) > 0)
	begin
		set @JoinStatement = @JoinStatement 
						 + ' left join ( select ' + @PKColum + ' from ' + @TableName + ' where ' + @securityCon + ' ) as ' + @UpdateTableName
						 + ' on ' +  @TempTableName + '.' + @PKColum + ' = ' + @UpdateTableName + '.' + @PKColum;
		set @SelectStatement = @SelectStatement + iif(len(@SelectStatement) > 0, ', ', '') 
					      + ' convert(bit, iif(' + @UpdateTableName + '.' + @PKColum + ' is null, 0, 1)) as _CanUpdate';
	end
	else begin
		set @SelectStatement = @SelectStatement + iif(len(@SelectStatement) > 0, ', ', '') + 'convert(bit, ' + convert(varchar, @canUpdate) + ')  as _CanUpdate';
	end

	--check delete
	set @securityCon = dbo.UFN_System_Check_Role_Condition(@UserId, @TableName, 'delete', '');
	declare @canDelete bit = dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'delete');
	if(@canDelete = 1 and len(@securityCon) > 0)
	begin
		set @JoinStatement = @JoinStatement 
						 + ' left join ( select ' + @PKColum + ' from ' + @TableName + ' where ' + @securityCon + ' ) as ' + @DeleteTableName
						 + ' on ' +  @TempTableName + '.' + @PKColum + ' = ' + @DeleteTableName + '.' + @PKColum;
		set @SelectStatement = @SelectStatement + iif(len(@SelectStatement) > 0, ', ', '')
					      + ' convert(bit, iif(' + @DeleteTableName + '.' + @PKColum + ' is null, 0, 1)) as _CanDelete';
	end
	else begin
		set @SelectStatement = @SelectStatement + iif(len(@SelectStatement) > 0, ', ', '') + 'convert(bit, '+ convert(varchar, @canDelete) + ')  as _CanDelete';
	end

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
						
					set @LastColumName = @specificColum;--@joinColumName;			
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
				set @markSelectColum = 'CONVERT(int, '+ @realColum +') as ' 
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

	set @securityCon  = dbo.UFN_System_Check_Role_Condition(@UserId, @TableName, 'select', @TempTableName);
	set @WhereStatement = iif(len(@Condition) > 0, '(' + @Condition + ')', '')
					   + iif(len(@Condition) > 0 and len(@FilterStatement) > 0, ' and (', '') + @FilterStatement
					   + iif(len(@Condition) > 0 and len(@FilterStatement) > 0, ' ) ', '');
	if(len(@securityCon) > 0)
	begin
		set @WhereStatement = @WhereStatement + iif(len(@WhereStatement) > 0, ' and ( ' + @securityCon + ' )', @securityCon);
	end
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
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Object_Delete]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	@UserId int,
	@TableName varchar(100),
	@Value int,
	@IsHardDelete bit = 0
AS
BEGIN

BEGIN TRANSACTION;

BEGIN TRY
	
	if(dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'delete') = 0)
	begin
		throw 51000, N'Bạn không có quyền xóa thông tin này.', 1;
	end

	declare @ColumName varchar(100);

	select @ColumName = COLUMN_NAME
	from INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	where OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo'	


	--check security		
	declare @isValidRecord bit = 0;
	declare @securityCon varchar(max) = dbo.UFN_System_Check_Role_Condition(@UserId, @TableName, 'delete', '');
	declare @SqlStatement nvarchar(max);
	set @SqlStatement = N'SELECT TOP 1 @isValidRecord = 1 from '+ @TableName 
						+' where ' + @ColumName + ' = ' + convert(varchar, @Value)
						+ iif(len(@securityCon) > 0, ' and ( ' + @securityCon + ' )', '');
	exec sp_executesql @SqlStatement, N'@isValidRecord int out', @isValidRecord out;

	if(@isValidRecord = 0)
	begin
		throw 51000, N'Bạn không có quyền xóa thông tin này.', 1;
	end
	
	if(@IsHardDelete = 0)
	begin
		set @SqlStatement = 'update ' + @TableName + ' set Isactive = 0 '
				+ ', modifiedby = ' + convert(varchar, @UserId)
				+ ' , modifieddate = getdate()'
				+'where ' 
				+ @ColumName + ' = ' + 'N''' + convert(varchar, @Value) + '''';
		exec (@SqlStatement);

		--log history data
		insert into [dbo].[T_System_Data_Log]
        ([TableName], [TableColumn], [KeyValue], [Data], [ModifiedBy], [ModifiedDate])
		select top 1 @TableName, 'IsActive', @Value, '0', @UserId, getdate()
		from dbo.T_System_Log_Config
		where TableName = @TableName and IsLog = 1
	end
	else begin
		set @SqlStatement = 'delete ' + @TableName + ' where ' + @ColumName + ' = ' + 'N''' + convert(varchar, @Value) + '''';
		exec (@SqlStatement);

		--log history data
		insert into [dbo].[T_System_Data_Log]
        ([TableName], [TableColumn], [KeyValue], [Data], [ModifiedBy], [ModifiedDate])
		select top 1 @TableName, '', @Value, 'deleted', @UserId, getdate()
		from dbo.T_System_Log_Config
		where TableName = @TableName and IsLog = 1
	end

	declare @triggerName varchar(100)
	
	declare trigger_cursor cursor for 
	select SPName
	from [dbo].[T_System_Triggers] 
	where TableName = @TableName and (OnDelete = 1 and @IsHardDelete = 1 
									 or OnUpdate = 1 and @IsHardDelete = 0)
	order by OrderExec

	open trigger_cursor

	fetch next from trigger_cursor 
	into @triggerName

	WHILE @@FETCH_STATUS = 0
	BEGIN

		if(len(@triggerName) > 0)
		begin
			exec (@triggerName + ' ' + @Value);
		end

		fetch next from trigger_cursor 
		into @triggerName
	END

	close trigger_cursor;
	deallocate  trigger_cursor;

END TRY
BEGIN CATCH


    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	declare @ErrorNumber int = ERROR_NUMBER()
			,@Errormessage nvarchar(2048) = ERROR_MESSAGE()
			,@ErrorState int = ERROR_STATE();

	INSERT INTO [dbo].[T_System_Exception_Log]
				([ObjectName], [ErrorMessage], [Data], [Source], [IsResolve]
				,[CreatedBy], [CreatedDate], [Version], [ModifiedBy], [ModifiedDate])
	VALUES
				(@TableName, @Errormessage, @Value, 'USP_System_Data_Object_Delete',0
				,@UserId, getdate(), 1, @UserId, getdate());

    THROW  @ErrorNumber, @Errormessage, @ErrorState

END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Object_Get]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	@UserId int,
	@TableName varchar(100),
	@ColumName varchar(100) = '', --If null or empty, get from primary key
	@Value nvarchar(1000)
AS
BEGIN

	if(dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'select') = 0)
	begin
		throw 51000, N'Bạn không có quyền xem thông tin này.', 1;
	end

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

	declare @securityCon varchar(max) = dbo.UFN_System_Check_Role_Condition(@UserId, @TableName, 'select', '');
	declare @sqlStement nvarchar(max);
	set @sqlStement = 'select ' + @listcolums + ' from ' + @TableName 
					+ ' where '+ @ColumName + ' = ' + 'N''' + @Value + '''' 
					+ iif(len(@securityCon) > 0, ' and ( ' + @securityCon + ' )', '');
	exec (@sqlStement);

END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Unpivot]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-05-03
-- Description:	Get history
-- =============================================
CREATE PROCEDURE [dbo].[USP_System_Data_Unpivot]
	@TableName varchar(100),
	@PKColum varchar(100),
	@KeyValue varchar(50),
	@Action varchar(50)
AS
BEGIN
	
	if(@Action = 'insert')
	begin
		DECLARE @colsUnpivot AS NVARCHAR(MAX),
			@colsConvertUnpivot AS NVARCHAR(MAX),
		@query  AS NVARCHAR(MAX)


		select @colsUnpivot 
		  = stuff((select ','+quotename(C.column_name)
				   from information_schema.columns as C
				   where C.table_name = @TableName
						 and C.column_name not in( @PKColum, 'version', 'modifiedby', 'modifieddate', 'createdby', 'createddate')
				   for xml path('')), 1, 1, '')

		select @colsConvertUnpivot 
		  = stuff((select ', convert(nvarchar(max), ' + quotename(C.column_name) +') as '+ quotename(C.column_name)
				   from information_schema.columns as C
				   where C.table_name = @TableName 
						 and C.column_name not in( @PKColum, 'version', 'modifiedby', 'modifieddate', 'createdby', 'createddate')
				   for xml path('')), 1, 1, '')

		set @query 
		  = 'insert into dbo.T_System_Tmp
			 select ''' + @TableName + ''', ''' + @KeyValue + ''', version, _NolumName, _DataValue
			 from (
				select version, ' + @colsConvertUnpivot + '
				from '+@TableName+'
				where ' + @PKColum + ' = ' + @KeyValue + '
			) as a
			 unpivot
			 (
				_DataValue
				for _NolumName in ('+ @colsunpivot +')
			 ) u'

		exec sp_executesql @query
	end
	else if(@Action = 'delete')
	begin
		delete dbo.T_System_Tmp
		where TableName = @TableName and KeyValue = @KeyValue
	end
END

GO
/****** Object:  StoredProcedure [dbo].[USP_System_Data_Update]    Script Date: 5/3/2016 3:50:23 PM ******/
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

BEGIN TRANSACTION;

BEGIN TRY

	set @Data = replace(@Data, '''', '''''');

	if(dbo.UFN_System_Check_Role_Object(@UserId, @TableName, 'update') = 0)
	begin
		throw 51000, N'Bạn không có quyền chỉnh sửa thông tin này.', 1;
	end

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
	
	--check security		
	declare @isValidRecord bit = 0;
	if( @isExistedRecord = 1)
	begin
		declare @securityCon varchar(max) = dbo.UFN_System_Check_Role_Condition(@UserId, @TableName, 'update', '');
		set @SqlStatement = N'SELECT TOP 1 @isValidRecord = 1 from '+ @TableName 
							+' where ' + @PrimaryKey + ' = ' + @PrimaryKeyValue
							+ iif(len(@securityCon) > 0, ' and ( ' + @securityCon + ' )', '');
		exec sp_executesql @SqlStatement, N'@isValidRecord int out', @isValidRecord out
	end
	else begin
		
		declare @Condition table (Columname varchar(100), Value varchar(max))

		insert into @Condition
		select * from [dbo].[UFN_System_Check_Role_Condition_Table](@UserId, @TableName, 'update')

		if( exists(select top(1) 1 from  @Condition))
		begin
			select @isValidRecord = 1
			from @DataTable as A
			join @Condition as B
			ON A.colum = B.Columname and A.data = B.Value
		end
		else begin
			set @isValidRecord = 1;
		end
		
	end
	if(@isValidRecord = 0)
	begin
		throw 51000, N'Bạn không có quyền chỉnh sửa thông tin này.', 1;
	end

	-- Process 
	set @SqlStatement = NULL;
	declare @SqlColumUpdate nvarchar(max), @SqlDataUpdate nvarchar(max)
	declare @result int = -1;
	if( @isExistedRecord = 1)
	begin
		
		--Check version
		declare @currentVersion int = 0, @userVersion int = 0;

		select @userVersion = data 
		from @DataTable
		where colum = 'version'

		set @SqlStatement = N'SELECT TOP 1 @currentVersion = [version] from '+ @TableName 
							+' where ' + @PrimaryKey + ' = ' + @PrimaryKeyValue;
		exec sp_executesql @SqlStatement, N'@currentVersion int out', @currentVersion out
		if(@currentVersion <> @userVersion)
		begin
			throw 51000, N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', 1;
		end
		
		--Update
		set @SqlStatement = NULL;
		set @SqlColumUpdate = NULL;		

		SELECT @SqlStatement = COALESCE(@SqlStatement + ', ', '') + colum + IIF(data IS NOT NULL, '= N''' + data + '''', ' = NULL') 
		FROM @DataTable AS A
		JOIN information_schema.columns AS B 
		ON A.colum = B.COLUMN_NAME		
		where  B.table_name = @TableName and A.colum not in( @PrimaryKey, 'version', 'modifiedby', 'modifieddate', 'createdby', 'createddate')

		--Take snapshoot before update
		exec [dbo].[USP_System_Data_Unpivot] @TableName, @PrimaryKey, @PrimaryKeyValue, 'insert'

		--set @SqlStatement = replace(@SqlStatement, '''', '''''');
		set @SqlStatement = 'update ' + @TableName + ' set ' +
							+ @SqlStatement
							+ ', modifiedby = ''' + convert(varchar(10), @UserId) + ''''
							+ ' , modifieddate = getdate()' 
							+ ' , version = version + 1' 
							+ ' where ' + @PrimaryKey + ' = ' + @PrimaryKeyValue ;

		exec(@SqlStatement);

		set @result = @PrimaryKeyValue;

		--Take snapshoot after update
		exec [dbo].[USP_System_Data_Unpivot] @TableName, @PrimaryKey, @result, 'insert';

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
		where B.table_name = @TableName and colum not in( @PrimaryKey, 'version', 'modifiedby', 'modifieddate', 'createdby', 'createddate')

		--set @SqlDataUpdate = replace(@SqlDataUpdate, '''', '''''');
		set @SqlStatement = 'insert into ' + @TableName + ' ' +
							+ '('  +  @SqlColumUpdate + ' ,version, createdby, createddate, modifiedby, modifieddate)'
							+ ' values ( ' + @SqlDataUpdate + ',1,' + convert(varchar(10), @UserId) + ',getdate(), '+ convert(varchar(10), @UserId) +',getdate())';

		exec(@SqlStatement);

		--select @SqlStatement

		set @result = IDENT_CURRENT( @TableName );

		--Take snapshoot after update
		exec [dbo].[USP_System_Data_Unpivot] @TableName, @PrimaryKey, @result, 'insert';

	end

	declare @triggerName varchar(100)
	
	declare trigger_cursor cursor for 
	select SPName
	from [dbo].[T_System_Triggers] 
	where TableName = @TableName and (OnInsert = 1 and @isExistedRecord = 0 
									 or OnUpdate = 1 and @isExistedRecord = 1)
	order by OrderExec

	open trigger_cursor

	fetch next from trigger_cursor 
	into @triggerName

	WHILE @@FETCH_STATUS = 0
	BEGIN

		if(len(@triggerName) > 0)
		begin
			exec (@triggerName + ' ' + @result);
		end

		fetch next from trigger_cursor 
		into @triggerName
	END

	close trigger_cursor;
	deallocate  trigger_cursor;


	declare @LastVersion int;
	select @LastVersion = max([version])
	from dbo.T_System_Tmp 
	where TableName = @TableName and KeyValue = @result 

	--log history data
	insert into [dbo].[T_System_Data_Log]
    ([TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate])
	select @TableName, A.ColumName, @result, @LastVersion, A.Data, @UserId, getdate()
	from dbo.T_System_Tmp as A
	left join dbo.T_System_Tmp as B
	on  A.TableName = B.TableName and A.KeyValue = B.KeyValue
		and A.ColumName = B.ColumName and B.[Version] = (@LastVersion-1)
	join dbo.T_System_Log_Config as C
	on C.TableName = @TableName and C.IsLog = 1
	where A.TableName = @TableName and A.KeyValue = @result
	and A.[Version] = @LastVersion
	and (A.Data <> B.Data 
		or (A.Data is null and B.Data is not null)
		or (A.Data is not null and B.Data is null))
		
	exec [dbo].[USP_System_Data_Unpivot] @TableName, @PrimaryKey, @result, 'delete'

	select @result as Result

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

	declare @ErrorNumber int = ERROR_NUMBER()
			,@Errormessage nvarchar(2048) = ERROR_MESSAGE()
			,@ErrorState int = ERROR_STATE();

	INSERT INTO [dbo].[T_System_Exception_Log]
				([ObjectName], [ErrorMessage], [Data], [Source], [IsResolve]
				,[CreatedBy], [CreatedDate], [Version], [ModifiedBy], [ModifiedDate])
	VALUES
				(@TableName, @Errormessage, @Data, 'USP_System_Data_Update',0
				,@UserId, getdate(), 1, @UserId, getdate());

    THROW  @ErrorNumber, @Errormessage, @ErrorState;

END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

END

GO
/****** Object:  StoredProcedure [dbo].[USP_Test]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	USP_Test
-- =============================================
CREATE PROCEDURE [dbo].[USP_Test]
	@P1 int
AS
BEGIN
	select 1;
END

GO
/****** Object:  StoredProcedure [dbo].[USP_TEST_DUMMY_DATA]    Script Date: 5/3/2016 3:50:23 PM ******/
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
truncate table [dbo].[T_Trans_Purchase_Product]
truncate table [dbo].[T_Trans_ProductQuantity_History]
truncate table [dbo].[T_Trans_ProductPrice_History]
truncate table [dbo].[T_Trans_Product_Store]
truncate table [dbo].[T_Trans_Order_Product]
truncate table [dbo].[T_Trans_Product_Attribute]

DELETE FROM T_Trans_Products
DBCC CHECKIDENT ('T_Trans_Products',RESEED, 0)

DELETE FROM T_Trans_Purchase
DBCC CHECKIDENT ('T_Trans_Purchase',RESEED, 0)

DELETE FROM T_Trans_Orders
DBCC CHECKIDENT ('T_Trans_Orders',RESEED, 0)

DELETE FROM T_Master_Customers
DBCC CHECKIDENT ('T_Master_Customers',RESEED, 0)

DELETE FROM T_Master_Suppliers
DBCC CHECKIDENT ('T_Master_Suppliers',RESEED, 0)


END

GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Inventory]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Inventory]
(	
	@StartDate date,
	@EndDate date,
	@ProductGroup int,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	ProductId int,
    ProductCode varchar(50),
	ProductName nvarchar(500),
	Quantity int,
	BeginPeriod int,
	NumIn int,
	NumOut int,
	EndPeriod int
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())
	
	DECLARE @SumInOut TABLE(ProductId int, NumIn int, NumOut int)
	DECLARE @SumBeginPeriod TABLE(ProductId int, Num int)

	INSERT INTO @SumInOut
	SELECT ProductId, SUM(NumIn), SUM(NumOut)	
	FROM [dbo].[T_Trans_ProductQuantity_History]
	where CONVERT(date, CreatedDate) between @StartDate and @EndDate
		 and [StoreId] = @StoreId
	group by ProductId

	INSERT INTO @SumBeginPeriod
	SELECT A.ProductId, ISNULL(SUM(A.NumIn), 0) - ISNULL(SUM(A.NumOut), 0)
	FROM [dbo].[T_Trans_ProductQuantity_History] AS A
	JOIN @SumInOut AS B
	ON A.ProductId = B.ProductId
	where CONVERT(date, CreatedDate) < @StartDate
		and A.[StoreId] = @StoreId
	group by A.ProductId

	insert into @RtnValue
	select C.ProductId, C.ProductCode, C.ProductName, C.Quantity, ISNULL(B.Num, 0), A.NumIn, A.NumOut, ISNULL(B.Num, 0) + A.NumIn - A.NumOut 
	from @SumInOut AS A
	left join @SumBeginPeriod AS B
	ON A.ProductId = B.ProductId
	join T_Trans_Products AS C
	On A.ProductId = C.ProductId
	where (@ProductGroup =0 or @ProductGroup = C.ProductGroup)

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Payment_Cashier]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
--select * from  [dbo].[UFN_Report_Revenue_By_Product]('2016-04-01', '2016-04-30', 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Payment_Cashier]
(	
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	Cashier int,
	StoreId int,
    CashierName nvarchar(100),
	Payment money,
	Receivement money,
	Pending money
)
AS
BEGIN

	insert into @RtnValue
	select Cashier.Cashier, Cashier.StoreId, Cashier.UserName
		  ,Cashier.Payment
		  ,Receivement.Amount
		  ,Cashier.Payment - Receivement.Amount
	from 
		(
		select Orders.Cashier, Orders.StoreId, Users.UserName
		  ,isnull(sum(Payment.Amount), 0) as Payment
		from dbo.T_Trans_Payment AS Payment
		join dbo.T_Trans_Orders AS Orders
		on Payment.OrderId = Orders.OrderId
		join dbo.T_Master_OrderStatus as [Status]
		on Orders.OrderStatus = [Status].StatusId
		join dbo.T_Master_User as Users
		on Orders.Cashier = Users.UserId
		where Orders.IsActive = 1 and [Status].IsFinish = 1
		and Orders.StoreId = @StoreId
		group by Orders.Cashier, Orders.StoreId, Users.UserName
		) as Cashier
	left join 
		(select Cashier, sum(Amount) as Amount 
		from dbo.T_Trans_Receivement
		where StoreId = @StoreId
		group by Cashier) AS Receivement
	on Cashier.Cashier = Receivement.Cashier
	
	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Profit_By_Product]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
-- select * from  [dbo].[UFN_Report_Profit_By_Product](1, '2016-04-01', '2016-04-30', 1, 0)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Profit_By_Product]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int,
	@ProductGroup int
)
RETURNS @RtnValue TABLE 
(
	ProductCode varchar(32),
	ProductName nvarchar(500),
    Quantity int,
	[ReturnQuan] int,
	Discount money,
	Revenue money,
	[ReturnAmount] money,
	Cost money,
	Profit money
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())

	declare @Stores table (value int)
	declare @Costs table (ProductId int, Cost money)
	declare @Orders table (ProductId int, IsActive bit, Quantity int, Discount money, Amount money)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')
	
	insert into @Orders
	select ProductOrder.ProductId,
			Orders.IsActive,
			count(1) as Quantity,
			SUM(ProductOrder.Quantity * ProductOrder.Price - ProductOrder.RealPrice) as Discount,
			SUM(ProductOrder.RealPrice) as SumMoney
	from T_Trans_Order_Product as ProductOrder
	join [dbo].[T_Trans_Orders] AS Orders
	on ProductOrder.OrderId = Orders.OrderId
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by ProductOrder.ProductId, Orders.IsActive

	insert into @Costs
	select ProductOrder.ProductId,
			sum(ProductOrder.Quantity * ProductOrder.Cost)
	from T_Trans_Order_Product as ProductOrder
	join [dbo].[T_Trans_Orders] AS Orders
	on ProductOrder.OrderId = Orders.OrderId
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where Orders.IsActive = 1 and [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by ProductOrder.ProductId

	insert into @RtnValue
	select Products.ProductCode, Products.ProductName
		  ,sum( iif(Orders.IsActive = 1, Orders.Quantity, 0))
		  ,sum(iif(Orders.IsActive = 0, Orders.Quantity, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Discount, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Amount, 0))
		  ,sum( iif(Orders.IsActive = 0, Orders.Amount, 0))
		  ,sum(isnull(Costs.Cost, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Amount, 0)) - sum(isnull(Costs.Cost, 0))
	from T_Trans_Products as Products
	join @Orders as Orders
	on Products.ProductId = Orders.ProductId
	left join @Costs as Costs
	on Orders.ProductId = Costs.ProductId and Orders.IsActive = 1
	where (@ProductGroup = 0 or Products.ProductGroup = @ProductGroup)
	group by Products.ProductCode, Products.ProductName
	order by Products.ProductCode

	return;
END


GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Profit_By_Store]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
-- select * from  [dbo].[UFN_Report_Profit_By_Store](1, '2016-04-01', '2016-04-30', 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Profit_By_Store]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	StoreCode nvarchar(100),
    Quantity int,
	[ReturnQuan] int,
	Discount money,
	Revenue money,
	[ReturnAmount] money,
	Cost money,
	Profit money
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())

	declare @Stores table (value int)
	declare @Costs table (StoreId int, Cost money)
	declare @Orders table (StoreId int, IsActive bit, Quantity int, Discount money, Amount money)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')
	
	insert into @Orders
	select  Orders.StoreId,
			Orders.IsActive,
			count(1) as Quantity,
			SUM(Orders.OrginalMoney - Orders.SumMoney) as Discount,
			SUM(Orders.SumMoney) as SumMoney
	from [dbo].[T_Trans_Orders] AS Orders
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by Orders.StoreId, Orders.IsActive

	insert into @Costs
	select  Orders.StoreId,
			sum(ProductOrder.Quantity * ProductOrder.Cost)
	from T_Trans_Order_Product as ProductOrder
	join [dbo].[T_Trans_Orders] AS Orders
	on ProductOrder.OrderId = Orders.OrderId
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where Orders.IsActive = 1 and [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by Orders.StoreId

	insert into @RtnValue
	select Stores.StoreCode
		  ,sum( iif(Orders.IsActive = 1, Orders.Quantity, 0))
		  ,sum(iif(Orders.IsActive = 0, Orders.Quantity, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Discount, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Amount, 0))
		  ,sum( iif(Orders.IsActive = 0, Orders.Amount, 0))
		  ,sum(isnull(Costs.Cost, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Amount, 0)) - sum(isnull(Costs.Cost, 0))
	from dbo.T_Master_Stores as Stores 
	join @Orders as Orders
	on Stores.StoreId = Orders.StoreId
	left join @Costs as Costs
	on Orders.StoreId = Costs.StoreId and Orders.IsActive = 1
	group by Stores.StoreCode

	return;
END


GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Profit_By_Time]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
-- select * from  [dbo].[UFN_Report_Profit_By_Time](1, '2016-04-01', '2016-04-30', 1, 'w')
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Profit_By_Time]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int,
	@ReportBy char
)
RETURNS @RtnValue TABLE 
(
	GroupBy varchar(50),
    Quantity int,
	[ReturnQuan] int,
	Discount money,
	Revenue money,
	[ReturnAmount] money,
	Cost money,
	Profit money
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())

	declare @Stores table (value int)
	declare @Costs table (GroupBy varchar(50), Cost money)
	declare @Orders table (GroupBy varchar(50), IsActive bit, Quantity int, Discount money, Amount money)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')
	
	insert into @Orders
	select case @ReportBy when 'd' then format(Orders.SoldDate, 'yyyy-MM-dd') 
							when 'm' then convert(varchar, year(Orders.SoldDate))+'-'+convert(varchar,month(Orders.SoldDate))
							when 'w' then 'W'+convert(varchar, datepart(WW, Orders.SoldDate))
			end as GroupBy,
			Orders.IsActive,
			count(1) as Quantity,
			SUM(Orders.OrginalMoney - Orders.SumMoney) as Discount,
			SUM(Orders.SumMoney) as SumMoney
	from [dbo].[T_Trans_Orders] AS Orders
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by case @ReportBy when 'd' then format(Orders.SoldDate, 'yyyy-MM-dd') 
							when 'm' then convert(varchar, year(Orders.SoldDate))+'-'+convert(varchar,month(Orders.SoldDate))
							when 'w' then 'W'+convert(varchar, datepart(WW, Orders.SoldDate))
			 end, Orders.IsActive

	insert into @Costs
	select case @ReportBy when 'd' then format(Orders.SoldDate, 'yyyy-MM-dd') 
							when 'm' then convert(varchar, year(Orders.SoldDate))+'-'+convert(varchar,month(Orders.SoldDate))
							when 'w' then 'W'+convert(varchar, datepart(WW, Orders.SoldDate))
			end as GroupBy,
			sum(ProductOrder.Quantity * ProductOrder.Cost)
	from T_Trans_Order_Product as ProductOrder
	join [dbo].[T_Trans_Orders] AS Orders
	on ProductOrder.OrderId = Orders.OrderId
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where Orders.IsActive = 1 and [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by case @ReportBy when 'd' then format(Orders.SoldDate, 'yyyy-MM-dd') 
							when 'm' then convert(varchar, year(Orders.SoldDate))+'-'+convert(varchar,month(Orders.SoldDate))
							when 'w' then 'W'+convert(varchar, datepart(WW, Orders.SoldDate))
			 end

	insert into @RtnValue
	select Orders.GroupBy
		  ,sum( iif(Orders.IsActive = 1, Orders.Quantity, 0))
		  ,sum(iif(Orders.IsActive = 0, Orders.Quantity, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Discount, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Amount, 0))
		  ,sum( iif(Orders.IsActive = 0, Orders.Amount, 0))
		  ,sum(isnull(Costs.Cost, 0))
		  ,sum( iif(Orders.IsActive = 1, Orders.Amount, 0)) - sum(isnull(Costs.Cost, 0))
	from @Orders as Orders
	left join @Costs as Costs
	on Orders.GroupBy = Costs.GroupBy and Orders.IsActive = 1
	group by Orders.GroupBy

	return;
END


GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Profit_RangeDate]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
-- select * from  [dbo].[UFN_Report_Profit_RangeDate](1, '2016-05-01', '2016-05-31', 0)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Profit_RangeDate]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	Discount money,
	Revenue money,
	[ReturnAmount] money,
	Cost money,
	ExtraCost money
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())

	declare @Stores table (value int);
	declare @Cost money = 0, @ExtraCost money = 0
			,@Revenue money = 0, @ReturnAmount money = 0
			,@Discount money = 0;
	declare @Orders table (IsActive bit, Discount money, Amount money);

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')
	
	insert into @Orders
	select Orders.IsActive,
			SUM(Orders.OrginalMoney - Orders.SumMoney) as Discount,
			SUM(Orders.SumMoney) as SumMoney
	from [dbo].[T_Trans_Orders] AS Orders
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by Orders.IsActive

	select @Cost = sum(ProductOrder.Quantity * ProductOrder.Cost)
	from [dbo].[T_Trans_Order_Product] as ProductOrder
	join [dbo].[T_Trans_Orders] AS Orders
	on ProductOrder.OrderId = Orders.OrderId
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where Orders.IsActive = 1 and [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 

	select @ExtraCost = sum(Amount)
	from [dbo].[T_Trans_Cost] as Cost
	join @Stores as Stores
	on Cost.StoreId = Stores.value
	where Cost.IsActive = 1 
	and (@StoreId = 0 or Cost.StoreId = @StoreId)
	and convert(date, Cost.PaidDate) between @StartDate and @EndDate 
	
	select @Revenue = Amount, @Discount = Discount
	from @Orders
	where IsActive = 1

	select @ReturnAmount = Amount
	from @Orders
	where IsActive = 0

	insert into @RtnValue
	select @Discount, @Revenue, @ReturnAmount, @Cost, @ExtraCost

	return;
END


GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Profit_Summary]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
-- select * from  [dbo].[UFN_Report_Profit_Summary](1, '2016-05-01', '2016-05-31', 0)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Profit_Summary]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	Discount money,
	Revenue money,
	ReturnAmount money,
	Cost money,
	ExtraCost money,
	PreDiscount money,
	PreRevenue money,
	PreReturnAmount money,
	PreCost money,
	PreExtraCost money,
	PreStartDate varchar(20),
	PreEndDate varchar(20)
)
AS
BEGIN

	Declare @ThisPer table(Discount money,
							Revenue money,
							ReturnAmount money,
							Cost money,
							ExtraCost money);

	Declare @PrePer table(Discount money,
							Revenue money,
							ReturnAmount money,
							Cost money,
							ExtraCost money);	

	declare @DateFormat varchar (20) = dbo.UFN_System_GetRule('DATE_FORMAT')

	insert into @ThisPer
	select Discount, Revenue, ReturnAmount, Cost, ExtraCost 
	from [dbo].[UFN_Report_Profit_RangeDate](@UserId, @StartDate, @EndDate, @StoreId);

	declare @diff int, @PreStartDate date, @PreEndDate date;
	set @EndDate = dateadd(DD, 1, @EndDate);
	if(day(@EndDate) = 1 and day(@StartDate) = 1)
	begin
		set @diff = datediff(MM,  @StartDate, @EndDate);
		set @PreEndDate = dateadd(DD, -1, @StartDate);
		set @PreStartDate = dateadd(MM, -@diff, @StartDate);
	end
	else begin
		set @EndDate = dateadd(DD, -1, @EndDate);
		set @diff = datediff(DD,  @StartDate, @EndDate);
		set @PreEndDate = dateadd(DD, -1, @StartDate);
		set @PreStartDate = dateadd(DD, -@diff, @PreEndDate);
	end


	insert into @PrePer
	select Discount, Revenue, ReturnAmount, Cost, ExtraCost
	from [dbo].[UFN_Report_Profit_RangeDate](@UserId, @PreStartDate, @PreEndDate, @StoreId);

	insert into @RtnValue
	select ThisPer.Discount, ThisPer.Revenue, ThisPer.ReturnAmount, ThisPer.Cost, ThisPer.ExtraCost,
		   PrePer.Discount, PrePer.Revenue, PrePer.ReturnAmount, PrePer.Cost, PrePer.ExtraCost,
		   format(@PreStartDate, @DateFormat), format(@PreEndDate, @DateFormat)
	from @ThisPer as ThisPer
	cross join @PrePer as PrePer

	return;
END



GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Revenue_By_Product]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
--select * from  [dbo].[UFN_Report_Revenue_By_Product]('2016-04-01', '2016-04-30', 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Revenue_By_Product]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	ProductId int,
    ProductCode varchar(32),
    ProductName varchar(500),
	Revenue money,
	Quantity int
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())
	
	declare @Stores table (value int)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')

	insert into @RtnValue
	select Products.ProductId, Products.ProductCode, Products.ProductName, isnull(Orders.Price, 0), isnull(Orders.Quantity, 0)
	from T_Trans_Products AS Products
	left join
		(select OrderProduct.ProductId
			 ,SUM(OrderProduct.Quantity * (OrderProduct.Price - (iif(OrderProduct.IsDiscountPercent = 1, OrderProduct.Discount * OrderProduct.Price / 100, OrderProduct.Discount)))) AS Price
			 ,SUM(OrderProduct.Quantity) as Quantity
		from [dbo].[T_Trans_Order_Product] AS OrderProduct
		join [dbo].[T_Trans_Orders] AS Orders
		on OrderProduct.OrderId = Orders.OrderId
		join [dbo].[T_Master_OrderStatus] as [Status]
		on Orders.OrderStatus = [Status].StatusId
		join @Stores as Stores
		on Orders.StoreId = Stores.value
		where Orders.IsActive = 1 and [Status].IsFinish = 1
		and (@StoreId = 0 or Orders.StoreId = @StoreId)
		and convert(date, Orders.SoldDate) between @StartDate and @EndDate
		group by OrderProduct.ProductId) AS Orders
	on Products.ProductId = Orders.ProductId
	order by Orders.Quantity desc

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Revenue_By_Seller]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
--select * from  [dbo].[UFN_Report_Revenue_By_Seller]('2016-04-01', '2016-04-30', 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Revenue_By_Seller]
(	
	@UserId int,
	@StartDate date,
	@EndDate date,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	UserId int,
    CashierName nvarchar(100),
	Revenue money,
	NumOrders int
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())

	declare @Stores table (value int)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')
	
	insert into @RtnValue
	select Orders.Cashier, Users.UserName, sum(Orders.SumMoney), count(1)
	from [dbo].[T_Trans_Orders] AS Orders
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join [dbo].[T_Master_User] as Users
	on Orders.Cashier = Users.UserId
	join @Stores as Stores
	on Orders.StoreId = Stores.value
	where Orders.IsActive = 1 and [Status].IsFinish = 1
	and (@StoreId = 0 or Orders.StoreId = @StoreId)
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate 
	group by Orders.Cashier, Users.UserName

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Revenue_By_Store]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
--select * from  [dbo].[UFN_Report_Revenue_By_Seller]('2016-04-01', '2016-04-30', 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Revenue_By_Store]
(	
	@StartDate date,
	@EndDate date
)
RETURNS @RtnValue TABLE 
(
	StoreId int,
    StoreCode nvarchar(100),
	Revenue money,
	NumOrders int
)
AS
BEGIN

	SET @StartDate = ISNULL(@StartDate, getdate())
	SET @EndDate = ISNULL(@EndDate, getdate())
	
	insert into @RtnValue
	select Orders.StoreId, Stores.StoreCode, sum(Orders.SumMoney), count(1)
	from [dbo].[T_Trans_Orders] AS Orders
	join [dbo].[T_Master_OrderStatus] as [Status]
	on Orders.OrderStatus = [Status].StatusId
	join [dbo].[T_Master_Stores] as Stores
	on Orders.StoreId = Stores.StoreId
	where Orders.IsActive = 1 and [Status].IsFinish = 1
	and convert(date, Orders.SoldDate) between @StartDate and @EndDate
	group by Orders.StoreId, Stores.StoreCode

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Revenue_In_Month]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
--select * from  [dbo].[UFN_Report_Revenue_In_Month](4, 2016, 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Revenue_In_Month]
(	
	@UserId int,
	@Month int,
	@Year int,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	[Day] int,
	Revenue money,
	NumOrders int
)
AS
BEGIN
	
	declare @StartDate date, @EndDate date;
	SET @StartDate = convert(varchar(5), @Year) + '-' + convert(varchar(5), @Month) + '-' + '01'
	SET @EndDate = dateadd(dd, -1, dateadd(mm, 1, @StartDate))

	declare @Dates table([date] date);
	declare @run date = @StartDate;
	while(@run <= @EndDate)
	begin
		insert @Dates
		values (@run);
		
		set @run = dateadd(dd, 1, @run);
		 
	end

	declare @Stores table (value int)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')

	insert into @RtnValue
	select day(Dates.[date]), isnull(sum(Orders.SumMoney), 0), isnull(sum(NumOrders), 0)
	from @Dates as Dates
	left join
		(select sum(Orders.SumMoney) as SumMoney, count(1) as NumOrders, convert(date, Orders.SoldDate) as SoldDate
		from [dbo].[T_Trans_Orders] AS Orders
		join [dbo].[T_Master_OrderStatus] as [Status]
		on Orders.OrderStatus = [Status].StatusId
		join @Stores as Stores
		on Orders.StoreId = Stores.value
		where Orders.IsActive = 1 and [Status].IsFinish = 1
		and (@StoreId = 0 or Orders.StoreId = @StoreId)
		and convert(date, Orders.SoldDate) between @StartDate and @EndDate
		group by convert(date, Orders.SoldDate)) AS Orders
	on Dates.[date] = Orders.SoldDate
	group by Dates.[date]

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_Report_Revenue_In_Year]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-03-31
-- Description:	Get Ineventory report
--select * from  [dbo].[UFN_Report_Revenue_In_Month](4, 2016, 1)
-- =============================================
CREATE FUNCTION [dbo].[UFN_Report_Revenue_In_Year]
(	
	@UserId int,
	@Year int,
	@StoreId int
)
RETURNS @RtnValue TABLE 
(
	[Month] int,
	Revenue money,
	NumOrders int
)
AS
BEGIN
	
	declare @StartDate date, @EndDate date;
	SET @StartDate = convert(varchar(5), @Year) + '-01-01'
	SET @EndDate = convert(varchar(5), @Year) + '-12-31'

	declare @Months table([month] int);
	declare @run int = 1;
	while(@run <= 12)
	begin
		insert @Months
		values (@run);
		
		set @run = @run + 1;
		 
	end

	declare @Stores table (value int)

	insert into @Stores
	select Value from 
	[dbo].[UFN_System_Check_Role_Condition_Table](@UserId, 'T_Trans_Orders', 'select')


	insert into @RtnValue
	select Months.[month], isnull(sum(Orders.SumMoney), 0), isnull(sum(NumOrders), 0)
	from @Months as Months
	left join
		(select sum(Orders.SumMoney) as SumMoney, count(1) as NumOrders, month(Orders.SoldDate) as [Month]
		from [dbo].[T_Trans_Orders] AS Orders
		join [dbo].[T_Master_OrderStatus] as [Status]
		on Orders.OrderStatus = [Status].StatusId
		join @Stores as Stores
		on Orders.StoreId = Stores.value
		where Orders.IsActive = 1 and [Status].IsFinish = 1
		and (@StoreId = 0 or Orders.StoreId = @StoreId)
		and convert(date, Orders.SoldDate) between @StartDate and @EndDate
		group by month(Orders.SoldDate)) AS Orders
	on Months.[month] = Orders.[Month]
	group by Months.[month]

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_Check_Role_Condition]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-24
-- Description:	select [dbo].[UFN_System_Check_Role_Condition](1, 'T_Trans_Orders', 'delete', 'a')
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_Check_Role_Condition]
(
	@UserId int,
	@ObjectName varchar(100),
	@Action varchar(20),
	@TempTableName varchar(100) = ''
)
RETURNS varchar(max)
AS
BEGIN
	
	set @ObjectName = replace(replace(replace(@ObjectName, 'dbo.', ''), ']', ''), '[', '');

	declare @Result varchar(max)

	declare @StoreUser table (Columname varchar(100), Value nvarchar(max))
	declare @StringValue table (Columname varchar(100), NameValues varchar(max))
	declare @FrezeCondition varchar(max) = '';

	insert into @StoreUser
	select distinct ColumName, Value 
	from dbo.V_System_User_Mapping_Filter
	where ObjectName = @ObjectName
	and UserId = @UserId
	and (@Action = 'select' and CanSelect = 1
		or @Action = 'update' and CanUpdate = 1
		or @Action = 'delete' and CanDelete = 1)
	
	insert into @StringValue
	SELECT 
	  Columname,
	  STUFF((
		SELECT ', ' + Value 
		FROM @StoreUser
		WHERE (Columname = Results.Columname)  
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		,1,2,'') AS NameValues
	FROM @StoreUser Results
	GROUP BY Columname


	select @Result = COALESCE(@Result + ' or ', '') 
					+ iif(len(@TempTableName) > 0, @TempTableName + '.' , '') 
					+ Columname + ' in (' + NameValues + ')'
	from @StringValue

	if(@Action = 'update')
	begin
		select top(1) @FrezeCondition = UpdatableCondition
		from dbo.T_System_Object_Freze_Condition
		where TableName = @ObjectName
	end
	else if(@Action = 'delete')
	begin
		select top(1) @FrezeCondition = DeletableCondition
		from dbo.T_System_Object_Freze_Condition
		where TableName = @ObjectName
	end
	if(len(@FrezeCondition) > 0)
	begin

		if(len(@TempTableName) > 0)
		begin
			set @FrezeCondition = replace(@FrezeCondition, '[', @TempTableName + '.[');
		end

		if(len(@Result) >0)
		begin
			set @Result = '( ' + @Result + ' ) and ( ' + @FrezeCondition + ' )';
		end
		else begin
			set @Result =  @FrezeCondition ;
		end
	end

	return ISNULL(@result, '');

END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_Check_Role_Condition_Table]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-24
-- Description:	select * from [dbo].[UFN_System_Check_Role_Condition_Table](1, 'T_Master_Stores', 'update')
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_Check_Role_Condition_Table]
(
	@UserId int,
	@ObjectName varchar(100),
	@Action varchar(20)
)
RETURNS @RtnValue TABLE 
(
	Columname varchar(100),
    Value varchar(max)
)
AS
BEGIN
	
	declare @StoreUser table (Columname varchar(100), Value nvarchar(max))

	--insert into @StoreUser
	insert into @RtnValue
	select distinct ColumName, Value 
	from dbo.V_System_User_Mapping_Filter
	where ObjectName = @ObjectName
	and UserId = @UserId
	and (@Action = 'select' and CanSelect = 1
		or @Action = 'update' and CanUpdate = 1
		or @Action = 'delete' and CanDelete = 1)
	
	/*insert into @RtnValue
	SELECT 
	  Columname,
	  STUFF((
		SELECT ', ' + Value 
		FROM @StoreUser
		WHERE (Columname = Results.Columname)  
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		,1,2,'') AS NameValues
	FROM @StoreUser Results
	GROUP BY Columname*/

	return ;

END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_Check_Role_Object]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Duong Thanh Phong
-- Create date: 2016-04-24
-- Description:	select dbo.UFN_System_Check_Role_Object (1, 'T_System_Role', 'update')
-- =============================================
CREATE FUNCTION [dbo].[UFN_System_Check_Role_Object]
(
	@UserId int,
	@ObjectName varchar(100),
	@Action varchar(20)
)
RETURNS bit
AS
BEGIN
	
	declare @result bit = 0, @count int = 0;
	set @ObjectName = replace(replace(replace(@ObjectName, 'dbo.', ''), '[', ''), ']', '');

	select @count = count(1) 
	from dbo.T_System_Role_Object_Mapping as ObjMap
	join dbo.V_System_Role_User_Mapping as Roles
	on ObjMap.Role =  Roles.RoleId or ObjMap.Role = 0
	where Roles.UserId = @UserId
	and (@Action = 'select' and ObjMap.CanSelect = 1
		or @Action = 'update' and ObjMap.CanUpdate = 1
		or @Action = 'delete' and ObjMap.CanDelete = 1)
	and ObjMap.IsActive = 1
	and ObjMap.ObjectName =  @ObjectName

	if(@count > 0)
		set @result = 1

	return @result;

END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_Get_Menu]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	join dbo.V_System_Role_User_Mapping as MappingUser
	on MappingMenu.RoleId = MappingUser.RoleId
	where MappingUser.UserId = @User and MappingMenu.IsActive = 1 

	return;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetDateTime]    Script Date: 5/3/2016 3:50:23 PM ******/
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

	if (LEN(@Value) = 0)
	begin
		set @Result = NULL;
	end
	else if(@Format = 'dd-MM-yyyy hh:mm:ss' or @Format = 'dd-MM-yyyy')
	begin
		set @Result = convert(datetime, @Value, 105);
	end

	RETURN @Result
END

GO
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetRule]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetTime]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[UFN_System_StandarlizeData]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  Table [dbo].[T_Master_Attibutes]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Attibutes](
	[AttributeId] [int] IDENTITY(1,1) NOT NULL,
	[AttributeName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_CostTypes]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_CostTypes](
	[CostTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CostTypeName] [nvarchar](200) NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_Customers]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_InventoryStatus]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_InventoryStatus](
	[StatusId] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) NULL,
	[DisplayClass] [varchar](20) NULL,
	[Description] [nvarchar](100) NULL,
	[IsFinish] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_InventoryStatus] PRIMARY KEY CLUSTERED 
(
	[StatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_InventTranStatus]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_InventTranStatus](
	[StatusId] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) NULL,
	[DisplayClass] [varchar](20) NULL,
	[Description] [nvarchar](100) NULL,
	[IsFinish] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_InventTranStatus] PRIMARY KEY CLUSTERED 
(
	[StatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Master_OrderStatus]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_PaymentType]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_PaymentType](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[PaymentName] [nvarchar](100) NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_PrintTemplates]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_PrintTemplates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [nvarchar](200) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_Producers]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Producers](
	[ProducerId] [int] IDENTITY(1,1) NOT NULL,
	[ProducerName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_ProductGroups]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_PurchaseStatus]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_Stores]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Master_Stores](
	[StoreId] [int] IDENTITY(1,1) NOT NULL,
	[StoreCode] [nvarchar](100) NOT NULL,
	[ProxyName] [nvarchar](100) NULL,
	[PhoneNumber] [varchar](50) NULL,
	[MobileNumber] [varchar](50) NULL,
	[Website] [nvarchar](500) NULL,
	[Address] [nvarchar](500) NULL,
	[Description] [nvarchar](1000) NULL,
	[TaxCode] [varchar](100) NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_Suppliers]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Master_User]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_System_Data_Log]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Data_Log](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[TableColumn] [varchar](100) NOT NULL,
	[KeyValue] [varchar](50) NOT NULL,
	[Version] [int] NULL,
	[Data] [nvarchar](1000) NULL,
	[ModifiedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_T_System_LogChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Exception_Log]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_Exception_Log](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [nvarchar](100) NULL,
	[ErrorMessage] [nvarchar](1000) NULL,
	[Data] [nvarchar](max) NULL,
	[Source] [nvarchar](100) NULL,
	[Hero] [int] NULL,
	[IsResolve] [bit] NULL,
	[Remarks] [nvarchar](500) NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Exception_Log] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_System_Log_Config]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Log_Config](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[Desciption] [nvarchar](200) NOT NULL,
	[IsLog] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Log_Config] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Menu]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_System_Object_Field_Filter]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Object_Field_Filter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [varchar](100) NOT NULL,
	[ColumName] [varchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Object_Field_Filter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Object_Freze_Condition]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Object_Freze_Condition](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[UpdatableCondition] [varchar](500) NOT NULL,
	[DeletableCondition] [varchar](500) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Object_Freze_Condition] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Role]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Role](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_System_Role_Menu_Mapping]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_Role_Menu_Mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MenuId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_System_Role_Object_Mapping]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Role_Object_Mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [varchar](100) NOT NULL,
	[Role] [int] NOT NULL,
	[CanSelect] [bit] NOT NULL,
	[CanUpdate] [bit] NOT NULL,
	[CanDelete] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Role_SP_Mapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Role_User_Mapping]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_System_Role_User_Mapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_System_Rule]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_System_Tmp]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Tmp](
	[TableName] [varchar](100) NOT NULL,
	[KeyValue] [varchar](50) NOT NULL,
	[Version] [int] NOT NULL,
	[ColumName] [varchar](100) NOT NULL,
	[Data] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_System_Triggers]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_System_Triggers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [varchar](100) NOT NULL,
	[SPName] [varchar](100) NOT NULL,
	[OrderExec] [int] NOT NULL,
	[OnInsert] [bit] NOT NULL,
	[OnUpdate] [bit] NOT NULL,
	[OnDelete] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_System_Triggers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Cost]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_Cost](
	[CostId] [int] IDENTITY(1,1) NOT NULL,
	[CostCode] [varchar](50) NULL,
	[CostName] [nvarchar](200) NOT NULL,
	[CostTypeId] [int] NOT NULL,
	[PaidDate] [date] NOT NULL,
	[Amount] [money] NOT NULL,
	[StoreId] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[IsActive] [bit] NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Cost] PRIMARY KEY CLUSTERED 
(
	[CostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Inventory]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_Inventory](
	[InventoryId] [int] IDENTITY(1,1) NOT NULL,
	[InventoryCode] [varchar](50) NULL,
	[StoreId] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[BalancerId] [int] NULL,
	[BalancedDate] [datetime] NULL,
	[NumProducts] [int] NULL,
	[StatusId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Inventory_Product]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Inventory_Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InventoryId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[RealQuantity] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_InventTran]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_InventTran](
	[InventTranId] [int] IDENTITY(1,1) NOT NULL,
	[InventTranCode] [varchar](50) NULL,
	[FromStoreId] [int] NOT NULL,
	[ToStoreId] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[TransferId] [int] NULL,
	[TransferedDate] [datetime] NULL,
	[NumProducts] [int] NULL,
	[StatusId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_InventTran] PRIMARY KEY CLUSTERED 
(
	[InventTranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_InventTran_Product]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_InventTran_Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InventTranId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[TranQuantity] [int] NOT NULL,
	[Notes] [nvarchar](500) NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_InventTran_Product] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_News]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_News](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[Type] [int] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Order_Product]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Order_Product](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Cost] [float] NOT NULL,
	[Price] [float] NOT NULL,
	[RealPrice] [float] NOT NULL,
	[Discount] [float] NOT NULL,
	[IsDiscountPercent] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Orders]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[OrginalMoney] [money] NOT NULL,
	[DebtMoney] [money] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Payment]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Payment](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[OrderId] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
	[PaymentType] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_MoneyIn] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_Product_Attribute]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Product_Attribute](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AttributeId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[Value] [nvarchar](200) NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Product_Store]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Product_Store](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[AllowNegative] [bit] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Product_Store] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_ProductPrice_History]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  Table [dbo].[T_Trans_ProductQuantity_History]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Trans_ProductQuantity_History](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
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
/****** Object:  Table [dbo].[T_Trans_Products]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Cost] [money] NOT NULL,
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
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[LastBoughtDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Products] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Trans_Purchase]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Purchase_Payment]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Purchase_Payment](
	[PaymentId] [int] IDENTITY(1,1) NOT NULL,
	[PurchaseId] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
	[PaymentType] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[IsActive] [bit] NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_Purchase_Payment] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_Purchase_Product]    Script Date: 5/3/2016 3:50:23 PM ******/
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
	[Version] [int] NULL,
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
/****** Object:  Table [dbo].[T_Trans_Receivement]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_Receivement](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Cashier] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
	[Amount] [money] NOT NULL,
	[Version] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [int] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_T_Trans_] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_Trans_User_Store]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Trans_User_Store](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[StoreId] [int] NOT NULL,
	[RoleId] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[Version] [int] NULL,
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
/****** Object:  UserDefinedFunction [dbo].[UFN_System_GetForienKey]    Script Date: 5/3/2016 3:50:23 PM ******/
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
/****** Object:  View [dbo].[V_System_Data_Log]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_System_Data_Log]
AS
SELECT        Results.[TableName], Results.[KeyValue], Results.[Version], Users.UserName, Results.[ModifiedDate], STUFF
                             ((SELECT        '<div class="col-pair"><div class="col-name">' + TableColumn + '</div><div class="col-value">' + Data + '</div></div>'
                                 FROM            [dbo].[T_System_Data_Log]
                                 WHERE        ([TableName] = Results.[TableName] AND [KeyValue] = Results.[KeyValue] AND [ModifiedBy] = Results.[ModifiedBy] AND [ModifiedDate] = Results.[ModifiedDate]) FOR XML PATH(''), 
                                                          TYPE ).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 0, '') AS Data
FROM            [dbo].[T_System_Data_Log] Results LEFT JOIN
                         dbo.T_Master_User AS Users ON Users.UserId = Results.ModifiedBy
GROUP BY Results.[TableName], Results.[KeyValue], Results.[Version], Results.[ModifiedBy], Results.[ModifiedDate], Users.UserName

GO
/****** Object:  View [dbo].[V_System_Role_User_Mapping]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_System_Role_User_Mapping]
AS
SELECT        UserId, RoleId
FROM            dbo.T_System_Role_User_Mapping
WHERE        (IsActive = 1)
union
select UserId, RoleId
from dbo.T_Trans_User_Store
where IsActive = 1

GO
/****** Object:  View [dbo].[V_System_User_Mapping_Filter]    Script Date: 5/3/2016 3:50:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_System_User_Mapping_Filter]
AS
SELECT DISTINCT ObjectDef.ObjectName, ObjectDef.ColumName, CONVERT(varchar(MAX), Mapping.StoreId) AS Value, Mapping.UserId, ObjMap.CanSelect, ObjMap.CanUpdate, ObjMap.CanDelete
FROM            dbo.T_System_Object_Field_Filter AS ObjectDef CROSS JOIN
                         dbo.T_Trans_User_Store AS Mapping INNER JOIN
                         dbo.T_System_Role_Object_Mapping AS ObjMap ON (Mapping.RoleId = ObjMap.Role OR
                         ObjMap.Role = 0) AND ObjectDef.ObjectName = ObjMap.ObjectName
WHERE        (ObjectDef.IsActive = 1) AND (Mapping.IsActive = 1)

GO
SET IDENTITY_INSERT [dbo].[T_Master_Attibutes] ON 

INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Size', 0, 1, 1, CAST(0x0000A5C9016496BD AS DateTime), 1, CAST(0x0000A5CA007C21AC AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Màu', 1, 1, 1, CAST(0x0000A5CA007C302B AS DateTime), 1, CAST(0x0000A5CE00A826A4 AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1002, N'Size', 1, 1, 1, CAST(0x0000A5CB007C722A AS DateTime), 1, CAST(0x0000A5FB00C2E6E2 AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1003, N'SIze', 0, 1, 1, CAST(0x0000A5CC015F4DA5 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1004, N'Sắc', 0, 1, 1, CAST(0x0000A5CE007C5174 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1005, N'Nguồn', 0, 1, 1, CAST(0x0000A5CF01667B38 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1006, N'AAA', 0, 1, 1, CAST(0x0000A5E6017811EF AS DateTime), 1, CAST(0x0000A5E8017A62DF AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1007, N'Trọng lượng', 0, 1, 1, CAST(0x0000A5F20183D6B6 AS DateTime), 1, CAST(0x0000A5F301548A4E AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1008, N'U1', 0, 1, 1, CAST(0x0000A5FB00C1521A AS DateTime), 1, CAST(0x0000A5FB00C20BED AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1009, N'U', 0, 1, 1, CAST(0x0000A5FB00C2B3C4 AS DateTime), 1, CAST(0x0000A5FB00C2CD06 AS DateTime))
INSERT [dbo].[T_Master_Attibutes] ([AttributeId], [AttributeName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1010, N'U1', 0, 1, 1, CAST(0x0000A5FB00C2D08D AS DateTime), 1, CAST(0x0000A5FB00C2DB1A AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Master_Attibutes] OFF
SET IDENTITY_INSERT [dbo].[T_Master_CostTypes] ON 

INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Tiền điện', NULL, 0, 1, 1, CAST(0x0000A5E200000000 AS DateTime), 1, CAST(0x0000A5E400C5168B AS DateTime))
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Tiền nước', NULL, 0, 1, 1, CAST(0x0000A5E200000000 AS DateTime), 1, CAST(0x0000A5E400C41350 AS DateTime))
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Thuê nhà', N'', 1, 1, 1, CAST(0x0000A5E400C5857E AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'Điện nước', N'Điện nước', 1, 1, 1, CAST(0x0000A5E400C59CBA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'Tiền internet', N'', 1, 1, 1, CAST(0x0000A5E400C5AA0B AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'Lương nhân viên', N'', 1, 1, 1, CAST(0x0000A5E400C5B617 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'Tiền ăn', N'', 1, 1, 1, CAST(0x0000A5E400C5C166 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'Tiền văn phòng phẩm', N'', 1, 1, 1, CAST(0x0000A5E400C5CF91 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'Phụ cấp', N'', 1, 1, 1, CAST(0x0000A5E400C5DB91 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'Chi phí quảng cáo', N'', 1, 1, 1, CAST(0x0000A5E400C5E658 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'Chi phí khác', N'Chi phí khác', 1, 1, 1, CAST(0x0000A5E400C5EE79 AS DateTime), 1, CAST(0x0000A5E400C5FF82 AS DateTime))
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1003, N'Internet', N'', 0, 1, 1, CAST(0x0000A5E800014322 AS DateTime), 1, CAST(0x0000A5E80001A460 AS DateTime))
INSERT [dbo].[T_Master_CostTypes] ([CostTypeId], [CostTypeName], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1004, N'Internet', N'', 0, 1, 1, CAST(0x0000A5E80001B5D3 AS DateTime), 1, CAST(0x0000A5E80001BCFB AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Master_CostTypes] OFF
SET IDENTITY_INSERT [dbo].[T_Master_Customers] ON 

INSERT [dbo].[T_Master_Customers] ([CustomerId], [CustomerCode], [CustomerName], [Phone], [Email], [Address], [Birthday], [Gender], [Notes], [IsWholeSale], [LastTimeVisited], [SumMoney], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'KHS000001', N'Google', N'', N'', N'', NULL, N'M', N'', 1, CAST(0x0000A5F9014258AA AS DateTime), 1590100.0000, 1590100.0000, 1, 1, 1, CAST(0x0000A5E101721A5F AS DateTime), 1, CAST(0x0000A5F30158E43C AS DateTime))
INSERT [dbo].[T_Master_Customers] ([CustomerId], [CustomerCode], [CustomerName], [Phone], [Email], [Address], [Birthday], [Gender], [Notes], [IsWholeSale], [LastTimeVisited], [SumMoney], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'KH000002', N'Trung Chanh', N'', N'', N'', NULL, N'M', N'', 0, CAST(0x0000A5F900B89DB6 AS DateTime), 1008500.0000, 898500.0000, 1, 2, 1, CAST(0x0000A5E10172290C AS DateTime), 1, CAST(0x0000A5FB00FA82EF AS DateTime))
INSERT [dbo].[T_Master_Customers] ([CustomerId], [CustomerCode], [CustomerName], [Phone], [Email], [Address], [Birthday], [Gender], [Notes], [IsWholeSale], [LastTimeVisited], [SumMoney], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'KHS000003', N'Vy', N'', N'', N'', NULL, N'M', N'', 1, NULL, NULL, NULL, 1, 1, 1, CAST(0x0000A5E60180DC36 AS DateTime), 1, CAST(0x0000A5F30158EF48 AS DateTime))
INSERT [dbo].[T_Master_Customers] ([CustomerId], [CustomerCode], [CustomerName], [Phone], [Email], [Address], [Birthday], [Gender], [Notes], [IsWholeSale], [LastTimeVisited], [SumMoney], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'KHS000004', N'XXX', N'', N'', N'', NULL, N'M', N'', 1, NULL, NULL, NULL, 1, 1, 1, CAST(0x0000A5E8017B6C43 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_Customers] OFF
SET IDENTITY_INSERT [dbo].[T_Master_InventoryStatus] ON 

INSERT [dbo].[T_Master_InventoryStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Đang kiểm kê', N'label label-warning', NULL, 0, 1, 1, CAST(0x0000A58F011C8BC0 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_InventoryStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Đã kiểm kê', N'label label-success', NULL, 1, 1, 1, CAST(0x0000A58F011DC5F1 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_InventoryStatus] OFF
SET IDENTITY_INSERT [dbo].[T_Master_InventTranStatus] ON 

INSERT [dbo].[T_Master_InventTranStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Lưu tạm', N'label label-warning', NULL, 0, 1, 1, CAST(0x0000A58F011C8BC0 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_InventTranStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Đã chuyển', N'label label-success', NULL, 1, 1, 1, CAST(0x0000A58F011DC5F1 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_InventTranStatus] OFF
SET IDENTITY_INSERT [dbo].[T_Master_OrderStatus] ON 

INSERT [dbo].[T_Master_OrderStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Lưu tạm', N'label label-warning', NULL, 0, 1, 1, CAST(0x0000A58F011C8BC0 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_OrderStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Hoàn thành', N'label label-success', NULL, 1, 1, 1, CAST(0x0000A58F011DC5F1 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_OrderStatus] OFF
SET IDENTITY_INSERT [dbo].[T_Master_PaymentType] ON 

INSERT [dbo].[T_Master_PaymentType] ([PaymentId], [PaymentName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Tiền mặt', 1, 1, CAST(0x0000A5D500000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_PaymentType] ([PaymentId], [PaymentName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'CK', 1, 1, CAST(0x0000A5D500000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_PaymentType] ([PaymentId], [PaymentName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Thẻ', 1, 1, CAST(0x0000A5D500000000 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_PaymentType] OFF
SET IDENTITY_INSERT [dbo].[T_Master_Producers] ON 

INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Khatao', 1, 1, 1, CAST(0x0000A5C500000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'John Henry', 1, 1, 1, CAST(0x0000A5C500000000 AS DateTime), 1, CAST(0x0000A5CC015260CD AS DateTime))
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Vy', 0, 1, 1, CAST(0x0000A5C9010A14E4 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1003, N'TKX', 1, 1, 1, CAST(0x0000A5C90137CBFA AS DateTime), 1, CAST(0x0000A5CC0157167E AS DateTime))
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1004, N'XK', 0, 1, 1, CAST(0x0000A5C90138FFA2 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1005, N'TT', 0, 1, 1, CAST(0x0000A5C901390775 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1006, N'TTXD', 1, 1, 1, CAST(0x0000A5E60166DB30 AS DateTime), 1, CAST(0x0000A5E60166F22A AS DateTime))
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1007, N'TTXD', 0, 1, 1, CAST(0x0000A5E60166E2F7 AS DateTime), 1, CAST(0x0000A5E60166EAA1 AS DateTime))
INSERT [dbo].[T_Master_Producers] ([ProducerId], [ProducerName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1008, N'TESTT', 0, 1, 1, CAST(0x0000A5ED0152FC2E AS DateTime), 1, CAST(0x0000A5F80167B8E0 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Master_Producers] OFF
SET IDENTITY_INSERT [dbo].[T_Master_ProductGroups] ON 

INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Áo thun', 0, 1012, 1, 1, 1, CAST(0x0000A5B300000000 AS DateTime), 1, CAST(0x0000A5CC0083A53A AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Giày', 0, 1012, 0, 1, 1, CAST(0x0000A5B300000000 AS DateTime), 1, CAST(0x0000A5CB007FD208 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Quần', 0, 1012, 1, 1, 1, CAST(0x0000A5B300000000 AS DateTime), 1, CAST(0x0000A5CB00803005 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'Mắt kính', 0, 1012, 1, 1, 1, CAST(0x0000A5B300000000 AS DateTime), 1, CAST(0x0000A5CB00800DA1 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'Điện thoại 2', 0, NULL, 0, 1, 1, CAST(0x0000A5C80187C7A5 AS DateTime), 1, CAST(0x0000A5C80188A78B AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'Chống nắng', 0, 1012, 0, 1, 1, CAST(0x0000A5C801886010 AS DateTime), 1, CAST(0x0000A5CB0178FCD7 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'Vật dụng', 0, 1012, 0, 1, 1, CAST(0x0000A5C8018880C7 AS DateTime), 1, CAST(0x0000A5CB0080392E AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'Váy', 0, 1012, 0, 1, 1, CAST(0x0000A5C80188C9A7 AS DateTime), 1, CAST(0x0000A5CB00804130 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'Đầm', 0, 1011, 0, 1, 1, CAST(0x0000A5C80188D536 AS DateTime), 1, CAST(0x0000A5CB01790F6C AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'Bộ Mỹ Phẩm', 0, NULL, 0, 1, 1, CAST(0x0000A5CB006D96F1 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1011, N'Mỹ phảm', 1, NULL, 0, 1, 1, CAST(0x0000A5CB0073AA19 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1012, N'Thời trang', 1, NULL, 1, 1, 1, CAST(0x0000A5CB007F9543 AS DateTime), 1, CAST(0x0000A5E6017474FE AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1013, N'My pham', 1, NULL, 0, 1, 1, CAST(0x0000A5CB017BBB47 AS DateTime), 1, CAST(0x0000A5CC0157CE85 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1014, N'My pham 3', 1, NULL, 0, 1, 1, CAST(0x0000A5CB017C64BA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1015, N'My pham 4', 1, NULL, 0, 1, 1, CAST(0x0000A5CB017CCDCF AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1016, N'Kem chong nang 2', 0, 1013, 0, 1, 1, CAST(0x0000A5CC008BE1B5 AS DateTime), 1, CAST(0x0000A5CD0150044C AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1017, N'AAA', 0, 1012, 0, 1, 1, CAST(0x0000A5CC008C6227 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1018, N'Ada', 0, 1012, 0, 1, 1, CAST(0x0000A5CC0158174C AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1019, N'qq', 0, 1013, 0, 1, 1, CAST(0x0000A5CE0078A8DB AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1020, N'Áo', 0, 1012, 1, 1, 1, CAST(0x0000A5DC011D84F9 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1021, N'TEST10', 0, 1012, 0, 1, 1, CAST(0x0000A5E601709B1E AS DateTime), 1, CAST(0x0000A5E80176A537 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1022, N'Test', 0, 1012, 0, 1, 1, CAST(0x0000A5E60170A750 AS DateTime), 1, CAST(0x0000A5E8016952D7 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1023, N'My pham', 1, NULL, 0, 1, 1, CAST(0x0000A5E60170C0DB AS DateTime), 1, CAST(0x0000A5E801464F09 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1024, N'AAA', 0, 1023, 0, 1, 1, CAST(0x0000A5E601749F19 AS DateTime), 1, CAST(0x0000A5E80166DD8F AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1025, N'Đồ gia dụng', 1, NULL, 0, 1, 1, CAST(0x0000A5E60174AE52 AS DateTime), 1, CAST(0x0000A5E601753721 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1026, N'dffdf', 1, NULL, 0, 1, 1, CAST(0x0000A5E60174C157 AS DateTime), 1, CAST(0x0000A5E60175CC89 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1027, N'TEST', 0, 1012, 0, 1, 1, CAST(0x0000A5E80177FF05 AS DateTime), 1, CAST(0x0000A5E801784B49 AS DateTime))
INSERT [dbo].[T_Master_ProductGroups] ([ProductGroupId], [GroupName], [IsParent], [ParentId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1028, N'Mỹ phẩm', 1, NULL, 0, 1, 1, CAST(0x0000A5E801781E27 AS DateTime), 1, CAST(0x0000A5E801783A5F AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Master_ProductGroups] OFF
SET IDENTITY_INSERT [dbo].[T_Master_PurchaseStatus] ON 

INSERT [dbo].[T_Master_PurchaseStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Lưu tạm', N'label label-warning', NULL, 0, 1, 1, CAST(0x0000A58F011C8BC0 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_PurchaseStatus] ([StatusId], [StatusName], [DisplayClass], [Description], [IsFinish], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Hoàn thành', N'label label-success', NULL, 1, 1, 1, CAST(0x0000A58F011DC5F1 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_PurchaseStatus] OFF
SET IDENTITY_INSERT [dbo].[T_Master_Stores] ON 

INSERT [dbo].[T_Master_Stores] ([StoreId], [StoreCode], [ProxyName], [PhoneNumber], [MobileNumber], [Website], [Address], [Description], [TaxCode], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'GILI-TQ', N'2', N'0963671267', N'0967371276', NULL, N'Tân Quới, Thanh Bình, Đồng Tháp', NULL, N'7566567672376', 1, 1, CAST(0x0000A58F011FDC30 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_Stores] ([StoreId], [StoreCode], [ProxyName], [PhoneNumber], [MobileNumber], [Website], [Address], [Description], [TaxCode], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'GILI-TB', N'3', N'0963671276', N'0967371242', NULL, N'Tân Bình, Thanh Bình, Đồng Tháp', NULL, N'7566567672376', 1, 1, CAST(0x0000A58F011FDC30 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_Stores] OFF
SET IDENTITY_INSERT [dbo].[T_Master_Suppliers] ON 

INSERT [dbo].[T_Master_Suppliers] ([SupplierId], [SupplierCode], [SupplierName], [Phone], [Email], [Address], [TaxCode], [Notes], [LastTimeProvided], [SumMoney], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'NCC000001', N'Đại ly TT', N'', N'', N'', N'', N'', CAST(0x0000A5E50172AA5A AS DateTime), 0.0000, 450000.0000, 1, 2, 1, CAST(0x0000A5E101720EAF AS DateTime), 1, CAST(0x0000A5FB00FA8D06 AS DateTime))
INSERT [dbo].[T_Master_Suppliers] ([SupplierId], [SupplierCode], [SupplierName], [Phone], [Email], [Address], [TaxCode], [Notes], [LastTimeProvided], [SumMoney], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'NCC000002', N'AAS', N'', N'', N'', N'', N'', NULL, NULL, NULL, 1, 1, 1, CAST(0x0000A5E7017D9E73 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_Suppliers] OFF
SET IDENTITY_INSERT [dbo].[T_Master_User] ON 

INSERT [dbo].[T_Master_User] ([UserId], [LoginId], [Password], [UserName], [Email], [Phone], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'admin', N'123456', N'SystemAdmin', N'admin@store.management.vn', N'0933144211', 1, 1, 1, CAST(0x0000A58F011F06E8 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_User] ([UserId], [LoginId], [Password], [UserName], [Email], [Phone], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'UIT', N'123456', N'Thành Phong', N'giang@store.management.vn', N'0933144211', 1, 1, 1, CAST(0x0000A58F011F06E8 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Master_User] ([UserId], [LoginId], [Password], [UserName], [Email], [Phone], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'UTY', N'123456', N'Hậu Nghĩa', N'giang@store.management.vn', N'0933144211', 1, 1, 1, CAST(0x0000A58F011F06E8 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Master_User] OFF
SET IDENTITY_INSERT [dbo].[T_System_Data_Log] ON 

INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (1, N'T_Trans_Orders', N'OrderCode', N'4021', 1, N'PX004021', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (2, N'T_Trans_Orders', N'StoreId', N'4021', 1, N'1', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (3, N'T_Trans_Orders', N'SoldDate', N'4021', 1, NULL, 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (4, N'T_Trans_Orders', N'Cashier', N'4021', 1, N'1', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (5, N'T_Trans_Orders', N'Customer', N'4021', 1, NULL, 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (6, N'T_Trans_Orders', N'Notes', N'4021', 1, N'', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (7, N'T_Trans_Orders', N'PaymentType', N'4021', 1, N'1', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (8, N'T_Trans_Orders', N'OrderStatus', N'4021', 1, N'1', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (9, N'T_Trans_Orders', N'Discount', N'4021', 1, N'0', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (10, N'T_Trans_Orders', N'IsDiscountPercent', N'4021', 1, N'1', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (11, N'T_Trans_Orders', N'SumMoney', N'4021', 1, N'220000', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (12, N'T_Trans_Orders', N'Paid', N'4021', 1, N'0', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (13, N'T_Trans_Orders', N'OrginalMoney', N'4021', 1, N'110000', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (14, N'T_Trans_Orders', N'DebtMoney', N'4021', 1, N'220000', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (15, N'T_Trans_Orders', N'IsActive', N'4021', 1, N'1', 1, CAST(0x0000A5FA01716838 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (16, N'T_Trans_Order_Product', N'OrderId', N'4025', 1, N'4021', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (17, N'T_Trans_Order_Product', N'ProductId', N'4025', 1, N'1', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (18, N'T_Trans_Order_Product', N'Quantity', N'4025', 1, N'2', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (19, N'T_Trans_Order_Product', N'Price', N'4025', 1, N'110000', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (20, N'T_Trans_Order_Product', N'RealPrice', N'4025', 1, N'220000', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (21, N'T_Trans_Order_Product', N'Discount', N'4025', 1, N'0', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (22, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4025', 1, N'1', 1, CAST(0x0000A5FA0171689A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (23, N'T_Trans_Orders', N'OrderCode', N'4021', 1, N'PX004021', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (24, N'T_Trans_Orders', N'StoreId', N'4021', 1, N'1', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (25, N'T_Trans_Orders', N'SoldDate', N'4021', 1, NULL, 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (26, N'T_Trans_Orders', N'Cashier', N'4021', 1, N'1', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (27, N'T_Trans_Orders', N'Customer', N'4021', 1, NULL, 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (28, N'T_Trans_Orders', N'Notes', N'4021', 1, N'', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (29, N'T_Trans_Orders', N'PaymentType', N'4021', 1, N'1', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (30, N'T_Trans_Orders', N'OrderStatus', N'4021', 1, N'2', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (31, N'T_Trans_Orders', N'Discount', N'4021', 1, N'0', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (32, N'T_Trans_Orders', N'IsDiscountPercent', N'4021', 1, N'1', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (33, N'T_Trans_Orders', N'SumMoney', N'4021', 1, N'110000', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (34, N'T_Trans_Orders', N'Paid', N'4021', 1, N'0', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (35, N'T_Trans_Orders', N'OrginalMoney', N'4021', 1, N'220000', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (36, N'T_Trans_Orders', N'DebtMoney', N'4021', 1, N'110000', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (37, N'T_Trans_Orders', N'IsActive', N'4021', 1, N'1', 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (38, N'T_Trans_Order_Product', N'OrderId', N'4025', 1, N'4021', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (39, N'T_Trans_Order_Product', N'ProductId', N'4025', 1, N'1', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (40, N'T_Trans_Order_Product', N'Quantity', N'4025', 1, N'1', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (41, N'T_Trans_Order_Product', N'Price', N'4025', 1, N'110000', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (42, N'T_Trans_Order_Product', N'RealPrice', N'4025', 1, N'110000', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (43, N'T_Trans_Order_Product', N'Discount', N'4025', 1, N'0', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (44, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4025', 1, N'1', 1, CAST(0x0000A5FA017DECEC AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (45, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (46, N'T_Trans_Products', N'ProductCode', N'6', 1, N'HH000006', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (47, N'T_Trans_Products', N'Quantity', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (48, N'T_Trans_Products', N'Price', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (49, N'T_Trans_Products', N'Cost', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (50, N'T_Trans_Products', N'ProductGroup', N'6', 1, NULL, 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (51, N'T_Trans_Products', N'ProducerId', N'6', 1, NULL, 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (52, N'T_Trans_Products', N'TrackInventory', N'6', 1, N'1', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (53, N'T_Trans_Products', N'AllowNegative', N'6', 1, N'1', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (54, N'T_Trans_Products', N'VAT', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (55, N'T_Trans_Products', N'AllowMin', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (56, N'T_Trans_Products', N'AllowMax', N'6', 1, N'100', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (57, N'T_Trans_Products', N'IsManageAsSerial', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (58, N'T_Trans_Products', N'IsManageAttribute', N'6', 1, N'0', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (59, N'T_Trans_Products', N'Description', N'6', 1, N'', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (60, N'T_Trans_Products', N'IsSelling', N'6', 1, N'1', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (61, N'T_Trans_Products', N'IsActive', N'6', 1, N'1', 1, CAST(0x0000A5FB00A6FAC6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (62, N'T_Trans_Products', N'IsActive', N'4', 1, N'0', 1, CAST(0x0000A5FB00A74681 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (63, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean3', 1, CAST(0x0000A5FB00E2A4CA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (64, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean', 1, CAST(0x0000A5FB00E2FF4A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (65, N'T_Trans_Products', N'Description', N'6', 1, N'Thesr', 1, CAST(0x0000A5FB00E2FF4A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (66, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean', 1, CAST(0x0000A5FB00E2FF4A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (67, N'T_Trans_Products', N'Description', N'6', 1, N'Thesr', 1, CAST(0x0000A5FB00E2FF4A AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (68, N'T_Trans_Orders', N'OrderCode', N'4022', 1, N'', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (69, N'T_Trans_Orders', N'StoreId', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (70, N'T_Trans_Orders', N'SoldDate', N'4022', 1, NULL, 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (71, N'T_Trans_Orders', N'Cashier', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (72, N'T_Trans_Orders', N'Customer', N'4022', 1, NULL, 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (73, N'T_Trans_Orders', N'Notes', N'4022', 1, N'', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (74, N'T_Trans_Orders', N'PaymentType', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (75, N'T_Trans_Orders', N'OrderStatus', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (76, N'T_Trans_Orders', N'Discount', N'4022', 1, N'0', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (77, N'T_Trans_Orders', N'IsDiscountPercent', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (78, N'T_Trans_Orders', N'SumMoney', N'4022', 1, N'250000', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (79, N'T_Trans_Orders', N'Paid', N'4022', 1, N'0', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (80, N'T_Trans_Orders', N'OrginalMoney', N'4022', 1, N'0', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (81, N'T_Trans_Orders', N'DebtMoney', N'4022', 1, N'250000', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (82, N'T_Trans_Orders', N'IsActive', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E33826 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (83, N'T_Trans_Order_Product', N'OrderId', N'4026', 1, N'4022', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (84, N'T_Trans_Order_Product', N'ProductId', N'4026', 1, N'2', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (85, N'T_Trans_Order_Product', N'Quantity', N'4026', 1, N'1', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (86, N'T_Trans_Order_Product', N'Cost', N'4026', 1, N'200000', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (87, N'T_Trans_Order_Product', N'Price', N'4026', 1, N'250000', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (88, N'T_Trans_Order_Product', N'RealPrice', N'4026', 1, N'250000', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (89, N'T_Trans_Order_Product', N'Discount', N'4026', 1, N'0', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (90, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4026', 1, N'1', 1, CAST(0x0000A5FB00E33843 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (91, N'T_Trans_Orders', N'OrderCode', N'4022', 1, N'PX004022', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (92, N'T_Trans_Orders', N'StoreId', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (93, N'T_Trans_Orders', N'Cashier', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (94, N'T_Trans_Orders', N'Notes', N'4022', 1, N'', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (95, N'T_Trans_Orders', N'PaymentType', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (96, N'T_Trans_Orders', N'OrderStatus', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (97, N'T_Trans_Orders', N'Discount', N'4022', 1, N'0', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (98, N'T_Trans_Orders', N'IsDiscountPercent', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (99, N'T_Trans_Orders', N'NumOfProduct', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
GO
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (100, N'T_Trans_Orders', N'SumMoney', N'4022', 1, N'250000.00', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (101, N'T_Trans_Orders', N'Paid', N'4022', 1, N'0.00', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (102, N'T_Trans_Orders', N'OrginalMoney', N'4022', 1, N'250000.00', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (103, N'T_Trans_Orders', N'DebtMoney', N'4022', 1, N'250000.00', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (104, N'T_Trans_Orders', N'IsActive', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (105, N'T_Trans_Orders', N'Customer', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E60ECA AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (106, N'T_Trans_Order_Product', N'OrderId', N'4026', 1, N'4022', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (107, N'T_Trans_Order_Product', N'ProductId', N'4026', 1, N'2', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (108, N'T_Trans_Order_Product', N'Quantity', N'4026', 1, N'1', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (109, N'T_Trans_Order_Product', N'Cost', N'4026', 1, N'200000', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (110, N'T_Trans_Order_Product', N'Price', N'4026', 1, N'250000', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (111, N'T_Trans_Order_Product', N'RealPrice', N'4026', 1, N'250000', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (112, N'T_Trans_Order_Product', N'Discount', N'4026', 1, N'0', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (113, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4026', 1, N'1', 1, CAST(0x0000A5FB00E60EE6 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (114, N'T_Trans_Orders', N'OrderCode', N'4022', 1, N'PXS004022', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (115, N'T_Trans_Orders', N'StoreId', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (116, N'T_Trans_Orders', N'Cashier', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (117, N'T_Trans_Orders', N'Customer', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (118, N'T_Trans_Orders', N'Notes', N'4022', 1, N'', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (119, N'T_Trans_Orders', N'PaymentType', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (120, N'T_Trans_Orders', N'OrderStatus', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (121, N'T_Trans_Orders', N'Discount', N'4022', 1, N'0', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (122, N'T_Trans_Orders', N'IsDiscountPercent', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (123, N'T_Trans_Orders', N'NumOfProduct', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (124, N'T_Trans_Orders', N'SumMoney', N'4022', 1, N'250000.00', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (125, N'T_Trans_Orders', N'Paid', N'4022', 1, N'0.00', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (126, N'T_Trans_Orders', N'OrginalMoney', N'4022', 1, N'250000.00', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (127, N'T_Trans_Orders', N'DebtMoney', N'4022', 1, N'250000.00', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (128, N'T_Trans_Orders', N'IsActive', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (129, N'T_Trans_Orders', N'Cashier', N'4022', 1, N'3', 1, CAST(0x0000A5FB00E67B82 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (130, N'T_Trans_Order_Product', N'OrderId', N'4026', 1, N'4022', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (131, N'T_Trans_Order_Product', N'ProductId', N'4026', 1, N'2', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (132, N'T_Trans_Order_Product', N'Quantity', N'4026', 1, N'1', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (133, N'T_Trans_Order_Product', N'Cost', N'4026', 1, N'200000', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (134, N'T_Trans_Order_Product', N'Price', N'4026', 1, N'250000', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (135, N'T_Trans_Order_Product', N'RealPrice', N'4026', 1, N'250000', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (136, N'T_Trans_Order_Product', N'Discount', N'4026', 1, N'0', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (137, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4026', 1, N'1', 1, CAST(0x0000A5FB00E67BA9 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (138, N'T_Trans_Orders', N'Customer', N'4022', 1, N'2', 1, CAST(0x0000A5FB00E8352F AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (139, N'T_Trans_Orders', N'Customer', N'4022', 1, N'1', 1, CAST(0x0000A5FB00E8621C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (140, N'T_Trans_Orders', N'PaymentType', N'4022', 1, N'2', 1, CAST(0x0000A5FB00E8621C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (141, N'T_Trans_Orders', N'SumMoney', N'4022', 1, N'225000.00', 1, CAST(0x0000A5FB00E8621C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (142, N'T_Trans_Orders', N'Paid', N'4022', 1, N'225000.00', 1, CAST(0x0000A5FB00E8621C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (143, N'T_Trans_Orders', N'DebtMoney', N'4022', 1, N'0.00', 1, CAST(0x0000A5FB00E8621C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (144, N'T_Trans_Order_Product', N'RealPrice', N'4026', 1, N'225000', 1, CAST(0x0000A5FB00E86236 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (145, N'T_Trans_Order_Product', N'Discount', N'4026', 1, N'10', 1, CAST(0x0000A5FB00E86236 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (146, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean1', 1, CAST(0x0000A5FB00ED2276 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (147, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean', 1, CAST(0x0000A5FB00ED338D AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (148, N'T_Trans_Orders', N'SumMoney', N'4023', 1, N'500000.00', 1, CAST(0x0000A5FB00ED5E55 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (149, N'T_Trans_Orders', N'DebtMoney', N'4023', 1, N'500000.00', 1, CAST(0x0000A5FB00ED5E55 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (150, N'T_Trans_Order_Product', N'Quantity', N'4027', 1, N'2', 1, CAST(0x0000A5FB00ED5E62 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (151, N'T_Trans_Order_Product', N'RealPrice', N'4027', 1, N'500000', 1, CAST(0x0000A5FB00ED5E62 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (152, N'T_Trans_Orders', N'OrderCode', N'4024', 1, N'', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (153, N'T_Trans_Orders', N'StoreId', N'4024', 1, N'1', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (154, N'T_Trans_Orders', N'Cashier', N'4024', 1, N'1', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (155, N'T_Trans_Orders', N'Notes', N'4024', 1, N'', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (156, N'T_Trans_Orders', N'PaymentType', N'4024', 1, N'1', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (157, N'T_Trans_Orders', N'OrderStatus', N'4024', 1, N'1', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (158, N'T_Trans_Orders', N'Discount', N'4024', 1, N'0', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (159, N'T_Trans_Orders', N'IsDiscountPercent', N'4024', 1, N'1', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (160, N'T_Trans_Orders', N'SumMoney', N'4024', 1, N'250000.00', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (161, N'T_Trans_Orders', N'Paid', N'4024', 1, N'0.00', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (162, N'T_Trans_Orders', N'OrginalMoney', N'4024', 1, N'250000.00', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (163, N'T_Trans_Orders', N'DebtMoney', N'4024', 1, N'250000.00', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (164, N'T_Trans_Orders', N'IsActive', N'4024', 1, N'1', 1, CAST(0x0000A5FB00ED9CE5 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (165, N'T_Trans_Order_Product', N'OrderId', N'4028', 1, N'4024', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (166, N'T_Trans_Order_Product', N'ProductId', N'4028', 1, N'2', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (167, N'T_Trans_Order_Product', N'Quantity', N'4028', 1, N'1', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (168, N'T_Trans_Order_Product', N'Cost', N'4028', 1, N'200000', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (169, N'T_Trans_Order_Product', N'Price', N'4028', 1, N'250000', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (170, N'T_Trans_Order_Product', N'RealPrice', N'4028', 1, N'250000', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (171, N'T_Trans_Order_Product', N'Discount', N'4028', 1, N'0', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (172, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4028', 1, N'1', 1, CAST(0x0000A5FB00ED9CFF AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (173, N'T_Trans_Orders', N'OrderCode', N'4025', 1, N'', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (174, N'T_Trans_Orders', N'StoreId', N'4025', 1, N'1', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (175, N'T_Trans_Orders', N'Cashier', N'4025', 1, N'1', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (176, N'T_Trans_Orders', N'Notes', N'4025', 1, N'', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (177, N'T_Trans_Orders', N'PaymentType', N'4025', 1, N'1', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (178, N'T_Trans_Orders', N'OrderStatus', N'4025', 1, N'1', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (179, N'T_Trans_Orders', N'Discount', N'4025', 1, N'0', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (180, N'T_Trans_Orders', N'IsDiscountPercent', N'4025', 1, N'1', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (181, N'T_Trans_Orders', N'SumMoney', N'4025', 1, N'250000.00', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (182, N'T_Trans_Orders', N'Paid', N'4025', 1, N'0.00', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (183, N'T_Trans_Orders', N'OrginalMoney', N'4025', 1, N'0.00', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (184, N'T_Trans_Orders', N'DebtMoney', N'4025', 1, N'250000.00', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (185, N'T_Trans_Orders', N'IsActive', N'4025', 1, N'1', 1, CAST(0x0000A5FB00F7660B AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (186, N'T_Trans_Order_Product', N'OrderId', N'4029', 1, N'4025', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (187, N'T_Trans_Order_Product', N'ProductId', N'4029', 1, N'2', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (188, N'T_Trans_Order_Product', N'Quantity', N'4029', 1, N'1', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (189, N'T_Trans_Order_Product', N'Cost', N'4029', 1, N'200000', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (190, N'T_Trans_Order_Product', N'Price', N'4029', 1, N'250000', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (191, N'T_Trans_Order_Product', N'RealPrice', N'4029', 1, N'250000', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (192, N'T_Trans_Order_Product', N'Discount', N'4029', 1, N'0', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (193, N'T_Trans_Order_Product', N'IsDiscountPercent', N'4029', 1, N'1', 1, CAST(0x0000A5FB00F7665C AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (194, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean''', 1, CAST(0x0000A5FB00FFA6D8 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (195, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean''''', 1, CAST(0x0000A5FB00FFC493 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (196, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean''', 1, CAST(0x0000A5FB01004073 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (197, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean', 1, CAST(0x0000A5FB0100464D AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (198, N'T_Trans_Products', N'ProductName', N'6', 1, N'Áo jean''', 1, CAST(0x0000A5FB0102C0A4 AS DateTime))
INSERT [dbo].[T_System_Data_Log] ([Id], [TableName], [TableColumn], [KeyValue], [Version], [Data], [ModifiedBy], [ModifiedDate]) VALUES (199, N'T_Trans_Orders', N'SoldDate', N'4023', 10, N'May 25 2016 12:00PM', 1, CAST(0x0000A5FB0104C5EB AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[T_System_Data_Log] OFF
SET IDENTITY_INSERT [dbo].[T_System_Exception_Log] ON 

INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'T_Trans_Orders', N'TEst', N'OrderId:4021,OrderCode:PX004021,StoreId:1,Customer:,CustomerName:,CustomerIsWholeSale:,SoldDate:,Cashier:1,CashierName:SystemAdmin,Notes:,OrderStatus:2,PaymentType:1,Price:110000,SumMoney:110000,Discount:0,DiscountAmmount:0,TotalDiscount:0,DebtMoney:110000,OrginalMoney:110000,Paid:0,IsDiscountPercent:1,IsActive:1,PaidForDebt:0,IsEditingPaidForDebt:false,_CanUpdate:true,_CanDelete:true', N'USP_System_Data_Update', 1, 1, N'Bug giả', 1, 1, CAST(0x0000A5FA00AE0A8E AS DateTime), 1, CAST(0x0000A5FA00C4B24E AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'TEST', N'Không xác d?nh', N'{}', N'', NULL, NULL, NULL, 1, 1, CAST(0x0000A5FA00C975D8 AS DateTime), 1, CAST(0x0000A5FA00C975D8 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Tạo bug', N'Không xác định', N'{}', N'ok', 1, 1, N'Đã fix', 1, 1, CAST(0x0000A5FA00CA8DD2 AS DateTime), 1, CAST(0x0000A5FA00CB016C AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'Tạo bug', N'Không reload', N'{}', N'o', 1, 1, N'Đã fix', 1, 1, CAST(0x0000A5FA00CADD06 AS DateTime), 1, CAST(0x0000A5FA00CAF90D AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'T_Trans_Orders', N'Cannot insert the value NULL into column ''Data'', table ''StoreManagement.dbo.T_System_Data_Log''; column does not allow nulls. INSERT fails.', N'OrderId::4021,,OrderCode::PX004021,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::360000,,SumMoney::360000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::360000,,OrginalMoney::110000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 1, 1, CAST(0x0000A5FA0170DC7B AS DateTime), 1, CAST(0x0000A5FA017DA5C7 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'T_System_Exception_Log', N'Incorrect syntax near ''Data''.', N'_CanUpdate::true,,_CanDelete::false,,ObjectName::T_Trans_Orders,,ErrorMessage::Cannot insert the value NULL into column ''Data'', table ''StoreManagement.dbo.T_System_Data_Log''; column does not allow nulls. INSERT fails.,,Data::OrderId:4021,OrderCode:PX004021,StoreId:1,Customer:,CustomerName:,CustomerIsWholeSale:,SoldDate:,Cashier:1,CashierName:SystemAdmin,Notes:,OrderStatus:1,PaymentType:1,Price:360000,SumMoney:360000,Discount:0,DiscountAmmount:0,TotalDiscount:0,DebtMoney:360000,OrginalMoney:110000,Paid:0,IsDiscountPercent:1,IsActive:1,PaidForDebt:0,IsEditingPaidForDebt:false,_CanUpdate:true,_CanDelete:true,,Source::USP_System_Data_Update,,Logger::SystemAdmin,,Hero::1,,Remarks::Fixed,,Id::5,,RowNum::1,,$$hashKey::object:56,,IsResolve::1', N'USP_System_Data_Update', 1, 1, N'Fix', 1, 1, CAST(0x0000A5FA017ACE24 AS DateTime), 1, CAST(0x0000A5FA017D97B0 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'T_System_Exception_Log', N'Incorrect syntax near ''Data''.', N'_CanUpdate::true,,_CanDelete::false,,ObjectName::T_Trans_Orders,,ErrorMessage::Cannot insert the value NULL into column ''Data'', table ''StoreManagement.dbo.T_System_Data_Log''; column does not allow nulls. INSERT fails.,,Data::OrderId:4021,OrderCode:PX004021,StoreId:1,Customer:,CustomerName:,CustomerIsWholeSale:,SoldDate:,Cashier:1,CashierName:SystemAdmin,Notes:,OrderStatus:1,PaymentType:1,Price:360000,SumMoney:360000,Discount:0,DiscountAmmount:0,TotalDiscount:0,DebtMoney:360000,OrginalMoney:110000,Paid:0,IsDiscountPercent:1,IsActive:1,PaidForDebt:0,IsEditingPaidForDebt:false,_CanUpdate:true,_CanDelete:true,,Source::USP_System_Data_Update,,Logger::SystemAdmin,,Hero::1,,Remarks::Fixed,,Id::5,,RowNum::1,,$$hashKey::object:56,,IsResolve::1', N'USP_System_Data_Update', 1, 1, N'Fix', 1, 1, CAST(0x0000A5FA017AD398 AS DateTime), 1, CAST(0x0000A5FA017D9370 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'T_System_Exception_Log', N'Incorrect syntax near ''T_System_Exception_Log''.', N'_CanUpdate::true,,_CanDelete::false,,ObjectName::T_System_Exception_Log,,ErrorMessage::Incorrect syntax near ''Data''.,,Data::_CanUpdate:true,_CanDelete:false,ObjectName:T_Trans_Orders,ErrorMessage:Cannot insert the value NULL into column ''Data'', table ''StoreManagement.dbo.T_System_Data_Log''; column does not allow nulls. INSERT fails.,Data:OrderId:4021,OrderCode:PX004021,StoreId:1,Customer:,CustomerName:,CustomerIsWholeSale:,SoldDate:,Cashier:1,CashierName:SystemAdmin,Notes:,OrderStatus:1,PaymentType:1,Price:360000,SumMoney:360000,Discount:0,DiscountAmmount:0,TotalDiscount:0,DebtMoney:360000,OrginalMoney:110000,Paid:0,IsDiscountPercent:1,IsActive:1,PaidForDebt:0,IsEditingPaidForDebt:false,_CanUpdate:true,_CanDelete:true,Source:USP_System_Data_Update,Logger:SystemAdmin,Hero:1,Remarks:Fixed,Id:5,RowNum:1,$$hashKey:object:56,IsResolve:1,,Source::USP_System_Data_Update,,Logger::SystemAdmin,,Hero::1,,Remarks::fix,,Id::7,,RowNum::1,,$$hashKey::object:40,,IsResolve::1', N'USP_System_Data_Update', 1, 1, N'Fix', 1, 1, CAST(0x0000A5FA017B61C8 AS DateTime), 1, CAST(0x0000A5FA017D8EB3 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'T_System_Exception_Log', N'Incorrect syntax near ''T_Trans_Orders''.', N'_CanUpdate::true,,_CanDelete::false,,ObjectName::T_Trans_Orders,,ErrorMessage::Cannot insert the value NULL into column ''Data'', table ''StoreManagement.dbo.T_System_Data_Log''; column does not allow nulls. INSERT fails.,,Data::OrderId:4021,OrderCode:PX004021,StoreId:1,Customer:,CustomerName:,CustomerIsWholeSale:,SoldDate:,Cashier:1,CashierName:SystemAdmin,Notes:,OrderStatus:1,PaymentType:1,Price:360000,SumMoney:360000,Discount:0,DiscountAmmount:0,TotalDiscount:0,DebtMoney:360000,OrginalMoney:110000,Paid:0,IsDiscountPercent:1,IsActive:1,PaidForDebt:0,IsEditingPaidForDebt:false,_CanUpdate:true,_CanDelete:true,,Source::USP_System_Data_Update,,Logger::SystemAdmin,,Hero::1,,Remarks::Fix,,Id::5,,RowNum::4,,$$hashKey::object:42,,IsResolve::1', N'USP_System_Data_Update', 1, 1, N'Fix', 1, 1, CAST(0x0000A5FA017B7E30 AS DateTime), 1, CAST(0x0000A5FA017D8A01 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'T_System_Exception_Log', N'Incorrect syntax near ''1''.', N'Id::9,,IsResolve::1,,Hero::1,,Remarks::fix', N'USP_System_Data_Update', 1, 1, N'Fix', 1, 1, CAST(0x0000A5FA017D4F41 AS DateTime), 1, CAST(0x0000A5FA017D84D6 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'T_System_Exception_Log', N'Incorrect syntax near ''SQL''.', N'Id::-1,,ObjectName::SQL,,ErrorMessage::If statement contain '',,Data::'',,Source::,,IsResolve::0', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FA017E75B3 AS DateTime), 1, CAST(0x0000A5FB0102E557 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, N'T_System_Exception_Log', N'Incorrect syntax near ''SQL''.', N'Id::-1,,ObjectName::SQL,,ErrorMessage::If statement contain single quote,,Data::quote,,Source::,,IsResolve::0', N'USP_System_Data_Update', 1, 1, N'Fix - duplicated', 1, 1, CAST(0x0000A5FA017E9ACF AS DateTime), 1, CAST(0x0000A5FA017EC87E AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (13, N'T_System_Exception_Log', N'Incorrect syntax near ''SQL''.', N'Id::-1,,ObjectName::SQL,,ErrorMessage::If statement contain single quote,,Data::quote,,Source::,,IsResolve::0', N'USP_System_Data_Update', 1, 1, N'Fix - duplicated', 1, 1, CAST(0x0000A5FA017EA3B1 AS DateTime), 1, CAST(0x0000A5FA017EC534 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (14, N'T_Master_Attibutes', N'Incorrect syntax near ''U''.', N'AttributeId::-1,,AttributeName::U,,IsActive::1', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00C06B33 AS DateTime), 1, CAST(0x0000A5FB00ECED25 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (15, N'T_Master_Attibutes', N'Incorrect syntax near ''U''.', N'AttributeId::-1,,AttributeName::U,,IsActive::1', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00C072A2 AS DateTime), 1, CAST(0x0000A5FB00ECE804 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (16, N'T_Master_Attibutes', N'Incorrect syntax near ''U''.', N'AttributeId::-1,,AttributeName::U,,IsActive::1', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00C0D64A AS DateTime), 1, CAST(0x0000A5FB00ECE374 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (17, N'T_Master_Attibutes', N'Incorrect syntax near ''U1''.', N'AttributeId::-1,,AttributeName::U1,,IsActive::1', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00C213C2 AS DateTime), 1, CAST(0x0000A5FB00ECDED9 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (18, N'T_Master_Attibutes', N'Incorrect syntax near ''U''.', N'AttributeId::-1,,AttributeName::U,,IsActive::1', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00C22E9C AS DateTime), 1, CAST(0x0000A5FB00ECDA45 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (19, N'T_System_Exception_Log', N'The column name "Data" specified in the UNPIVOT operator conflicts with the existing column name in the UNPIVOT argument.', N'Id::18,,IsResolve::1,,Hero::1,,Remarks::Fix', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00E95888 AS DateTime), 1, CAST(0x0000A5FB00ECD4F6 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (20, N'T_System_Exception_Log', N'Cannot insert the value NULL into column ''Version'', table ''StoreManagement.dbo.T_System_Tmp''; column does not allow nulls. INSERT fails.', N'Id::19,,IsResolve::1,,Hero::1,,Remarks::fix', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00EAE3CB AS DateTime), 1, CAST(0x0000A5FB00ECCF11 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (21, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F1D71B AS DateTime), 1, CAST(0x0000A5FB00FD387F AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (22, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F1DE38 AS DateTime), 1, CAST(0x0000A5FB00FD328A AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (23, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F1F057 AS DateTime), 1, CAST(0x0000A5FB00FD2F84 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (24, N'T_System_Exception_Log', N'Cannot insert the value NULL into column ''Version'', table ''StoreManagement.dbo.T_System_Tmp''; column does not allow nulls. INSERT fails.', N'Id::23,,IsResolve::1,,Hero::1,,Remarks::Fix', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F21707 AS DateTime), 1, CAST(0x0000A5FB00FD2C80 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (25, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F3E7E6 AS DateTime), 1, CAST(0x0000A5FB00FD2935 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (26, N'T_Trans_Orders', N'Incorrect syntax near the keyword ''SELECT''.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Version::3,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F49339 AS DateTime), 1, CAST(0x0000A5FB00FD2647 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (27, N'T_Trans_Orders', N'Incorrect syntax near the keyword ''SELECT''.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Version::3,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F49D0B AS DateTime), 1, CAST(0x0000A5FB00FD2382 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (28, N'T_Trans_Orders', N'Incorrect syntax near the keyword ''SELECT''.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Version::4,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F5A931 AS DateTime), 1, CAST(0x0000A5FB00FD1FB7 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (29, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F62D2D AS DateTime), 1, CAST(0x0000A5FB00FD1C91 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (30, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F6358F AS DateTime), 1, CAST(0x0000A5FB00FD1980 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (31, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F695F2 AS DateTime), 1, CAST(0x0000A5FB00FD15A8 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (32, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Version::5,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F6FF58 AS DateTime), 1, CAST(0x0000A5FB00FD119C AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (33, N'T_Trans_Orders', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OrderId::4023,,OrderCode::PX004023,,StoreId::1,,Customer::,,CustomerName::,,CustomerIsWholeSale::,,SoldDate::,,Cashier::1,,CashierName::SystemAdmin,,Notes::,,OrderStatus::1,,PaymentType::1,,Price::500000,,SumMoney::500000,,Discount::0,,DiscountAmmount::0,,TotalDiscount::0,,DebtMoney::500000,,OrginalMoney::500000,,Paid::0,,IsDiscountPercent::1,,IsActive::1,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Version::8,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F72741 AS DateTime), 1, CAST(0x0000A5FB00FD0E5E AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (34, N'T_Trans_Products', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OldProductId::-1,,ProductId::6,,ProductCode::HH000006,,ProductName::Áo jean,,Quantity::0,,TrackInventory::1,,AllowNegative::1,,Cost::190000,,Price::210000,,ProductGroup::1,,ProducerId::1,,VAT::0,,IsSelling::1,,IsActive::1,,AllowMin::0,,AllowMax::110,,IsManageAsSerial::0,,IsManageAttribute::0,,Description::Thesr,,ProductGroupName::Áo thun,,ProducerName::Khatao,,IsCost::0,,LastReferNo::,,LastComment::,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00F771F0 AS DateTime), 1, CAST(0x0000A5FB00FD0B43 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (35, N'T_Trans_Products', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OldProductId::-1,,ProductId::6,,ProductCode::HH000006,,ProductName::Áo jean,,Quantity::0,,TrackInventory::1,,AllowNegative::1,,Cost::190000,,Price::210000,,ProductGroup::1,,ProducerId::1,,VAT::0,,IsSelling::1,,IsActive::1,,AllowMin::0,,AllowMax::110,,IsManageAsSerial::0,,IsManageAttribute::0,,Description::Thesr,,ProductGroupName::Áo thun,,ProducerName::Khatao,,IsCost::0,,LastReferNo::,,LastComment::,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FA6C43 AS DateTime), 1, CAST(0x0000A5FB00FD080E AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (36, N'T_Trans_Purchase', N'Cannot insert the value NULL into column ''Version'', table ''StoreManagement.dbo.T_System_Tmp''; column does not allow nulls. INSERT fails.', N'PurchaseId::8,,PurchaseCode::PN000008,,StoreId::1,,SupplierId::,,SupplierName::,,PurchaseDate::,,Purchaser::1,,PurchaserName::SystemAdmin,,Notes::,,StatusId::1,,PaymentType::1,,Price::90000,,SumMoney::90000,,SumTax::0,,Debt::90000,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Paid::0,,IsActive::1,,_CanUpdate::true,,_CanDelete::true,,Version::', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FA9903 AS DateTime), 1, CAST(0x0000A5FB00FD0508 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (37, N'T_Trans_Purchase', N'Cannot insert the value NULL into column ''Version'', table ''StoreManagement.dbo.T_System_Tmp''; column does not allow nulls. INSERT fails.', N'PurchaseId::10,,PurchaseCode::PN000010,,StoreId::1,,SupplierId::,,SupplierName::,,PurchaseDate::,,Purchaser::1,,PurchaserName::SystemAdmin,,Notes::,,StatusId::1,,PaymentType::1,,Price::90000,,SumMoney::90000,,SumTax::0,,Debt::90000,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Paid::0,,IsActive::1,,_CanUpdate::true,,_CanDelete::true,,Version::', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FAC46D AS DateTime), 1, CAST(0x0000A5FB00FD0201 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (38, N'T_Trans_Purchase', N'Cannot insert the value NULL into column ''Version'', table ''StoreManagement.dbo.T_System_Tmp''; column does not allow nulls. INSERT fails.', N'PurchaseId::8,,PurchaseCode::PN000008,,StoreId::1,,SupplierId::,,SupplierName::,,PurchaseDate::,,Purchaser::1,,PurchaserName::SystemAdmin,,Notes::,,StatusId::1,,PaymentType::1,,Price::90000,,SumMoney::90000,,SumTax::0,,Debt::90000,,PaidForDebt::0,,IsEditingPaidForDebt::false,,Paid::0,,IsActive::1,,_CanUpdate::true,,_CanDelete::true,,Version::', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FB24AD AS DateTime), 1, CAST(0x0000A5FB00FCFEEE AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (39, N'T_Trans_Inventory', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'InventoryId::1013,,InventoryCode::PKK001013,,BalancedDate::,,BalancerName::,,CreatedDate::29-04-2016 10:44:51,,CreatorName::SystemAdmin,,StoreId::1,,StatusId::1,,IsActive::1,,NumProducts::1,,NumDiffs::1,,NumMore::1,,NumLess::0,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FB5B87 AS DateTime), 1, CAST(0x0000A5FB00FCF90B AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (40, N'T_System_Exception_Log', N'Cannot insert the value NULL into column ''Version'', table ''StoreManagement.dbo.T_System_Tmp''; column does not allow nulls. INSERT fails.', N'Id::39,,IsResolve::1,,Hero::1,,Remarks::fix', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FBF8F8 AS DateTime), 1, CAST(0x0000A5FB00FCF3FB AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (41, N'T_System_Exception_Log', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'Id::40,,IsResolve::1,,Hero::1,,Remarks::Fix', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FCA7F0 AS DateTime), 1, CAST(0x0000A5FB00FCEEFA AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (42, N'T_Trans_Cost', N'Incorrect syntax near ''11''.', N'CostName::'',,CostTypeId::11,,PaidDate::03-05-2016,,Amount::100000,,Notes::,,StoreId::1,,IsActive::1,,Version::0', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FF6BE7 AS DateTime), 1, CAST(0x0000A5FB0102E168 AS DateTime))
INSERT [dbo].[T_System_Exception_Log] ([Id], [ObjectName], [ErrorMessage], [Data], [Source], [Hero], [IsResolve], [Remarks], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (43, N'T_Trans_Products', N'Vui lòng tải lại trang và chỉnh sửa lại, dữ liệu bạn đang xem đã bị chỉnh sửa bởi người khác.', N'OldProductId::-1,,ProductId::6,,ProductCode::HH000006,,ProductName::Áo jean'''''''',,Quantity::0,,TrackInventory::1,,AllowNegative::1,,Cost::190000,,Price::210000,,ProductGroup::1,,ProducerId::1,,VAT::0,,IsSelling::1,,IsActive::1,,AllowMin::0,,AllowMax::110,,IsManageAsSerial::0,,IsManageAttribute::0,,Description::Thesr,,ProductGroupName::,,ProducerName::,,IsCost::0,,LastReferNo::,,LastComment::,,Version::9,,_CanUpdate::true,,_CanDelete::true', N'USP_System_Data_Update', 1, 1, N'Fix', 2, 1, CAST(0x0000A5FB00FFB084 AS DateTime), 1, CAST(0x0000A5FB0102DD61 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_System_Exception_Log] OFF
SET IDENTITY_INSERT [dbo].[T_System_Log_Config] ON 

INSERT [dbo].[T_System_Log_Config] ([Id], [TableName], [Desciption], [IsLog], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'T_Trans_Orders', N'Đơn hàng', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Log_Config] ([Id], [TableName], [Desciption], [IsLog], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'T_Trans_Order_Product', N'Sản phẩm trong đơn hàng', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Log_Config] ([Id], [TableName], [Desciption], [IsLog], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'T_Trans_Products', N'Sản phẩm', 1, 1, 1, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Log_Config] OFF
SET IDENTITY_INSERT [dbo].[T_System_Menu] ON 

INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Tổng quan', N'/Admin/General', 0, 1, 1, 1, N'fa fa-dashboard fa-fw', 1, 1, CAST(0x0000A59E00A729D2 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Đơn hàng', N'/Admin/Orders', 0, 1, 2, 1, N'fa fa-shopping-cart fa-fw', 1, 1, CAST(0x0000A59E00A729D9 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Hàng hóa', N'/Admin/Products', 0, 1, 3, 1, N'fa fa-barcode fa-fw', 1, 1, CAST(0x0000A59E00A762FD AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'Khách hàng', N'/Admin/Customers', 0, 1, 4, 1, N'fa fa-group fa-fw', 1, 1, CAST(0x0000A59E00A78E04 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'Nhập kho', N'/Admin/Purchase', 0, 1, 5, 1, N'fa fa-truck fa-fw', 1, 1, CAST(0x0000A59E00A7D98E AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'Tồn kho', N'/Admin/Inventory', 0, 1, 6, 1, N'fa fa-list-alt fa-fw', 1, 1, CAST(0x0000A59E00A830BD AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'Doanh số', N'/Admin/Revenue', 0, 1, 7, 1, N'fa fa-signal fa-fw', 1, 1, CAST(0x0000A59E00A86D3E AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'Thu chi', N'/Admin/Payment', 0, 1, 8, 1, N'fa fa-file-text fa-fw', 1, 1, CAST(0x0000A59E00A8A0BF AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'Lợi nhuận', N'/Admin/Profit', 0, 1, 9, 1, N'fa fa-dollar fa-fw', 1, 1, CAST(0x0000A59E00A8D287 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'Thiết lập', N'/Admin/Setting', 0, 1, 10, 1, N'fa fa-cogs fa-fw', 1, 1, CAST(0x0000A59E00A90611 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'Exception', N'/Admin/Exception', 0, 1, 11, 1, N'fa fa-bug fa-fw', 1, 1, CAST(0x0000A59E00A90611 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Menu] ([MenuId], [Menu], [Url], [Parent], [Level], [DisplayOrder], [IsActive], [CssClass], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, N'Data Log', N'/Admin/LogData', 0, 1, 12, 1, N'fa fa-book fa-fw', 1, 1, CAST(0x0000A59E00A90611 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Menu] OFF
SET IDENTITY_INSERT [dbo].[T_System_Object_Field_Filter] ON 

INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'T_Master_Stores', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'T_Trans_Cost', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'T_Trans_Inventory', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'T_Trans_InventTran', N'FromStoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'T_Trans_InventTran', N'ToStoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'T_Trans_Orders', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'T_Trans_Payment', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'T_Trans_Product_Store', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'T_Trans_ProductQuantity_History', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'T_Trans_Purchase', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'T_Trans_Purchase_Payment', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, N'T_Trans_Receivement', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Field_Filter] ([Id], [ObjectName], [ColumName], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (13, N'UFN_Report_Revenue_By_Store', N'StoreId', 1, 1, 1, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Object_Field_Filter] OFF
SET IDENTITY_INSERT [dbo].[T_System_Object_Freze_Condition] ON 

INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'T_Trans_Orders', N'[IsActive] = 1 and [OrderStatus] = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'T_Trans_Products', N'[IsActive] = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'T_Master_Customers', N'[IsActive] = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'T_Master_Suppliers', N'[IsActive] = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'T_Trans_Purchase', N'[IsActive] = 1 and [StatusId] = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'T_Trans_Inventory', N'[IsActive] = 1 and [StatusId] = 1', N'[IsActive] = 1 and [StatusId] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'T_Trans_InventTran', N'[IsActive] = 1 and [StatusId] = 1', N'[IsActive] = 1 and [StatusId] = 0', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'T_Trans_Cost', N'0 = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'T_Trans_Payment', N'0 = 1', N'[IsActive] = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'T_Trans_Receivement', N'0 = 1', N'0 = 1', 1, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[T_System_Object_Freze_Condition] ([Id], [TableName], [UpdatableCondition], [DeletableCondition], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1003, N'T_System_Exception_Log', N'[IsResolve] = 0', N'0 =1', 1, 1, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Object_Freze_Condition] OFF
SET IDENTITY_INSERT [dbo].[T_System_Role] ON 

INSERT [dbo].[T_System_Role] ([RoleId], [RoleName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'Developer', 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Role] ([RoleId], [RoleName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Admin', 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Role] ([RoleId], [RoleName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Staff', 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role] ([RoleId], [RoleName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'Manager', 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role] ([RoleId], [RoleName], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'Boss', 1, 1, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Role] OFF
SET IDENTITY_INSERT [dbo].[T_System_Role_Menu_Mapping] ON 

INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (1, 10, 1, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (3, 1, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (4, 2, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (5, 3, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (6, 4, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (7, 5, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (8, 6, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (9, 7, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (10, 8, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (11, 9, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (12, 10, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (1002, 11, 1, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_Menu_Mapping] ([Id], [MenuId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (1003, 12, 1, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[T_System_Role_Menu_Mapping] OFF
SET IDENTITY_INSERT [dbo].[T_System_Role_Object_Mapping] ON 

INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'T_Master_Attibutes', 0, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'T_Master_Attibutes', 2, 1, 1, 1, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'T_Master_Attibutes', 4, 1, 1, 1, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'T_Master_Attibutes', 5, 1, 1, 1, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'T_Master_CostTypes', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F20101120C AS DateTime), 1, CAST(0x0000A5F20101120C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'T_Master_CostTypes', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101120C AS DateTime), 1, CAST(0x0000A5F20101120C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'T_Master_CostTypes', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101120C AS DateTime), 1, CAST(0x0000A5F20101120C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'T_Master_CostTypes', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101120C AS DateTime), 1, CAST(0x0000A5F20101120C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'T_Master_Customers', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010133F6 AS DateTime), 1, CAST(0x0000A5F2010133F6 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, N'T_Master_Customers', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010133F6 AS DateTime), 1, CAST(0x0000A5F2010133F6 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (13, N'T_Master_Customers', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010133F6 AS DateTime), 1, CAST(0x0000A5F2010133F6 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (14, N'T_Master_InventoryStatus', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010151BC AS DateTime), 1, CAST(0x0000A5F2010151BC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (15, N'T_Master_InventoryStatus', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010151BC AS DateTime), 1, CAST(0x0000A5F2010151BC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (16, N'T_Master_InventoryStatus', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010151BC AS DateTime), 1, CAST(0x0000A5F2010151BC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (17, N'T_Master_InventoryStatus', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010151BC AS DateTime), 1, CAST(0x0000A5F2010151BC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (18, N'T_Master_InventTranStatus', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F201015CBA AS DateTime), 1, CAST(0x0000A5F201015CBA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (19, N'T_Master_InventTranStatus', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201015CBA AS DateTime), 1, CAST(0x0000A5F201015CBA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (20, N'T_Master_InventTranStatus', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201015CBA AS DateTime), 1, CAST(0x0000A5F201015CBA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (21, N'T_Master_InventTranStatus', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201015CBA AS DateTime), 1, CAST(0x0000A5F201015CBA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (22, N'T_Master_OrderStatus', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010168EA AS DateTime), 1, CAST(0x0000A5F2010168EA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (23, N'T_Master_OrderStatus', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010168EA AS DateTime), 1, CAST(0x0000A5F2010168EA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (24, N'T_Master_OrderStatus', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010168EA AS DateTime), 1, CAST(0x0000A5F2010168EA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (25, N'T_Master_OrderStatus', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010168EA AS DateTime), 1, CAST(0x0000A5F2010168EA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (26, N'T_Master_PaymentType', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010181D5 AS DateTime), 1, CAST(0x0000A5F2010181D5 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (27, N'T_Master_PaymentType', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010181D5 AS DateTime), 1, CAST(0x0000A5F2010181D5 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (28, N'T_Master_PaymentType', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010181D5 AS DateTime), 1, CAST(0x0000A5F2010181D5 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (29, N'T_Master_PaymentType', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010181D5 AS DateTime), 1, CAST(0x0000A5F2010181D5 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (31, N'T_Master_PrintTemplates', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010191B1 AS DateTime), 1, CAST(0x0000A5F2010191B1 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (32, N'T_Master_PrintTemplates', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010191B1 AS DateTime), 1, CAST(0x0000A5F2010191B1 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (33, N'T_Master_PrintTemplates', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010191B1 AS DateTime), 1, CAST(0x0000A5F2010191B1 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (35, N'T_Master_Producers', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201019E60 AS DateTime), 1, CAST(0x0000A5F201019E60 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (36, N'T_Master_Producers', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201019E60 AS DateTime), 1, CAST(0x0000A5F201019E60 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (37, N'T_Master_Producers', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201019E60 AS DateTime), 1, CAST(0x0000A5F201019E60 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (38, N'T_Master_ProductGroups', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F20101AE45 AS DateTime), 1, CAST(0x0000A5F20101AE45 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (39, N'T_Master_ProductGroups', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101AE45 AS DateTime), 1, CAST(0x0000A5F20101AE45 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (40, N'T_Master_ProductGroups', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101AE45 AS DateTime), 1, CAST(0x0000A5F20101AE45 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (41, N'T_Master_ProductGroups', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101AE45 AS DateTime), 1, CAST(0x0000A5F20101AE45 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (42, N'T_Master_PurchaseStatus', 0, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F20101B9AA AS DateTime), 1, CAST(0x0000A5F20101B9AA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (43, N'T_Master_PurchaseStatus', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101B9AA AS DateTime), 1, CAST(0x0000A5F20101B9AA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (44, N'T_Master_PurchaseStatus', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101B9AA AS DateTime), 1, CAST(0x0000A5F20101B9AA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (45, N'T_Master_PurchaseStatus', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101B9AA AS DateTime), 1, CAST(0x0000A5F20101B9AA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (47, N'T_Master_Stores', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101C5D7 AS DateTime), 1, CAST(0x0000A5F20101C5D7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (48, N'T_Master_Stores', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101C5D7 AS DateTime), 1, CAST(0x0000A5F20101C5D7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (49, N'T_Master_Stores', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101C5D7 AS DateTime), 1, CAST(0x0000A5F20101C5D7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (51, N'T_Master_Suppliers', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101D43A AS DateTime), 1, CAST(0x0000A5F20101D43A AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (52, N'T_Master_Suppliers', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101D43A AS DateTime), 1, CAST(0x0000A5F20101D43A AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (53, N'T_Master_Suppliers', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101D43A AS DateTime), 1, CAST(0x0000A5F20101D43A AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (55, N'T_Master_User', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101DFCF AS DateTime), 1, CAST(0x0000A5F20101DFCF AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (56, N'T_Master_User', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101DFCF AS DateTime), 1, CAST(0x0000A5F20101DFCF AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (57, N'T_Master_User', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20101DFCF AS DateTime), 1, CAST(0x0000A5F20101DFCF AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (58, N'T_Trans_Inventory', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201098CCA AS DateTime), 1, CAST(0x0000A5F201098CCA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (59, N'T_Trans_Inventory', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201098CCA AS DateTime), 1, CAST(0x0000A5F201098CCA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (60, N'T_Trans_Inventory', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201098CCA AS DateTime), 1, CAST(0x0000A5F201098CCA AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (61, N'T_Trans_Inventory_Product', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201099973 AS DateTime), 1, CAST(0x0000A5F201099973 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (62, N'T_Trans_Inventory_Product', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201099973 AS DateTime), 1, CAST(0x0000A5F201099973 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (63, N'T_Trans_Inventory_Product', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F201099973 AS DateTime), 1, CAST(0x0000A5F201099973 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (64, N'T_Trans_InventTran', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109A445 AS DateTime), 1, CAST(0x0000A5F20109A445 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (65, N'T_Trans_InventTran', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109A445 AS DateTime), 1, CAST(0x0000A5F20109A445 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (66, N'T_Trans_InventTran', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109A445 AS DateTime), 1, CAST(0x0000A5F20109A445 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (67, N'T_Trans_InventTran_Product', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109B01B AS DateTime), 1, CAST(0x0000A5F20109B01B AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (68, N'T_Trans_InventTran_Product', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109B01B AS DateTime), 1, CAST(0x0000A5F20109B01B AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (69, N'T_Trans_InventTran_Product', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109B01B AS DateTime), 1, CAST(0x0000A5F20109B01B AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (70, N'T_Trans_News', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109BB1A AS DateTime), 1, CAST(0x0000A5F20109BB1A AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (71, N'T_Trans_News', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109BB1A AS DateTime), 1, CAST(0x0000A5F20109BB1A AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (72, N'T_Trans_News', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109BB1A AS DateTime), 1, CAST(0x0000A5F20109BB1A AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (73, N'T_Trans_Order_Product', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109C6A7 AS DateTime), 1, CAST(0x0000A5F20109C6A7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (74, N'T_Trans_Order_Product', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109C6A7 AS DateTime), 1, CAST(0x0000A5F20109C6A7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (75, N'T_Trans_Order_Product', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109C6A7 AS DateTime), 1, CAST(0x0000A5F20109C6A7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (76, N'T_Trans_Orders', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109D974 AS DateTime), 1, CAST(0x0000A5F20109D974 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (77, N'T_Trans_Orders', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109D974 AS DateTime), 1, CAST(0x0000A5F20109D974 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (78, N'T_Trans_Orders', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109D974 AS DateTime), 1, CAST(0x0000A5F20109D974 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (79, N'T_Trans_Payment', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109E6D3 AS DateTime), 1, CAST(0x0000A5F20109E6D3 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (80, N'T_Trans_Payment', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109E6D3 AS DateTime), 1, CAST(0x0000A5F20109E6D3 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (81, N'T_Trans_Payment', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109E6D3 AS DateTime), 1, CAST(0x0000A5F20109E6D3 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (82, N'T_Trans_Product_Attribute', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109F387 AS DateTime), 1, CAST(0x0000A5F20109F387 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (83, N'T_Trans_Product_Attribute', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109F387 AS DateTime), 1, CAST(0x0000A5F20109F387 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (84, N'T_Trans_Product_Attribute', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109F387 AS DateTime), 1, CAST(0x0000A5F20109F387 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (85, N'T_Trans_Product_Store', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109FDB0 AS DateTime), 1, CAST(0x0000A5F20109FDB0 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (86, N'T_Trans_Product_Store', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109FDB0 AS DateTime), 1, CAST(0x0000A5F20109FDB0 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (87, N'T_Trans_Product_Store', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F20109FDB0 AS DateTime), 1, CAST(0x0000A5F20109FDB0 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (88, N'T_Trans_ProductPrice_History', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010A0B32 AS DateTime), 1, CAST(0x0000A5F2010A0B32 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (89, N'T_Trans_ProductPrice_History', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010A0B32 AS DateTime), 1, CAST(0x0000A5F2010A0B32 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (90, N'T_Trans_ProductPrice_History', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010A0B32 AS DateTime), 1, CAST(0x0000A5F2010A0B32 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (91, N'T_Trans_ProductQuantity_History', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010A1744 AS DateTime), 1, CAST(0x0000A5F2010A1744 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (92, N'T_Trans_ProductQuantity_History', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010A1744 AS DateTime), 1, CAST(0x0000A5F2010A1744 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (93, N'T_Trans_ProductQuantity_History', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2010A1744 AS DateTime), 1, CAST(0x0000A5F2010A1744 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (94, N'T_Trans_Products', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A2254 AS DateTime), 1, CAST(0x0000A5F2010A2254 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (95, N'T_Trans_Products', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A2254 AS DateTime), 1, CAST(0x0000A5F2010A2254 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (96, N'T_Trans_Products', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A2254 AS DateTime), 1, CAST(0x0000A5F2010A2254 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (97, N'T_Trans_Purchase', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A2C94 AS DateTime), 1, CAST(0x0000A5F2010A2C94 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (98, N'T_Trans_Purchase', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A2C94 AS DateTime), 1, CAST(0x0000A5F2010A2C94 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (99, N'T_Trans_Purchase', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A2C94 AS DateTime), 1, CAST(0x0000A5F2010A2C94 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (100, N'T_Trans_Purchase_Payment', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A3B00 AS DateTime), 1, CAST(0x0000A5F2010A3B00 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (101, N'T_Trans_Purchase_Payment', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A3B00 AS DateTime), 1, CAST(0x0000A5F2010A3B00 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (102, N'T_Trans_Purchase_Payment', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A3B00 AS DateTime), 1, CAST(0x0000A5F2010A3B00 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (103, N'T_Trans_Purchase_Product', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A453B AS DateTime), 1, CAST(0x0000A5F2010A453B AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (104, N'T_Trans_Purchase_Product', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A453B AS DateTime), 1, CAST(0x0000A5F2010A453B AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (105, N'T_Trans_Purchase_Product', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A453B AS DateTime), 1, CAST(0x0000A5F2010A453B AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (106, N'T_Trans_Receivement', 2, 1, 1, 0, 1, 1, 1, CAST(0x0000A5F2010A5078 AS DateTime), 1, CAST(0x0000A5F2010A5078 AS DateTime))
GO
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (107, N'T_Trans_Receivement', 4, 1, 1, 0, 1, 1, 1, CAST(0x0000A5F2010A5078 AS DateTime), 1, CAST(0x0000A5F2010A5078 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (108, N'T_Trans_Receivement', 5, 1, 1, 0, 1, 1, 1, CAST(0x0000A5F2010A5078 AS DateTime), 1, CAST(0x0000A5F2010A5078 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (109, N'T_Trans_User_Store', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A6784 AS DateTime), 1, CAST(0x0000A5F2010A6784 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (110, N'T_Trans_User_Store', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A6784 AS DateTime), 1, CAST(0x0000A5F2010A6784 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (111, N'T_Trans_User_Store', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010A6784 AS DateTime), 1, CAST(0x0000A5F2010A6784 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (112, N'T_Trans_Cost', 2, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010AD948 AS DateTime), 1, CAST(0x0000A5F2010AD948 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (113, N'T_Trans_Cost', 4, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010AD948 AS DateTime), 1, CAST(0x0000A5F2010AD948 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (114, N'T_Trans_Cost', 5, 1, 1, 1, 1, 1, 1, CAST(0x0000A5F2010AD948 AS DateTime), 1, CAST(0x0000A5F2010AD948 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (115, N'UFN_System_Get_Menu', 0, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (116, N'UFN_Report_Inventory', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013D97EC AS DateTime), 1, CAST(0x0000A5F2013D97EC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (117, N'UFN_Report_Inventory', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013D97EC AS DateTime), 1, CAST(0x0000A5F2013D97EC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (118, N'UFN_Report_Inventory', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013D97EC AS DateTime), 1, CAST(0x0000A5F2013D97EC AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (119, N'UFN_Report_Payment_Cashier', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DA10C AS DateTime), 1, CAST(0x0000A5F2013DA10C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (120, N'UFN_Report_Payment_Cashier', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DA10C AS DateTime), 1, CAST(0x0000A5F2013DA10C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (121, N'UFN_Report_Payment_Cashier', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DA10C AS DateTime), 1, CAST(0x0000A5F2013DA10C AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (122, N'UFN_Report_Revenue_By_Product', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DA8D4 AS DateTime), 1, CAST(0x0000A5F2013DA8D4 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (123, N'UFN_Report_Revenue_By_Product', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DA8D4 AS DateTime), 1, CAST(0x0000A5F2013DA8D4 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (124, N'UFN_Report_Revenue_By_Product', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DA8D4 AS DateTime), 1, CAST(0x0000A5F2013DA8D4 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (125, N'UFN_Report_Revenue_By_Seller', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DB359 AS DateTime), 1, CAST(0x0000A5F2013DB359 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (126, N'UFN_Report_Revenue_By_Seller', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DB359 AS DateTime), 1, CAST(0x0000A5F2013DB359 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (127, N'UFN_Report_Revenue_By_Seller', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DB359 AS DateTime), 1, CAST(0x0000A5F2013DB359 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (128, N'UFN_Report_Revenue_By_Store', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DBDD7 AS DateTime), 1, CAST(0x0000A5F2013DBDD7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (129, N'UFN_Report_Revenue_By_Store', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DBDD7 AS DateTime), 1, CAST(0x0000A5F2013DBDD7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (130, N'UFN_Report_Revenue_By_Store', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DBDD7 AS DateTime), 1, CAST(0x0000A5F2013DBDD7 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (131, N'UFN_Report_Revenue_In_Month', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DC5E9 AS DateTime), 1, CAST(0x0000A5F2013DC5E9 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (132, N'UFN_Report_Revenue_In_Month', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DC5E9 AS DateTime), 1, CAST(0x0000A5F2013DC5E9 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (133, N'UFN_Report_Revenue_In_Month', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DC5E9 AS DateTime), 1, CAST(0x0000A5F2013DC5E9 AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (134, N'UFN_Report_Revenue_In_Year', 2, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DD03D AS DateTime), 1, CAST(0x0000A5F2013DD03D AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (135, N'UFN_Report_Revenue_In_Year', 4, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DD03D AS DateTime), 1, CAST(0x0000A5F2013DD03D AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (136, N'UFN_Report_Revenue_In_Year', 5, 1, 0, 0, 1, 1, 1, CAST(0x0000A5F2013DD03D AS DateTime), 1, CAST(0x0000A5F2013DD03D AS DateTime))
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (138, N'UFN_Report_Profit_By_Time', 2, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (139, N'UFN_Report_Profit_By_Time', 5, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (140, N'UFN_Report_Profit_By_Product', 2, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (141, N'UFN_Report_Profit_By_Product', 5, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (142, N'UFN_Report_Profit_By_Store', 2, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (143, N'UFN_Report_Profit_By_Store', 5, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (145, N'UFN_Report_Profit_Summary', 2, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (146, N'UFN_Report_Profit_Summary', 5, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (147, N'T_System_Exception_Log', 1, 1, 1, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (148, N'T_System_Data_Log', 1, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (149, N'V_System_Data_Log', 1, 1, 0, 0, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Role_Object_Mapping] ([Id], [ObjectName], [Role], [CanSelect], [CanUpdate], [CanDelete], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (150, N'T_System_Log_Config', 1, 1, 1, 0, 1, 1, 1, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Role_Object_Mapping] OFF
SET IDENTITY_INSERT [dbo].[T_System_Role_User_Mapping] ON 

INSERT [dbo].[T_System_Role_User_Mapping] ([Id], [UserId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (1, 1, 1, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[T_System_Role_User_Mapping] ([Id], [UserId], [RoleId], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsActive]) VALUES (2, 1, 2, 1, 1, CAST(0x0000A59E00000000 AS DateTime), NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[T_System_Role_User_Mapping] OFF
INSERT [dbo].[T_System_Rule] ([RuleId], [RuleName], [Value], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'DATE_FORMAT', N'dd-MM-yyyy', 1, 1, CAST(0x0000A59700000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Rule] ([RuleId], [RuleName], [Value], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'DATETIME_FORMAT', N'dd-MM-yyyy hh:mm:ss', 1, 1, CAST(0x0000A59700000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Rule] ([RuleId], [RuleName], [Value], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'TIME_FORMAT', N'hh:mm:ss', 1, 1, CAST(0x0000A59700000000 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Triggers] ON 

INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'T_Master_Customers', N'Trigger_Customer_SetDefaultCode', 1, 1, 0, 0, 1, 1, CAST(0x0000A5DC00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'T_Master_Suppliers', N'Trigger_Supplier_SetDefaultCode', 1, 1, 0, 0, 1, 1, CAST(0x0000A5DC00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'T_Trans_Order_Product', N'Trigger_ProductOrder_CheckContraint', 1, 1, 1, 0, 1, 1, CAST(0x0000A5DC00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'T_Trans_Orders', N'Trigger_Order_SetCode', 1, 1, 1, 0, 1, 1, CAST(0x0000A5DC00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'T_Trans_Orders', N'Trigger_Order_UpdateContraint', 2, 1, 1, 0, 1, 1, CAST(0x0000A5DC00000000 AS DateTime), NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'T_Trans_Purchase_Product', N'Trigger_PurchaseProduct_CheckContraint', 1, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'T_Trans_Purchase', N'Trigger_Purchase_SetCode', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'T_Trans_Purchase', N'Trigger_Purchase_CheckContraint', 2, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'T_Trans_Products', N'Trigger_Product_SetCode', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'T_Trans_Products', N'Trigger_Product_Price_TrackHistory', 2, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, N'T_Trans_Products', N'Trigger_Product_CheckContraint', 3, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (13, N'T_Master_Stores', N'Trigger_Store_CheckContraint', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (14, N'T_Trans_Inventory', N'Trigger_Inventory_SetCode', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (15, N'T_Trans_Inventory_Product', N'Trigger_InventoryProduct_CheckContraint', 1, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (16, N'T_Trans_Inventory', N'Trigger_Inventory_SetBalancedDate', 2, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (17, N'T_Trans_Purchase', N'Trigger_Purchase_SetPurchaseDate', 3, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (18, N'T_Trans_InventTran', N'Trigger_InventTran_SetCode', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (19, N'T_Trans_InventTran', N'Trigger_InventTran_SetTranferedDate', 2, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (20, N'T_Trans_InventTran_Product', N'Trigger_InventTranProduct_CheckContraint', 1, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (21, N'T_Trans_Orders', N'Trigger_Order_Payment', 3, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (22, N'T_Trans_Payment', N'Trigger_Payment_CheckContraint', 1, 0, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (23, N'T_Trans_Payment', N'Trigger_Payment_PaidDebt', 2, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (24, N'T_Trans_Cost', N'Trigger_Payment_SetCode', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1022, N'T_Trans_Purchase', N'Trigger_Purchase_Payment', 4, 1, 1, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1023, N'T_Trans_Purchase_Payment', N'Trigger_Purchase_Payment_PaidDebt', 1, 1, 0, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_System_Triggers] ([Id], [TableName], [SPName], [OrderExec], [OnInsert], [OnUpdate], [OnDelete], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1024, N'T_Trans_Orders', N'Trigger_Order_SetSoldDate', 4, 1, 1, 0, 1, 1, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_System_Triggers] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Cost] ON 

INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'PC000001 ', N'Tiền điện tháng 4', 1, CAST(0x3C3B0B00 AS Date), 200000.0000, 1, N'Test thôi', 0, 1, 1, CAST(0x0000A5E200D0BD80 AS DateTime), 1, CAST(0x0000A5E200DCEE25 AS DateTime))
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'PC000002 ', N'Tiền nước tháng 4', 1, CAST(0x443B0B00 AS Date), 12455.0000, 1, N'test', 0, 1, 1, CAST(0x0000A5E400B28EE2 AS DateTime), 1, CAST(0x0000A5E400B7EB2E AS DateTime))
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'PC000004', N'Tiền điện tháng 4', 1, CAST(0x3B3B0B00 AS Date), 200000.0000, 1, N'Đã Duyệt', 1, 1, 1, CAST(0x0000A5E400B8F070 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'PC000005', N'Tiền nước', 4, CAST(0x453B0B00 AS Date), 200000.0000, 1, N'sdsd', 1, 1, 1, CAST(0x0000A5EA0124B94A AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'PC000006', N'TERS', 11, CAST(0x483B0B00 AS Date), 300000.0000, 1, N'', 0, 1, 1, CAST(0x0000A5ED015B791E AS DateTime), 1, CAST(0x0000A5ED015B8A2F AS DateTime))
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'PC000007', N'TEST', 11, CAST(0x483B0B00 AS Date), 500000.0000, 1, N'ghjgjhjhjh hjshdsdsdsd', 1, 1, 1, CAST(0x0000A5ED015BBF83 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'PC000008', N'TEST', 11, CAST(0x4D3B0B00 AS Date), 100000.0000, 2, N'ok', 1, 1, 1, CAST(0x0000A5F2014C43B5 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'PC000009', N'''', 11, CAST(0x563B0B00 AS Date), 100000.0000, 1, N'', 1, 1, 1, CAST(0x0000A5FB00FEA601 AS DateTime), 1, CAST(0x0000A5FB00FEA601 AS DateTime))
INSERT [dbo].[T_Trans_Cost] ([CostId], [CostCode], [CostName], [CostTypeId], [PaidDate], [Amount], [StoreId], [Notes], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'PC000010', N'''', 11, CAST(0x563B0B00 AS Date), 100000.0000, 1, N'', 1, 1, 1, CAST(0x0000A5FB00FF8E9A AS DateTime), 1, CAST(0x0000A5FB00FF8E9A AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Cost] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Inventory] ON 

INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'PKK000006', 1, NULL, 1, CAST(0x0000A5DE017767F8 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DD00BA6C9C AS DateTime), 1, CAST(0x0000A5DE017767F6 AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'PKK000007', 1, NULL, 1, CAST(0x0000A5DE01770ECC AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DD00BABC4C AS DateTime), 1, CAST(0x0000A5DE01770ECA AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'PKK000008', 1, N'TEts', 1, CAST(0x0000A5DE01760CF7 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DE009783E4 AS DateTime), 1, CAST(0x0000A5DE01760CF5 AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'PKK000009', 1, NULL, 1, CAST(0x0000A5DE0168A8DF AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DE00996B64 AS DateTime), 1, CAST(0x0000A5DE0168A8DD AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'PKK000010', 1, NULL, 1, CAST(0x0000A5DE0177DDE4 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DE00B1C498 AS DateTime), 1, CAST(0x0000A5DE0177DDE2 AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'PKK000011', 2, NULL, 1, CAST(0x0000A5DE0177FE42 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DE0177FE40 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, N'PKK000012', 1, NULL, NULL, NULL, 1, 1, 0, 1, 1, CAST(0x0000A5DE017B2404 AS DateTime), 1, CAST(0x0000A5DE017B7616 AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (13, N'PKK000013', 2, NULL, 1, CAST(0x0000A5ED01593720 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5ED00935724 AS DateTime), 1, CAST(0x0000A5ED0159371D AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (14, N'PKK000014', 2, N'', NULL, NULL, 1, 1, 1, 1, 1, CAST(0x0000A5ED015A1B36 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1013, N'PKK001013', 1, NULL, 1, CAST(0x0000A5FB00FB9E6C AS DateTime), 1, 2, 1, 3, 1, CAST(0x0000A5F70176DE04 AS DateTime), 1, CAST(0x0000A5FB00FB9E6A AS DateTime))
INSERT [dbo].[T_Trans_Inventory] ([InventoryId], [InventoryCode], [StoreId], [Notes], [BalancerId], [BalancedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1014, N'PKK001014', 1, NULL, NULL, NULL, 1, 1, 1, 2, 1, CAST(0x0000A5FB01007284 AS DateTime), 1, CAST(0x0000A5FB01007D70 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Inventory] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Inventory_Product] ON 

INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 9, 1, 2, 3, N'2', 1, 1, CAST(0x0000A5DE015F4D37 AS DateTime), 1, CAST(0x0000A5DE0168A8F6 AS DateTime))
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 8, 1, 3, 3, N'', 1, 1, CAST(0x0000A5DE0168D01F AS DateTime), 1, CAST(0x0000A5DE01760D11 AS DateTime))
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 7, 2, 4, 10, N'x', 1, 1, CAST(0x0000A5DE01770EDA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 6, 2, 10, 6, N'd', 1, 1, CAST(0x0000A5DE01776806 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 10, 2, 6, 7, N'sd', 1, 1, CAST(0x0000A5DE017786AB AS DateTime), 1, CAST(0x0000A5DE0177DDF2 AS DateTime))
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, 11, 2, 0, 3, N'd', 1, 1, CAST(0x0000A5DE0177FE51 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, 12, 1, 3, 1, N'1', 1, 1, CAST(0x0000A5DE017B2423 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, 13, 1, 0, 2, N'Test', 1, 1, CAST(0x0000A5ED015918F9 AS DateTime), 1, CAST(0x0000A5ED015938CB AS DateTime))
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, 14, 1, 2, 1, N'test', 1, 1, CAST(0x0000A5ED015A1B5D AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1008, 1013, 1, -5, 2, N'ewe', 3, 1, CAST(0x0000A5F70176DE60 AS DateTime), 1, CAST(0x0000A5FB00FB9E7E AS DateTime))
INSERT [dbo].[T_Trans_Inventory_Product] ([Id], [InventoryId], [ProductId], [Quantity], [RealQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1009, 1014, 1, 2, 3, N'^&*()&%^$^%^%''', 2, 1, CAST(0x0000A5FB0100729C AS DateTime), 1, CAST(0x0000A5FB01007D7E AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Inventory_Product] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_InventTran] ON 

INSERT [dbo].[T_Trans_InventTran] ([InventTranId], [InventTranCode], [FromStoreId], [ToStoreId], [Notes], [TransferId], [TransferedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'PCK000002', 1, 2, N'', 1, CAST(0x0000A5DF0188B557 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DF00C138D8 AS DateTime), 1, CAST(0x0000A5DF0188B555 AS DateTime))
INSERT [dbo].[T_Trans_InventTran] ([InventTranId], [InventTranCode], [FromStoreId], [ToStoreId], [Notes], [TransferId], [TransferedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'PCK000003', 1, 2, N'Tets', 1, CAST(0x0000A5DF018A5131 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5DF018A512F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_InventTran] ([InventTranId], [InventTranCode], [FromStoreId], [ToStoreId], [Notes], [TransferId], [TransferedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'PCK000005', 2, 1, N'Test', 1, CAST(0x0000A5E40171B75D AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5E40171B61E AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_InventTran] ([InventTranId], [InventTranCode], [FromStoreId], [ToStoreId], [Notes], [TransferId], [TransferedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'PCK000006', 2, 1, N'', 1, CAST(0x0000A5ED015A67E6 AS DateTime), 1, 2, 1, 1, 1, CAST(0x0000A5ED015A67CB AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_InventTran] ([InventTranId], [InventTranCode], [FromStoreId], [ToStoreId], [Notes], [TransferId], [TransferedDate], [NumProducts], [StatusId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'PCK000007', 1, 2, N'', NULL, NULL, 1, 1, 1, 2, 1, CAST(0x0000A5FB00FBB3ED AS DateTime), 1, CAST(0x0000A5FB00FBB963 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_InventTran] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_InventTran_Product] ON 

INSERT [dbo].[T_Trans_InventTran_Product] ([Id], [InventTranId], [ProductId], [Quantity], [TranQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 2, 1, 3, 1, N'', 1, 1, CAST(0x0000A5DF0186FB49 AS DateTime), 1, CAST(0x0000A5DF0188B566 AS DateTime))
INSERT [dbo].[T_Trans_InventTran_Product] ([Id], [InventTranId], [ProductId], [Quantity], [TranQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 3, 1, 2, 1, N'Ok', 1, 1, CAST(0x0000A5DF018A513E AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_InventTran_Product] ([Id], [InventTranId], [ProductId], [Quantity], [TranQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 5, 2, 2, 1, N'', 1, 1, CAST(0x0000A5E40171B76D AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_InventTran_Product] ([Id], [InventTranId], [ProductId], [Quantity], [TranQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 6, 1, 2, 2, N'test', 1, 1, CAST(0x0000A5ED015A6814 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_InventTran_Product] ([Id], [InventTranId], [ProductId], [Quantity], [TranQuantity], [Notes], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 7, 1, 2, 1, N'a', 2, 1, CAST(0x0000A5FB00FBB3FF AS DateTime), 1, CAST(0x0000A5FB00FBB971 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_InventTran_Product] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Order_Product] ON 

INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 1, 1, 3, 90000, 100000, 300000, 0, 1, 1, 1, CAST(0x0000A5DC017F4926 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 2, 1, 2, 90000, 100000, 200000, 0, 1, 1, 1, CAST(0x0000A5DC017F6A80 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 3, 1, 1, 90000, 100000, 100000, 0, 1, 1, 1, CAST(0x0000A5DC017F976D AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 4, 1, 2, 90000, 110000, 220000, 0, 1, 1, 1, CAST(0x0000A5DC0186226F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 5, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5DD0005C699 AS DateTime), 1, CAST(0x383B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, 6, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5E2018450E3 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, 7, 2, 1, 200000, 250000, 250000, 0, 1, 1, 1, CAST(0x0000A5E300870EAF AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, 8, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5E40126502B AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1007, 1008, 2, 1, 200000, 250000, 250000, 0, 1, 1, 1, CAST(0x0000A5E40164A91B AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1008, 1009, 2, 1, 200000, 250000, 250000, 0, 1, 1, 1, CAST(0x0000A5E50168838C AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1010, 1010, 2, 2, 200000, 250000, 500000, 0, 1, 1, 1, CAST(0x0000A5E701794959 AS DateTime), 1, CAST(0x4D3B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1011, 1011, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F201515B09 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1012, 1012, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F201840D28 AS DateTime), 1, CAST(0x4E3B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1013, 1013, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F601531338 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1014, 1014, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F601531F76 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3014, 3014, 3, 1, 100000, 200000, 180000, 10, 1, 1, 1, CAST(0x0000A5F9009AE13E AS DateTime), 1, CAST(0x543B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4020, 4018, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F900B7E50C AS DateTime), 1, CAST(0x543B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4021, 4019, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F900B803C5 AS DateTime), 1, CAST(0x543B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4022, 4019, 2, 1, 200000, 250000, 250000, 0, 1, 1, 1, CAST(0x0000A5F9010FC2D9 AS DateTime), 1, CAST(0x543B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4023, 4020, 2, 2, 200000, 250000, 427500, 5, 1, 1, 1, CAST(0x0000A5F9014251B3 AS DateTime), 1, CAST(0x543B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4024, 4020, 1, 1, 90000, 110000, 99000, 0, 1, 1, 1, CAST(0x0000A5F9014251C2 AS DateTime), 1, CAST(0x543B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4025, 4021, 1, 1, 90000, 110000, 110000, 0, 1, 1, 1, CAST(0x0000A5F9014552E0 AS DateTime), 1, CAST(0x553B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4026, 4022, 2, 1, 200000, 250000, 225000, 10, 1, 2, 1, CAST(0x0000A5FB00E33843 AS DateTime), 1, CAST(0x563B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4027, 4023, 2, 2, 200000, 250000, 500000, 0, 1, 10, 1, CAST(0x0000A5FB00E8D05D AS DateTime), 1, CAST(0x563B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4028, 4024, 2, 1, 200000, 250000, 250000, 0, 1, 1, 1, CAST(0x0000A5FB00ED9CF4 AS DateTime), 1, CAST(0x563B0B00 AS Date))
INSERT [dbo].[T_Trans_Order_Product] ([Id], [OrderId], [ProductId], [Quantity], [Cost], [Price], [RealPrice], [Discount], [IsDiscountPercent], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4029, 4025, 2, 1, 200000, 250000, 250000, 0, 1, 1, 1, CAST(0x0000A5FB00F7664D AS DateTime), 1, CAST(0x563B0B00 AS Date))
SET IDENTITY_INSERT [dbo].[T_Trans_Order_Product] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Orders] ON 

INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'PX000001', 2, CAST(0x0000A5DC017F490F AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 3, 300000.0000, 300000.0000, 320000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5DC017F490D AS DateTime), 1, CAST(0x0000A5EE01759EA5 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'PX000002', 2, CAST(0x0000A5DC017F6A55 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 2, 200000.0000, 0.0000, 200000.0000, 200000.0000, 1, 1, 1, CAST(0x0000A5DC017F6A54 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'PX000003', 1, CAST(0x0000A5DC017F9755 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 100000.0000, 100000.0000, 100000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5DC017F9754 AS DateTime), 1, CAST(0x0000A5E400DE862B AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'PX000004', 1, CAST(0x0000A5DC01862256 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 2, 220000.0000, 100000.0000, 220000.0000, 120000.0000, 1, 1, 1, CAST(0x0000A5DC01862255 AS DateTime), 1, CAST(0x0000A5F20150DCAC AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'PX000005', 1, CAST(0x0000A5DD00CB86BC AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 110000.0000, 110000.0000, 110000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5DD0005C639 AS DateTime), 1, CAST(0x0000A5E300A14AC5 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'PX000006', 1, CAST(0x0000A5E200BE8ED0 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 110000.0000, 110000.0000, 110000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5E2018450AB AS DateTime), 1, CAST(0x0000A5E300985B55 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'PX000007', 1, CAST(0x0000A5E300870DE5 AS DateTime), 1, 2, N'', 3, 2, 0, 1, 1, 250000.0000, 250000.0000, 250000.0000, 0.0000, 0, 1, 1, CAST(0x0000A5E300870D71 AS DateTime), 1, CAST(0x0000A5E7016E4F5C AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'PX000008', 2, CAST(0x0000A5E401264FD3 AS DateTime), 3, 2, N'', 1, 2, 0, 1, 1, 110000.0000, 110000.0000, 110000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5E401264FC5 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1008, N'PX001008', 2, CAST(0x0000A5E40164A89F AS DateTime), 2, NULL, N'', 1, 2, 0, 1, 1, 250000.0000, 0.0000, 275000.0000, 250000.0000, 1, 1, 1, CAST(0x0000A5E40164A882 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1009, N'PXS001009', 2, CAST(0x0000A5E50168833A AS DateTime), 1, 1, N'', 1, 2, 0, 1, 1, 250000.0000, 0.0000, 250000.0000, 250000.0000, 1, 1, 1, CAST(0x0000A5E501688338 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1010, N'PX001010', 1, CAST(0x0000A5E50168833A AS DateTime), 1, NULL, N'', 2, 2, 0, 1, 2, 500000.0000, 250000.0000, 550000.0000, 250000.0000, 1, 1, 1, CAST(0x0000A5E701794932 AS DateTime), 1, CAST(0x0000A5F200C369B1 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1011, N'PX001011', 2, CAST(0x0000A5F201515AED AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 110000.0000, 100000.0000, 120000.0000, 10000.0000, 1, 1, 1, CAST(0x0000A5F201515ACA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1012, N'PX001012', 1, CAST(0x0000A5E50168833A AS DateTime), 1, 2, N'cfd', 1, 2, 0, 1, 1, 110000.0000, 0.0000, 120000.0000, 110000.0000, 1, 1, 1, CAST(0x0000A5F201840D01 AS DateTime), 1, CAST(0x0000A5F3016A328F AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1013, N'PX001013', 1, CAST(0x0000A5F6015312B1 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 110000.0000, 0.0000, 110000.0000, 110000.0000, 1, 1, 1, CAST(0x0000A5F6015312A5 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1014, N'PX001014', 1, CAST(0x0000A5F601531F5F AS DateTime), 1, NULL, N'', 1, 1, 0, 1, 1, 110000.0000, 0.0000, 110000.0000, 110000.0000, 0, 1, 1, CAST(0x0000A5F601531F5E AS DateTime), 1, CAST(0x0000A5F601532538 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2014, N'PX002014', 1, CAST(0x0000A5F7017539F8 AS DateTime), 1, NULL, N'', 1, 1, 0, 1, 1, 110000.0000, 0.0000, 110000.0000, 110000.0000, 1, 1, 1, CAST(0x0000A5F7017539F4 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3014, N'PXS003014', 1, CAST(0x0000A5E50168833A AS DateTime), 1, 1, N'', 1, 2, 0, 1, 1, 180000.0000, 0.0000, 180000.0000, 180000.0000, 1, 1, 1, CAST(0x0000A5F9009AE061 AS DateTime), 1, CAST(0x0000A5F9009B2F11 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4018, N'PX004018', 1, CAST(0x0000A5F9014264B5 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 110000.0000, 0.0000, 110000.0000, 110000.0000, 1, 1, 1, CAST(0x0000A5F900B7E4FE AS DateTime), 1, CAST(0x0000A5F9014264B5 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4019, N'PX004019', 1, CAST(0x0000A5F901425F47 AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 2, 360000.0000, 0.0000, 360000.0000, 360000.0000, 1, 1, 1, CAST(0x0000A5F900B8039B AS DateTime), 1, CAST(0x0000A5F901425F46 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4020, N'PXS004020', 1, CAST(0x0000A5F9014258AA AS DateTime), 1, 1, N'', 1, 2, 10, 1, 3, 526500.0000, 0.0000, 610000.0000, 526500.0000, 1, 1, 1, CAST(0x0000A5F901425173 AS DateTime), 1, CAST(0x0000A5F9014258AA AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4021, N'PX004021', 1, CAST(0x0000A5FA017DECDA AS DateTime), 1, NULL, N'', 1, 2, 0, 1, 1, 110000.0000, 0.0000, 110000.0000, 110000.0000, 1, 1, 1, CAST(0x0000A5F9014552C3 AS DateTime), 1, CAST(0x0000A5FA017DECCA AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4022, N'PXS004022', 1, NULL, 3, 1, N'', 2, 1, 0, 1, 1, 225000.0000, 225000.0000, 250000.0000, 0.0000, 1, 2, 1, CAST(0x0000A5FB00E33826 AS DateTime), 1, CAST(0x0000A5FB00F715BA AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4023, N'PX004023', 1, CAST(0x0000A61100C5C100 AS DateTime), 1, NULL, N'', 1, 1, 0, 1, 2, 500000.0000, 0.0000, 500000.0000, 500000.0000, 1, 10, 1, CAST(0x0000A5FB00E8D035 AS DateTime), 1, CAST(0x0000A5FB0104C5DC AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4024, N'PX004024', 1, NULL, 1, NULL, N'', 1, 1, 0, 1, 1, 250000.0000, 0.0000, 250000.0000, 250000.0000, 1, 1, 1, CAST(0x0000A5FB00ED9CC6 AS DateTime), 1, CAST(0x0000A5FB00ED9CC6 AS DateTime))
INSERT [dbo].[T_Trans_Orders] ([OrderId], [OrderCode], [StoreId], [SoldDate], [Cashier], [Customer], [Notes], [PaymentType], [OrderStatus], [Discount], [IsDiscountPercent], [NumOfProduct], [SumMoney], [Paid], [OrginalMoney], [DebtMoney], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4025, N'PX004025', 1, NULL, 1, NULL, N'', 1, 1, 0, 1, 1, 250000.0000, 0.0000, 250000.0000, 250000.0000, 1, 1, 1, CAST(0x0000A5FB00F765F0 AS DateTime), 1, CAST(0x0000A5FB00F765F0 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Orders] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Payment] ON 

INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 6, 1, 1, 100000.0000, 0, 1, 1, CAST(0x0000A5E2018450B6 AS DateTime), 1, CAST(0x0000A5E201889AFD AS DateTime))
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 7, 1, 1, 250000.0000, 1, 1, 1, CAST(0x0000A5E300870E3F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 6, 1, 1, 110000.0000, 1, 1, 1, CAST(0x0000A5E300985B79 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 5, 1, 1, 10000.0000, 0, 1, 1, CAST(0x0000A5E3009F5A5D AS DateTime), 1, CAST(0x0000A5E300A089BA AS DateTime))
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 5, 1, 1, 90000.0000, 1, 1, 1, CAST(0x0000A5E3009FB32F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, 5, 1, 1, 20000.0000, 0, 1, 1, CAST(0x0000A5E300A1054E AS DateTime), 1, CAST(0x0000A5E300A1143E AS DateTime))
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, 5, 1, 1, 20000.0000, 1, 1, 1, CAST(0x0000A5E300A14AC4 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, 3, 1, 1, 100000.0000, 1, 1, 1, CAST(0x0000A5E400DE8623 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, 8, 2, 1, 110000.0000, 1, 1, 1, CAST(0x0000A5E401264FF8 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1004, 1, 2, 1, 300000.0000, 1, 1, 1, CAST(0x0000A5EE01759EA4 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2004, 4, 1, 1, 20000.0000, 1, 1, 1, CAST(0x0000A5F200BFF4D9 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2005, 1010, 1, 2, 250000.0000, 1, 1, 1, CAST(0x0000A5F200C369C2 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2006, 4, 1, 2, 20000.0000, 1, 1, 1, CAST(0x0000A5F200C99B61 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2007, 4, 1, 2, 20000.0000, 1, 1, 1, CAST(0x0000A5F200C9B49F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2008, 4, 1, 3, 20000.0000, 1, 1, 1, CAST(0x0000A5F200C9D5EA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2009, 4, 1, 1, 20000.0000, 1, 1, 1, CAST(0x0000A5F20150DCAA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Payment] ([PaymentId], [OrderId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2010, 1011, 2, 1, 100000.0000, 1, 1, 1, CAST(0x0000A5F201515AF7 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Trans_Payment] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Product_Attribute] ON 

INSERT [dbo].[T_Trans_Product_Attribute] ([Id], [AttributeId], [ProductId], [Value], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 2, 3, N'X', 1, 1, CAST(0x0000A5E60150D8AB AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Attribute] ([Id], [AttributeId], [ProductId], [Value], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 1002, 3, N'S', 1, 1, CAST(0x0000A5E60150D8B5 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Attribute] ([Id], [AttributeId], [ProductId], [Value], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 2, 5, N'N', 1, 1, CAST(0x0000A5E60185000B AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Trans_Product_Attribute] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Product_Store] ON 

INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 1, 1, 2, 1, 1, 1, CAST(0x0000A5DC017EAB8B AS DateTime), 1, CAST(0x0000A5FB00FB9E88 AS DateTime))
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 1, 2, -1, 1, 1, 1, CAST(0x0000A5DC017EDB0A AS DateTime), 1, CAST(0x0000A5F201515B12 AS DateTime))
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 2, 1, 0, 1, 1, 1, CAST(0x0000A5DD001AF58F AS DateTime), 1, CAST(0x0000A5F901425F60 AS DateTime))
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 2, 2, 0, 1, 1, 1, CAST(0x0000A5DD001AF58F AS DateTime), 1, CAST(0x0000A5E501688397 AS DateTime))
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 3, 1, -5, 1, 1, 1, CAST(0x0000A5E60150D868 AS DateTime), 1, CAST(0x0000A5F900B89DE3 AS DateTime))
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, 3, 2, 1, 1, 1, 1, CAST(0x0000A5E60150D868 AS DateTime), 1, CAST(0x0000A5F2015138DD AS DateTime))
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, 4, 1, 0, 1, 1, 1, CAST(0x0000A5E601840B86 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, 4, 2, 0, 1, 1, 1, CAST(0x0000A5E601840B86 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, 5, 1, 0, 0, 1, 1, CAST(0x0000A5E601850001 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, 5, 2, 0, 0, 1, 1, CAST(0x0000A5E601850001 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, 6, 1, 0, 1, 1, 1, CAST(0x0000A5EA011B7564 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Product_Store] ([Id], [ProductId], [StoreId], [Quantity], [AllowNegative], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (12, 6, 2, 0, 1, 1, 1, CAST(0x0000A5EA011B7564 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Trans_Product_Store] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_ProductPrice_History] ON 

INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (1, 1, 0.0000, 0.0000, N'Khai báo mới hàng hóa', 1, CAST(0x0000A5DC017E8617 AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (2, 1, 90000.0000, 100000.0000, N'Nhập kho PN000001', 1, CAST(0x0000A5DC017EAB8E AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (3, 1, NULL, 110000.0000, N'Cập nhật giá cho hàng hóa', 1, CAST(0x0000A5DC01860A64 AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (4, 2, 0.0000, 0.0000, N'Khai báo mới hàng hóa', 1, CAST(0x0000A5DD001AF58C AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (5, 2, 200000.0000, 250000.0000, N'Nhập kho PN000003', 1, CAST(0x0000A5DD001B12BA AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (6, 3, 100000.0000, 200000.0000, N'Khai báo mới hàng hóa', 1, CAST(0x0000A5E60150D866 AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (7, 4, 100000.0000, 200000.0000, N'Khai báo mới hàng hóa', 1, CAST(0x0000A5E601840B84 AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (8, 5, 100000.0000, 200000.0000, N'Khai báo mới hàng hóa', 1, CAST(0x0000A5E60184FFFF AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (9, 6, 0.0000, 0.0000, N'Khai báo mới hàng hóa', 1, CAST(0x0000A5EA011B7559 AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (1009, 6, 190000.0000, NULL, N'Cập nhật giá cho hàng hóa', 1, CAST(0x0000A5FB00E16798 AS DateTime))
INSERT [dbo].[T_Trans_ProductPrice_History] ([Id], [ProductId], [Cost], [Price], [Description], [CreatedBy], [CreatedDate]) VALUES (1010, 6, NULL, 210000.0000, N'Cập nhật giá cho hàng hóa', 1, CAST(0x0000A5FB00E181A0 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_ProductPrice_History] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_ProductQuantity_History] ON 

INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1, 1, 1, N'PN000001', 6, 0, 6, N'Nhập kho PN000001', 1, CAST(0x0000A5DC017EAB8D AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2, 1, 2, N'PN000002', 4, 0, 4, N'Nhập kho PN000002', 1, CAST(0x0000A5DC017EDB0A AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3, 1, 2, N'PX000001', 0, 3, 1, N'Bán hàng PX000001', 1, CAST(0x0000A5DC017F4932 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (4, 1, 2, N'PX000002', 0, 2, -1, N'Bán hàng PX000002', 1, CAST(0x0000A5DC017F6A90 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (5, 1, 1, N'PX000003', 0, 1, 5, N'Bán hàng PX000003', 1, CAST(0x0000A5DC017F977B AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (6, 1, 1, N'PX000004', 0, 2, 3, N'Bán hàng PX000004', 1, CAST(0x0000A5DC0186227A AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (7, 1, 1, N'PX000005', 0, 1, 2, N'Bán hàng PX000005', 1, CAST(0x0000A5DD00093BCD AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (8, 2, 1, N'PN000003', 4, 0, 4, N'Nhập kho PN000003', 1, CAST(0x0000A5DD001B12B8 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (9, 1, 1, N'PKK000009', 1, -1, 3, N'Nhập kiểm kê PKK000009', 1, CAST(0x0000A5DE0168A900 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (10, 2, 1, N'PKK000007', 6, -6, 10, N'Nhập kiểm kê PKK000007', 1, CAST(0x0000A5DE01770EE6 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (11, 2, 1, N'PKK000006', 0, 4, 6, N'Xuất kiểm kê PKK000006', 1, CAST(0x0000A5DE01776811 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (12, 2, 1, N'PKK000010', 1, 0, 7, N'Nhập kiểm kê PKK000010', 1, CAST(0x0000A5DE0177DDFD AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (13, 2, 2, N'PKK000011', 3, 0, 3, N'Nhập kiểm kê PKK000011', 1, CAST(0x0000A5DE0177FE5E AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (14, 1, 1, N'PCK000002', 0, 1, 2, N'Chuyển kho đi PCK000002', 1, CAST(0x0000A5DF0188B576 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (15, 1, 1, N'PCK000002', 1, 0, 0, N'Chuyển kho từ PCK000002', 1, CAST(0x0000A5DF0188B576 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (16, 1, 1, N'PCK000003', 0, 1, 1, N'Chuyển kho đi PCK000003', 1, CAST(0x0000A5DF018A514F AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (17, 1, 2, N'PCK000003', 1, 0, 1, N'Chuyển kho từ PCK000003', 1, CAST(0x0000A5DF018A514F AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (18, 1, 1, N'PX000006', 0, 1, 0, N'Bán hàng PX000006', 1, CAST(0x0000A5E2018450F0 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (19, 2, 1, N'PX000007', 0, 1, 6, N'Bán hàng PX000007', 1, CAST(0x0000A5E300870EEB AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (20, 1, 2, N'PX000008', 0, 1, 0, N'Bán hàng PX000008', 1, CAST(0x0000A5E401265034 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1019, 2, 2, N'PX001008', 0, 1, 2, N'Bán hàng PX001008', 1, CAST(0x0000A5E40164A931 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1020, 2, 1, N'PCK000005', 1, 0, 7, N'Chuyển kho từ PCK000005', 1, CAST(0x0000A5E40171B7AB AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1021, 2, 2, N'PCK000005', 0, 1, 1, N'Chuyển kho đi PCK000005', 1, CAST(0x0000A5E40171B7AB AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1022, 2, 2, N'PXS001009', 0, 1, 0, N'Bán hàng PXS001009', 1, CAST(0x0000A5E501688397 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1023, 1, 1, N'PN000004', 5, 0, 5, N'Nhập kho PN000004', 1, CAST(0x0000A5E50172AA7E AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1024, 2, 1, N'PX000007', 1, 0, 8, N'Hủy đơn hàng PX000007', 1, CAST(0x0000A5E7016E4F63 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1025, 1, 2, N'PKK000013', 2, 0, 2, N'Nhập kiểm kê PKK000013', 1, CAST(0x0000A5ED015938D5 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1026, 1, 1, N'PCK000006', 2, 0, 7, N'Chuyển kho từ PCK000006', 1, CAST(0x0000A5ED015A681E AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (1027, 1, 2, N'PCK000006', 0, 2, 0, N'Chuyển kho đi PCK000006', 1, CAST(0x0000A5ED015A681E AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2025, 2, 1, N'PX001010', 0, 2, 6, N'Bán hàng PX001010', 1, CAST(0x0000A5F200C36A0D AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2026, 1, 1, N'PN000005', 1, 0, 8, N'Nhập kho PN000005', 1, CAST(0x0000A5F201511B07 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2027, 3, 2, N'PN000006', 1, 0, 1, N'Nhập kho PN000006', 1, CAST(0x0000A5F2015138DD AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2028, 1, 2, N'PX001011', 0, 1, -1, N'Bán hàng PX001011', 1, CAST(0x0000A5F201515B12 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2029, 1, 1, N'PN000004', 0, 5, 3, N'Hủy phiếu nhập kho PN000004', 1, CAST(0x0000A5F3015907CB AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2030, 1, 1, N'PX001012', 0, 1, 2, N'Bán hàng PX001012', 1, CAST(0x0000A5F3016A32DF AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2031, 1, 1, N'PX001013', 0, 1, 1, N'Bán hàng PX001013', 1, CAST(0x0000A5F601531343 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (2032, 3, 1, N'PXS003014', 0, 1, -1, N'Bán hàng PXS003014', 1, CAST(0x0000A5F9009B2FDD AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3032, 1, 1, N'PX004014', 0, 1, 0, N'Bán hàng PX004014', 1, CAST(0x0000A5F900ADCD03 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3033, 1, 1, N'PXS004015', 0, 1, -1, N'Bán hàng PXS004015', 1, CAST(0x0000A5F900AE1646 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3034, 2, 1, N'PXS004016', 0, 1, 5, N'Bán hàng PXS004016', 1, CAST(0x0000A5F900B5EE15 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3035, 3, 1, N'PXS004016', 0, 2, -3, N'Bán hàng PXS004016', 1, CAST(0x0000A5F900B5EE1D AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3036, 2, 1, N'PX004017', 0, 2, 3, N'Bán hàng PX004017', 1, CAST(0x0000A5F900B89DDC AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3037, 3, 1, N'PX004017', 0, 2, -5, N'Bán hàng PX004017', 1, CAST(0x0000A5F900B89DE3 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3038, 2, 1, N'PXS004020', 0, 2, 1, N'Bán hàng PXS004020', 1, CAST(0x0000A5F9014258EC AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3039, 1, 1, N'PXS004020', 0, 1, -2, N'Bán hàng PXS004020', 1, CAST(0x0000A5F901425917 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3040, 1, 1, N'PX004019', 0, 1, -3, N'Bán hàng PX004019', 1, CAST(0x0000A5F901425F59 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3041, 2, 1, N'PX004019', 0, 1, 0, N'Bán hàng PX004019', 1, CAST(0x0000A5F901425F60 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3042, 1, 1, N'PX004018', 0, 1, -4, N'Bán hàng PX004018', 1, CAST(0x0000A5F9014265D0 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3043, 1, 1, N'PX004021', 0, 1, -5, N'Bán hàng PX004021', 1, CAST(0x0000A5FA017DECF7 AS DateTime))
INSERT [dbo].[T_Trans_ProductQuantity_History] ([Id], [ProductId], [StoreId], [ReferNo], [NumIn], [NumOut], [NumRemain], [Description], [CreatedBy], [CreatedDate]) VALUES (3044, 1, 1, N'PKK001013', 7, 0, 2, N'Nhập kiểm kê PKK001013', 1, CAST(0x0000A5FB00FB9E88 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_ProductQuantity_History] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Products] ON 

INSERT [dbo].[T_Trans_Products] ([ProductId], [ProductName], [ProductCode], [Quantity], [Price], [Cost], [ProductGroup], [ProducerId], [Image], [TrackInventory], [AllowNegative], [VAT], [AllowMin], [AllowMax], [IsManageAsSerial], [IsManageAttribute], [Description], [IsSelling], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [LastBoughtDate]) VALUES (1, N'Áo thun', N'HH000001', 1, 110000.0000, 90000.0000, NULL, NULL, N'', 1, 1, 0, 0, 100, 0, 0, N'', 1, 1, 1, 1, CAST(0x0000A5DC017E8615 AS DateTime), 1, CAST(0x0000A5FB00FB9E87 AS DateTime), CAST(0x0000A5FA017DECF7 AS DateTime))
INSERT [dbo].[T_Trans_Products] ([ProductId], [ProductName], [ProductCode], [Quantity], [Price], [Cost], [ProductGroup], [ProducerId], [Image], [TrackInventory], [AllowNegative], [VAT], [AllowMin], [AllowMax], [IsManageAsSerial], [IsManageAttribute], [Description], [IsSelling], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [LastBoughtDate]) VALUES (2, N'Áo tay dài', N'HH000002', 0, 250000.0000, 200000.0000, 1, NULL, NULL, 1, 1, 0, 0, 100, 0, 0, N'', 1, 1, 1, 1, CAST(0x0000A5DD001AF58A AS DateTime), 1, CAST(0x0000A5F901425F60 AS DateTime), CAST(0x0000A5F901425F60 AS DateTime))
INSERT [dbo].[T_Trans_Products] ([ProductId], [ProductName], [ProductCode], [Quantity], [Price], [Cost], [ProductGroup], [ProducerId], [Image], [TrackInventory], [AllowNegative], [VAT], [AllowMin], [AllowMax], [IsManageAsSerial], [IsManageAttribute], [Description], [IsSelling], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [LastBoughtDate]) VALUES (3, N'Ao thun la', N'HH000003', -4, 200000.0000, 100000.0000, NULL, NULL, NULL, 1, 1, 0, 0, 100, 0, 1, N'', 1, 1, 1, 1, CAST(0x0000A5E60150D861 AS DateTime), 1, CAST(0x0000A5F900B89DE3 AS DateTime), CAST(0x0000A5F900B89DE3 AS DateTime))
INSERT [dbo].[T_Trans_Products] ([ProductId], [ProductName], [ProductCode], [Quantity], [Price], [Cost], [ProductGroup], [ProducerId], [Image], [TrackInventory], [AllowNegative], [VAT], [AllowMin], [AllowMax], [IsManageAsSerial], [IsManageAttribute], [Description], [IsSelling], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [LastBoughtDate]) VALUES (4, N'Ao thun la - Copy', N'HH000004', 0, 200000.0000, 100000.0000, NULL, NULL, NULL, 1, 1, 0, 0, 100, 0, 1, N'', 0, 0, 1, 1, CAST(0x0000A5E601840B80 AS DateTime), 1, CAST(0x0000A5FB00A74681 AS DateTime), CAST(0x0000A5E601840B82 AS DateTime))
INSERT [dbo].[T_Trans_Products] ([ProductId], [ProductName], [ProductCode], [Quantity], [Price], [Cost], [ProductGroup], [ProducerId], [Image], [TrackInventory], [AllowNegative], [VAT], [AllowMin], [AllowMax], [IsManageAsSerial], [IsManageAttribute], [Description], [IsSelling], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [LastBoughtDate]) VALUES (5, N'Ao thun la - Copy -Copy', N'HH000005', 0, 200000.0000, 100000.0000, NULL, NULL, NULL, 1, 0, 0, 0, 100, 0, 1, N'', 0, 0, 1, 1, CAST(0x0000A5E60184FFFA AS DateTime), 1, CAST(0x0000A5F60167380E AS DateTime), CAST(0x0000A5E60184FFFC AS DateTime))
INSERT [dbo].[T_Trans_Products] ([ProductId], [ProductName], [ProductCode], [Quantity], [Price], [Cost], [ProductGroup], [ProducerId], [Image], [TrackInventory], [AllowNegative], [VAT], [AllowMin], [AllowMax], [IsManageAsSerial], [IsManageAttribute], [Description], [IsSelling], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [LastBoughtDate]) VALUES (6, N'Áo jean''', N'HH000006', 0, 210000.0000, 190000.0000, 1, 1, NULL, 1, 1, 0, 0, 110, 0, 0, N'Thesr', 1, 1, 14, 1, CAST(0x0000A5EA011B7503 AS DateTime), 1, CAST(0x0000A5FB0102C0A0 AS DateTime), CAST(0x0000A5EA011B7541 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Products] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Purchase] ON 

INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, N'PN000001', 1, 2, 6, CAST(0x0000A5DC017EAB60 AS DateTime), 1, NULL, N'', 1, 540000.0000, 0.0000, 140000.0000, 400000.0000, 1, 1, 1, CAST(0x0000A5DC017EAB5F AS DateTime), 1, CAST(0x0000A5F20150FF11 AS DateTime))
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, N'PN000002', 2, 2, 4, CAST(0x0000A5DC017EDAF1 AS DateTime), 1, NULL, N'', 1, 360000.0000, 0.0000, 0.0000, 360000.0000, 1, 1, 1, CAST(0x0000A5DC017EDAF1 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, N'PN000003', 1, 2, 4, CAST(0x0000A5DD001B128D AS DateTime), 1, NULL, N'', 1, 800000.0000, 0.0000, 800000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5DD001B128C AS DateTime), 1, CAST(0x0000A5F800E75DED AS DateTime))
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, N'PN000004', 1, 2, 5, CAST(0x0000A5E50172AA5B AS DateTime), 1, 1, N'', 1, 450000.0000, 0.0000, 450000.0000, 0.0000, 0, 1, 1, CAST(0x0000A5E50172AA42 AS DateTime), 1, CAST(0x0000A5F3015907C4 AS DateTime))
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, N'PN000005', 1, 2, 1, CAST(0x0000A5F201511A4D AS DateTime), 1, NULL, N'', 1, 90000.0000, 0.0000, 0.0000, 90000.0000, 1, 1, 1, CAST(0x0000A5F201511A44 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, N'PN000006', 2, 2, 1, CAST(0x0000A5F2015138CB AS DateTime), 1, NULL, N'', 2, 100000.0000, 0.0000, 100000.0000, 0.0000, 1, 1, 1, CAST(0x0000A5F2015138BC AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, N'PN000007', 1, 1, 1, NULL, 1, NULL, N'', 1, 90000.0000, 0.0000, 0.0000, 90000.0000, 0, 1, 1, CAST(0x0000A5F7016F1FF5 AS DateTime), 1, CAST(0x0000A5F70175ADC1 AS DateTime))
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, N'PN000008', 1, 1, 1, NULL, 1, NULL, N'', 1, 90000.0000, 0.0000, 0.0000, 90000.0000, 1, 2, 1, CAST(0x0000A5F7016F3483 AS DateTime), 1, CAST(0x0000A5FB00FB47AC AS DateTime))
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, N'PN000009', 1, 1, 1, NULL, 1, NULL, N'', 1, 90000.0000, 0.0000, 0.0000, 90000.0000, 1, 1, 1, CAST(0x0000A5F7016F8676 AS DateTime), 1, CAST(0x0000A5FB00C6E6F6 AS DateTime))
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, N'PN000010', 1, 1, 1, NULL, 1, NULL, N'', 1, 90000.0000, 0.0000, 0.0000, 90000.0000, 1, 1, 1, CAST(0x0000A5F7016FBEAA AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase] ([PurchaseId], [PurchaseCode], [StoreId], [StatusId], [Quantity], [PurchaseDate], [Purchaser], [SupplierId], [Notes], [PaymentType], [SumMoney], [SumTax], [Paid], [Debt], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, N'PN000011', 1, 1, 1, NULL, 1, NULL, N'', 1, 90000.0000, 0.0000, 0.0000, 90000.0000, 1, 1, 1, CAST(0x0000A5FB00FAB4F9 AS DateTime), 1, CAST(0x0000A5FB00FABF31 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Purchase] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Purchase_Payment] ON 

INSERT [dbo].[T_Trans_Purchase_Payment] ([PaymentId], [PurchaseId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 1, 1, 3, 40000.0000, 1, 1, 1, CAST(0x0000A5F200DA4CB4 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Payment] ([PaymentId], [PurchaseId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 1, 1, 1, 50000.0000, 1, 1, 1, CAST(0x0000A5F200DAA43F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Payment] ([PaymentId], [PurchaseId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 4, 1, 1, 450000.0000, 1, 1, 1, CAST(0x0000A5F200DADDC3 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Payment] ([PaymentId], [PurchaseId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 1, 1, 1, 50000.0000, 1, 1, 1, CAST(0x0000A5F20150FF0F AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Payment] ([PaymentId], [PurchaseId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 6, 2, 2, 100000.0000, 1, 1, 1, CAST(0x0000A5F2015138CB AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Payment] ([PaymentId], [PurchaseId], [StoreId], [PaymentType], [Amount], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, 3, 1, 1, 800000.0000, 1, 1, 1, CAST(0x0000A5F800E75DD2 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Trans_Purchase_Payment] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Purchase_Product] ON 

INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 1, 1, 100000.0000, 90000.0000, 6, 0, 1, 1, CAST(0x0000A5DC017EAB7C AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 1, 2, 100000.0000, 90000.0000, 4, 0, 1, 1, CAST(0x0000A5DC017EDB05 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 2, 3, 250000.0000, 200000.0000, 4, 0, 1, 1, CAST(0x0000A5DD001B12AE AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 1, 4, 110000.0000, 90000.0000, 5, 0, 1, 1, CAST(0x0000A5E50172AA6E AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 1, 5, 110000.0000, 90000.0000, 1, 0, 1, 1, CAST(0x0000A5F201511AF1 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (6, 3, 6, 200000.0000, 100000.0000, 1, 0, 1, 1, CAST(0x0000A5F2015138DD AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (7, 1, 7, 110000.0000, 90000.0000, 1, 0, 1, 1, CAST(0x0000A5F7016F2052 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (8, 1, 8, 110000.0000, 90000.0000, 1, 0, 2, 1, CAST(0x0000A5F7016F349B AS DateTime), 1, CAST(0x0000A5FB00FB48AF AS DateTime))
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (9, 1, 9, 110000.0000, 90000.0000, 1, 0, 1, 1, CAST(0x0000A5F7016F8699 AS DateTime), 1, CAST(0x0000A5FB00C6E704 AS DateTime))
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (10, 1, 10, 110000.0000, 90000.0000, 1, 0, 1, 1, CAST(0x0000A5F7016FBEC4 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Purchase_Product] ([Id], [ProductId], [PurchaseId], [Price], [Cost], [Quantity], [VAT], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (11, 1, 11, 110000.0000, 90000.0000, 1, 0, 2, 1, CAST(0x0000A5FB00FAB522 AS DateTime), 1, CAST(0x0000A5FB00FABF42 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Purchase_Product] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_Receivement] ON 

INSERT [dbo].[T_Trans_Receivement] ([Id], [Cashier], [StoreId], [Amount], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (1, 1, 2, 50000.0000, NULL, 1, CAST(0x0000A5F100AA4186 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Receivement] ([Id], [Cashier], [StoreId], [Amount], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 1, 1, 100000.0000, NULL, 1, CAST(0x0000A5F100AACC94 AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Receivement] ([Id], [Cashier], [StoreId], [Amount], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 1, 2, 100000.0000, NULL, 1, CAST(0x0000A5F100ACED5D AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Receivement] ([Id], [Cashier], [StoreId], [Amount], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 1, 1, 50000.0000, NULL, 1, CAST(0x0000A5F20184B6AB AS DateTime), NULL, NULL)
INSERT [dbo].[T_Trans_Receivement] ([Id], [Cashier], [StoreId], [Amount], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 1, 1, 50000.0000, 1, 1, CAST(0x0000A5FB00FBDAB0 AS DateTime), 1, CAST(0x0000A5FB00FBDAB0 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_Trans_Receivement] OFF
SET IDENTITY_INSERT [dbo].[T_Trans_User_Store] ON 

INSERT [dbo].[T_Trans_User_Store] ([Id], [UserId], [StoreId], [RoleId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (2, 1, 1, 4, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_Trans_User_Store] ([Id], [UserId], [StoreId], [RoleId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (3, 1, 1, 5, 1, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_Trans_User_Store] ([Id], [UserId], [StoreId], [RoleId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (4, 1, 2, 4, 0, 1, 1, NULL, NULL, NULL)
INSERT [dbo].[T_Trans_User_Store] ([Id], [UserId], [StoreId], [RoleId], [IsActive], [Version], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]) VALUES (5, 1, 2, 5, 1, 1, 1, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[T_Trans_User_Store] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Master_Customers]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Master_Customers] ON [dbo].[T_Master_Customers]
(
	[CustomerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Master_Suppliers]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Master_Suppliers] ON [dbo].[T_Master_Suppliers]
(
	[SupplierCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_System_Log_Config]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_System_Log_Config] ON [dbo].[T_System_Log_Config]
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_System_Object_Freze_Condition]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_System_Object_Freze_Condition] ON [dbo].[T_System_Object_Freze_Condition]
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_Cost]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Trans_Cost] ON [dbo].[T_Trans_Cost]
(
	[CostCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_InventTran]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Trans_InventTran] ON [dbo].[T_Trans_InventTran]
(
	[InventTranCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_Orders]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Trans_Orders] ON [dbo].[T_Trans_Orders]
(
	[OrderCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_Products]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE NONCLUSTERED INDEX [IX_T_Trans_Products] ON [dbo].[T_Trans_Products]
(
	[ProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_T_Trans_Purchase]    Script Date: 5/3/2016 3:50:23 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_T_Trans_Purchase] ON [dbo].[T_Trans_Purchase]
(
	[PurchaseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Master_Customers] ADD  CONSTRAINT [DF_T_Master_Customers_IsWholeSale]  DEFAULT ((0)) FOR [IsWholeSale]
GO
ALTER TABLE [dbo].[T_Master_ProductGroups]  WITH CHECK ADD  CONSTRAINT [FK_T_Master_ProductGroups_T_Master_ProductGroups] FOREIGN KEY([ParentId])
REFERENCES [dbo].[T_Master_ProductGroups] ([ProductGroupId])
GO
ALTER TABLE [dbo].[T_Master_ProductGroups] CHECK CONSTRAINT [FK_T_Master_ProductGroups_T_Master_ProductGroups]
GO
ALTER TABLE [dbo].[T_System_Data_Log]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Data_Log_T_Master_User] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_System_Data_Log] CHECK CONSTRAINT [FK_T_System_Data_Log_T_Master_User]
GO
ALTER TABLE [dbo].[T_System_Exception_Log]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Exception_Log_T_Master_User] FOREIGN KEY([Hero])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_System_Exception_Log] CHECK CONSTRAINT [FK_T_System_Exception_Log_T_Master_User]
GO
ALTER TABLE [dbo].[T_System_Exception_Log]  WITH CHECK ADD  CONSTRAINT [FK_T_System_Exception_Log_T_Master_User1] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_System_Exception_Log] CHECK CONSTRAINT [FK_T_System_Exception_Log_T_Master_User1]
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
ALTER TABLE [dbo].[T_Trans_Cost]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Cost_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Cost] CHECK CONSTRAINT [FK_T_Trans_Cost_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Cost]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Cost_T_Master_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Cost] CHECK CONSTRAINT [FK_T_Trans_Cost_T_Master_User]
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
ALTER TABLE [dbo].[T_Trans_Inventory]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Inventory_T_Trans_Inventory] FOREIGN KEY([StatusId])
REFERENCES [dbo].[T_Master_InventoryStatus] ([StatusId])
GO
ALTER TABLE [dbo].[T_Trans_Inventory] CHECK CONSTRAINT [FK_T_Trans_Inventory_T_Trans_Inventory]
GO
ALTER TABLE [dbo].[T_Trans_Inventory_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Inventory_Product_T_Trans_Inventory] FOREIGN KEY([InventoryId])
REFERENCES [dbo].[T_Trans_Inventory] ([InventoryId])
GO
ALTER TABLE [dbo].[T_Trans_Inventory_Product] CHECK CONSTRAINT [FK_T_Trans_Inventory_Product_T_Trans_Inventory]
GO
ALTER TABLE [dbo].[T_Trans_Inventory_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Inventory_Product_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_Inventory_Product] CHECK CONSTRAINT [FK_T_Trans_Inventory_Product_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_InventTran]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_T_Master_InventTranStatus] FOREIGN KEY([StatusId])
REFERENCES [dbo].[T_Master_InventTranStatus] ([StatusId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran] CHECK CONSTRAINT [FK_T_Trans_InventTran_T_Master_InventTranStatus]
GO
ALTER TABLE [dbo].[T_Trans_InventTran]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_T_Master_Stores] FOREIGN KEY([FromStoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran] CHECK CONSTRAINT [FK_T_Trans_InventTran_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_InventTran]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_T_Master_Stores1] FOREIGN KEY([ToStoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran] CHECK CONSTRAINT [FK_T_Trans_InventTran_T_Master_Stores1]
GO
ALTER TABLE [dbo].[T_Trans_InventTran]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_T_Master_User] FOREIGN KEY([TransferId])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran] CHECK CONSTRAINT [FK_T_Trans_InventTran_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_InventTran]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_T_Master_User1] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran] CHECK CONSTRAINT [FK_T_Trans_InventTran_T_Master_User1]
GO
ALTER TABLE [dbo].[T_Trans_InventTran_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_Product_T_Trans_InventTran] FOREIGN KEY([InventTranId])
REFERENCES [dbo].[T_Trans_InventTran] ([InventTranId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran_Product] CHECK CONSTRAINT [FK_T_Trans_InventTran_Product_T_Trans_InventTran]
GO
ALTER TABLE [dbo].[T_Trans_InventTran_Product]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_InventTran_Product_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_InventTran_Product] CHECK CONSTRAINT [FK_T_Trans_InventTran_Product_T_Trans_Products]
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
ALTER TABLE [dbo].[T_Trans_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Payment_T_Master_PaymentType] FOREIGN KEY([PaymentType])
REFERENCES [dbo].[T_Master_PaymentType] ([PaymentId])
GO
ALTER TABLE [dbo].[T_Trans_Payment] CHECK CONSTRAINT [FK_T_Trans_Payment_T_Master_PaymentType]
GO
ALTER TABLE [dbo].[T_Trans_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Payment_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Payment] CHECK CONSTRAINT [FK_T_Trans_Payment_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Payment_T_Master_User] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Payment] CHECK CONSTRAINT [FK_T_Trans_Payment_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Payment_T_Trans_Orders] FOREIGN KEY([OrderId])
REFERENCES [dbo].[T_Trans_Orders] ([OrderId])
GO
ALTER TABLE [dbo].[T_Trans_Payment] CHECK CONSTRAINT [FK_T_Trans_Payment_T_Trans_Orders]
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
ALTER TABLE [dbo].[T_Trans_Product_Store]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Product_Store_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Product_Store] CHECK CONSTRAINT [FK_T_Trans_Product_Store_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Product_Store]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Product_Store_T_Trans_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[T_Trans_Products] ([ProductId])
GO
ALTER TABLE [dbo].[T_Trans_Product_Store] CHECK CONSTRAINT [FK_T_Trans_Product_Store_T_Trans_Products]
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
ALTER TABLE [dbo].[T_Trans_ProductQuantity_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_ProductQuantity_History_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_ProductQuantity_History] CHECK CONSTRAINT [FK_T_Trans_ProductQuantity_History_T_Master_Stores]
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
ALTER TABLE [dbo].[T_Trans_Purchase_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_Payment_T_Master_PaymentType] FOREIGN KEY([PaymentType])
REFERENCES [dbo].[T_Master_PaymentType] ([PaymentId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment] CHECK CONSTRAINT [FK_T_Trans_Purchase_Payment_T_Master_PaymentType]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_Payment_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment] CHECK CONSTRAINT [FK_T_Trans_Purchase_Payment_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Purchase_Payment_T_Trans_Purchase] FOREIGN KEY([PurchaseId])
REFERENCES [dbo].[T_Trans_Purchase] ([PurchaseId])
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment] CHECK CONSTRAINT [FK_T_Trans_Purchase_Payment_T_Trans_Purchase]
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
ALTER TABLE [dbo].[T_Trans_Receivement]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Receivement_T_Master_Stores] FOREIGN KEY([StoreId])
REFERENCES [dbo].[T_Master_Stores] ([StoreId])
GO
ALTER TABLE [dbo].[T_Trans_Receivement] CHECK CONSTRAINT [FK_T_Trans_Receivement_T_Master_Stores]
GO
ALTER TABLE [dbo].[T_Trans_Receivement]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Receivement_T_Master_User] FOREIGN KEY([Cashier])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Receivement] CHECK CONSTRAINT [FK_T_Trans_Receivement_T_Master_User]
GO
ALTER TABLE [dbo].[T_Trans_Receivement]  WITH CHECK ADD  CONSTRAINT [FK_T_Trans_Receivement_T_Master_User1] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[T_Master_User] ([UserId])
GO
ALTER TABLE [dbo].[T_Trans_Receivement] CHECK CONSTRAINT [FK_T_Trans_Receivement_T_Master_User1]
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
ALTER TABLE [dbo].[T_Trans_Cost]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Cost] CHECK  (([Amount]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Cost] CHECK CONSTRAINT [CK_T_Trans_Cost]
GO
ALTER TABLE [dbo].[T_Trans_InventTran]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_InventTran] CHECK  (([FromStoreId]<>[ToStoreId]))
GO
ALTER TABLE [dbo].[T_Trans_InventTran] CHECK CONSTRAINT [CK_T_Trans_InventTran]
GO
ALTER TABLE [dbo].[T_Trans_InventTran_Product]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_InventTran_Product] CHECK  (([Quantity]>(0) AND [TranQuantity]>(0) AND [Quantity]>=[TranQuantity]))
GO
ALTER TABLE [dbo].[T_Trans_InventTran_Product] CHECK CONSTRAINT [CK_T_Trans_InventTran_Product]
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
ALTER TABLE [dbo].[T_Trans_Orders]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Orders_1] CHECK  (([Paid]>=(0) AND [DebtMoney]>=(0) AND [Paid]<=[SumMoney] AND [DebtMoney]<=[SumMoney]))
GO
ALTER TABLE [dbo].[T_Trans_Orders] CHECK CONSTRAINT [CK_T_Trans_Orders_1]
GO
ALTER TABLE [dbo].[T_Trans_Payment]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Payment] CHECK  (([Amount]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Payment] CHECK CONSTRAINT [CK_T_Trans_Payment]
GO
ALTER TABLE [dbo].[T_Trans_Product_Store]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Product_Store] CHECK  (([AllowNegative]=(1) OR [AllowNegative]=(0) AND [Quantity]>=(0)))
GO
ALTER TABLE [dbo].[T_Trans_Product_Store] CHECK CONSTRAINT [CK_T_Trans_Product_Store]
GO
ALTER TABLE [dbo].[T_Trans_Products]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Products] CHECK  (([AllowMax]>=[AllowMin]))
GO
ALTER TABLE [dbo].[T_Trans_Products] CHECK CONSTRAINT [CK_T_Trans_Products]
GO
ALTER TABLE [dbo].[T_Trans_Products]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Products_1] CHECK  (([AllowNegative]=(1) OR [AllowNegative]=(0) AND [Quantity]>=(0)))
GO
ALTER TABLE [dbo].[T_Trans_Products] CHECK CONSTRAINT [CK_T_Trans_Products_1]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Purchase_Payment] CHECK  (([Amount]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Payment] CHECK CONSTRAINT [CK_T_Trans_Purchase_Payment]
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Purchase_Product] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Purchase_Product] CHECK CONSTRAINT [CK_T_Trans_Purchase_Product]
GO
ALTER TABLE [dbo].[T_Trans_Receivement]  WITH CHECK ADD  CONSTRAINT [CK_T_Trans_Receivement] CHECK  (([Amount]>(0)))
GO
ALTER TABLE [dbo].[T_Trans_Receivement] CHECK CONSTRAINT [CK_T_Trans_Receivement]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tối thiểu bán 1 sản phẩm' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_Trans_Order_Product', @level2type=N'CONSTRAINT',@level2name=N'CK_T_Trans_Order_Product'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Check discount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_Trans_Order_Product', @level2type=N'CONSTRAINT',@level2name=N'CK_T_Trans_Order_Product_2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[11] 4[5] 2[67] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_System_Data_Log'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_System_Data_Log'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_System_Role_User_Mapping"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_System_Role_User_Mapping'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_System_Role_User_Mapping'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ObjectDef"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Mapping"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ObjMap"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_System_User_Mapping_Filter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_System_User_Mapping_Filter'
GO
USE [master]
GO
ALTER DATABASE [StoreManagement] SET  READ_WRITE 
GO
