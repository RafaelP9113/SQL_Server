set dateformat dmy



declare @inicio  smalldatetime
declare @fim	 smalldatetime
declare @inicio_filial   int
declare @fim_filial	int

set @inicio = '04/05/2021'
set @fim = '04/05/2021'



UPDATE	CLIENTES_VAREJO SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	CLIENTES_VAREJO
WHERE	CODIGO_CLIENTE IN (SELECT CODIGO_CLIENTE FROM LOJA_VENDA WHERE DATA_VENDA = @inicio and DATA_VENDA < dateadd(dd, 1, @fim))

UPDATE	LOJA_NOTA_FISCAL SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	LOJA_NOTA_FISCAL
WHERE	EMISSAO = @inicio and emissao < dateadd(dd, 1, @fim)

UPDATE	LOJA_VENDA SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	LOJA_VENDA
WHERE	DATA_VENDA = @inicio and DATA_VENDA < dateadd(dd, 1, @fim)

UPDATE	LOJA_CAIXA_LANCAMENTOS SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	LOJA_CAIXA_LANCAMENTOS
WHERE	DATA = @inicio and DATA < dateadd(dd, 1, @fim)


SELECT	*
FROM	LJ_ETL_REPOSITORIO

SELECT	*
FROM	LOJA_NOTA_FISCAL
WHERE	EMISSAO >= @inicio and emissao < dateadd(dd, 1, @fim)


SELECT	*
FROM	LOJA_VENDA
WHERE	DATA_VENDA = @inicio and DATA_VENDA < dateadd(dd, 1, @fim)


SELECT	*
FROM	LOJA_CAIXA_LANCAMENTOS
WHERE	DATA = @inicio and DATA < dateadd(dd, 1, @fim)

--SELECT *
--FROM LOJA_VENDA_PGTO
--WHERE VENDA_FINALIZADA = '0'

