

/****** Object:  StoredProcedure [dbo].[SP_LNX_GERA_IMPOSTOS_SAIDA_NFCE]    Script Date: 03/03/2021 09:43:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_LNX_GERA_IMPOSTOS_SAIDA_NFCE] 
                     @CODIGO_FILIAL                VARCHAR(6), 
                     @NF_SAIDA                     CHAR(15), -- #1# ALTERADO TAMANHO DA VARIAVEL @NF_SAIDA DE 7 PARA 15.
                     @SERIE_NF                     CHAR(6)

AS
-- 17/11/2017 - LUIS HENRIQUE - OTIMIZACAO PARA NFC-E CITYCOL
-- 05/06/2017 - LUIS HENRIQUE - ADAPTADO PARA IMPOSTOS DE LOJA - NFC-E
-- 23/07/2012 - DANIEL GONCALVES 1 TP 2819859 - #1# ALTERADO TAMANHO DA VARIAVEL @NF_SAIDA DE 7 PARA 15.
-- 29/02/2008 - JOAO RICARDO - CORRIGIDO A FORMA DE BUSCAR O ESTADO DE ORIGEM
-- 15/02/2008 - JOAO RICARDO - CORRIGIDO A VERIFICAÇÃO DO TIPO_DPV
-- 15/01/2008 - JOAO RICARDO - VERIFICAR O PARAMETRO TIPO_PDV E QUANDO FOR IGUAL A POWS UTILIZAR A UF DO TERCEIRO E NÃO A DA FILIAL
-- 31/01/2007 - JOAO RICARDO - RETIRADO A ALTERAÇÃO DE 17/04/2006
-- 17/04/2006 - JOAO RICARDO - VERIFICAR SE O CLIENTE É PESSOA FISICA E UTILIZAR A UF DA FILIAL
-- 14/03/2005 - Atualização conforme verificação da base adicional
-- 12/01/2004 - Alessandro - Ajustes nos arredondamentos
-- 13/10/2004 - joão ricardo - @Porcent_Reducao_de_Base aumentei a qtde de decimais
BEGIN
		------------------------------------------------------------------------------------------------------------------------------------------
		-- EFETUA LEITURA DE LINHAS QUE FORAM MODIFICADAS POR OUTRAS TRANSAÇÕES, MAS QUE AINDA NÃO FORAM CONFIRMADAS, NÃO NECESSITA USAR NOLOCK --
		------------------------------------------------------------------------------------------------------------------------------------------
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET NOCOUNT ON

DECLARE				 @FILIAL                       VARCHAR(25),
                     @RECRIAR                      BIT   = 0, 
                     @EXECUTAR_AJUSTE_GRUPO        BIT   = 1, 
                     @RECALCULAR_IMPOSTO_AGREGAR   BIT   = 0 

--Definido constantes dos impostos
DECLARE  @cnICMS    SMALLINT
, @cnIPI     SMALLINT
, @cnIRRF    SMALLINT
, @cnINSS    SMALLINT
, @cnPIS     SMALLINT
, @cnCOFINS  SMALLINT
, @cnIIMPORT SMALLINT
, @cnIVA     SMALLINT
, @cnRECARGO SMALLINT
, @cnIRPF    SMALLINT
, @cnDICMS   SMALLINT
, @cnISS     SMALLINT
, @Valor_Imposto_Agregar Numeric(14,2)
, @Valor_Imposto_Agregar_ant Numeric(14,2)


SELECT  @cnICMS =   1, @cnIPI     =  2, @cnIRRF    =  3, @cnINSS    =  4, @cnPIS     =  5, @cnCOFINS  =  6, 
@cnIIMPORT = 7, @cnIVA     = 8, @cnRECARGO = 9, @cnIRPF    = 10, @cnDICMS   = 11, @cnISS = 14

------------------------------------------------------

--Informações dos impostos
DECLARE @ID_Imposto             tinyint,
@Imposto                        varchar(25),
@Incidencia                     tinyint,
@Porcent_Reducao_de_Base        numeric(12,6),
@Aliquota_Fixa                  bit,
@Taxa_Imposto_Excecao           numeric(8,2),
@Taxa_Imposto                   numeric(8,2),
@Agrega_Apos_Encargo            bit,
@Agrega_Apos_Desconto           bit,
@APLICA_ESPELHO_ENTRADA         bit,
@ISENTO_OU_OUTROS               char(1),
@Calculo_Decimal                tinyint,
@base_adicional 		numeric(14,2),
@indica_consumidor_final 	bit
---------------------------------------------------------

--Declarações extras
declare @cSelect varchar(4000), @nTaxa numeric(14,6) , @nTaxaAux  numeric(14,6), @nBase  numeric(14,6), @nBase_Espelho   numeric(14,6), 
@nValor   numeric(14,6), @nImposto_Total  numeric(14,6), @nAgrega   numeric(14,6), @lExisteImposto bit, @nID_Excecao_Imposto int, 
@tipo_operacao CHAR(1), @CTB_Tipo_Operacao INT, @PJ_PF bit,  @UF_ORIGEM CHAR(2), @UF_DESTINO CHAR(2), @IPI_CALC numeric(8,5)


--Declaração das variáveis dos itens de saida
DECLARE @ITEM_IMPRESSAO CHAR(4), @SUB_ITEM_TAMANHO INT, @ID_EXCECAO_IMPOSTO INT,
@VALOR_ENCARGOS NUMERIC(14,2), @VALOR_DESCONTOS NUMERIC(14,2),  @VALOR_ITEM NUMERIC(14,2), @INDICADOR_CFOP TINYINT, @valor_encargos_importacao NUMERIC(14,2),
@CLASSIF_FISCAL CHAR(10), @TERCEIRO VARCHAR(25)



-- APOIO AO ICMS
DECLARE @ICMS_SAIDA NUMERIC(14,6)

--filial
--SELECT @FILIAL = FILIAL FROM FILIAIS (NOLOCK) WHERE COD_FILIAL = @CODIGO_FILIAL -->> Comentado por Marco variavel sem utilização - 27/11/2017



--Terceiro
--SELECT @TERCEIRO = ISNULL(CODIGO_FILIAL_DESTINO,CODIGO_CLIENTE) FROM LOJA_NOTA_FISCAL WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND NF_NUMERO = @NF_SAIDA AND SERIE_NF = @SERIE_NF

--SELECT @TERCEIRO = NOME_CLIFOR  FROM FATURAMENTO WHERE FILIAL=@FILIAL AND NF_SAIDA=@NF_SAIDA AND SERIE_NF=@SERIE_NF


--- SEMPRE RECRIA OS IMPOSTOS
--IF @RECRIAR = 0 AND EXISTS(SELECT 1 FROM FATURAMENTO_IMPOSTO WHERE FILIAL = @FILIAL AND  NF_SAIDA=@NF_SAIDA AND SERIE_NF=@SERIE_NF)
--BEGIN 
--   Print 'Já foram gerados os impostos da nf: '+@NF_SAIDA+', série: '+ @SERIE_NF+', da filial "'+@FILIAL+'"'   
--   return 
--END 

/*
IF @RECRIAR = 1 --Se recriar, exclui os impostos
BEGIN 
    DELETE FROM LOJA_NOTA_FISCAL_IMPOSTO WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND  NF_NUMERO=@NF_SAIDA AND SERIE_NF=@SERIE_NF
END 
*/
--Pegando informações do terceiro

