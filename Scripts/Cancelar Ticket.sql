------------------------------------------- $1. Declarando Variáveis-------------------------------------------------------

DECLARE @TICKET CHAR(8),@FILIAL CHAR(6),@DATA DATETIME,@TERMINAL CHAR(3),@LANCAMENTO_CAIXA CHAR(7), @STATUS  TINYINT, @COMISSAO NUMERIC(9,4)

------------------------------------------- $2. Atribuindo valores às variáveis--------------------------------------------
    
SELECT @TICKET   = '263'                              -- Digite o número do ticket
SELECT @FILIAL   = '001018'     -- Digite o código da filial
SELECT @DATA     = '20150228'   -- Digite a data da venda
SELECT @TERMINAL = '002'        -- Digite o código do terminal
SELECT @STATUS     = '3'        -- "0" para cancelar ou "1" para desfazer cancelamento. "2" PARA CANCELAR UMA DEVOLUÇÃO EM DINHEIRO. "3" USAR SÓ O SELECT.

SELECT 
    @LANCAMENTO_CAIXA = LANCAMENTO_CAIXA 
FROM 
    LOJA_VENDA 
WHERE 
    TICKET=@TICKET AND 
    DATA_VENDA=@DATA AND 
    TERMINAL=@TERMINAL AND 
    CODIGO_FILIAL=@FILIAL
    
-------------------------------------------------- $3.Selects de verificação ---------------------------------------------------------

SELECT    
    *
FROM
    LOJA_VENDA
WHERE    
    TICKET            = @TICKET AND    
    CODIGO_FILIAL    = @FILIAL AND    
    TERMINAL        = @TERMINAL AND        
    DATA_VENDA        = @DATA
    
------------------------------------------------------------    

SELECT
    *
FROM
    LOJA_VENDA_PGTO
WHERE    
    LANCAMENTO_CAIXA    = @LANCAMENTO_CAIXA AND    
    TERMINAL            = @TERMINAL AND        
    CODIGO_FILIAL        = @FILIAL AND        
    DATA                = @DATA
    
-------------------------------------------------------------

SELECT    
    *
FROM    
    LOJA_VENDA_PRODUTO
WHERE    
    TICKET            = @TICKET AND    
    CODIGO_FILIAL    = @FILIAL AND        
    DATA_VENDA        = @DATA
    
-------------------------------------------------------------

SELECT
    *
FROM
    LOJA_VENDA_PARCELAS
WHERE
    CODIGO_FILIAL    = @FILIAL AND
    TERMINAL        = @TERMINAL AND
    LANCAMENTO_CAIXA= @LANCAMENTO_CAIXA
    
--------------------------------------------------------------
    
SELECT
    *
FROM    
    LOJA_VENDA_TROCA
WHERE
    CODIGO_FILIAL    = @FILIAL AND
    TICKET            = @TICKET AND
    DATA_VENDA        = @DATA

--------------------------------------------------------------

SELECT  *
--DELETE
FROM   LOJA_HISTORICO_VENDA
WHERE TICKET                                 = @TICKET
AND                      DATA_VENDA                  = @DATA
AND                      CODIGO_FILIAL               = @FILIAL


------------------------------------------------------- &4. Inicio da programação-------------------------------------------------------------

IF @STATUS = 0

BEGIN TRAN

