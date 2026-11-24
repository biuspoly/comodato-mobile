
# Carregar dados ----------------------------------------------------------
source(glue("{diretorio}pages/Inicio/Dados/dados_comodato.R"), local = TRUE, encoding = "UTF-8")


pag_detalhes_comod <- function() {
  
  
  comod_selecionado = reactive({
    req(input$card_clicado_inicio)
    
    comodatos_geral %>% 
      filter(CEV == input$card_clicado_inicio,
             grepl(revenda_query(), toupper(EMPRESA)))
  })
  
  
  output$det_comodato = renderUI({
    
    
    f7List(
      id = "lista-grande",
      dividers = TRUE,
      strong = TRUE,
      outline = FALSE,
      mode = NULL,
      
      # f7BlockTitle("DETALHES DO COMODATO"),
      f7ListItem(
        header = HTML("<b>EMPRESA</b>"),
        text = unique(comod_selecionado()$EMPRESA)
      ),
      
      f7ListItem(
        header = HTML("<b>CLIENTE</b>"),
        text = paste(unique(comod_selecionado()$Cliente), unique(comod_selecionado()$`Razão Social`), sep = " - ")
      ),
      
      f7ListItem(
        title = "",
        header = HTML("<b>ENDEREÇO</b>"),
        text = unique(comod_selecionado()$ENDERECO),
        right = f7Button(
          label = NULL, 
          size = "small",
          icon = icon("map-marker-alt", style = "font-size:18px;"),
          href = paste0("https://www.google.com/maps/dir/?api=1", "&origin=Current+Location", "&destination=", URLencode(unique(comod_selecionado()$ENDERECO))),
          fill = FALSE
        )
      ),
      
      f7ListItem(
        title = "",
        header = HTML("<b>CONTATAR RESPONSÁVEL</b>"),
        text = unique(comod_selecionado()$FONE),
        right = f7Segment(
          f7Button(
            label = NULL, 
            size = "small",
            icon = icon("phone-square-alt", style = "font-size:18px;"),
            href = paste0("tel:+55", unique(comod_selecionado()$FONE)),
            fill = FALSE
          ),
          f7Button(
            label = NULL, 
            size = "small",
            icon = icon("whatsapp", style = "font-size:18px;"),
            href = paste0("https://wa.me/55", gsub("\\D", "", unique(comod_selecionado()$FONE))),
            fill = FALSE
          )
        )
        
      ),
      
      f7ListItem(
        header = HTML("<b>MOTORISTA</b>"),
        text = unique(comod_selecionado()$MOT)
      ),
      
      f7ListItem(
        header = HTML("<b>NR CEV</b>"),
        text = input$card_clicado_inicio
      ),
      
      f7ListItem(
        header = HTML("<b>PRODUTOS</b>"),
        title = f7Table(
          comod_selecionado()[,c("PRODUTO", "QTD")],
          colnames = c("DESCRIÇÃO", "QUANTIDADE")
        )
      ),
      
      f7ListItem(
        header = HTML("<b>NOTA FISCAL</b>"),
        text = unique(comod_selecionado()$NF)
      ),
      
      f7ListItem(
        header = HTML("<b>DOCUMENTO ASSINADO</b>?"),
        text = unique(comod_selecionado()$status_assinatura)
      )
    )
    
  })
  
  
  uiOutput("det_comodato")
}