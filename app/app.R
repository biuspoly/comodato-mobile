suppressPackageStartupMessages({
  library(shiny)
  library(shinyMobile)
  library(glue)
  library(dplyr)
  library(shinyjs)
  library(jsonlite)
  library(cookies)
  library(nanoparquet)
})
# Diretorio ---------------------------------------------------------------
diretorio = "Comodato/"

if (!dir.exists(diretorio)){
  diretorio = ""
}

# Rodando no navegador (shinylive / webR)? -------------------------------
# No webR nao ha service worker proprio

em_navegador = R.version$os == "emscripten"

# Configurações dos usuarios --------------------------------------------------
# DADOS FICTICIOS: revendas e codigos de demonstracao

credentials <- data.frame(
  user = c("1001", "1002", "1003"),
  password = c("123", "123", "123"),  # depois pode criptografar
  revenda = c("REVENDA NORTE", "REVENDA SUL", "REVENDA CENTRO"),
  stringsAsFactors = FALSE
)

# Forçar caminho estatico -------------------------------------------------

source(glue("{diretorio}pwa_config.R"), local = TRUE, encoding = "UTF-8")

# Cores Layout ------------------------------------------------------------

cores = c("#1f1f1f")

# Opções do app -----------------------------------------------------------
app_opts <-   list(
  theme = "auto",
  dark = FALSE,
  skeletonsOnLoad = TRUE,
  preloader = FALSE,
  filled = FALSE,
  color = "#1f1f1f",
  touch = list(
    touchClicksDistanceThreshold = 5,
    tapHold = TRUE,
    tapHoldDelay = 750,
    tapHoldPreventClicks = TRUE,
    iosTouchRipple = FALSE,
    mdTouchRipple = TRUE
  ),
  iosTranslucentBars = FALSE,
  navbar = list(
    iosCenterTitle = FALSE,
    hideOnPageScroll = TRUE
  ),
  toolbar = list(
    hideOnPageScroll = FALSE
  ),
  pullToRefresh = FALSE
)



# UI ----------------------------------------------------------------------
ui <- add_cookie_handlers(
  f7Page(
    allowPWA = FALSE,
    title = "Comodatos",
    options = app_opts,
    useShinyjs(),
    includeCSS(glue("{diretorio}www/style_geral.css")),
    pwa_config(registrar_sw = !em_navegador),
    body = tagList(
      tags$div(
        id = "tela_login",
        style = "display: none;",
        tags$img(
          src = "img/log2_bg.jpg",
          class = "background-image"
        ),
        f7List(
          inset = TRUE,
          dividers = FALSE,
          strong = TRUE,
          outline = FALSE,
          tags$div(
            class = "logo-container",
            tags$img(
              src = "img/logo_app_transp.png",
              class = "logo-image"
            )
          ),
          f7BlockTitle("Autenticação"),

          # Valores de demonstracao ja preenchidos (revenda 1001, motorista 101, senha 123)
          f7Text(
            inputId = "id_rev",
            label = "Revenda",
            value = "1001",
            style = list(
              outline = TRUE,
              clearable = TRUE,
              media = f7Icon("house")
            )
          ),

          f7Text(
            inputId = "id_mot",
            label = "Motorista (Cód)",
            value = "101",
            style = list(
              outline = TRUE,
              clearable = TRUE,
              media = f7Icon("person")
            )
          ),

          f7Password(
            inputId = "id_pass",
            label = "Senha",
            placeholder = "Demonstração: 123",
            style = list(
              outline = TRUE,
              clearable = TRUE,
              media = f7Icon("keyboard")
            )
          ),
          br(),br(),
          f7Button(
            inputId = "btn_login",
            label = "Entrar",
            fill = TRUE
          )


        )
      ),
      f7TabLayout(
        id = "tela_principal",
        style = "display: none;",
        tags$img(
          src = "img/log2_bg.jpg",
          class = "background-image"
        ),
        navbar = f7Navbar(

          title = "Comodatos assinados",
          leftPanel = FALSE,
          tags$div(
            style = "margin-left:auto;",
            f7Segment(
              f7Button("bt_procura",
                       size = "small",
                       color = cores[1],
                       icon = f7Icon("search_circle"),
                       fill = FALSE),
              f7Button("bt_atualiza",
                       size = "small",
                       color = cores[1],
                       icon = f7Icon("arrow_2_circlepath_circle"),
                       fill = FALSE),
              f7Button(
                inputId = "btn_erase_login",
                size = "small",
                color = cores[1],
                icon = f7Icon("arrow_uturn_left_circle"),
                fill = FALSE)
            )
          )
        ),
        f7Tabs(
          id = "tabs",
          animated = FALSE,
          swipeable = TRUE,
          f7Tab(
            tabName = "home",
            active = TRUE,
            title = "Início",
            icon = f7Icon("house"),
            uiOutput("lista_inicial")
          ),
          f7Tab(
            tabName = "tab_comod",
            title = "Detalhes",
            icon = f7Icon("list_number"),
            uiOutput("pag_detalhes")
          )

        ),
        f7Sheet(
          id = "modal_busca",
          swipeToClose = TRUE,
          orientation = "bottom",
          closeByOutsideClick = TRUE,
          f7Text(
            inputId = "busca_modal",
            placeholder = "Digite para buscar..."
          )
        )

      )
    )
  )
)
# Server ------------------------------------------------------------------