BEGIN

    IF(
        SELECT    CANCELADO_FISCAL
        FROM    LOJA_VENDA_PGTO
        WHERE    LANCAMENTO_CAIXA    = @LANCAMENTO_CAIXA AND    
                TERMINAL            = @TERMINAL AND        
                CODIGO_FILIAL        = @FILIAL AND        
                DATA                = @DATA    
    ) = 1
    
    BEGIN
        PRINT 'Esta venda já se encontra cancelada em loja_venda_pgto. Por favor, verifique. '
        return
    END
    
    ELSE
    BEGIN
                               -- &4.   DELETANDO LOJA_HISTORICO_VENDA -- LUIZ

                               DELETE
                                               FROM   LOJA_HISTORICO_VENDA
                                               WHERE TICKET                                 = @TICKET
                                               AND                      DATA_VENDA                  = @DATA
                                               AND                      CODIGO_FILIAL               = @FILIAL

        -- &4.a. Cancelando a venda em LOJA_VENDA

        UPDATE    
            LOJA_VENDA
        SET        
            TOTAL_QTDE_CANCELADA    = TOTAL_QTDE_CANCELADA + QTDE_TOTAL, 
            QTDE_TOTAL                = 0 , 
            DESCONTO                = 0, 
            VALOR_TIKET                = 0, 
            VALOR_CANCELADO            = VALOR_VENDA_BRUTA, 
            VALOR_VENDA_BRUTA        = 0, 
            VALOR_PAGO                = 0
        WHERE    
            TICKET            = @TICKET AND    
            CODIGO_FILIAL    = @FILIAL AND    
            TERMINAL        = @TERMINAL AND        
            DATA_VENDA        = @DATA
            

        -- &4.b. Cancelando a venda em LOJA_VENDA_PGTO

        UPDATE    
            LOJA_VENDA_PGTO
        SET        
            VALOR_CANCELADO        = TOTAL_VENDA, 
            TOTAL_VENDA            = 0, 
            CANCELADO_FISCAL    = 1
        WHERE    
            LANCAMENTO_CAIXA    = @LANCAMENTO_CAIXA AND    
            TERMINAL            = @TERMINAL AND        
            CODIGO_FILIAL        = @FILIAL AND        
            DATA                = @DATA
            
        -- &4.c. Cancelando em LOJA_VENDA_PRODUTO

        UPDATE    
            LOJA_VENDA_PRODUTO
        SET        
            QTDE_CANCELADA            = QTDE_CANCELADA + QTDE, 
            PRECO_LIQUIDO            = PRECO_LIQUIDO + DESCONTO_ITEM,
            DESCONTO_ITEM            = 0, 
            FATOR_DESCONTO_VENDA    = 0, 
            QTDE                    = 0        
        WHERE    
            TICKET            = @TICKET AND    
            CODIGO_FILIAL    = @FILIAL AND        
            DATA_VENDA        = @DATA
            
        -- Cancelando em LOJA_VENDA_PARCELAS

        UPDATE
            LOJA_VENDA_PARCELAS
        SET
            VALOR_CANCELADO = VALOR,
            VALOR            = 0
        WHERE
            CODIGO_FILIAL    = @FILIAL AND
            TERMINAL        = @TERMINAL AND
            LANCAMENTO_CAIXA= @LANCAMENTO_CAIXA
            
        -- Cancelando em LOJA_VENDA_TROCA

        UPDATE
            LOJA_VENDA_TROCA
        SET    
            QTDE_CANCELADA    = QTDE,
            QTDE            = 0
        WHERE
            CODIGO_FILIAL    = @FILIAL AND
            TICKET            = @TICKET AND
            DATA_VENDA        = @DATA
        END
END

-- &4.a. Desfazendo cancelamento

-- &4.a. Desfazendo cancelamento em LOJA_VENDA

IF @STATUS = 1

