--DDL : Data Definition Language
	--CREATE ALTER DROP

USE [master]	--Permet de sélectionner la base cible pour les requêtes
GO				--Permet d'indiquer au moteur SQL d'exécuter les requêtes ci-dessus

IF EXISTS (SELECT TOP(1) 1 FROM sys.databases WHERE name = 'AddressBook')
BEGIN

	--On passe la base en mode mono-utilisateur (une seule session possible)
	--WITH ROLLBACK IMMEDIATE permet d'annuler les transactions incomplètes en cours
	--le mode mono-utilisateur déconnecte automatiquement les autres sessions
	ALTER DATABASE [AddressBook] SET SINGLE_USER WITH ROLLBACK IMMEDIATE

	DROP DATABASE [AddressBook]
END

CREATE DATABASE [AddressBook]
ON PRIMARY --Fichier de données
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
-> Chaînes ASCII (1 octet par caractère)
	CHAR(n) :		Taille fixe, ajout du caractère de bourage ' ' pour combler l'espace. n >= 1 && <= 8000
	VARCHAR(n) :	Taille variable, n>= 1 && <= 8000
	VARCHAR(MAX) :	Limité à 2Go. A éviter pour des raisons de performance.

-> Chaînes UNICODE (2 octets par caractère donc n >= 1 && <= 4000)
	NCHAR(n)
	NVARCHAR(n)
	NVARCHAR(MAX)

-> Valeur numériques exactes :
	TYNIINT :		Entier sur 1 octet
	SMALLINT :		Entier sur 2 octets
	INT :			Entier sur 4 octets
	BIGINT :		Entier sur 8 octets
	NUMERIC(p,s) :	Similaire à DECIMAL(p,s)
	DECIMAL(p,s) :	Décimal à vigule fixe ( de 5 à 17 octets)
					p désigne le nombre de chiffres total (entre 1 et 38, 18 par défaut)
					s désigne le nombre de décimales après la virgule (entre 0 et p)
	SMALLMONEY :	Décimal monétaire sur 4 octets
	MONEY :			Décimal monétaire sur 8 octets

	<!> Utilisez DECIMAL au lieu de SMALLMONEY et MONEY

-> Valeur numérique approximatives
	FLOAT :	Flotant de 4 à 8 octets
	REAL :	Flotant de 4 octets

	<!> provoques des erreurs d'arrondi dans les calculs (gestion sous forme de fraction).

-> Date et heure :
	DATE :				Date du 01/01/0001 au 31/12/9999 sur 3 octets
	DATETIME2(f) :		Date du 01/01/0001 au 31/12/9999 et heures (de 6 à 8 octets)
						f st le nombre de chiffres après la seconde (de 0 à 7, 7 par défaut)
	DATETIMEOFFSET :	Ajoute au DATETIME2(f) le fuseau horraire (10 octets)
	TIME(f) :			Heures sur 5 octets
						f st le nombre de chiffres après la seconde (de 0 à 7, 7 par défaut)

	<!> SMALLDATETIME et DATETIME non standardisé et commence au 01/01/1900

	<!> ROWVERSION anciennement TIMESTAMP n'a pas de signification temporelle pour SQL Server
		-> Utilié pour le vérouillage optimiste

-> Chaînes  binaires :
	BIT :				1 bit
	BINARY(n) :			données binaires de longueur fixe; n >= 1 && <= 8000
	VARBINARY(n) :		données binaires de longueur variable; n >= 1 && <= 8000
	VARBINARY(MAX) :	Limité à 2 Go. A éviter pour des raisons de performance

-> Autre type de données :
	HIERARCHYID :		Type système de longueur variable (type CLR).
						Représente une position dans une hiérarchie.
	UNIQUEIDENTIFIER :	GUID sur 16 octets
	...

-> Types obsolètes :
	TEXT, NTEXT et IMAGE

*/

