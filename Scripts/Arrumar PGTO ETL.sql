set dateformat dmy



declare @inicio  smalldatetime
declare @fim	 smalldatetime
declare @inicio_filial   int
declare @fim_filial	int

set @inicio = '16/03/2021'
set @fim = '16/03/2021'

UPDATE	LOJA_VENDA_PGTO SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	LOJA_VENDA_PGTO
WHERE	DATA = @inicio and DATA < dateadd(dd, 1, @fim)
AND CODIGO_FILIAL = @inicio_filial and CODIGO_FILIAL <= @fim_filial
and LANCAMENTO_CAIXA = '163L008'  -- 163L00A
and TERMINAL = '002'

SELECT	*
FROM	LJ_ETL_REPOSITORIO