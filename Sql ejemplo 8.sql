-- ================================
-- Create User-defined Table Type
-- ================================
USE Uib
GO

-- Create the data type

CREATE TYPE MiTipoTablaEjercicio8 AS TABLE 
(
	ciudad int NOT NULL,
	categoria varchar(15) NOT NULL,
	desde decimal(10, 2) NOT NULL,
	hasta decimal (10, 2) NOT NULL,
	noches int
)
GO

CREATE FUNCTION GET_CATEGORIA_AS_TEXTO
(
	-- Add the parameters for the function here
	@categoria varchar(15)
)
RETURNS varchar(15)
AS
BEGIN
	-- Declare the return variable here
	IF @categoria = '*' RETURN '1 estrella'


	RETURN convert(varchar,len(@categoria)) + ' estrellas'
	
END
GO

CREATE PROCEDURE GET_EJERCICIO_8
 @filtro as MiTipoTablaEjercicio8 READONLY
 , @idioma varchar(2)
 AS
 BEGIN
	 -- Insert statements for procedure here
	select
	 HOT_codigo, HOT_nombre, hot_categoria, ciu.ciu_codigo, ciu.PAI_codigo into #temp
	 from 
		(SELECT HOT_codigo, HOT_nombre, hot_categoria, ciu_codigo
		from @filtro fil
		inner join  HOTEL hot with(nolock)
		 on hot.CIU_codigo = fil.ciudad
		and hot.hot_categoria = fil.categoria) hotelesQuePasanFiltro
		inner join CIUDAD ciu witH(nolock)
		on hotelesQuePasanFiltro.CIU_codigo = ciu.CIU_codigo



		select hot.*, pre.HPM_pvp,pre.HPM_regimen, pre.HPM_fechaEntrada, pre.HPM_noches into #temp2
		from #temp hot
		inner join HOTEL_PRECIO_MINIMO pre
		on hot.HOT_codigo = pre.HOT_codigo
		inner join @filtro fil
		on fil.ciudad = hot.CIU_codigo
		and fil.categoria = hot.hot_categoria
		and pre.HPM_pvp between fil.desde and fil.hasta
		and pre.HPM_noches = fil.noches


		select  h.*, isnull(ipa.IDP_nombre, pai.PAI_descripcion) as pais,
		 h.hot_nombre + ' ' + dbo.GET_CATEGORIA_AS_TEXTO(h.hot_categoria) as textoEncadenado, hf.*
				from #temp2 h
		inner join PAIS pai 
		on h.PAI_codigo = pai.PAI_codigo
		left join IDIOMA_PAIS ipa
			on ipa.PAI_codigo = pai.PAI_codigo
			and ipa.IDI_codigo = @idioma
		left join HOTEL_FICHA hf 
			on h.HOT_codigo = hf.HOT_codigo
			and hf.IDI_codigo = @idioma

		
		drop table #temp
		drop table #temp2
		
 END
 GO


 declare @param as MiTipoTablaEjercicio8
 insert into @param(ciudad, categoria, desde, hasta, noches)
 values(6600, '**', 0, 50, 2), (6600, '***', 0, 100, 2) 

  exec GET_EJERCICIO_8 @param, 'es' INTO #myTemp

 select * from #myTemp