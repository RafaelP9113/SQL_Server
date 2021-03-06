SELECT	*
FROM	FATURAMENTO
WHERE	NF_SAIDA LIKE '%000013971%'
--AND		NOME_CLIFOR = 'PERDAS'
AND		FILIAL = 'ES DISTRIBUIDORA'

SELECT	*
FROM	FATURAMENTO_ITEM
WHERE	NF_SAIDA LIKE '%48995%'

SELECT	*
FROM	LOJA_ENTRADAS
WHERE	NUMERO_NF_TRANSFERENCIA LIKE '%000013971%'
AND		FILIAL_ORIGEM = 'ES DISTRIBUIDORA'

SELECT	*
FROM	LOJA_SAIDAS
WHERE	NUMERO_NF_TRANSFERENCIA LIKE '%000000008%'
AND		FILIAL_DESTINO = 'PERDAS'

LX_GERA_TRANSFERENCIA_AUTOMATICA @FILIAL='ES DISTRIBUIDORA', @ROMANEIO_PRODUTO='000013971',
@FILIAL_DESTINO='MOSTRUARIO ESTILO ESC ',@SERIE_NF='3', @ORIGEM='F', @EXCLUSAO='N'

SELECT	*
FROM	LOJAS_VAREJO
WHERE	FILIAL = 'ES DISTRIBUIDORA'