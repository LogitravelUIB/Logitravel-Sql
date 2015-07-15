-- ========================
-- Ejercicio 1
-- ========================
SELECT 
   CIU_codigo, CIU_nombre, PAI_codigo, CIU_numHoteles
FROM
	CIUDAD with(nolock)
WHERE
	CIU_nombre like 'Bar%'
	--AND not (CIU_latitud is null OR CIU_longitud is null)
	AND  not CIU_latitud is null 
	AND not CIU_longitud is null
ORDER BY 
	CIU_numHoteles desc

-- ========================
-- Ejercicio 2
-- ========================
-- OPCION A
SELECT  HOT_codigo, HOT_nombre, hot_categoria, CIU_codigo
FROM HOTEL with(nolock)
WHERE
	(hot_categoria in ('*', '**') AND CIU_codigo = 4522)
OR (hot_categoria in ('****', '*****') AND CIU_codigo = 652)


-- OPCION B
SELECT  HOT_codigo, HOT_nombre, hot_categoria, CIU_codigo
FROM HOTEL with(nolock)
WHERE
	(hot_categoria in ('*', '**') AND CIU_codigo = 4522)

UNION 

SELECT  HOT_codigo, HOT_nombre, hot_categoria, CIU_codigo
FROM HOTEL with(nolock)
WHERE
	 (hot_categoria in ('****', '*****') AND CIU_codigo = 652)

-- ========================
-- Ejercicio 3
-- ========================
SELECT TOP 100
	HOT_nombre,
	ciu.CIU_nombre,
	pai.PAI_descripcion,
	con.CON_nombre
FROM HOTEL hot witH(nolock)
INNER JOIN CIUDAD ciu witH(nolock)
	on hot.CIU_codigo = ciu.CIU_codigo
INNER JOIN PAIS pai witH(nolock)
	on pai.PAI_codigo = ciu.PAI_codigo
INNER JOIN CONTINENTE con witH(nolock)
	on con.CON_codigo = pai.CON_codigo
ORDER BY HOT_popularidad desc

-- ========================
-- Ejercicio 4
-- ========================
SELECT 
	hot.HOT_codigo, hot.hot_nombre, hot.hot_categoria
FROM HOTEL hot witH(nolock)
LEFT JOIN HOTEL_PRECIO_MINIMO pm witH(nolock)
	on pm.HOT_codigo = hot.HOT_codigo
WHERE 
hot.HOT_activo = 1
and pm.HOT_codigo is null

-- ========================
-- Ejercicio 6
-- ========================
SELECT round(min(hpm.HPM_pvp),2) as Minimo,
	   round(max(hpm.HPM_pvp),2) as Maximo,
       round(avg(hpm.HPM_pvp),2) as Medio,
	   isnull(idp.IDP_nombre, pai.PAI_descripcion) as Pais,
	   ciu.CIU_nombre as Ciudad
 from HOTEL hot with(nolock)
INNER JOIN HOTEL_PRECIO_MINIMO hpm witH(nolock)
	on hot.HOT_codigo = hpm.HOT_codigo
INNER JOIN CIUDAD ciu witH(nolock)
	on hot.CIU_codigo = ciu.CIU_codigo
INNER JOIN PAIS pai witH(nolock)
	on pai.PAI_codigo = ciu.PAI_codigo
LEFT JOIN IDIOMA_PAIS idp witH(nolock)
	on pai.PAI_codigo = idp.PAI_codigo
	and idp.IDI_codigo = 'es'
GROUP BY isnull(idp.IDP_nombre, pai.PAI_descripcion), CIU_nombre	

--==============================
-- Declaración de variables
--==============================
DECLARE @mask as varchar(20) = '%Agora%'
DECLARE @hotCodigo AS INT = 20
DECLARE @hotNombre as varchar(400)

set @hotCodigo = 20

select top 1 @hotCodigo = hot_codigo, @hotNombre = hot_nombre
from hotel
where hot_nombre like @mask

--==============================
-- Condicional
--==============================
if (Exists(select top 1 1 from HOTEL_PRECIO_MINIMO where HOT_codigo = @hotCodigo)) 
BEGIN
	print 'El Hotel ' + @hotNombre + ' tiene precio minimo';
