--SELECT * 
UPDATE LOJA_NOTA_FISCAL SET NATUREZA_OPERACAO_CODIGO = '1913' --1913 5912
FROM LOJA_NOTA_FISCAL
WHERE NF_NUMERO IN ('000001814')
AND SERIE_NF = '4'
AND CODIGO_FILIAL = '000144'


--SELECT * 
UPDATE LOJA_NOTA_FISCAL_ITEM SET CODIGO_FISCAL_OPERACAO = '1913'
FROM LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO IN ('000001815')
AND SERIE_NF = '4'
AND CODIGO_FILIAL = '000144'

SELECT * 
--UPDATE LOJA_NOTA_FISCAL SET NATUREZA_OPERACAO_CODIGO = '1913' --1913 5912
FROM LOJA_NOTA_FISCAL
WHERE NF_NUMERO IN ('000001815')
AND SERIE_NF = '4'
AND CODIGO_FILIAL = '000144'


SELECT * 
--UPDATE LOJA_NOTA_FISCAL_ITEM SET CODIGO_FISCAL_OPERACAO = '5912'
FROM LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO IN ('000001815')
AND SERIE_NF = '4'
AND CODIGO_FILIAL = '000144'


select COD_FILIAL,FILIAL from FILIAIS
where filial like '%park%'