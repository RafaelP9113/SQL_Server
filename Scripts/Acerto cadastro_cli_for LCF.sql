select * from CADASTRO_CLI_FOR_log
where cod_clifor='014233'

update cadastro_cli_for_log
set cidade='UBERLANDIA'
where cod_clifor='012623'


sp_whoisactive

kill 108

sp_who2 108



select * from LOJA_CAIXA_LANCAMENTOS
where DATA='20200208'
and CODIGO_FILIAL='000025'

select * from CADASTRO_CLI_FOR_LOG
where COD_CLIFOR='014233'

select * from CADASTRO_CLI_FOR
where CLIFOR='014215'

update CADASTRO_CLI_FOR
set UF='RJ', PAIS = 'BRASIL',CIDADE = 'SAMAMBAIA', COD_MUNICIPIO_IBGE = '3304557', COD_MUNICIPIO_IBGE_COBRANCA = '3304557', COD_MUNICIPIO_IBGE_ENTREGA = '3304557'
where CLIFOR='014215'

update CADASTRO_CLI_FOR_log
set CIDADE='SAO PAULO'
where COD_CLIFOR='012536'