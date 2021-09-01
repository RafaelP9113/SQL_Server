

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- ANALISES ENTRADAS -----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- PIS ENTRADA -----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE 
	@DT_INI DATE,
	@DT_FIM DATE

SELECT @DT_INI = '20210101'
SELECT @DT_FIM = '20210131'

select 
	A.RECEBIMENTO,
	A.MATRIZ_FISCAL, A.FILIAL, 
	A.NOME_CLIFOR, A.NF_ENTRADA, A.SERIE_NF_ENTRADA, A.CHAVE_NFE, A.CTB_LANCAMENTO,
	A.CODIGO_FISCAL_OPERACAO, A.CONTA_CONTABIL_ITEM, A.DESC_CONTA,
	A.CONTA_CONTABIL_IMPOSTO,  
	A.ID_IMPOSTO, CONVERT(MONEY, A.BASE_IMPOSTO) as BASE_IMPOSTO, A.TAXA_IMPOSTO, CONVERT(MONEY, A.VALOR_IMPOSTO) as VALOR_IMPOSTO
from 
(

	select
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_ENTRADA, A.SERIE_NF_ENTRADA, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from ENTRADAS A (nolock)
		inner join ENTRADAS_ITEM B (nolock)
			on A.NOME_CLIFOR=B.NOME_CLIFOR
			and A.NF_ENTRADA=B.NF_ENTRADA
			and A.SERIE_NF_ENTRADA=B.SERIE_NF_ENTRADA
		inner join ENTRADAS_IMPOSTO C (nolock)
			on A.NOME_CLIFOR=C.NOME_CLIFOR
			and A.NF_ENTRADA=C.NF_ENTRADA
			and A.SERIE_NF_ENTRADA=C.SERIE_NF_ENTRADA
			and B.ITEM_IMPRESSAO=C.ITEM_IMPRESSAO
			and B.SUB_ITEM_TAMANHO=C.SUB_ITEM_TAMANHO
		inner join FILIAIS F (nolock)
			on A.FILIAL=F.FILIAL
		inner join CTB_CONTA_PLANO P (nolock)
			on B.CONTA_CONTABIL=P.CONTA_CONTABIL
		left join CTB_EXCECAO_IMPOSTO X (nolock)
			on B.ID_EXCECAO_IMPOSTO=X.ID_EXCECAO_IMPOSTO
		inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
			on X.ID_EXCECAO_IMPOSTO=Y.ID_EXCECAO_IMPOSTO
			and C.ID_IMPOSTO=Y.ID_IMPOSTO
		inner join CTB_LANCAMENTO C1 (nolock)
			on A.CTB_LANCAMENTO=C1.LANCAMENTO
		inner join CTB_LANCAMENTO_ITEM C2 (nolock)
			on C1.LANCAMENTO=C2.LANCAMENTO
	where 
		A.RECEBIMENTO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('5')
		and C2.CONTA_CONTABIL='1102090002'
	group by 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_ENTRADA, A.SERIE_NF_ENTRADA, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

	UNION ALL

	select 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM,
		P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from LOJA_NOTA_FISCAL A (nolock)
		inner join LOJA_NOTA_FISCAL_ITEM B (nolock)
			on A.CODIGO_FILIAL = B.CODIGO_FILIAL 
			and A.NF_NUMERO = B.NF_NUMERO
			and A.SERIE_NF = B.SERIE_NF
		inner join LOJA_NOTA_FISCAL_IMPOSTO C (nolock)
			on C.CODIGO_FILIAL = B.CODIGO_FILIAL 
			and C.NF_NUMERO = B.NF_NUMERO
			and C.SERIE_NF = B.SERIE_NF		 
			and C.ITEM_IMPRESSAO = B.ITEM_IMPRESSAO
			and C.SUB_ITEM_TAMANHO = B.SUB_ITEM_TAMANHO 
		inner join LOJAS_VAREJO V
			on V.CODIGO_FILIAL = A.CODIGO_FILIAL
		inner join FILIAIS F (nolock)
			on F.FILIAL = V.FILIAL
		inner join CTB_CONTA_PLANO P (nolock)
			on P.CONTA_CONTABIL = B.CONTA_CONTABIL
		left join CTB_EXCECAO_IMPOSTO X (nolock)
			on X.ID_EXCECAO_IMPOSTO = B.ID_EXCECAO_IMPOSTO
		inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
			on Y.ID_EXCECAO_IMPOSTO = X.ID_EXCECAO_IMPOSTO
			and Y.ID_IMPOSTO = C.ID_IMPOSTO
		inner join CTB_LANCAMENTO C1 (nolock)
			on C1.LANCAMENTO = A.CTB_LANCAMENTO
		inner join CTB_LANCAMENTO_ITEM C2 (nolock)
			on C2.LANCAMENTO = C1.LANCAMENTO
	where 
		A.EMISSAO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('5')
		and C2.CONTA_CONTABIL='1102090002'
		and B.CODIGO_FISCAL_OPERACAO <='3999'
	group by 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL,
		P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

) as A

	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- COFINS ENTRADA --------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


