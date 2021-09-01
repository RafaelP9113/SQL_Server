set dateformat dmy
	
declare @data smalldatetime
set @data = dateadd(dd,-1,getdate())
set @data = convert (int,@data)

select @data
SELECT dateadd (dd, 1, @data)


SELECT *
FROM	LOJA_NOTA_FISCAL
WHERE	EMISSAO >= @data and EMISSAO < dateadd (dd, 1, @data)

SELECT *
FROM	LOJA_VENDA
WHERE	DATA_VENDA >= @data  and data_venda < dateadd (dd, 1, @data)

SELECT *
FROM	LOJA_CAIXA_LANCAMENTOS
WHERE	DATA >= @data  and DATA < dateadd (dd, 1, @data)
