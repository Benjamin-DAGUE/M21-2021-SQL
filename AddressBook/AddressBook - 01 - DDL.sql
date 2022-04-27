--DDL : Data Definition Language
	--CREATE ALTER DROP

USE [master]	--Permet de s�lectionner la base cible pour les requ�tes
GO				--Permet d'indiquer au moteur SQL d'ex�cuter les requ�tes ci-dessus

IF EXISTS (SELECT TOP(1) 1 FROM sys.databases WHERE name = 'AddressBook')
BEGIN

	--On passe la base en mode mono-utilisateur (une seule session possible)
	--WITH ROLLBACK IMMEDIATE permet d'annuler les transactions incompl�tes en cours
	--le mode mono-utilisateur d�connecte automatiquement les autres sessions
	ALTER DATABASE [AddressBook] SET SINGLE_USER WITH ROLLBACK IMMEDIATE

	DROP DATABASE [AddressBook]
END

CREATE DATABASE [AddressBook]
ON PRIMARY --Fichier de donn�es
(
	NAME = AddressBook_dat --Nom logique du fichier
	,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AddressBook_dat.mdf' --Chemin physique
	,SIZE = 64MB --Taille initiale
	,FILEGROWTH = 64MB --Taille d'agrandissement lorsque la taille max est atteinte
	,MAXSIZE = UNLIMITED --Taille maximum
)
LOG ON --Fichier journal
(
	NAME = AddressBook_log
	,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AddressBook_log.ldf' --Chemin physique
	,SIZE = 512MB --Taille initiale
	,FILEGROWTH = 128MB --Taille d'agrandissement lorsque la taille max est atteinte
	,MAXSIZE = UNLIMITED --Taille maximum
)

GO

USE AddressBook
GO

/*
-> Cha�nes ASCII (1 octet par caract�re)
	CHAR(n) :		Taille fixe, ajout du caract�re de bourage ' ' pour combler l'espace. n >= 1 && <= 8000
	VARCHAR(n) :	Taille variable, n>= 1 && <= 8000
	VARCHAR(MAX) :	Limit� � 2Go. A �viter pour des raisons de performance.

-> Cha�nes UNICODE (2 octets par caract�re donc n >= 1 && <= 4000)
	NCHAR(n)
	NVARCHAR(n)
	NVARCHAR(MAX)

-> Valeur num�riques exactes :
	TYNIINT :		Entier sur 1 octet
	SMALLINT :		Entier sur 2 octets
	INT :			Entier sur 4 octets
	BIGINT :		Entier sur 8 octets
	NUMERIC(p,s) :	Similaire � DECIMAL(p,s)
	DECIMAL(p,s) :	D�cimal � vigule fixe ( de 5 � 17 octets)
					p d�signe le nombre de chiffres total (entre 1 et 38, 18 par d�faut)
					s d�signe le nombre de d�cimales apr�s la virgule (entre 0 et p)
	SMALLMONEY :	D�cimal mon�taire sur 4 octets
	MONEY :			D�cimal mon�taire sur 8 octets

	<!> Utilisez DECIMAL au lieu de SMALLMONEY et MONEY

-> Valeur num�rique approximatives
	FLOAT :	Flotant de 4 � 8 octets
	REAL :	Flotant de 4 octets

	<!> provoques des erreurs d'arrondi dans les calculs (gestion sous forme de fraction).

-> Date et heure :
	DATE :				Date du 01/01/0001 au 31/12/9999 sur 3 octets
	DATETIME2(f) :		Date du 01/01/0001 au 31/12/9999 et heures (de 6 � 8 octets)
						f st le nombre de chiffres apr�s la seconde (de 0 � 7, 7 par d�faut)
	DATETIMEOFFSET :	Ajoute au DATETIME2(f) le fuseau horraire (10 octets)
	TIME(f) :			Heures sur 5 octets
						f st le nombre de chiffres apr�s la seconde (de 0 � 7, 7 par d�faut)

	<!> SMALLDATETIME et DATETIME non standardis� et commence au 01/01/1900

	<!> ROWVERSION anciennement TIMESTAMP n'a pas de signification temporelle pour SQL Server
		-> Utili� pour le v�rouillage optimiste

-> Cha�nes  binaires :
	BIT :				1 bit
	BINARY(n) :			donn�es binaires de longueur fixe; n >= 1 && <= 8000
	VARBINARY(n) :		donn�es binaires de longueur variable; n >= 1 && <= 8000
	VARBINARY(MAX) :	Limit� � 2 Go. A �viter pour des raisons de performance

-> Autre type de donn�es :
	HIERARCHYID :		Type syst�me de longueur variable (type CLR).
						Repr�sente une position dans une hi�rarchie.
	UNIQUEIDENTIFIER :	GUID sur 16 octets
	...

-> Types obsol�tes :
	TEXT, NTEXT et IMAGE

*/