GO 
CREATE TABLE [AddressBook].[dbo].[City] --268 octets
(
	--<COLUMN_NAME>	<TYPE>			[NULL|NOT NULL]	[IDENTITY]
	[Identifier]	BIGINT			NOT NULL		IDENTITY --IDENTITY => incrément automatique
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
	--[Code] NVARCHAR(30) NULL --S'il existe des enregistrement, les nouveaux champs doivent être NULL
	--[Code] NVARCHAR(30) NOT NULL DEFAULT (N'0000')     
	[Code] NVARCHAR(30) NOT NULL CONSTRAINT [DF_Address_Code] DEFAULT (N'0000')

ALTER TABLE [AddressBook].[dbo].[City]
ADD
	[IsActive] BIT NOT NULL CONSTRAINT [DF_City_IsActive] DEFAULT (0)

GO
ALTER TABLE [AddressBook].[dbo].[Address] DROP CONSTRAINT [DF_Address_Code]

GO

/*
Les contraintes ont pour but de programmer les règles de gestion au niveau des colonnes.
On peut les déclarer en même temps que la table (inline constraints).
Il est préférable de les déclarer séparément pur ne pas avoir à respecter un ordre de création des tables.

Chaque contrainte peut s'apliquer à une ou plusieurs colonnes (couple, triplets...)

	UNIQUE (UK) :		Impose une valeur distrinct pour chaque enregistrement. Les valeurs NULL sont autorisées.
	PRIMARY KEY (PK) :	Clé primaire de la table. Les valeurs ne peuvent être ni NULL ni identiques.
						Un index CLUSTURED est généré auomatiquement.
	FOREIGN KEY (FK) :	Clé étrangère, permet de maintenir l'intégrité référentielle.
						Attention, aucun index n'est généré automatiquement.
	DEFAULT (DF) :		Valeur par défaut.
	CHECK (CK) :		Impose un domaine de valeurs ou un condition entre colonnes
*/

 GO


--ALTER TABLE [AddressBook].[dbo].[City]
--ADD CONSTRAINT [PK_City_Identifier]
--PRIMARY KEY ( [Identifier] )




GO
/*


--On déclare les variables qui vont contenir les données de chaque ligne du jeu de résultat de la requête.
DECLARE @Query NVARCHAR(4000)

--On créé ensuite un curseur en précisant la requête à exécuter

DECLARE
	QueryCursor
CURSOR STATIC FOR   
(
	SELECT
		CONCAT(N'ALTER TABLE [AddressBook].[dbo].[', t0.name, N'] ADD CONSTRAINT [PK_', t0.name, N'_Identifier] PRIMARY KEY ([Identifier])') AS Query
	FROM
		sys.tables AS t0
)

--"Exécute" la requête
OPEN QueryCursor;

--Demande la lecture du premier résultat
FETCH NEXT FROM QueryCursor INTO @Query;


--On boucle tant que FETCH NEXT fait une lecture d'un résultat
WHILE (@@FETCH_STATUS = 0)
BEGIN  

	PRINT @Query;

	EXEC sp_executesql @Query;

	---On va chercher le résultat suivant
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

--Il existe plusieurs manières de concaténer, la différence ce siotue dans la gestion des valeurs NULL.
SELECT
	'MaVariable' + NULL					--NULL l'emporte sur la valeur avec +
	,'MaVariable' + ISNULL(NULL, '')
	,CONCAT('MaVariable', NULL)

SELECT 
	'MaVariable'	-- ASCII
	,N'MaVariable'	-- UNICODE

--FK
/*
Intégrité référentielle

Actions à mener sur UPDATE | DELETE sur la/les colonne(s) référencée(s)
CASCADE :		Répercute sur les enregistrements liés.
SET NULL :		Donne pour valeur NULL aux lignes de la clef étrangère qui pointent sur l'enregistrement affecté.
				Possible seulement si la/les colonne(s) FK accepte(ent) le marqueur NULL.
SET DEFAULT :	Applique la valeur par défaut aux lignes de la clef étrangère qui pointent sur l'enregistrement affecté.
				Possible seulement si la/les colonne(s) FK ont une contrainte DEFAULT.
NO ACTION :		Déclenche une erreur si l'enregistrement est référencé par la clef étrangère. (comportement par défaut)

*/

--TODO : Générer les 4 FK pour les colonnes suivantes
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

CLUSTER :		Index qui détermine l'ordre du stockage des lignes dans les pages de données.
				Il ne peut exister qu'un seul index CLUSTER par table.

NONCLUSTURED :	Créer des fichiers d'indexation trié sur une ou plusieurs colonnes.
				Les pages de l'index pointent sur les pages de données.

Index implicite :
	-> Lors de la création d'une contrainte PRIMARY KEY (index CLUSTER)
	-> Lors de la création d'une contrainte UNIQUE (index NONCLUSTERED)

	UNIQUE :					Interdit les doublons
	CLUSTERED|NONCLUSTERED :	Détermine le type d'index
	ASC | DESC :				Détermine l'ordre du tri de l'index (ASC par défaut)
	WHERE :						Applique une restriction sur les lignes à indexer
	INCLUDE :					Permet d'inclure des données non inexées de la table à indexer.
								Permet d'éviter une double lecture (index + page de données).
								Plus le nombre de colonne élevé, plus l'index est compliqué à maintenir.
	DROP_EXISTING :				Permet de regénérer l'index s'il existait déjà (par défaut OFF).

	1000 index maximum par table (1 CLUSTURED + 999 NONCLUSTURED)
	Il est déconseillé d'avoir trop d'indexes.
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
TODO : Générer un jeu de résultat avec 1200 lignes aléatoires :

| Name  |
|-------|
| Jean  | < Prénom choisi aléatoirement parmis une liste de 25 prénom prédéfinie
| Alain |
| ...   |

*/

--Active ou désactive les statistiques de temps ou d'entrée / sortie
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