server <- function(input, output, session) {


  res_auth <- reactiveValues(
    user = NULL,
    revenda = NULL,
    motorista = NULL
  )


  # Autenticação ------------------------------------------------------------

  observe({

    user_cookie <- get_cookie("user_login")

    mot_cookie  <- get_cookie("motorista_login")

    if (!is.null(user_cookie) && user_cookie != "") {

      user_row <- credentials[credentials$user == user_cookie, ]

      if (nrow(user_row) == 1) {

        res_auth$revenda <- user_row$revenda
        res_auth$user <- user_row$user
        res_auth$motorista <- mot_cookie

        hide("tela_login")
        show("tela_principal")

        return()
      }
    }

    hide("tela_principal")
    show("tela_login")
  })

  observeEvent(input$btn_login, {

    req(input$id_rev, input$id_mot)

    # filtra usuário
    user_row <- credentials[credentials$user == input$id_rev, ]

    if (nrow(user_row) == 1 && user_row$password == input$id_pass) {

      f7Skeleton(".tabs", "fade")

      # salva dados do usuário autenticado
      res_auth$revenda <- user_row$revenda
      res_auth$user <- user_row$user
      res_auth$motorista <- input$id_mot

      set_cookie("user_login", input$id_rev)
      set_cookie("motorista_login", input$id_mot)

      hide("tela_login")
      show("tela_principal")
    } else {

      showNotification("Informações inválidas", type = "error")

    }
  })


  observeEvent(input$btn_erase_login, {
    remove_cookie("user_login")
    remove_cookie("motorista_login")
    session$reload()
  })


  revenda_query <- reactive({
    res_auth$revenda
  })

  motorista_query = reactive({
    res_auth$motorista
  })

  # Carregar páginas --------------------------------------------------------

  source(glue("{diretorio}pages/Inicio/pag_inicio_app.R"), local = TRUE, encoding = "UTF-8")
  source(glue("{diretorio}pages/Inicio/pag_detalhes_comod.R"), local = TRUE, encoding = "UTF-8")


  # Icones de revenda dinamicos --------------------------------------------------------


  # Saida das paginas -------------------------------------------------------

  output$lista_inicial = renderUI({
    home_page()
  })

  output$pag_detalhes = renderUI({
    pag_detalhes_comod()
  })


  # Eventos do inicio ---------------------------------------------------------

  observeEvent(input$card_clicado_inicio, {
    updateF7Tabs("tabs",selected = "tab_comod")
    # hide("bt_procura")
  })

  observeEvent(input$bt_atualiza,{
    # show("bt_procura")
    session$reload()
  })

  observeEvent(input$bt_procura, {
    updateF7Sheet("modal_busca")
  })

  observeEvent(input$busca_modal, {
    # req(input$busca_modal)

    termo <- input$busca_modal

    if (is.null(termo) || termo == "") {

      # mostra tudo
      for(i in seq_len(nrow(comodatos_geral))) {
        id_card <- paste0("card_", comodatos_geral$CEV[i])
        show(id_card)
      }

      return()

    }

    # TRUE/FALSE pra cada linha
    filtro = comodatos_geral %>%
      mutate(visivel = (
        grepl(termo, Cliente, ignore.case = TRUE) |
          grepl(termo, `Razão Social`, ignore.case = TRUE) |
          grepl(termo, CEV, ignore.case = TRUE) |
          grepl(termo, NF, ignore.case = TRUE)
      )
      )

    comodatos_geral$visivel <- filtro$visivel

    for(i in seq_len(nrow(comodatos_geral))) {

      id_card <- paste0("card_", comodatos_geral$CEV[i])

      if (comodatos_geral$visivel[i]) {
        show(id_card)
      } else {
        hide(id_card)
      }

    }
  })


  observe({
    req(input$tabs)
    if(input$tabs == "tab_comod"){
      hide("bt_procura")
    } else{
      show("bt_procura")
    }
  })

}

shinyApp(ui, server)
# runApp(shinyApp(ui, server),port = 8000,host = "0.0.0.0")