GO 
CREATE TABLE [AddressBook].[dbo].[City] --268 octets
(
	--<COLUMN_NAME>	<TYPE>			[NULL|NOT NULL]	[IDENTITY]
	[Identifier]	BIGINT			NOT NULL		IDENTITY --IDENTITY => incr�ment automatique
	,[Name]			NVARCHAR(100)	NOT NULL
	,[ZipCode]		NVARCHAR(30)	NOT NULL
)
GO
CREATE TABLE [AddressBook].[dbo].[Civility] --98 octets
(
	[Identifier]	BIGINT			NOT NULL	IDENTITY
	,[ShortName]	NVARCHAR(5)		NOT NULL
	,[Name]			NVARCHAR(40)	NOT NULL
)

GO
CREATE TABLE [AddressBook].[dbo].[Contact] --619 octets
(
	[Identifier]			BIGINT			NOT NULL	IDENTITY
	,[IdentifierCivility]	BIGINT			NULL
	,[FirstName]			NVARCHAR(100)	NULL
	,[LastName]				NVARCHAR(100)	NOT NULL
	,[BirthDate]			DATE			NULL
	,[EMail]				NVARCHAR(100)	NULL
)

GO
CREATE TABLE [AddressBook].[dbo].[Address] --1146 octets
(
	[Identifier]		BIGINT			NOT NULL	IDENTITY
	,[IdentifierCity]	BIGINT			NOT NULL
	,[StreetNumber]		NVARCHAR(10)	NULL
	,[RoadType]			NVARCHAR(50)	NOT NULL
	,[RoadName]			NVARCHAR(4000)	NULL
	,[Complement1]		NVARCHAR(2000)	NULL
	,[Complement2]		NVARCHAR(200)	NULL
	,[Latitude]			DECIMAL(7,5)	NULL
	,[Longitude]		DECIMAL(7,5)	NULL
)

GO
CREATE TABLE [AddressBook].[dbo].[AddressContact] --24 octets
(
	[Identifier]			BIGINT		NOT NULL	IDENTITY
	,[IdentifierAddress]	BIGINT		NOT NULL
	,[IdentifierContact]	BIGINT		NOT NULL
)

GO
ALTER TABLE [AddressBook].[dbo].[Address]
ADD
	--[Code] NVARCHAR(30) NULL --S'il existe des enregistrement, les nouveaux champs doivent �tre NULL
	--[Code] NVARCHAR(30) NOT NULL DEFAULT (N'0000')     
	[Code] NVARCHAR(30) NOT NULL CONSTRAINT [DF_Address_Code] DEFAULT (N'0000')

ALTER TABLE [AddressBook].[dbo].[City]
ADD
	[IsActive] BIT NOT NULL CONSTRAINT [DF_City_IsActive] DEFAULT (0)

GO
ALTER TABLE [AddressBook].[dbo].[Address] DROP CONSTRAINT [DF_Address_Code]

GO

/*
Les contraintes ont pour but de programmer les r�gles de gestion au niveau des colonnes.
On peut les d�clarer en m�me temps que la table (inline constraints).
Il est pr�f�rable de les d�clarer s�par�ment pur ne pas avoir � respecter un ordre de cr�ation des tables.

Chaque contrainte peut s'apliquer � une ou plusieurs colonnes (couple, triplets...)

	UNIQUE (UK) :		Impose une valeur distrinct pour chaque enregistrement. Les valeurs NULL sont autoris�es.
	PRIMARY KEY (PK) :	Cl� primaire de la table. Les valeurs ne peuvent �tre ni NULL ni identiques.
						Un index CLUSTURED est g�n�r� auomatiquement.
	FOREIGN KEY (FK) :	Cl� �trang�re, permet de maintenir l'int�grit� r�f�rentielle.
						Attention, aucun index n'est g�n�r� automatiquement.
	DEFAULT (DF) :		Valeur par d�faut.
	CHECK (CK) :		Impose un domaine de valeurs ou un condition entre colonnes
*/

 GO


