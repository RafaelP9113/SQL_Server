select NOTA_CANCELADA,* 
--UPDATE LOJA_NOTA_FISCAL set NOTA_CANCELADA = '1', QTDE_CANCELADA = '5', QTDE_TOTAL = '0', VALOR_CANCELADO = '349.95',
--VALOR_TOTAL = '0', VALOR_TOTAL_ITENS = '0', DATA_CANCELAMENTO = NULL
from LOJA_NOTA_FISCAL
where NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_FILIAL = '900086'


begin tran
alter table LOJA_NOTA_FISCAL disable trigger TU_SS_LOJA_NOTA_FISCAL
Update LOJA_NOTA_FISCAL set NOTA_CANCELADA = '0'
from LOJA_NOTA_FISCAL
where NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_FILIAL = '900086'
alter table LOJA_NOTA_FISCAL enable trigger TU_SS_LOJA_NOTA_FISCAL

commit tran

select * 
from LOJA_NOTA_FISCAL_ITEM
where NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_FILIAL = '900086'


update LOJA_NOTA_FISCAL_ITEM set QTDE_ITEM = '3.0000', VALOR_ITEM ='20.97', PRECO_UNITARIO = '6.9900000000',  DESCONTO_ITEM ='0.29'
from LOJA_NOTA_FISCAL_ITEM
where NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_ITEM = '0193680013UNICO'
and CODIGO_FILIAL = '900086'


update LOJA_NOTA_FISCAL_ITEM set QTDE_ITEM = '1.0000', VALOR_ITEM ='199.99', PRECO_UNITARIO = '199.9900000000',  DESCONTO_ITEM ='2.79'
from LOJA_NOTA_FISCAL_ITEM
where NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_ITEM = '0223170014M'
and CODIGO_FILIAL = '900086'


update LOJA_NOTA_FISCAL_ITEM set QTDE_ITEM = '1.0000', VALOR_ITEM ='279.99', PRECO_UNITARIO = '279.9900000000',  DESCONTO_ITEM ='3.91'
from LOJA_NOTA_FISCAL_ITEM
where NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_ITEM = '0226240008M'
and CODIGO_FILIAL = '900086'



DELETE 
--select *
FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO in ('000002566') AND SERIE_NF = '7' AND CODIGO_FILIAL = '900086'

EXEC SP_LNX_GERA_IMPOSTOS_SAIDA_NFCE
@CODIGO_FILIAL = '900086',
@NF_SAIDA = '000002566',
@SERIE_NF = '7'


SELECT * FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO in ('000002566') AND SERIE_NF = '7' AND CODIGO_FILIAL = '900086'





UPDATE	LOJA_NOTA_FISCAL SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	LOJA_NOTA_FISCAL
WHERE	EMISSAO = '20210311'
and NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_FILIAL = '900086'

UPDATE	LOJA_NOTA_FISCAL_ITEM SET DATA_PARA_TRANSFERENCIA = GETDATE()
FROM	LOJA_NOTA_FISCAL_ITEM
WHERE NF_NUMERO = '000002566'
and SERIE_NF = '7'
and CODIGO_FILIAL = '900086'

UPDATE	LOJA_NOTA_FISCAL_IMPOSTO SET DATA_PARA_TRANSFERENCIA = GETDATE()
 FROM LOJA_NOTA_FISCAL_IMPOSTO
WHERE NF_NUMERO in ('000002566') AND SERIE_NF = '7' AND CODIGO_FILIAL = '900086'


SELECT	*
FROM	LJ_ETL_REPOSITORIO