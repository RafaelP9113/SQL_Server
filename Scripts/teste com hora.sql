set dateformat dmy
	
declare @data smalldatetime
set @data = getdate()

select @data
SELECT dateadd (HH, -1, @data)

SELECT *
FROM	LOJA_NOTA_FISCAL
WHERE	EMISSAO <= @data and DATA_PARA_TRANSFERENCIA >= dateadd (HH, -1, @data)

SELECT *
FROM	LOJA_VENDA
WHERE	DATA_VENDA <= @data  and DATA_PARA_TRANSFERENCIA >= dateadd (HH, -1, @data)

SELECT *
FROM	LOJA_CAIXA_LANCAMENTOS
WHERE	DATA <= @data  and DATA_PARA_TRANSFERENCIA >=  dateadd (HH, -1, @data)