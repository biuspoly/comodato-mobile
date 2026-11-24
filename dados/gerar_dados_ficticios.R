# Gera a base FICTÍCIA de comodatos usada pelo app ---------------------------
# Substitui a consulta ao MariaDB (TB_COMODATO + TB_EMPRESAS + tb_anexos_cev +
# tb_clientes_inad) por um arquivo Parquet com as MESMAS colunas.
# Nenhum dado aqui é real: empresas, clientes, telefones, endereços e
# documentos foram inventados.
#
# Rodar a partir da raiz do repositório:
#   Rscript dados/gerar_dados_ficticios.R

library(dplyr)
library(nanoparquet)

set.seed(2026)

# Revendas (o login filtra por grepl(revenda, toupper(EMPRESA))) ------------

empresas = data.frame(
  EMPRESA = c("Revenda Norte Bebidas Ltda", "Revenda Sul Bebidas Ltda", "Revenda Centro Bebidas Ltda"),
  cnpj    = c("00.000.000/0001-01", "00.000.000/0001-02", "00.000.000/0001-03"),  # fictícios
  stringsAsFactors = FALSE
)

# Motoristas por revenda (códigos fictícios)
motoristas = list(
  "Revenda Norte Bebidas Ltda"  = c(101, 102, 103),
  "Revenda Sul Bebidas Ltda"    = c(201, 202),
  "Revenda Centro Bebidas Ltda" = c(301, 302)
)

# Clientes fictícios --------------------------------------------------------

nomes_clientes = c(
  "Mercadinho Boa Vista", "Bar do Ponto", "Conveniência Estrela", "Restaurante Sabor da Terra",
  "Mercearia Dois Irmãos", "Lanchonete Esquina", "Depósito Bom Gelo", "Espetinho do Bairro",
  "Pizzaria Forno Velho", "Quiosque Beira Mar", "Supermercado Economia", "Bar e Petiscaria Lua",
  "Padaria Pão Quente", "Churrascaria Fogo Alto", "Conveniência Parada Certa", "Adega Vila Nova",
  "Mercado Popular", "Bar da Praça", "Lanchonete Sabor Caseiro", "Restaurante Maré Alta",
  "Cantina Central", "Mercadinho Família", "Bar Ponto Final", "Empório Cidade Exemplo"
)

ruas = c("Rua das Acácias", "Avenida Principal", "Rua Projetada A", "Rua do Comércio",
         "Avenida das Palmeiras", "Rua São João", "Travessa da Paz", "Rua Sete")
bairros = c("Centro", "Jardim Exemplo", "Vila Nova", "Bairro Alto", "Parque das Árvores")

# Itens de comodato (PRODUTO_GENERICO)
produtos = c("FREEZER HORIZONTAL 400L", "VISA COOLER 300L", "JOGO DE MESA PLASTICA",
             "CADEIRA PLASTICA", "CHOPEIRA ELETRICA", "GUARDA-SOL", "EXPOSITOR DE GARRAFAS",
             "CAIXA TERMICA 120L")

# Monta os comodatos (cada CEV pode ter 1 a 3 produtos) --------------------

cevs = list()
num_cev = 50001
num_nf = 300001
pre_ped = 202605010001

for (i in seq_along(nomes_clientes)) {

  empresa = empresas$EMPRESA[(i - 1) %% 3 + 1]
  cnpj = empresas$cnpj[empresas$EMPRESA == empresa]

  # 1 ou 2 comodatos por cliente
  for (k in seq_len(sample(1:2, 1))) {

    n_prod = sample(1:3, 1)
    assinado = runif(1) < 0.45
    dte = as.Date("2026-05-02") + sample(0:40, 1)
    codcli = 10000 + i
    anexo = if (assinado) paste0("Anexos_Comodato/", num_cev, "_contrato.pdf") else NA_character_

    cevs[[length(cevs) + 1]] = data.frame(
      EMPRESA = empresa,
      CEV = num_cev,
      CODCOMP = sprintf("CP%04d", seq_len(n_prod) + length(cevs) * 3),
      PRODUTO = sample(produtos, n_prod),
      QTD = sample(1:4, n_prod, replace = TRUE),
      NF = num_nf,
      MOT = sample(motoristas[[empresa]], 1),
      Cliente = codcli,
      Fantasia = toupper(nomes_clientes[i]),
      `Razão Social` = paste(toupper(nomes_clientes[i]), "LTDA"),
      FONE = sprintf("(00) 90000-%04d", i),  # telefone fictício
      ENDERECO = paste0(sample(ruas, 1), ", ", sample(10:999, 1), " - ", sample(bairros, 1), ", Cidade Exemplo - UF"),
      PTO_REF = sample(c("Próximo à praça", "Em frente à escola", "Ao lado do posto", NA), 1),
      `Data Emissão` = as.integer(format(dte, "%Y%m%d")),
      `Data Vencimento` = as.integer(format(dte + 365, "%Y%m%d")),
      anexo1 = anexo,
      anexo2 = NA_character_,
      anexo3 = NA_character_,
      cnpj = cnpj,
      status_assinatura = if (assinado) "Assinado" else "Não assinado",
      PRE_PED = pre_ped,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )

    num_cev = num_cev + 1
    num_nf = num_nf + sample(3:40, 1)
    pre_ped = pre_ped + 1
  }
}

comodatos = bind_rows(cevs) %>%
  mutate(across(c(CEV, NF, MOT, Cliente, QTD), as.integer),
         PRE_PED = as.numeric(PRE_PED))

# Grava dentro da pasta do app (o shinylive só leva o que está em app/) ----

dir.create("app/dados", showWarnings = FALSE, recursive = TRUE)
write_parquet(comodatos, "app/dados/comodatos.parquet")

message(nrow(comodatos), " linhas / ", length(unique(comodatos$CEV)), " CEVs gravados em app/dados/comodatos.parquet")
