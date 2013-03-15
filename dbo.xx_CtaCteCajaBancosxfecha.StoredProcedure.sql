SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [xx_CtaCteCajaBancosxfecha]
as
select  * from te_saldosmensuales b
inner join 
( 
select  distinct empresacodigo,tipocajabanco ,CajaBancoCodigo ,MonedaCuenta ,
	aaaamm=(select max(mesproceso) from te_saldosmensuales b 
            where b.empresacodigo+b.tipocajabanco+b.CajaBancoCodigo+b.MonedaCuenta=
                  a.empresacodigo+a.tipocajabanco+a.CajaBancoCodigo+a.MonedaCuenta )
	from te_saldosmensuales a
) as a
on b.empresacodigo+b.tipocajabanco+b.CajaBancoCodigo+b.MonedaCuenta+b.mesproceso=
                  a.empresacodigo+a.tipocajabanco+a.CajaBancoCodigo+a.MonedaCuenta+a.aaaamm
GO
