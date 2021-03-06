SELECT  REPLICATE('0', 4 - LEN(ITEM_NFE)) + RTrim(ITEM_NFE), *
FROM LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO in ('000003081') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000012'
ORDER BY ITEM_NFE

--ROLLBACK
--BEGIN TRAN
UPDATE LOJA_NOTA_FISCAL_ITEM
SET ITEM_IMPRESSAO =   REPLICATE('0', 4 - LEN(ITEM_NFE)) + RTrim(ITEM_NFE), SUB_ITEM_TAMANHO = '1'
WHERE NF_NUMERO in ('000003170') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000012'

--COMMIT TRAN 


DELETE 
--select *
FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO in ('000003170') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000012'

EXEC SP_LNX_GERA_IMPOSTOS_SAIDA_NFCE
@CODIGO_FILIAL = '000012',
@NF_SAIDA = '000003170',
@SERIE_NF = '4'


SELECT * FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO in ('000004210') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000006'



---------------------ITEM_NFE DUPLICADO----------------------------

--BEGIN TRAN
delete from LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO in ('000003170') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000012'
and SUB_ITEM_TAMANHO >1
--order by item_impressao
--AND ITEM_IMPRESSAO = '0006'

COMMIT TRAN


SELECT ID_EXCECAO_IMPOSTO,* FROM LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO in ('000006565') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000052'
and SUB_ITEM_TAMANHO >1
order by item_impressao
--AND ITEM_IMPRESSAO = '0006'

SELECT * FROM LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO in ('000000662') AND SERIE_NF = '6' AND CODIGO_FILIAL = '900049'
--and SUB_ITEM_TAMANHO <='1'
order by item_impressao
--AND ITEM_IMPRESSAO = '0006'
