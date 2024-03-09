-- Relational Model

--1. Nurse

CREATE SEQUENCE Seq_Nurse
START WITH 100
INCREMENT BY 1;
GO

CREATE TABLE Nurse
(
	NurseID INT DEFAULT NEXT VALUE FOR Seq_Nurse NOT NULL,
	NurseUserName nvarchar(20) NOT NULL,
	NurseGroupName NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_NurseID PRIMARY KEY (NurseID)
);
GO
-- POPULATING Nurse tbl
INSERT INTO Nurse (NurseUserName,NurseGroupName)
(SELECT Completed_UserID,User_Group_Name FROM dbo.[Well_Being_RawData_200] 
GROUP BY Completed_UserID,User_Group_Name);

SELECT * FROM Nurse
------------------------------ X ---------------------------------- X ----------------------------------

--2. PatientStatus
CREATE SEQUENCE Seq_PatientStatus
START WITH 10
INCREMENT BY 1;
GO
CREATE TABLE PatientStatus
(
	StatusID INT NOT NULL DEFAULT NEXT VALUE FOR Seq_PatientStatus,
	StatusName NVARCHAR(40) NOT NULL,
	CONSTRAINT PK_PatientStatus PRIMARY KEY ( StatusID )
);
GO
INSERT INTO PatientStatus (StatusName)
(SELECT DISTINCT (FirstStatChange) FROM Well_Being_RawData);

INSERT INTO PatientStatus (StatusName)
VALUES ('New');

SELECT * FROM PatientStatus ORDER BY StatusID
------------------------------ X ---------------------------------- X ----------------------------------

--4. PatientType

CREATE SEQUENCE Seq_PatientType
START WITH 1000
INCREMENT BY 1;
GO
CREATE TABLE PatientType
(
	PatientTypeID INT NOT NULL DEFAULT NEXT VALUE FOR Seq_PatientType,
	PatientType NVARCHAR(20) NOT NULL,
	CONSTRAINT PK_PatientTypeID PRIMARY KEY (PatientTypeID),
	CONSTRAINT U_PatientType UNIQUE(PatientType)
)
GO
INSERT INTO PatientType(PatientType)
VALUES ('NEW');
INSERT INTO PatientType(PatientType)
VALUES ('EXISTING');
INSERT INTO PatientType(PatientType)
VALUES ('ACTIVE');
------------------------ X ------------------------------ X -------------------------------------

--5. PriorityType
CREATE SEQUENCE Seq_PriorityType
START WITH 100
INCREMENT BY 1;
GO
CREATE TABLE PriorityType
(
	PriorityTypeID INT NOT NULL DEFAULT NEXT VALUE FOR Seq_PriorityType,
	PriorityTypeName NVARCHAR(30) NOT NULL,
	CONSTRAINT PK_Priority_TypeID PRIMARY KEY ( PriorityTypeID ),
	CONSTRAINT U_Priority_Type_Name UNIQUE( PriorityTypeName )
);
GO

-- POPULATING PriorityType
INSERT INTO PriorityType(PriorityTypeName)
(SELECT DISTINCT (Priority) FROM Well_Being_RawData);

SELECT * FROM PriorityType ORDER BY PriorityTypeID
-------------------------- X -------------------------------- X --------------------------

--6. Department
CREATE SEQUENCE Seq_Department
START WITH 100
INCREMENT BY 1;
GO
CREATE TABLE Department
(
	DepartmentID INT NOT NULL DEFAULT NEXT VALUE FOR Seq_Department,
	DepartmentName NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_DepartmentID PRIMARY KEY (DepartmentID),
	CONSTRAINT U_DepartmentName UNIQUE(DepartmentName)
);
GO

--Populating Department Tbl
INSERT INTO Department(DepartmentName)
(SELECT DISTINCT(Referral_Category) FROM [Well_Being_RawData_200]);

SELECT * FROM Department ORDER BY DepartmentID
------------------------------- X --------------------------------- X ---------------------------------------


--7. Locations
CREATE SEQUENCE Seq_Location
START WITH 100
INCREMENT BY 1;
GO
CREATE TABLE Locations
(
	LocationID INT NOT NULL DEFAULT NEXT VALUE FOR Seq_Location,
	LocationName NVARCHAR(10) NOT NULL
	CONSTRAINT PK_LocationID PRIMARY KEY (LocationID),
	CONSTRAINT U_DepartmentLocation UNIQUE(LocationName)
);
GO
--- POPULATING Location tbl
INSERT INTO Locations (LocationName)
(SELECT DISTINCT Location FROM [Well_Being_RawData_200]);