--select @PJ_PF = c.PJ_PF from cadastro_cli_for as c join faturamento as f on (c.nome_clifor=f.nome_clifor) WHERE f.FILIAL = @FILIAL AND  f.NF_SAIDA=@NF_SAIDA AND f.SERIE_NF=@SERIE_NF
/*
SELECT @PJ_PF = ISNULL( C.PJ_PF, CASE WHEN ISNULL(V.PF_PJ,0) = 0 THEN 1 ELSE 0 END ) 
 FROM LOJA_NOTA_FISCAL LNF (NOLOCK)
	LEFT JOIN CADASTRO_CLI_FOR C ON LNF.CODIGO_FILIAL_DESTINO = C.COD_CLIFOR
	LEFT JOIN CLIENTES_VAREJO V ON LNF.CODIGO_CLIENTE =V.CODIGO_CLIENTE
	WHERE LNF.CODIGO_FILIAL = @CODIGO_FILIAL AND  LNf.NF_NUMERO=@NF_SAIDA AND LNf.SERIE_NF=@SERIE_NF
*/

--CAPTURANDO INFORMAÇÕES DA TABELA PAI

/*
IF (SELECT DISTINCT ISNULL(RTRIM(C.VALOR_ATUAL),'POS')
		FROM LOJA_NOTA_FISCAL A (NOLOCK)
				LEFT JOIN LOJAS_VAREJO B (NOLOCK) ON 
					B.CODIGO_FILIAL					= A.CODIGO_FILIAL
				LEFT JOIN PARAMETROS_LOJA C (NOLOCK) ON
					C.PARAMETRO				= 'TIPO_PDV'		AND
					C.CODIGO_FILIAL		= 	B.CODIGO_FILIAL 
			WHERE A.CODIGO_FILIAL = @CODIGO_FILIAL AND  A.NF_NUMERO=@NF_SAIDA AND A.SERIE_NF=@SERIE_NF	) = 'POWS'
		BEGIN

			SELECT @tipo_operacao = tipo_operacao, @CTB_Tipo_Operacao = CTB_Tipo_Operacao,
			@UF_ORIGEM = F.UF, 
			@UF_DESTINO = T.UF, 
			@indica_consumidor_final = E.INDICA_CONSUMIDOR_FINAL
			 FROM FATURAMENTO (NOLOCK) AS E 
						JOIN NATUREZAS_SAIDAS (NOLOCK) AS N ON (E.NATUREZA_SAIDA=N.NATUREZA_SAIDA)
						JOIN CADASTRO_CLI_FOR (NOLOCK) AS T ON (E.NOME_CLIFOR = T.NOME_CLIFOR)
						JOIN CADASTRO_CLI_FOR (NOLOCK) AS F ON (E.FILIAL      = F.NOME_CLIFOR)
			WHERE E.FILIAL = @FILIAL AND  E.NF_SAIDA=@NF_SAIDA AND E.SERIE_NF=@SERIE_NF
		END
	ELSE
		BEGIN
*/
			 SELECT /*@tipo_operacao = tipo_operacao,*/
				   /*@CTB_Tipo_Operacao = LN.CTB_Tipo_Operacao,*/
				   @UF_ORIGEM = F.UF,
				   @UF_DESTINO = ISNULL(DC.UF, F.UF),
				   @indica_consumidor_final = E.INDICA_CONSUMIDOR_FINAL
			 FROM LOJA_NOTA_FISCAL    AS E  WITH (NOLOCK) 
				 JOIN LOJAS_NATUREZA_OPERACAO LN  WITH (NOLOCK)  ON E.NATUREZA_OPERACAO_CODIGO = LN.NATUREZA_OPERACAO_CODIGO
				 --JOIN NATUREZAS_SAIDAS    AS N WITH (NOLOCK) ON LN.NATUREZA_SAIDA = N.NATUREZA_SAIDA
				 LEFT JOIN CADASTRO_CLI_FOR DC  WITH (NOLOCK)  ON E.COD_CLIFOR = DC.COD_CLIFOR
				 LEFT JOIN CLIENTES_VAREJO DV  WITH (NOLOCK)  ON E.CODIGO_CLIENTE = DV.CODIGO_CLIENTE
				 JOIN CADASTRO_CLI_FOR    AS F WITH (NOLOCK) ON E.CODIGO_FILIAL = F.COD_CLIFOR
			 WHERE E.CODIGO_FILIAL = @CODIGO_FILIAL
				  AND E.NF_NUMERO = @NF_SAIDA
				  AND E.SERIE_NF = @SERIE_NF;
