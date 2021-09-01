select  ent.ROMANEIO_PRODUTO, ent.FILIAL, ent.FILIAL_ORIGEM,ent.NUMERO_NF_TRANSFERENCIA,ent.EMISSAO,ent.QTDE_TOTAL,ent.VALOR_TOTAL
,pro.PRODUTO, pro.COR_PRODUTO,pro.VALOR as VALOR_PRODUTO_TOTAL,pro.PRECO1 AS PRECO_UNIT, pro.QTDE_ENTRADA, TP.TABELA
from LOJA_ENTRADAS ent
left join loja_entradas_produto pro 
on ent.ROMANEIO_PRODUTO = pro.ROMANEIO_PRODUTO AND ENT.FILIAL = pro.FILIAL
left join TABELAS_PRECO TP 
on ent.CODIGO_TAB_PRECO = TP.CODIGO_TAB_PRECO
where ent.FILIAL = 'OUTLET RECIFE'