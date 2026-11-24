pwa_config <- function(
    base_path = ".",
    prefix = "",
    registrar_sw = TRUE
) {

  # Caminhos relativos ao app (www/ e servido na raiz)
  sw_path <- "service-worker.js"
  scope   <- paste0(base_path, "/", prefix)
  manifest_path <- paste0(base_path, "/", prefix, "manifest.json")
  icon_path <- paste0(base_path, "/", prefix, "icons/icon-192.png")

  tagList(

    # Manifest
    tags$head(
      tags$link(
        rel = "manifest",
        href = manifest_path,
        crossorigin = "use-credentials"
      )
    ),

    # Icone
    tags$link(
      rel = "icon",
      href = icon_path,
      type = "image/png"
    ),

    # Service Worker (desligado no shinylive, que ja usa o proprio service worker)
    if (registrar_sw) {
      tags$script(HTML(glue::glue("
        if ('serviceWorker' in navigator) {{
          navigator.serviceWorker.register('{sw_path}', {{
            scope: '{scope}'
          }}).then(function(reg) {{
            console.log('SW registrado', reg);
          }}).catch(function(err) {{
            console.error('Erro SW', err);
          }});
        }}
      ")))
    }

  )
}
