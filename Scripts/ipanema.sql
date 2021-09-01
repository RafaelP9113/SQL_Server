----------------------------retaguarda-----------------
SELECT	*
FROM	LOJA_VENDA
WHERE	DATA_VENDA = '20210205'
AND CODIGO_FILIAL = '000061'


----------------------------loja----------------------
SELECT	vp.TIPO_PGTO, tp.DESC_TIPO_PGTO, *
FROM	LOJA_VENDA v
join loja_venda_parcelas vp
on v.LANCAMENTO_CAIXA = vp.LANCAMENTO_CAIXA
left join  TIPOS_PGTO tp
on vp.TIPO_PGTO = tp.TIPO_PGTO
WHERE	DATA_VENDA = '20210205'
and v.TICKET in( '00011681', '00011682', '00011691')