--Data Query Language

--Retourner l'ensemble des villes avec le nom et le code postal
SELECT
	t0.Name		AS [Nom ville]
	,t0.ZipCode	AS [Code postal]
FROM 
	City AS t0

--Retourner l'ensemble des villes avec le nom et le code postal 
--limité aux 2 premier résultats : TOP(n)
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

--Retourner l'ensemble des noms des villes sans doublon ordonnés par nom
SELECT DISTINCT
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
ORDER BY
	[Nom ville] ASC --ASC (par défaut) | DESC

--Avec ORDER BY, il est possible d'utiliser les alias de la projection.
--Ceci est lié à l'ordre d'exécution des mots clefs :
-- FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY


--Sélectionner la ville avec l'identifiant 11
SELECT 
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
WHERE
	t0.Identifier = 11

--Sélectionner les villes qui n'ont pas l'identifiant 11
SELECT 
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
WHERE
	t0.Identifier <> 11
	--t0.Identifier != 11
	--NOT t0.Identifier = 11

--Sélectionner les villes qui ont un identifiant inférieur ou égale à 4
SELECT 
	t0.Name		AS [Nom ville]
FROM 
	City AS t0
WHERE
	t0.Identifier <= 4

--Sélectionner les contacts qui ont une date de naissance comprise
--entre 01/01/1990 et 31/12/1999
SELECT
	*
FROM
	Contact AS t0
WHERE 
	t0.Birthdate BETWEEN DATEFROMPARTS(1990,01,01) AND DATEFROMPARTS(1999,12,31)
	--t0.Birthdate BETWEEN '1990-01-01' AND '31/12/1999'
	--t0.Birthdate >= DATEFROMPARTS(1990,01,01) AND t0.Birthdate <= '31/12/1999'

--Sélectionner les contacts qui n'ont pas une date de naissance comprise
--entre 01/01/1990 et 31/12/1999
SELECT
	*
FROM
	Contact AS t0
WHERE 
	t0.Birthdate NOT BETWEEN DATEFROMPARTS(1990,01,01) AND DATEFROMPARTS(1999,12,31)
	--t0.Birthdate < DATEFROMPARTS(1990,01,01) OR t0.Birthdate > '31/12/1999'


--Sélectionner les villes qui...
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
--terminent par A suivi d'un unique caractère
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'%A_'
--commencent par un caractère compris entre a et l
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'[a-l]%'
--ne commencent pas par un caractère compris entre a et l
SELECT * FROM City AS t0 WHERE t0.Name NOT LIKE N'[a-l]%'
SELECT * FROM City AS t0 WHERE t0.Name LIKE N'[^a-l]%'


--Attention LIKE '%...' sont des requêtes qui n'utilisent pas les indexes

SELECT
	CAST(t0.Char AS INT)
FROM
(
	SELECT '6' AS Char UNION ALL
	SELECT '.' AS Char --Attention, ISNUMERIC(..) retourne 1 pour '.' ou ','
) AS t0
WHERE
	ISNUMERIC(t0.Char) = 1 -- On ne consèrve que les numéros

	

--Nombre de code postaux différents
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
--En conservant les résultats qui ont au moins un nombre de 2
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
HAVING --HAVING permet d'appliquer des conditions sur le résultat d'une agrégation
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
En une seule requête
	-> Identifiant de la ville
	-> Type de rue
	-> Total adresse regroupé par ville (Identifier) et par type de rue
	-> Total adresse régroupé par ville (Identifier)
	-> Total général

| CityIdentifier | RoadType | TotalCityRoadType | TotalCity | Total |
---------------------------------------------------------------------

*/

--V1
SELECT
	t0.IdentifierCity
	,t0.RoadType
	,t0.TotalCityRoadType
	,t1.TotalCity
	,(SELECT COUNT(*) FROM Address) AS Total
FROM
(
	SELECT
		t0.IdentifierCity
		,t0.RoadType
		,COUNT(*)		AS TotalCityRoadType
	FROM
		Address AS t0
	GROUP BY
		t0.IdentifierCity
		,t0.RoadType
) AS t0
INNER JOIN
(
	SELECT
		t0.IdentifierCity
		,COUNT(*)		AS TotalCity
	FROM
		Address AS t0
	GROUP BY
		t0.IdentifierCity
) AS t1 ON t0.IdentifierCity = t1.IdentifierCity

--V2
SELECT
	t0.IdentifierCity
	,t0.RoadType
	,t0.TotalCityRoadType
	,t1.TotalCity
	,t2.Total
FROM
(
	SELECT
		t0.IdentifierCity
		,t0.RoadType
		,COUNT(*)		AS TotalCityRoadType
	FROM
		Address AS t0
	GROUP BY
		t0.IdentifierCity
		,t0.RoadType
) AS t0
INNER JOIN
(
	SELECT
		t0.IdentifierCity
		,COUNT(*)		AS TotalCity
	FROM
		Address AS t0
	GROUP BY
		t0.IdentifierCity
) AS t1 ON t0.IdentifierCity = t1.IdentifierCity
CROSS JOIN
(
	SELECT
		COUNT(*) AS Total
	FROM 
		Address
) AS t2

--V3
SELECT DISTINCT
	t0.IdentifierCity
	,t0.RoadType
	,COUNT(*) OVER (PARTITION BY t0.IdentifierCity, t0.RoadType) 	AS TotalCityRoadType
	,COUNT(*) OVER (PARTITION BY t0.IdentifierCity) 				AS TotalCity
	,COUNT(*) OVER () 												AS Total
FROM
	Address AS t0

