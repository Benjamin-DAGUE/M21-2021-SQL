--Data Query Language

--Retourner l'ensemble des villes avec le nom et le code postal
SELECT
	t0.Name		AS [Nom ville]
	,t0.ZipCode	AS [Code postal]
FROM 
	City AS t0

--Retourner l'ensemble des villes avec le nom et le code postal 
--limit� aux 2 premier r�sultats : TOP(n)
SELECT TOP(2)
	t0.Name		AS [Nom ville]
	,t0.ZipCode	AS [Code postal]
FROM 
	City AS t0

--Retourner l'ensemble des noms des villes sans doublon : DISTINCT
SELECT DISTINCT
	t0.Name		AS [Nom ville]
FROM 
	City AS t0

SELECT
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
GROUP BY
	t0.Name

--Retourner l'ensemble des noms des villes sans doublon ordonn�s par nom
SELECT DISTINCT
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
ORDER BY
	[Nom ville] ASC --ASC (par d�faut) | DESC

--Avec ORDER BY, il est possible d'utiliser les alias de la projection.
--Ceci est li� � l'ordre d'ex�cution des mots clefs :
-- FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY


--S�lectionner la ville avec l'identifiant 11
SELECT 
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
WHERE
	t0.Identifier = 11

--S�lectionner les villes qui n'ont pas l'identifiant 11
SELECT 
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
WHERE
	t0.Identifier <> 11
	--t0.Identifier != 11
	--NOT t0.Identifier = 11

--S�lectionner les villes qui ont un identifiant inf�rieur ou �gale � 4
SELECT 
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
WHERE
	t0.Identifier <= 4

--S�lectionner les contacts qui ont une date de naissance comprise
--entre 01/01/1990 et 31/12/1999
SELECT
	*
FROM
	Contact AS t0
WHERE 
	t0.Birthdate BETWEEN DATEFROMPARTS(1990,01,01) AND DATEFROMPARTS(1999,12,31)
	--t0.Birthdate BETWEEN '1990-01-01' AND '31/12/1999'
	--t0.Birthdate >= DATEFROMPARTS(1990,01,01) AND t0.Birthdate <= '31/12/1999'

--S�lectionner les contacts qui n'ont pas une date de naissance comprise
--entre 01/01/1990 et 31/12/1999
SELECT
	*
FROM
	Contact AS t0
WHERE 
	t0.Birthdate NOT BETWEEN DATEFROMPARTS(1990,01,01) AND DATEFROMPARTS(1999,12,31)
	--t0.Birthdate < DATEFROMPARTS(1990,01,01) OR t0.Birthdate > '31/12/1999'


--S�lectionner les villes qui...
--commencent par LAV
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'LAV%'
SELECT * FROM City AS t0 WHERE CHARINDEX(N'LAV', t0.Name) = 1
SELECT * FROM City AS t0 WHERE LEFT(t0.Name, 3) = N'LAV'
--terminent par VAL
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'%VAL'
SELECT * FROM City AS t0 WHERE RIGHT(t0.Name, 3) = N'VAL'
--contiennent AVA
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'%AVA%'
--contiennent au moins 2 A
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'%A%A%'
--terminent par A suivi d'un unique caract�re
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'%A_'
--commencent par un caract�re compris entre a et l
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'[a-l]%'
--ne commencent pas par un caract�re compris entre a et l
SELECT * FROM City AS t0 WHERE t0.Name NOT LIKE N'[a-l]%'
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'[^a-l]%'


--Attention LIKE '%...' sont des requ�tes qui n'utilisent pas les indexes

SELECT
	CAST(t0.Char AS INT)
FROM
(
	SELECT '6' AS Char UNION ALL
	SELECT '.' AS Char --Attention, ISNUMERIC(..) retourne 1 pour '.' ou ','
) AS t0
WHERE
	ISNUMERIC(t0.Char) = 1 -- On ne cons�rve que les num�ros

	

--Nombre de code postaux diff�rents
SELECT
	COUNT(DISTINCT t0.ZipCode)
FROM 
	City AS t0

SELECT
	COUNT(t0.ZipCode)
FROM 
(
	SELECT DISTINCT
		t0.ZipCode
	FROM 
		City AS t0
) AS t0


--Regroupement : GROUP BY
--Nombre de code postaux par nom de ville
SELECT
	t0.Name
	,COUNT(t0.ZipCode)
FROM 
	City AS t0
GROUP BY 
	t0.Name

SELECT DISTINCT
	t0.Name
	,COUNT(t0.ZipCode) OVER (PARTITION BY t0.Name)
FROM 
	City AS t0

--Nombre d'adresse par ville et par type de rue
SELECT
	t0.Name
	,t1.RoadType
	,COUNT(t1.Identifier)
FROM 
	City AS t0
INNER JOIN 
	Address AS t1 ON t0.Identifier = t1.IdentifierCity
GROUP BY 
	t0.Name
	,t1.RoadType

--Nombre d'adresse par rue (type de rue + nom de la rue + nom ville)
SELECT
	CONCAT(t1.RoadType, N' ', t1.RoadName, N' ', t0.Name) AS Road
	,COUNT(t1.Identifier)
FROM 
	City AS t0
INNER JOIN 
	Address AS t1 on t0.Identifier = t1.IdentifierCity
GROUP BY 
	t0.Name
	,t1.RoadType
	,t1.RoadName

SELECT
	t0.FullAddress
	,COUNT(t0.Identifier)
FROM
(
	SELECT
		t1.Identifier
		,CONCAT(t1.RoadType, N' ', t1.RoadName, N' ', t0.Name) AS FullAddress
	FROM 
		City AS t0
	INNER JOIN 
		Address AS t1 on t0.Identifier = t1.IdentifierCity
) AS t0
GROUP BY 
	t0.FullAddress

--Nombre d'adresse par rue (type de rue + nom de la rue + nom ville)
--En conservant les r�sultats qui ont au moins un nombre de 2
SELECT
	CONCAT(t1.RoadType, N' ', t1.RoadName, N' ', t0.Name) AS Road
	,COUNT(t1.Identifier)
FROM 
	City AS t0
INNER JOIN 
	Address AS t1 on t0.Identifier = t1.IdentifierCity
GROUP BY 
	t0.Name
	,t1.RoadType
	,t1.RoadName
HAVING --HAVING permet d'appliquer des conditions sur le r�sultat d'une agr�gation
	COUNT(t0.Identifier) > 1


SELECT
	*
FROM
(
	SELECT
		CONCAT(t1.RoadType, N' ', t1.RoadName, N' ', t0.Name)	AS Road
		,COUNT(t1.Identifier)									AS TotalAddress
	FROM 
		City AS t0
	INNER JOIN 
		Address AS t1 on t0.Identifier = t1.IdentifierCity
	GROUP BY 
		t0.Name
		,t1.RoadType
		,t1.RoadName
) AS t0
WHERE
	t0.TotalAddress > 1

/*
En une seule requ�te
	-> Identifiant de la ville
	-> Type de rue
	-> Total adresse regroup� par ville (Identifier) et par type de rue
	-> Total adresse r�group� par ville (Identifier)
	-> Total g�n�ral
*/