--ALTER TABLE [AddressBook].[dbo].[City]
--ADD CONSTRAINT [PK_City_Identifier]
--PRIMARY KEY ( [Identifier] )




GO
/*


--On d�clare les variables qui vont contenir les donn�es de chaque ligne du jeu de r�sultat de la requ�te.
DECLARE @Query NVARCHAR(4000)

--On cr�� ensuite un curseur en pr�cisant la requ�te � ex�cuter

DECLARE
	QueryCursor
CURSOR STATIC FOR   
(
	SELECT
		CONCAT(N'ALTER TABLE [AddressBook].[dbo].[', t0.name, N'] ADD CONSTRAINT [PK_', t0.name, N'_Identifier] PRIMARY KEY ([Identifier])') AS Query
	FROM
		sys.tables AS t0
)

--"Ex�cute" la requ�te
OPEN QueryCursor;

--Demande la lecture du premier r�sultat
FETCH NEXT FROM QueryCursor INTO @Query;


--On boucle tant que FETCH NEXT fait une lecture d'un r�sultat
WHILE (@@FETCH_STATUS = 0)
BEGIN  

	PRINT @Query;

	EXEC sp_executesql @Query;

	---On va chercher le r�sultat suivant
	FETCH NEXT FROM QueryCursor INTO @Query;
END

--Fermeture puis suppression du curseur
CLOSE QueryCursor;
DEALLOCATE QueryCursor;


*/

DECLARE @MyQuery NVARCHAR(MAX)

SELECT
	@MyQuery = STRING_AGG
	(
		CONCAT(N'ALTER TABLE [AddressBook].[dbo].[', t0.name, N'] ADD CONSTRAINT [PK_', t0.name, N'_Identifier] PRIMARY KEY ([Identifier])')
		,NCHAR(13) --\n
	)
FROM
	sys.tables AS t0

PRINT @MyQuery

EXEC sp_executesql @MyQuery
GO

--Il existe plusieurs mani�res de concat�ner, la diff�rence ce siotue dans la gestion des valeurs NULL.
SELECT
	'MaVariable' + NULL					--NULL l'emporte sur la valeur avec +
	,'MaVariable' + ISNULL(NULL, '')
	,CONCAT('MaVariable', NULL)

SELECT 
	'MaVariable'	-- ASCII
	,N'MaVariable'	-- UNICODE

--FK
/*
Int�grit� r�f�rentielle

Actions � mener sur UPDATE | DELETE sur la/les colonne(s) r�f�renc�e(s)
CASCADE :		R�percute sur les enregistrements li�s.
SET NULL :		Donne pour valeur NULL aux lignes de la clef �trang�re qui pointent sur l'enregistrement affect�.
				Possible seulement si la/les colonne(s) FK accepte(ent) le marqueur NULL.
SET DEFAULT :	Applique la valeur par d�faut aux lignes de la clef �trang�re qui pointent sur l'enregistrement affect�.
				Possible seulement si la/les colonne(s) FK ont une contrainte DEFAULT.
NO ACTION :		D�clenche une erreur si l'enregistrement est r�f�renc� par la clef �trang�re. (comportement par d�faut)

*/

--TODO : G�n�rer les 4 FK pour les colonnes suivantes
SELECT
	t1.name			AS TableName
	,t0.name		AS ColumnName
FROM
	sys.Columns AS t0
INNER JOIN
	sys.tables AS t1 ON t0.object_id = t1.object_id
WHERE
	t0.name LIKE 'Identifier_%'

GO
DECLARE @Query NVARCHAR(MAX)


SELECT
	@Query = STRING_AGG(t0.Query, NCHAR(13))