select 
	A.RECEBIMENTO,
	A.MATRIZ_FISCAL, A.FILIAL, 
	A.NOME_CLIFOR, A.NF_ENTRADA, A.SERIE_NF_ENTRADA, A.CHAVE_NFE, A.CTB_LANCAMENTO,
	A.CODIGO_FISCAL_OPERACAO, A.CONTA_CONTABIL_ITEM, A.DESC_CONTA,
	A.CONTA_CONTABIL_IMPOSTO,  
	A.ID_IMPOSTO, CONVERT(MONEY, A.BASE_IMPOSTO) as BASE_IMPOSTO, A.TAXA_IMPOSTO, CONVERT(MONEY, A.VALOR_IMPOSTO) as VALOR_IMPOSTO
from 
(

	select
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_ENTRADA, A.SERIE_NF_ENTRADA, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		--CONVERT(MONEY, C2.DEBITO) as DEBITO_CONTABIL, 
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from ENTRADAS A (nolock)
		inner join ENTRADAS_ITEM B (nolock)
			on A.NOME_CLIFOR=B.NOME_CLIFOR
			and A.NF_ENTRADA=B.NF_ENTRADA
			and A.SERIE_NF_ENTRADA=B.SERIE_NF_ENTRADA
		inner join ENTRADAS_IMPOSTO C (nolock)
			on A.NOME_CLIFOR=C.NOME_CLIFOR
			and A.NF_ENTRADA=C.NF_ENTRADA
			and A.SERIE_NF_ENTRADA=C.SERIE_NF_ENTRADA
			and B.ITEM_IMPRESSAO=C.ITEM_IMPRESSAO
			and B.SUB_ITEM_TAMANHO=C.SUB_ITEM_TAMANHO
		inner join FILIAIS F (nolock)
			on A.FILIAL=F.FILIAL
		inner join CTB_CONTA_PLANO P (nolock)
			on B.CONTA_CONTABIL=P.CONTA_CONTABIL
		left join CTB_EXCECAO_IMPOSTO X (nolock)
			on B.ID_EXCECAO_IMPOSTO=X.ID_EXCECAO_IMPOSTO
		inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
			on X.ID_EXCECAO_IMPOSTO=Y.ID_EXCECAO_IMPOSTO
			and C.ID_IMPOSTO=Y.ID_IMPOSTO
		inner join CTB_LANCAMENTO C1 (nolock)
			on A.CTB_LANCAMENTO=C1.LANCAMENTO
		inner join CTB_LANCAMENTO_ITEM C2 (nolock)
			on C1.LANCAMENTO=C2.LANCAMENTO
	where 
		A.RECEBIMENTO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('6')
		and C2.CONTA_CONTABIL='1102090001'
	group by 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_ENTRADA, A.SERIE_NF_ENTRADA, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

	UNION ALL

	select
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from LOJA_NOTA_FISCAL A (nolock)
		inner join LOJA_NOTA_FISCAL_ITEM B (nolock)
			on A.CODIGO_FILIAL = B.CODIGO_FILIAL 
			and A.NF_NUMERO = B.NF_NUMERO
			and A.SERIE_NF = B.SERIE_NF
		inner join LOJA_NOTA_FISCAL_IMPOSTO C (nolock)
			on C.CODIGO_FILIAL = B.CODIGO_FILIAL 
			and C.NF_NUMERO = B.NF_NUMERO
			and C.SERIE_NF = B.SERIE_NF		 
			and C.ITEM_IMPRESSAO = B.ITEM_IMPRESSAO
			and C.SUB_ITEM_TAMANHO = B.SUB_ITEM_TAMANHO 
		inner join LOJAS_VAREJO V
			on V.CODIGO_FILIAL = A.CODIGO_FILIAL
		inner join FILIAIS F (nolock)
			on F.FILIAL = V.FILIAL
		inner join CTB_CONTA_PLANO P (nolock)
			on P.CONTA_CONTABIL = B.CONTA_CONTABIL
		left join CTB_EXCECAO_IMPOSTO X (nolock)
			on X.ID_EXCECAO_IMPOSTO = B.ID_EXCECAO_IMPOSTO
		inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
			on Y.ID_EXCECAO_IMPOSTO = X.ID_EXCECAO_IMPOSTO
			and Y.ID_IMPOSTO = C.ID_IMPOSTO
		inner join CTB_LANCAMENTO C1 (nolock)
			on C1.LANCAMENTO = A.CTB_LANCAMENTO
		inner join CTB_LANCAMENTO_ITEM C2 (nolock)
			on C2.LANCAMENTO = C1.LANCAMENTO
	where 
		A.EMISSAO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('6')
		and C2.CONTA_CONTABIL='1102090001'
		and B.CODIGO_FISCAL_OPERACAO <='3999'
	group by 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO
) as A




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- ANALISES FATURAMENTO -------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- PIS SAIDA -------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select
	A.EMISSAO,
	A.MATRIZ_FISCAL, A.FILIAL, 
	A.NOME_CLIFOR, A.NF_SAIDA, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
	A.CODIGO_FISCAL_OPERACAO,  A.CONTA_CONTABIL_ITEM, A.DESC_CONTA,
	A.CONTA_CONTABIL_IMPOSTO, 
	A.ID_IMPOSTO, CONVERT(MONEY, A.BASE_IMPOSTO) as BASE_IMPOSTO, A.TAXA_IMPOSTO, CONVERT(MONEY, A.VALOR_IMPOSTO) as VALOR_IMPOSTO
