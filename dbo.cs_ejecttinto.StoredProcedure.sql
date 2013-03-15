SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [cs_ejecttinto]
/*
  8 paso
  Procedimiento que ejecuta todos los procedimientos
  
*/
--Declare
@basedest varchar(50),
@baseorig varchar(50),
@basaux varchar(50),
@baseemp varchar(50),
@unidadnegociocodigo varchar(2),
@flujonegociocodigo varchar(2),
@mes int,
@anno varchar(4),
@Nmesatras int,
@Nmesadela int, 
@compu varchar(50)
/*set @basedest='costos'
set @baseorig='db_costos'
set @basaux='empresas'
set @baseemp='etextil0001'
set @unidadnegociocodigo='01'
set @flujonegociocodigo='01'
set @mes=4
set @anno ='2003'
set @Nmesatras=2
set @Nmesadela=1 
set @compu='Desarrollo4'*/
--exec cs_ejecttinto 'costos','db_costos','empresas','etextil0001','01','01',4,'2003',2,1,'desarrollo4'
                    
as
declare @year int
set @year=cast(@anno as int)
--Print('Generando Temporales')
exec dbo.cs_gentemptinto
@base=@baseorig, @baseemp=@baseemp, @mes=@mes, @anno=@anno, @compu=@compu, @Nmesatras=@Nmesatras, @Nmesadela=@Nmesadela
--Print('Registrando las maquinas')
exec dbo.cs_settintopaso1
@Basedest=@basedest, @BaseOrig=@baseorig, @unidadnegociocodigo=@unidadnegociocodigo, @flujonegociocodigo=@flujonegociocodigo, @compu=@compu
--Print('Registrando los Productos')
exec dbo.cs_settintopaso2
@Basedest=@basedest, @BaseOrig=@BaseOrig, @unidadnegociocodigo=@unidadnegociocodigo, @compu=@compu
--Print('Registrando la produccion por maquina')
exec dbo.cs_settintopaso3
@Basedest=@basedest, @BaseOrig=@BaseOrig, @unidadnegociocodigo=@unidadnegociocodigo, @compu=@compu, @mes=@mes, @year=@year
--Print('Registrando familias de insumos')
--BaseOrig base de datos origen
exec dbo.cs_settintopaso4
@Basedest=@Basedest, @BaseOrig=@basaux, @unidadnegociocodigo=@unidadnegociocodigo, @compu=@compu
--Print('Registrando insumos utilizados en la elaboracion de un producto')
--BaseOrig base de datos origen
exec dbo.cs_settintopaso5
@Basedest=@Basedest, @BaseOrig=@basaux, @unidadnegociocodigo=@unidadnegociocodigo, @compu=@compu
--Print('Registrando el consumo de insumos por producto y por maquina')
exec dbo.cs_settintopaso6
@Basedest=@Basedest, @BaseOrig=@BaseOrig, @unidadnegociocodigo=@unidadnegociocodigo, @compu=@compu, @mes=@mes, @year=@year
GO