select * from Locations order by LocationID
-------------------------------- X-------------------------------- X-------------------------------

--8. DepartmentLocation
CREATE SEQUENCE Seq_DepartmentLocation
START WITH 100
INCREMENT BY 1;
GO
CREATE TABLE DepartmentLocation
(
	DepartmentLocationID INT DEFAULT NEXT VALUE FOR Seq_DepartmentLocation,
	DepartmentID INT NOT NULL,
	LocationID INT NOT NULL,
	CONSTRAINT PK_DepartmentLocationID PRIMARY KEY (DepartmentLocationID),
	CONSTRAINT FK_DepartmentLocation_DepartmentID FOREIGN KEY (DepartmentID) REFERENCES dbo.Department ( DepartmentID ),
	CONSTRAINT FK_DepartmentLocation_LocationID FOREIGN KEY (LocationID) REFERENCES dbo.Locations ( LocationID )
);
GO

INSERT INTO DepartmentLocation (DepartmentID,LocationID)
	(
		SELECT dep.DepartmentID,loc.LocationID FROM [Well_Being_RawData_200] stg
		INNER JOIN Department dep
		ON dep.DepartmentName = stg.Referral_Category
		INNER JOIN Locations loc
		ON loc.LocationName = stg.Location
	);

SELECT * FROM DepartmentLocation ORDER BY DepartmentLocationID
-------------------------------- X -------------------------------------- X ------------------------------------------------

--9. Patient Table
CREATE TABLE Patient
(
	PatientID BIGINT PRIMARY KEY NOT NULL,
	PatientTypeID INT NOT NULL,
	PatientReferralCategoryID INT NOT NULL,
	LocationID INT NOT NULL,
	PriorityTypeID INT NOT NULL,
	PatientCurrentStatusID INT NOT NULL,
	CreatedAtWorkingHours NVARCHAR(20) NOT NULL,
	CreatedAtDateTime DATE DEFAULT GETDATE(),
	CreatedAtFY_Name NVARCHAR(10),
	DischargedWorkingHours NVARCHAR(20) NOT NULL, 
	CONSTRAINT FK_Patient_PatientTypeID FOREIGN KEY (PatientTypeID) REFERENCES dbo.PatientType ( PatientTypeID ),
	CONSTRAINT FK_Patient_DepartmentID FOREIGN KEY (PatientReferralCategoryID) REFERENCES dbo.Department ( DepartmentID ),
	CONSTRAINT FK_Patient_LocationID FOREIGN KEY (LocationID) REFERENCES dbo.Locations ( LocationID ),
	CONSTRAINT FK_Patient_PriorityTypeID  FOREIGN KEY (PriorityTypeID) REFERENCES dbo.PriorityType ( PriorityTypeID ),
	CONSTRAINT FK_Patient_PatientCurrentStatusID FOREIGN KEY (PatientCurrentStatusID) REFERENCES dbo.PatientStatus ( StatusID )
);
GO

--POPULATING PATIENT TBL
INSERT INTO Patient (PatientID,PatientTypeID,PatientReferralCategoryID,LocationID,PriorityTypeID,PatientCurrentStatusID,
	CreatedAtWorkingHours,CreatedAtDateTime,CreatedAtFY_Name,DischargedWorkingHours)
	(
		SELECT stg.ClientID,p_type.PatientTypeID,dept.DepartmentID,loc.LocationID,priority_type.PriorityTypeID,
		p_status.StatusID,Work_OutsideDay,CreatedDateTime,stg.FYear_Name,Completed_Work_OutsideDay
		FROM [Well_Being_RawData_200] stg
		JOIN PatientType p_type
		ON stg.Patient = p_type.PatientType
		JOIN Department dept
		ON dept.DepartmentName = stg.Referral_Category
		JOIN Locations loc ON loc.LocationName = stg.Location
		JOIN PriorityType priority_type
		ON priority_type.PriorityTypeName = stg.Priority
		JOIN PatientStatus p_status
		ON p_status.StatusName = stg.LastStatChange
	)

SELECT * FROM Patient ORDER BY PatientID
-------------------------------- X -------------------------------------- X ------------------------------------------------

--3. Patient_PatientStatus

