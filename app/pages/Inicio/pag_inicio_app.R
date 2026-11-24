
# Carregar dados ----------------------------------------------------------
source(glue("{diretorio}pages/Inicio/Dados/dados_comodato.R"), local = TRUE, encoding = "UTF-8")

home_page <- function() {
  
  
  # Server ------------------------------------------------------------------
  
  if(motorista_query() != "9999"){
    assinados = comodatos_geral %>% 
      filter(status_assinatura == "Assinado",
             MOT == motorista_query(),
             grepl(revenda_query(), toupper(EMPRESA))) %>% 
      group_by(CEV, EMPRESA) %>% 
      summarise(CEV = unique(CEV), 
                EMPRESA = unique(EMPRESA), 
                Cliente = unique(Cliente), 
                `Razão Social` = unique(`Razão Social`), 
                NF = unique(NF), 
                status_assinatura = unique(status_assinatura))
    
    nao_assin = comodatos_geral %>% 
      filter(status_assinatura == "Não assinado",
             MOT == motorista_query(),
             grepl(revenda_query(), toupper(EMPRESA))) %>% 
      group_by(CEV, EMPRESA) %>% 
      summarise(CEV = unique(CEV), 
                EMPRESA = unique(EMPRESA), 
                Cliente = unique(Cliente), 
                `Razão Social` = unique(`Razão Social`), 
                NF = unique(NF), 
                status_assinatura = unique(status_assinatura))
    
  } else{
    assinados = comodatos_geral %>% 
      filter(status_assinatura == "Assinado",
             # MOT == motorista_query(),
             grepl(revenda_query(), toupper(EMPRESA))) %>% 
      group_by(CEV, EMPRESA) %>% 
      summarise(CEV = unique(CEV), 
                EMPRESA = unique(EMPRESA), 
                Cliente = unique(Cliente), 
                `Razão Social` = unique(`Razão Social`), 
                NF = unique(NF), 
                status_assinatura = unique(status_assinatura))
    
    nao_assin = comodatos_geral %>% 
      filter(status_assinatura == "Não assinado",
             # MOT == motorista_query(),
             grepl(revenda_query(), toupper(EMPRESA))) %>% 
      group_by(CEV, EMPRESA) %>% 
      summarise(CEV = unique(CEV), 
                EMPRESA = unique(EMPRESA), 
                Cliente = unique(Cliente), 
                `Razão Social` = unique(`Razão Social`), 
                NF = unique(NF), 
                status_assinatura = unique(status_assinatura))
    
  }
  
  card_nao_assinados = lapply(seq_len(nrow(nao_assin)), function(indice){
    
    linha = nao_assin[indice,]
    
    tags$div(
      class = "card_n_assinado",
      id = paste0("card_", linha$CEV),
      onclick = glue("Shiny.setInputValue('card_clicado_inicio', '{linha$CEV}', {{priority: 'event'}})"), 
      f7Card(
        title = HTML(glue("<p><b>CEV:</b> {as.character(linha$CEV)}</p>")),
        f7Block(HTML(glue("<b>Cliente:</b> {as.character(linha$Cliente)} - {linha$`Razão Social`}"))),
        br(),br(),br(),
        f7Block(HTML(glue("<p><b>NF:</b> {as.character(linha$NF)}</p>"))),
        footer = tags$div(
          style = "width:100%; display:flex; justify-content:flex-end;",
          f7Icon("xmark_circle") 
        ),
        raised = TRUE
      )
    )
    
  })
  
  card_assinados = lapply(seq_len(nrow(assinados)), function(indice){
    
    linha = assinados[indice,]
    tags$div(
      class = "card_assinado",
      id = paste0("card_", linha$CEV),
      onclick = glue("Shiny.setInputValue('card_clicado_inicio', '{linha$CEV}', {{priority: 'event'}})"), 
      f7Card(
        title = HTML(glue("<p><b>CEV:</b> {as.character(linha$CEV)}</p>")),
        f7Block(HTML(glue("<b>Cliente:</b> {as.character(linha$Cliente)} - {linha$`Razão Social`}"))),
        br(),br(),br(),
        f7Block(HTML(glue("<p><b>NF:</b> {as.character(linha$NF)}</p>"))),
        footer = tags$div(
          style = "width:100%; display:flex; justify-content:flex-end;",
          f7Icon("checkmark_circle") 
        ),
        raised = TRUE
      )
    )
    
  })
  
  
  
  output$lista_inicio = renderUI({
    
    tags$div(
      class = "search-list",
      if(nrow(nao_assin)>0){
        tagList(
          h3("Não assinados"),
          card_nao_assinados
        )
      },
      if(nrow(assinados)>0){
        tagList(
          h3("Assinados"),
          card_assinados
        )
      }
    )
      
  })
  
  uiOutput("lista_inicio")
}