from
(

	select
		A.EMISSAO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_SAIDA, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from FATURAMENTO A (nolock)
		inner join FATURAMENTO_ITEM B (nolock)
			on A.FILIAL=B.FILIAL
			and A.NF_SAIDA=B.NF_SAIDA
			and A.SERIE_NF=B.SERIE_NF
		inner join FATURAMENTO_IMPOSTO C (nolock)
			on A.FILIAL=C.FILIAL
			and A.NF_SAIDA=C.NF_SAIDA
			and A.SERIE_NF=C.SERIE_NF
			and B.ITEM_IMPRESSAO=C.ITEM_IMPRESSAO
			and B.SUB_ITEM_TAMANHO=C.SUB_ITEM_TAMANHO
		inner join FILIAIS F (nolock)
			on A.FILIAL=F.FILIAL
		inner join CTB_CONTA_PLANO P (nolock)
			on B.CONTA_CONTABIL=P.CONTA_CONTABIL
		left join CTB_EXCECAO_IMPOSTO X (nolock)
			on B.ID_EXCECAO_IMPOSTO=X.ID_EXCECAO_IMPOSTO
		inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
			on X.ID_EXCECAO_IMPOSTO=Y.ID_EXCECAO_IMPOSTO
			and C.ID_IMPOSTO=Y.ID_IMPOSTO
		left join CTB_LANCAMENTO C1 (nolock)
			on A.CTB_LANCAMENTO=C1.LANCAMENTO
		inner join CTB_LANCAMENTO_ITEM C2 (nolock)
			on C1.LANCAMENTO=C2.LANCAMENTO
	where 
		A.EMISSAO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('5')
		and C2.CONTA_CONTABIL='1102090002'
	group by 
		A.EMISSAO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_SAIDA, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

	UNION ALL

	select
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from LOJA_NOTA_FISCAL A (nolock)
			inner join LOJA_NOTA_FISCAL_ITEM B (nolock)
				on A.CODIGO_FILIAL = B.CODIGO_FILIAL 
				and A.NF_NUMERO = B.NF_NUMERO
				and A.SERIE_NF = B.SERIE_NF
			inner join LOJA_NOTA_FISCAL_IMPOSTO C (nolock)
				on C.CODIGO_FILIAL = B.CODIGO_FILIAL 
				and C.NF_NUMERO = B.NF_NUMERO
				and C.SERIE_NF = B.SERIE_NF		 
				and C.ITEM_IMPRESSAO = B.ITEM_IMPRESSAO
				and C.SUB_ITEM_TAMANHO = B.SUB_ITEM_TAMANHO 
			inner join LOJAS_VAREJO V
				on V.CODIGO_FILIAL = A.CODIGO_FILIAL
			inner join FILIAIS F (nolock)
				on F.FILIAL = V.FILIAL
			inner join CTB_CONTA_PLANO P (nolock)
				on P.CONTA_CONTABIL = B.CONTA_CONTABIL
			left join CTB_EXCECAO_IMPOSTO X (nolock)
				on X.ID_EXCECAO_IMPOSTO = B.ID_EXCECAO_IMPOSTO
			inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
				on Y.ID_EXCECAO_IMPOSTO = X.ID_EXCECAO_IMPOSTO
				and Y.ID_IMPOSTO = C.ID_IMPOSTO
			inner join CTB_LANCAMENTO C1 (nolock)
				on C1.LANCAMENTO = A.CTB_LANCAMENTO
			inner join CTB_LANCAMENTO_ITEM C2 (nolock)
				on C2.LANCAMENTO = C1.LANCAMENTO
	where 
		A.EMISSAO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('5')
		and C2.CONTA_CONTABIL='1102090002'
		and B.CODIGO_FISCAL_OPERACAO >='5000'
	group by 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

) as A

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------COFINS SAIDA------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select
	A.EMISSAO,
	A.MATRIZ_FISCAL, A.FILIAL, 
	A.NOME_CLIFOR, A.NF_SAIDA, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
	A.CODIGO_FISCAL_OPERACAO,  A.CONTA_CONTABIL_ITEM, A.DESC_CONTA,
	A.CONTA_CONTABIL_IMPOSTO, 
	A.ID_IMPOSTO, CONVERT(MONEY, A.BASE_IMPOSTO) as BASE_IMPOSTO, A.TAXA_IMPOSTO, CONVERT(MONEY, A.VALOR_IMPOSTO) as VALOR_IMPOSTO