CREATE SEQUENCE Seq_Patient_PatientStatus
START WITH 100
INCREMENT BY 1;
GO
CREATE TABLE Patient_PatientStatus
(
	Patient_PatientStatusID INT NOT NULL DEFAULT NEXT VALUE FOR Seq_Patient_PatientStatus, 
	PatientID BIGINT NOT NULL,
	StatusID INT NOT NULL,
	Time_To_Status INT,
	MarkedCompletedByNurse INT,
	MarkedCompletedOnDate DATE,
	MarkedCompletedOnTime TIME,

	CONSTRAINT PK_Patient_PatientStatusID PRIMARY KEY (Patient_PatientStatusID),
	CONSTRAINT FK_Patient_PatientStatus_PatientID FOREIGN KEY (PatientID) REFERENCES dbo.Patient ( PatientID ),
	CONSTRAINT FK_Patient_PatientStatus_Patient_StatusID FOREIGN KEY (StatusID) REFERENCES dbo.PatientStatus ( StatusID ),
	CONSTRAINT FK_Patient_PatientStatus_MarkedCompletedByNurse FOREIGN KEY (MarkedCompletedByNurse) REFERENCES dbo.Nurse ( NurseID )
);
GO


--POPULATING Patient_Patientstatus
BEGIN
	WITH Patient_PatientStatus_CTE AS
	(
		SELECT stg.ClientID AS ClientID,StatNew,ps_new.StatusID [NewStatusID],
		TimeTo_NewStat as TimeTo_NewStat,FirstStatChange as FirstStatChange
		,ps_psa_review.StatusID [FirstStatChangeStatusID],
		TimeTo_FirstStatChange as TimeTo_FirstStatChange
		FROM [Well_Being_RawData_200] stg
		LEFT JOIN PatientStatus ps_new
		ON ps_new.StatusName = stg.StatNew
		LEFT JOIN PatientStatus ps_psa_review
		ON ps_psa_review.StatusName = stg.FirstStatChange
	)
	SELECT IDENTITY(INT,1,1) AS Temp_ID,* INTO Patient_Temp
	FROM (SELECT * FROM Patient_PatientStatus_CTE) as temp;

	Declare @RowNum INT,@TempID INT,@PatientID INT, @NewStat NVARCHAR(20),@NewStatID INT,@TimeToNewStat INT,
	@FirstStatChange NVARCHAR(20),@FirstStatChangeID INT,@TimeToFirstStatChange INT;

	select @TempID=MAX(Temp_ID) FROM Patient_Temp
	Select @RowNum = Count(*) From Patient_Temp      
	WHILE @RowNum > 0
	BEGIN
		SELECT @PatientID = ClientID,@FirstStatChange = FirstStatChange, @FirstStatChangeID = FirstStatChangeStatusID,
		@TimeToFirstStatChange = TimeTo_FirstStatChange,@NewStatID = NewStatusID,@TimeToNewStat = TimeTo_NewStat
		FROM Patient_Temp where Temp_ID = @TempID
		group by ClientID,FirstStatChange,FirstStatChangeStatusID,TimeTo_FirstStatChange,NewStatusID,
		TimeTo_NewStat;
				
		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@NewStatID,@TimeToNewStat);
		
		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@FirstStatChangeID,@TimeToFirstStatChange);

		select top 1 @TempID=Temp_ID from Patient_Temp where Temp_ID < @TempID order by Temp_ID DESC
		set @RowNum = @RowNum - 1
	END
	
	--DELETE TEMP TABLE
	DROP TABLE Patient_Temp;
END
GO