/*		END	
*/
--RECALCULANDO RATEIOS

/*
EXEC LX_CALCULA_PORCENTAGEM_ITEM_RATEIO @FILIAL , @NF_SAIDA , @SERIE_NF , 'S'
EXEC LX_CALCULA_RATEIO_ENCARGOS_DESCONTOS @FILIAL , @NF_SAIDA , @SERIE_NF , 'S'
*/
--------------------------------------------------------------------------------------

DECLARE CUR_ITENS CURSOR LOCAL READ_ONLY
FOR
    SELECT ITEM_IMPRESSAO,
           SUB_ITEM_TAMANHO,
           ID_EXCECAO_IMPOSTO,
           VALOR_ENCARGOS ,
           VALOR_DESCONTOS ,
           VALOR_ITEM,
           INDICADOR_CFOP,
           valor_encargos_importacao = 0,
           CLASSIF_FISCAL
    FROM LOJA_NOTA_FISCAL_ITEM  WITH (NOLOCK) 
    WHERE CODIGO_FILIAL = @CODIGO_FILIAL
          AND NF_NUMERO = @NF_SAIDA
          AND SERIE_NF = @SERIE_NF;


OPEN CUR_ITENS

FETCH NEXT FROM CUR_ITENS INTO @ITEM_IMPRESSAO , @SUB_ITEM_TAMANHO , @ID_EXCECAO_IMPOSTO ,
@VALOR_ENCARGOS , @VALOR_DESCONTOS,  @VALOR_ITEM , @INDICADOR_CFOP, @valor_encargos_importacao, @CLASSIF_FISCAL


