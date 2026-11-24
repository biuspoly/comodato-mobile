library(glue)
library(nanoparquet)


# Configurações do banco e arquivos --------------------------------------------------
# Versao portfolio: no lugar do MariaDB (TB_COMODATO + TB_EMPRESAS + tb_anexos_cev +
# tb_clientes_inad) o app le um Parquet com DADOS FICTICIOS nas mesmas colunas.
# O arquivo e gerado por dados/gerar_dados_ficticios.R (raiz do repositorio).
# nanoparquet e usado porque funciona no navegador (webR / shinylive).


# Consultas ---------------------------------------------------------------
# Colunas (iguais as da consulta original):
# EMPRESA, CEV, CODCOMP, PRODUTO, QTD, NF, MOT, Cliente, Fantasia, Razão Social,
# FONE, ENDERECO, PTO_REF, Data Emissão, Data Vencimento, anexo1, anexo2, anexo3,
# cnpj, status_assinatura, PRE_PED

comodatos_geral = as.data.frame(read_parquet(glue("{diretorio}dados/comodatos.parquet")))

comodatos_geral = unique(comodatos_geral)

