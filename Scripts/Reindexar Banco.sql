--SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
CREATE TABLE #TABELA (NOME VARCHAR(100),ID_NOME INT IDENTITY (1,1))
DECLARE @COMANDO VARCHAR(100)
DECLARE @ID int
set @ID = 1
DECLARE @MAXID INT
SET @MAXID = 1
INSERT INTO #TABELA(NOME) 
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
 WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME
WHILE @ID <= @MAXID
BEGIN
SELECT 'RECRIANDO OS INDICES DA TABELA '+NOME FROM #TABELA WHERE ID_NOME = @ID
SET @COMANDO = (SELECT 'DBCC DBREINDEX ('''+NOME+''')' FROM #TABELA WHERE ID_NOME = @ID)
EXEC (@COMANDO)
IF (@MAXID = 1)
BEGIN
  SET @MAXID = (SELECT MAX(ID_NOME) FROM #TABELA)
 
END
SET @ID = @ID + 1
PRINT  @ID
END
DROP TABLE #TABELA