END
ELSE
BEGIN
	print 'El Hotel ' + @hotNombre + ' no tiene precio minimo';
END

--==============================
-- While 
--==============================
declare @myVar as int = 0
WHILE @myVar <= 10 
BEGIN
	IF @myVar % 2 = 0 
	BEGIN
		print 'Par: ' + convert(varchar, @myVar)

	END
	ELSE
	BEGIN
		print 'Impar: ' + convert(varchar, @myVar)
	END

	set @myVar = @myVar + 1
END

--==============================
-- Tablas temporales 
--==============================

SELECT HOT_codigo, HOT_nombre into #tempHotelesDosEstrellas
FROM HOTEL with(nolock)
WHERE HOT_categoria = '**'

select HOT_codigo, HOT_nombre from #tempHotelesDosEstrellas

DROP TABLE #tempHotelesDosEstrellas


--==============================
-- Tablas variable 
--==============================

DECLARE @tempTable TABLE
(
HOT_codigo int,
HOT_nombre varchar(250)
)

INSERT INTO @tempTable(HOT_codigo, HOT_nombre)
select  HOT_codigo, HOT_nombre 
FROM HOTEL with(nolock)
WHERE HOT_categoria = '**'

select HOT_codigo, HOT_nombre from @tempTable

-- ========================
-- Ejercicio 7
-- ========================
SELECT
 HOT_codigo, HOT_nombre, HOT_categoria into #tempHoteles
from HOTEL 
WHERE CIU_codigo = 5833


WHILE (Exists(SELECT TOP 1 1 FROM #tempHoteles))
BEGIN
	declare @auxCodigo int
	declare @auxNombre varchar(250)
	declare @hotCategoria varchar(50)
	declare @pvp decimal(10,2)
	declare @regimen as varchar(2)

	select top 1
	@auxCodigo = HOT_codigo, @auxNombre = hot_nombre, @hotCategoria = hot_categoria 
	from #tempHoteles ORDER BY hot_nombre

	SELECT TOP 1 @pvp = HPM_pvp, @regimen = HPM_regimen
	FROM HOTEL_PRECIO_MINIMO 
	WHERE HOT_codigo = @auxCodigo

	if(not @pvp is null)
	BEGIN
		PRINT @auxNombre + '(' + @hotCategoria + ') tiene un precio de ' 
				+ convert(varchar, @pvp) 
				+ ' en regimen ' + @regimen
	END
	ELSE
	BEGIN
		PRINT @auxNombre + '(' + @hotCategoria + ') no tiene precio.'
	END

	DELETE FROM #tempHoteles WHERE HOT_codigo = @auxCodigo
END

DROP TABLE #tempHoteles

-- ==============================
-- Ejercicio 7 bis
-- ==============================

DECLARE @auxTable TABLE
(
	HOT_codigo int, HOT_nombre varchar(250), HOT_categoria varchar(40),	Mensaje varchar(max), Indice int)

INSERT 
INTO @auxTable (HOT_codigo, HOT_nombre, HOT_categoria, Indice)
SELECT HOT_codigo, HOT_nombre, HOT_categoria, ROW_NUMBER() OVER(ORDER BY HOT_nombre ASC)
FROM HOTEL
WHERE CIU_codigo = 5833

UPDATE
     @auxTable 
SET
     Mensaje = ' tiene un precio de ' + convert(varchar, HOTEL_PRECIO_MINIMO.HPM_pvp) + ' en regimen ' + HOTEL_PRECIO_MINIMO.HPM_regimen
FROM
     @auxTable a
INNER JOIN     
     HOTEL_PRECIO_MINIMO 
ON     
     a.HOT_codigo = HOTEL_PRECIO_MINIMO.HOT_codigo 


UPDATE
     @auxTable 
SET
     Mensaje = ' no tiene precio'
WHERE Mensaje is null

declare @finish int = (select count(1) from @auxTable)
declare @i int = 1
declare @print varchar(max)

WHILE (@i<=@finish)
BEGIN
	set @print = (select top 1 HOT_nombre + '(' + HOT_categoria + ') ' + Mensaje from @auxTable WHERE Indice = @i)
	print @print
	set @i = @i + 1
END
