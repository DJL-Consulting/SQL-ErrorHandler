USE [Utils]
GO

/****** Object:  Table [dbo].[SQL_Errors]    Script Date: 11/08/2022 10:53:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQL_Errors](
	[ErrorID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [nvarchar](200) NULL,
	[Object] [nvarchar](max) NULL,
	[UserName] [nvarchar](200) NULL,
	[ErrorNumber] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorLine] [int] NULL,
	[ErrorProcedure] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[ErrorDateTime] [datetime] NULL,
 CONSTRAINT [PK_SQL_Errors] PRIMARY KEY CLUSTERED 
(
	[ErrorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

