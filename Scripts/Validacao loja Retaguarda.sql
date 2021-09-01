
set dateformat dmy



declare @inicio  smalldatetime
declare @fim	 smalldatetime
declare @inicio_filial   int
declare @fim_filial	int

set @inicio = '04/05/2021'
set @fim = '04/05/2021'
set @inicio_filial   = '000151'
set @fim_filial	 = '000151'



SELECT	*
FROM	LOJA_NOTA_FISCAL
WHERE	EMISSAO >= @inicio and emissao < dateadd(dd, 1, @fim)
AND CODIGO_FILIAL = @inicio_filial and CODIGO_FILIAL <= @fim_filial 

SELECT	*
FROM	LOJA_VENDA
WHERE	DATA_VENDA = @inicio and DATA_VENDA < dateadd(dd, 1, @fim)
AND CODIGO_FILIAL = @inicio_filial and CODIGO_FILIAL <= @fim_filial 

SELECT	*
FROM	LOJA_CAIXA_LANCAMENTOS
WHERE	DATA = @inicio and DATA < dateadd(dd, 1, @fim)
AND CODIGO_FILIAL = @inicio_filial and CODIGO_FILIAL <= @fim_filial 

