SELECT  REPLICATE('0', 4 - LEN(ITEM_NFE)) + RTrim(ITEM_NFE), *
FROM LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO = '000057352' AND SERIE_NF = '5' AND CODIGO_FILIAL = '000064'
ORDER BY ITEM_NFE


bEGIN TRAN

UPDATE LOJA_NOTA_FISCAL_ITEM
SET ITEM_IMPRESSAO =   REPLICATE('0', 4 - LEN(ITEM_NFE)) + RTrim(ITEM_NFE), SUB_ITEM_TAMANHO = '1'
WHERE NF_NUMERO = '000003408' AND SERIE_NF = '4' AND CODIGO_FILIAL = '000094'

COMMIT TRAN 



DELETE 
--select *
FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO = '000057352' AND SERIE_NF = '5' AND CODIGO_FILIAL = '000064'

EXEC SP_LNX_GERA_IMPOSTOS_SAIDA_NFCE
@CODIGO_FILIAL = '000064',
@NF_SAIDA = '000057352',
@SERIE_NF = '5'


SELECT * FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO in ('000003102','000003107','000003109','000003114','000003120','000003122') AND SERIE_NF = '4' AND CODIGO_FILIAL = '000012'