FROM
(
	SELECT
		CONCAT(N'ALTER TABLE [AddressBook].[dbo].[', t0.SourceTableName, N']
		ADD CONSTRAINT [FK_', t0.SourceTableName, N'_', t0.TargetTableName, N'_', t0.SourceColumnName, N'_Identifier]
			FOREIGN KEY ([', t0.SourceColumnName, N'])
			REFERENCES [AddressBook].[dbo].[', t0.TargetTableName, N'] ([Identifier])
			ON DELETE NO ACTION
			ON UPDATE NO ACTION') AS Query
	FROM
	(
		SELECT
			t1.name										AS SourceTableName
			,t0.name									AS SourceColumnName
			,SUBSTRING(t0.name, 11, LEN(t0.Name) - 10)  AS TargetTableName
		FROM
			sys.Columns AS t0
		INNER JOIN
			sys.tables AS t1 ON t0.object_id = t1.object_id
		WHERE
			t0.name LIKE N'Identifier_%'
	) AS t0
) AS t0

PRINT @Query
EXEC sp_executesql @Query;

/*
Index (IX)

CLUSTER :		Index qui d�termine l'ordre du stockage des lignes dans les pages de donn�es.
				Il ne peut exister qu'un seul index CLUSTER par table.

NONCLUSTURED :	Cr�er des fichiers d'indexation tri� sur une ou plusieurs colonnes.
				Les pages de l'index pointent sur les pages de donn�es.

Index implicite :
	-> Lors de la cr�ation d'une contrainte PRIMARY KEY (index CLUSTER)
	-> Lors de la cr�ation d'une contrainte UNIQUE (index NONCLUSTERED)

	UNIQUE :					Interdit les doublons
	CLUSTERED|NONCLUSTERED :	D�termine le type d'index
	ASC | DESC :				D�termine l'ordre du tri de l'index (ASC par d�faut)
	WHERE :						Applique une restriction sur les lignes � indexer
	INCLUDE :					Permet d'inclure des donn�es non inex�es de la table � indexer.
								Permet d'�viter une double lecture (index + page de donn�es).
								Plus le nombre de colonne �lev�, plus l'index est compliqu� � maintenir.
	DROP_EXISTING :				Permet de reg�n�rer l'index s'il existait d�j� (par d�faut OFF).

	1000 index maximum par table (1 CLUSTURED + 999 NONCLUSTURED)
	Il est d�conseill� d'avoir trop d'indexes.
*/


GO
CREATE NONCLUSTERED INDEX IX_City_ZipCode ON [AddressBook].[dbo].[City]
(
	[ZipCode]
)

GO
CREATE NONCLUSTERED INDEX  IX_City_Name ON [AddressBook].[dbo].[City]
(
	[Name]
)
INCLUDE
(
	[ZipCode]
)


GO


DECLARE @value INT = 0;
CREATE TABLE Number (
	Value INT NOT NULL PRIMARY KEY
)

WHILE @value < 4000
BEGIN

	INSERT INTO Number ( Value ) SELECT @value

	SET @value = @value + 1;
END

GO

SELECT Value FROM Number WHERE Value < 1200

/*
TODO : G�n�rer un jeu de r�sultat avec 1200 lignes al�atoires :

| Name  |
|-------|
| Jean  | < Pr�nom choisi al�atoirement parmis une liste de 25 pr�nom pr�d�finie
| Alain |
| ...   |

*/

--Active ou d�sactive les statistiques de temps ou d'entr�e / sortie
--SET STATISTICS IO (ON | OFF)
--SET STATISTICS TIME (ON | OFF)


SELECT
	Name
	,ROW_NUMBER() OVER (ORDER BY Name) AS Identifier
INTO
	#FirstName
FROM
(
	SELECT N'A' AS Name UNION ALL
	SELECT N'B' AS Name UNION ALL
	SELECT N'C' AS Name UNION ALL
	SELECT N'D' AS Name UNION ALL
	SELECT N'E' AS Name UNION ALL
	SELECT N'F' AS Name UNION ALL
	SELECT N'G' AS Name UNION ALL
	SELECT N'H' AS Name UNION ALL
	SELECT N'I' AS Name UNION ALL
	SELECT N'J' AS Name
) AS t0

SELECT
	(ABS(CHECKSUM(NEWID())) % 10) +1 AS RandNumber
INTO
	#RandomNumbers
FROM
	Number AS t0
WHERE
	Value < 1200


SELECT
	t0.RandNumber
	,t1.Identifier
	,t1.Name
FROM
	#RandomNumbers AS t0
INNER JOIN
	#FirstName AS t1 ON t0.RandNumber = t1.Identifier



DROP TABLE #FirstName
DROP TABLE #RandomNumbers



GO
ALTER TABLE [dbo].[Contact]
	ADD FullName AS (CONCAT(FirstName + N' ', LastName)) PERSISTED
 
ALTER TABLE [dbo].[Contact]
	ADD Age AS (CAST(DATEDIFF(DAY, BirthDate, GETDATE()) / 365.25 AS INT))