WHILE @@FETCH_STATUS = 0
BEGIN
--SELECT 'ENTRANDO NO WHILE DO PRIMEIRO CURSOR - ITENS' + ' - ITEM - ' + CONVERT(VARCHAR,@ITEM_IMPRESSAO) + CONVERT(VARCHAR,GETDATE(),113)	


--SELECT '@'+CONVERT(VARCHAR(30),COLUMN_NAME) , CONVERT(VARCHAR(30),DATA_TYPE)+',',CHARACTER_MAXIMUM_LENGTH, CHARACTER_OCTET_LENGTH, NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TESTE_ALE'
--SELECT '@'+CONVERT(VARCHAR(30),COLUMN_NAME)+','  FROM INFORMATION_SCHEMA.COLUMNS   WHERE TABLE_NAME = 'TESTE_ALE'

	--Zerando base adicional
	select @base_adicional = 0	

	DECLARE CUR_IMPOSTOS CURSOR LOCAL READ_ONLY FOR
	SELECT CTB_LX_Imposto_Tipo.ID_Imposto, CTB_LX_Imposto_Tipo.Imposto, ISNULL(CTB_Excecao_Imposto_Item.Incidencia, 
	CTB_LX_Imposto_Tipo.Incidencia) AS Incidencia, ISNULL(CTB_Excecao_Imposto_Item.Porcent_Reducao_de_Base, 0) AS 
	Porcent_Reducao_de_Base, CTB_LX_Imposto_Tipo.Aliquota_Fixa, ISNULL(CTB_Excecao_Imposto_Item.Taxa_Imposto, 0) AS Taxa_Imposto_Excecao, 
	CTB_LX_Imposto_Tipo.Aliquota As Taxa_Imposto , 
	ISNULL(CTB_Excecao_Imposto_Item.Agrega_Apos_Encargo, CTB_LX_Imposto_Tipo.Agrega_Apos_Encargo) AS Agrega_Apos_Encargo, 
	ISNULL(CTB_Excecao_Imposto_Item.Agrega_Apos_Desconto, CTB_LX_Imposto_Tipo.Agrega_Apos_Desconto) AS Agrega_Apos_Desconto, 
	ISNULL(CTB_Excecao_Imposto_Item.APLICA_ESPELHO_ENTRADA,0) AS APLICA_ESPELHO_ENTRADA, ISNULL(CTB_Excecao_Imposto_Item.ISENTO_OU_OUTROS,'') AS ISENTO_OU_OUTROS, 
	CTB_LX_Imposto_Tipo.Calculo_Decimal 
	FROM CTB_LX_Imposto_Tipo  WITH (NOLOCK)  LEFT JOIN CTB_Excecao_Imposto_ITem  WITH (NOLOCK)  ON CTB_LX_Imposto_Tipo.ID_Imposto = 
	CTB_Excecao_Imposto_Item.ID_Imposto AND ID_Excecao_Imposto = @ID_EXCECAO_IMPOSTO WHERE ( Gera_na_Saida = 1 OR ID_Excecao_Imposto = @ID_EXCECAO_IMPOSTO )
	order by ctb_lx_imposto_tipo.id_imposto desc 
	
	OPEN CUR_IMPOSTOS

	FETCH NEXT FROM CUR_IMPOSTOS INTO @ID_Imposto,
	@Imposto,
	@Incidencia,
	@Porcent_Reducao_de_Base,
	@Aliquota_Fixa,
	@Taxa_Imposto_Excecao,
	@Taxa_Imposto,
	@Agrega_Apos_Encargo,
	@Agrega_Apos_Desconto,
	@APLICA_ESPELHO_ENTRADA,
	@ISENTO_OU_OUTROS,
	@Calculo_Decimal


	WHILE @@FETCH_STATUS = 0
	BEGIN 