from
(

	select
		A.EMISSAO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_SAIDA, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from FATURAMENTO A (nolock)
		inner join FATURAMENTO_ITEM B (nolock)
			on A.FILIAL=B.FILIAL
			and A.NF_SAIDA=B.NF_SAIDA
			and A.SERIE_NF=B.SERIE_NF
		inner join FATURAMENTO_IMPOSTO C (nolock)
			on A.FILIAL=C.FILIAL
			and A.NF_SAIDA=C.NF_SAIDA
			and A.SERIE_NF=C.SERIE_NF
			and B.ITEM_IMPRESSAO=C.ITEM_IMPRESSAO
			and B.SUB_ITEM_TAMANHO=C.SUB_ITEM_TAMANHO
		inner join FILIAIS F (nolock)
			on A.FILIAL=F.FILIAL
		inner join CTB_CONTA_PLANO P (nolock)
			on B.CONTA_CONTABIL=P.CONTA_CONTABIL
		left join CTB_EXCECAO_IMPOSTO X (nolock)
			on B.ID_EXCECAO_IMPOSTO=X.ID_EXCECAO_IMPOSTO
		inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
			on X.ID_EXCECAO_IMPOSTO=Y.ID_EXCECAO_IMPOSTO
			and C.ID_IMPOSTO=Y.ID_IMPOSTO
		left join CTB_LANCAMENTO C1 (nolock)
			on A.CTB_LANCAMENTO=C1.LANCAMENTO
		inner join CTB_LANCAMENTO_ITEM C2 (nolock)
			on C1.LANCAMENTO=C2.LANCAMENTO
	where 
		A.EMISSAO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('6')
		and C2.CONTA_CONTABIL='1102090001'
	group by 
		A.EMISSAO,
		F.MATRIZ_FISCAL, A.FILIAL, 
		A.NOME_CLIFOR, A.NF_SAIDA, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

	UNION ALL

	select
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL as CONTA_CONTABIL_ITEM, P.DESC_CONTA,
		C2.CONTA_CONTABIL as CONTA_CONTABIL_IMPOSTO,
		C.ID_IMPOSTO, CONVERT(MONEY, C.BASE_IMPOSTO) as BASE_IMPOSTO, C.TAXA_IMPOSTO, CONVERT(MONEY, C.VALOR_IMPOSTO) as VALOR_IMPOSTO
	from LOJA_NOTA_FISCAL A (nolock)
			inner join LOJA_NOTA_FISCAL_ITEM B (nolock)
				on A.CODIGO_FILIAL = B.CODIGO_FILIAL 
				and A.NF_NUMERO = B.NF_NUMERO
				and A.SERIE_NF = B.SERIE_NF
			inner join LOJA_NOTA_FISCAL_IMPOSTO C (nolock)
				on C.CODIGO_FILIAL = B.CODIGO_FILIAL 
				and C.NF_NUMERO = B.NF_NUMERO
				and C.SERIE_NF = B.SERIE_NF		 
				and C.ITEM_IMPRESSAO = B.ITEM_IMPRESSAO
				and C.SUB_ITEM_TAMANHO = B.SUB_ITEM_TAMANHO 
			inner join LOJAS_VAREJO V
				on V.CODIGO_FILIAL = A.CODIGO_FILIAL
			inner join FILIAIS F (nolock)
				on F.FILIAL = V.FILIAL
			inner join CTB_CONTA_PLANO P (nolock)
				on P.CONTA_CONTABIL = B.CONTA_CONTABIL
			left join CTB_EXCECAO_IMPOSTO X (nolock)
				on X.ID_EXCECAO_IMPOSTO = B.ID_EXCECAO_IMPOSTO
			inner join CTB_EXCECAO_IMPOSTO_ITEM Y (nolock)
				on Y.ID_EXCECAO_IMPOSTO = X.ID_EXCECAO_IMPOSTO
				and Y.ID_IMPOSTO = C.ID_IMPOSTO
			inner join CTB_LANCAMENTO C1 (nolock)
				on C1.LANCAMENTO = A.CTB_LANCAMENTO
			inner join CTB_LANCAMENTO_ITEM C2 (nolock)
				on C2.LANCAMENTO = C1.LANCAMENTO
	where 
		A.EMISSAO between @DT_INI and @DT_FIM
		and C.ID_IMPOSTO in ('6')
		and C2.CONTA_CONTABIL='1102090001'
		and B.CODIGO_FISCAL_OPERACAO >='5000'
	group by 
		A.RECEBIMENTO,
		F.MATRIZ_FISCAL, F.FILIAL, 
		A.COD_CLIFOR, A.NF_NUMERO, A.SERIE_NF, A.CHAVE_NFE, A.CTB_LANCAMENTO,
		B.CODIGO_FISCAL_OPERACAO, B.CONTA_CONTABIL, P.DESC_CONTA,
		C2.CONTA_CONTABIL, 
		C.ID_IMPOSTO, C.BASE_IMPOSTO, C.TAXA_IMPOSTO, 
		C.VALOR_IMPOSTO

) as A