BEGIN	
	Declare @RowNum INT,@PatientID INT, @TimeTo_PSA_Review INT,@PSAReviewID INT = 22,@TimeTo_PSA_Accepted INT,
	@PSA_AcceptedID INT= 15,@TimeTo_Triaged INT, @TriagedID INT = 19,@TimeTo_CC_Accepted INT,@CC_AcceptedID INT = 17,
	@TimeTo_Awaiting_CallBack INT,@Awaiting_CallBackID INT = 21,@TimeTo_Completed INT,@CompletedID INT = 18,
	@CompletedDate DATE,@CompletedTime TIME,@NurseID INT;

	select @PatientID=MAX(ClientID) FROM [Well_Being_RawData_200]
	Select @RowNum = Count(*) From [Well_Being_RawData_200]      
	WHILE @RowNum > 0
	BEGIN
		SELECT @PatientID = ClientID,@TimeTo_PSA_Review = TimeTo_PSA_Review,
		@TimeTo_PSA_Accepted = TimeTo_PSA_Accepted,
		@TimeTo_Triaged = TimeTo_Triaged,@TimeTo_CC_Accepted = 
		TimeTo_CC_Accepted,@TimeTo_Awaiting_CallBack = TimeTo_Awaiting_CallBack,
		@TimeTo_Completed = TimeTo_Completed,@CompletedDate = cast(CompletedDateTime as date),@CompletedTime = FORMAT(CompletedDateTime ,'hh:mm:00'),
		@NurseID = (SELECT NurseID FROM Nurse where NurseUserName=Completed_UserID)
		FROM [Well_Being_RawData_200] where ClientID = @PatientID;
	
		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@PSAReviewID,@TimeTo_PSA_Review);
		
		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@PSA_AcceptedID,@TimeTo_PSA_Accepted);

		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@TriagedID,@TimeTo_Triaged);

		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@CC_AcceptedID,@TimeTo_CC_Accepted);

		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status) 
		VALUES (@PatientID,@Awaiting_CallBackID,@TimeTo_Awaiting_CallBack);
		
		INSERT INTO Patient_PatientStatus (PatientID,StatusID,Time_To_Status,MarkedCompletedByNurse,MarkedCompletedOnDate,MarkedCompletedOnTime) 
		VALUES (@PatientID,@CompletedID,@TimeTo_Completed,@NurseID,@CompletedDate,@CompletedTime);

		select top 1 @PatientID=ClientID from [Well_Being_RawData_200] where ClientID < @PatientID order by ClientID DESC
		set @RowNum = @RowNum - 1
	END
END	
GO

SELECT * FROM Patient_PatientStatus
------------------------------- X ------------------------------------ X -----------------------------------------------------------------



SELECT *  FROM Nurse
SELECT *  FROM PriorityType
SELECT *  FROM Department
SELECT *  FROM Locations
SELECT *  FROM DepartmentLocation
SELECT *  FROM PatientType 
SELECT *  FROM PatientStatus			
SELECT *  FROM Patient
SELECT * FROM Patient_PatientStatus


DROP TABLE Patient_PatientStatus
DROP TABLE Patient
DROP TABLE PatientStatus
DROP TABLE PatientType 
DROP TABLE DepartmentLocation
DROP TABLE Locations
DROP TABLE Department
DROP TABLE PriorityType
DROP TABLE Nurse



DROP SEQUENCE Seq_Nurse
DROP SEQUENCE Seq_PatientStatus
DROP SEQUENCE Seq_PatientType
DROP SEQUENCE Seq_PriorityType
DROP SEQUENCE Seq_Department
DROP SEQUENCE Seq_Location
DROP SEQUENCE Seq_DepartmentLocation
DROP SEQUENCE Seq_Patient_PatientStatus


--- LOADING INTO RAW_TABLE (10.000 RECORDS)
/*
DELETE FROM [dbo].[Well_Being_RawData_200]

INSERT INTO [dbo].[Well_Being_RawData_200]
(
	 [ClientID]			
	,[CreatedDateTime]	
	,[FYear_Name]		
	,[Work_OutsideDay]	
	,[StatNew]			
	,[TimeTo_NewStat]	
	,[FirstStatChange]	
	,[TimeTo_FirstStatChange]	
	,[TimeTo_PSA_Review]			
	,[TimeTo_PSA_Accepted]		
	,[TimeTo_Triaged]			
	,[TimeTo_CC_Accepted]		
	,[TimeTo_Awaiting_CallBack]  
	,[StatCompleted]				
	,[CompletedDateTime]			
	,[TimeTo_Completed]			
	,[Patient]					
	,[Priority]					
	,[Referral_Category]			
	,[Location]					
	,[Completed_UserID]			
	,[User_Group_Name]			
	,[Completed_Work_OutsideDay] 
	,[_1stStat_To_Triage_Hour]	
	,[_1stStat_To_Completed_Hour]
	,[TimeTo_Completed_Day]		
	,[LastStatChange]			
)


SELECT top 6594 * FROM [dbo].[Well_Being_RawData] where StatCompleted='Completed' --6594
SELECT * from [dbo].[Well_Being_RawData] where StatCompleted='In-Progress'   --3406


SELECT * FROM [dbo].[Well_Being_RawData_200]
*/






	