---SELECT 'ENTRANDO NO WHILE DO SEGUNDO CURSOR - GERANDO IMPOSTO' + ' - ITEM - ' + CONVERT(VARCHAR,@ITEM_IMPRESSAO) +    '- IMPOSTO - ' + CONVERT(VARCHAR,@Imposto) + CONVERT(VARCHAR,GETDATE(),113)		
		SELECT 	@nTaxa          = 0,
			@nBase          = 0,
			@nValor         = 0,
			@lExisteImposto = 1


		--Calculando taxa do imposto que não é especial		
		If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) 
			select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
		Else
			select @lExisteImposto = 0
		-----------------------------------------------

		if @ID_Imposto = @cnICMS   
		begin        

				   --LH
				If  NOT (RTRIM(@ISENTO_OU_OUTROS)='X' OR  @INDICADOR_CFOP=89) --SERVIÇOS DIVERSOS 
					BEGIN
						SELECT  @ICMS_SAIDA=ICMS_SAIDA FROM UNIDADES_FEDERACAO_ICMS  WITH (NOLOCK) WHERE UF =@UF_ORIGEM AND UF_DESTINO = @UF_DESTINO
						select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else 
								case when @Aliquota_Fixa=1 then  @Taxa_Imposto else	@ICMS_SAIDA  end end
					END				
				Else
					select @lExisteImposto = 0
		end
				
				
		if @ID_Imposto = @cnIPI
		begin
				
				If  NOT (RTRIM(@ISENTO_OU_OUTROS)='X' OR  @INDICADOR_CFOP=89) --SERVIÇOS DIVERSOS 
                                begin
					SELECT @IPI_CALC = IPI FROM Classif_Fiscal  WITH (NOLOCK) WHERE Classif_Fiscal = @CLASSIF_FISCAL
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else @IPI_CALC end end
				end
				Else
					select @lExisteImposto = 0
		end
				
	/*	if @ID_Imposto = @cnIRRF
		begin
				
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) AND  @INDICADOR_CFOP=89 AND @CTB_Tipo_Operacao= 202 --SERVIÇOS DIVERSOS 
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end
	*/			
				
		if @ID_Imposto = @cnINSS
		begin
						
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) 
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end
				
		if @ID_Imposto = @cnPIS
		begin
				
			
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) 
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end
				
		if @ID_Imposto = @cnCOFINS
		begin
				
			
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) 
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end

		if @ID_Imposto = @cnISS
		begin
				
			
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) 
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end

/*		if @ID_Imposto = @cnIIMPORT
		begin
				

				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) 
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end
	*/			