BEGIN    

    SELECT    @comissao =        COMISSAO /100 * (    SELECT    VALOR_TIKET
                                                FROM    LOJA_VENDA
                                                WHERE    TICKET            = @TICKET AND    
                                                        CODIGO_FILIAL    = @FILIAL AND    
                                                        TERMINAL        = @TERMINAL AND        
                                                        DATA_VENDA        = @DATA)
    FROM    LOJA_VENDEDORES
    WHERE    VENDEDOR IN (    SELECT    VENDEDOR
                            FROM    LOJA_VENDA
                            WHERE    TICKET            = @TICKET AND    
                                    CODIGO_FILIAL    = @FILIAL AND    
                                    TERMINAL        = @TERMINAL AND        
                                    DATA_VENDA        = @DATA) 
                                        
                                
    --    update em LOJA_VENDA
    
    UPDATE    LOJA_VENDA
    SET        COMISSAO = @COMISSAO,
            QTDE_TOTAL = TOTAL_QTDE_CANCELADA,
            TOTAL_QTDE_CANCELADA = 0,
            VALOR_TIKET = VALOR_CANCELADO,
           VALOR_VENDA_BRUTA = VALOR_CANCELADO,
            VALOR_PAGO = VALOR_CANCELADO,
            VALOR_CANCELADO = 0,
            DATA_HORA_CANCELAMENTO = NULL,
            MOTIVO_CANCELAMENTO = NULL
    WHERE    TICKET            = @TICKET AND    
            CODIGO_FILIAL    = @FILIAL AND    
            TERMINAL        = @TERMINAL AND        
            DATA_VENDA        = @DATA
            
    IF(    SELECT    COUNT(*) 
        FROM    LOJA_VENDA_PRODUTO
        WHERE    TICKET            = @TICKET AND    
                CODIGO_FILIAL    = @FILIAL AND        
                DATA_VENDA        = @DATA)>0
    BEGIN
        UPDATE    LOJA_VENDA
        SET        VALOR_IPI =    (    CAST(((    SELECT    SUM(IPI*(QTDE*PRECO_LIQUIDO))
                                        FROM    LOJA_VENDA_PRODUTO
                                        WHERE    TICKET            = @TICKET AND    
                                                CODIGO_FILIAL    = @FILIAL AND        
                                                DATA_VENDA        = @DATA)/100) AS NUMERIC(14,2)))
        WHERE    TICKET            = @TICKET AND    
                CODIGO_FILIAL    = @FILIAL AND    
                TERMINAL        = @TERMINAL AND        
                DATA_VENDA        = @DATA
        
    END
                                
-- UPDATE EM LOJA_VENDA_PGTO

    UPDATE    LOJA_VENDA_PGTO
    SET        TOTAL_VENDA = VALOR_CANCELADO,
            VALOR_CANCELADO = 0,
            CANCELADO_FISCAL=0
    where    LANCAMENTO_CAIXA = @LANCAMENTO_CAIXA and
            CODIGO_FILIAL = @FILIAL and
            TERMINAL = @TERMINAL and
            DATA = @DATA        

END

IF @STATUS       = 2  --"2" PARA CANCELAR UMA DEVOLUÇÃO EM DINHEIRO. ##LUIZ -- TRATAMENTO PARA CANCELAMENTOS COM DEVOLUÇÃO EM DINHEIRO.

BEGIN TRAN

                BEGIN

                               UPDATE               LOJA_VENDA SET VALOR_TROCA = 0, QTDE_TROCA_TOTAL = 0, DATA_HORA_CANCELAMENTO = GETDATE()
                               FROM   LOJA_VENDA
                               WHERE LOJA_VENDA.CODIGO_FILIAL  = @FILIAL
                               AND                      LOJA_VENDA.DATA_VENDA                     = @DATA
                               AND                      LOJA_VENDA.TERMINAL                            = @TERMINAL
                               AND                      LOJA_VENDA.TICKET                                    = @TICKET


                               UPDATE               LOJA_VENDA_TROCA SET QTDE = 0, PRECO_LIQUIDO = 0, CUSTO = 0
                               FROM   LOJA_VENDA_TROCA
                               WHERE CODIGO_FILIAL               = @FILIAL
                               AND                      DATA_VENDA                  = @DATA
                               AND                      TICKET                                 = @TICKET


                               UPDATE               LOJA_VENDA_PARCELAS SET VALOR = 0, VENCIMENTO = NULL
                               FROM   LOJA_VENDA_PARCELAS
                               WHERE CODIGO_FILIAL                               = @FILIAL
                               AND                      LANCAMENTO_CAIXA  = @LANCAMENTO_CAIXA
                               AND                      TERMINAL                                         = @TERMINAL


                               UPDATE               LOJA_VENDA_PGTO SET CANCELADO_FISCAL = 1, TOTAL_VENDA = 0
                               FROM   LOJA_VENDA_PGTO
                               WHERE CODIGO_FILIAL                               = @FILIAL
                               AND                      LANCAMENTO_CAIXA  = @LANCAMENTO_CAIXA
                               AND                      TERMINAL                                         = @TERMINAL

END

--COMMIT ROLLBACK