/*		if @ID_Imposto = @cnIVA
		begin	
				
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) AND CHARINDEX(@tipo_operacao,'GNTR')>0
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		
		end
				
	*/	
			
	/*	if @ID_Imposto = @cnRECARGO
		begin
					
				
				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) AND @PJ_PF=0
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
		end
*/
	/*	if @ID_Imposto = @cnIRPF			
		begin
						

				If   ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' ) AND @PJ_PF=0 and @CTB_Tipo_Operacao in (201,202,205)
					select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else 0 end end
				Else
					select @lExisteImposto = 0
				
		end
	*/			
/*		if @ID_Imposto = @cnDICMS	
		begin
							
				IF @INDICADOR_CFOP in (13,20) --MATERIAL DE USO E CONSUMO ou ATIVO FIXO / IMOBILIZADO
				begin
					
				    IF ( NOT RTRIM(@ISENTO_OU_OUTROS)='X' )  --Não há exceção que possa impedir a geração do imposto
				    Begin
						
						select  @nTaxa = case when @Taxa_Imposto_Excecao > 0 then @Taxa_Imposto_Excecao else case when @Aliquota_Fixa=1 then  @Taxa_Imposto else DBO.FX_DIFERENCIAL_ICMS(@UF_ORIGEM, @UF_DESTINO,@TIPO_OPERACAO) end end
						IF @nTaxa <= 0
						   select @lExisteImposto = 0
				    end
				    Else
						select @lExisteImposto = 0
				end 	
				Else
					select @lExisteImposto = 0
		end		
*/		
		
		If @lExisteImposto = 1
		begin

					
			If @nTaxa = 0
			begin	

				select 	@nTaxa  = 0,
					@nBase  = 0,
					@nValor = 0
			end
			Else
			begin
				
						
				select @nBase = @Valor_Item + case when @ID_Imposto = 1 then @base_adicional else 0 end
				
				If @Agrega_Apos_Encargo = 1
				begin
					select @nBase   = ( @nBase + @valor_encargos )
				End
				
				If @Agrega_Apos_Desconto=1
				begin					
					select @nBase   = ( @nBase - @valor_descontos )
				End
				
				--Aplicando a redução de base
				select @nBase = ( @nBase * ( ( 100 - @Porcent_Reducao_de_Base ) / 100.00 ) )
				
				select @nValor = case when (@Calculo_Decimal in (0,2)) then Round(( ( @nBase * @nTaxa ) / 100.00 ),2) else convert(Int,( @nBase * @nTaxa))/100.00  end

				if @indica_consumidor_final=1 and @ID_Imposto=2
					select @base_adicional = @nValor
					
			End
			
			--Inserindo impostos
				INSERT INTO LOJA_NOTA_FISCAL_IMPOSTO
					   (CODIGO_FILIAL,
					    NF_NUMERO,
					    SERIE_NF,
					    Item_Impressao,
					    Sub_Item_Tamanho,
					    ID_Imposto,
					    Taxa_Imposto,
					    Base_Imposto,
					    Valor_Imposto,
					    Incidencia,
					    Agrega_Apos_Encargo,
					    Agrega_Apos_Desconto
					   )
				SELECT
					    @CODIGO_FILIAL,
					    @NF_SAIDA,
					    @SERIE_NF,
					    @Item_Impressao,
					    @Sub_Item_Tamanho,
					    @ID_Imposto,
					    CASE WHEN @nBase = 0 THEN 0 ELSE @nTaxa END,
					    @nBase,
					    @nValor,
					    @Incidencia,
					    @Agrega_Apos_Encargo,
					    @Agrega_Apos_Desconto
				WHERE NOT EXISTS (SELECT 1 FROM LOJA_NOTA_FISCAL_IMPOSTO  WITH (NOLOCK) 
							WHERE CODIGO_FILIAL = @CODIGO_FILIAL AND NF_NUMERO = @NF_SAIDA AND SERIE_NF = @SERIE_NF
							AND ITEM_IMPRESSAO = @ITEM_IMPRESSAO AND ID_IMPOSTO = @ID_IMPOSTO )

				--WHERE RTRIM(@CODIGO_FILIAL) + RTRIM(@NF_SAIDA) + RTRIM(@SERIE_NF)+RTRIM(@ITEM_IMPRESSAO)+ RTRIM(CONVERT(VARCHAR(3),@ID_IMPOSTO))
				--		NOT IN (SELECT LTRIM(CODIGO_FILIAL)+RTRIM(NF_NUMERO)+RTRIM(SERIE_NF) + RTRIM(ITEM_IMPRESSAO) + RTRIM(CONVERT(VARCHAR(3),ID_IMPOSTO))
				--				FROM LOJA_NOTA_FISCAL_IMPOSTO (NOLOCK));

								
		end 

--SELECT 'FINAL DO WHILE DO SEGUNDO CURSOR - GERANDO IMPOSTO' + ' - ITEM - ' + CONVERT(VARCHAR,@ITEM_IMPRESSAO) +    '- IMPOSTO - ' + CONVERT(VARCHAR,@Imposto) + CONVERT(VARCHAR,GETDATE(),113)
			
			FETCH NEXT FROM CUR_IMPOSTOS INTO @ID_Imposto,
			@Imposto,
			@Incidencia,
			@Porcent_Reducao_de_Base,
			@Aliquota_Fixa,
			@Taxa_Imposto_Excecao,
			@Taxa_Imposto,
			@Agrega_Apos_Encargo,
			@Agrega_Apos_Desconto,
			@APLICA_ESPELHO_ENTRADA,
			@ISENTO_OU_OUTROS,
			@Calculo_Decimal

	End -- Impostos 
	
	CLOSE CUR_IMPOSTOS
	DEALLOCATE CUR_IMPOSTOS


	FETCH NEXT FROM CUR_ITENS INTO @ITEM_IMPRESSAO , @SUB_ITEM_TAMANHO , @ID_EXCECAO_IMPOSTO ,
	@VALOR_ENCARGOS , @VALOR_DESCONTOS,  @VALOR_ITEM , @INDICADOR_CFOP, @valor_encargos_importacao, @CLASSIF_FISCAL

--SELECT 'FINAL DO WHILE DO PRIMEIRO CURSOR - ITENS' + ' - ITEM - ' + CONVERT(VARCHAR,@ITEM_IMPRESSAO) +CONVERT(VARCHAR,GETDATE(),113)	
End --Itens Fiscais

CLOSE CUR_ITENS
DEALLOCATE CUR_ITENS

/*
IF @EXECUTAR_AJUSTE_GRUPO=1
	EXEC LX_CALCULA_AJUSTE_GRUPO_IMPOSTO @FILIAL , @NF_SAIDA , @SERIE_NF , 'S'



--Atualizando o imposto a agregar na nota fiscal
IF @RECALCULAR_IMPOSTO_AGREGAR=1
BEGIN

	SELECT @Valor_Imposto_Agregar=Sum ( Valor_Imposto * case when Incidencia = 2 then  -1 else  1 end ) 
	FROM FATURAMENTO_IMPOSTO WHERE FILIAL = @FILIAL AND  NF_SAIDA=@NF_SAIDA AND SERIE_NF=@SERIE_NF AND ( INCIDENCIA in (1,2) )
	
	SELECT @Valor_Imposto_Agregar_ant=Valor_Imposto_Agregar 
	FROM FATURAMENTO WHERE FILIAL = @FILIAL AND  NF_SAIDA=@NF_SAIDA AND SERIE_NF=@SERIE_NF
	
	IF (ISNULL(@Valor_Imposto_Agregar,0)-ISNULL(@Valor_Imposto_Agregar_ant,0))<>0
		UPDATE FATURAMENTO SET  Valor_Imposto_Agregar = ISNULL(@Valor_Imposto_Agregar,0), valor_total = valor_total + (ISNULL(@Valor_Imposto_Agregar,0)-ISNULL(@Valor_Imposto_Agregar_ant,0))
		WHERE  FILIAL = @FILIAL AND  NF_SAIDA=@NF_SAIDA AND SERIE_NF=@SERIE_NF

END
-------------------------------------------------
*/

SET NOCOUNT OFF

END


GO


