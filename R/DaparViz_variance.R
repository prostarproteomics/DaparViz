#' @title Displays a correlation matrix of the quantitative data of a
#' numeric matrix.
#'
#' @description
#' xxxx
#'
#' @name plot-variance
#'
#' @param id A `character(1)` which is the id of the shiny module.
#' @param obj xxx
#' @param pal.name A `character(1)` which is the name of the palette from the
#' package `RColorBrewer` from which the colors are taken.
#' Default value is 'Set1'.
#'
#'
#' @examples
#' if (interactive()) {
#'   data(vData_ft)
#'   DaparViz_variance(vData_ft[[1]])
#' }
#'
NULL


#' @importFrom shiny NS tagList
#' @rdname plot-variance
#' @export
#' @return NA
#'
DaparViz_variance_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinyjs::useShinyjs(),
    shinyjs::hidden(div(id = ns("badFormatMsg"), h3(bad_format_txt))),
    uiOutput(ns("helpTxt")),
    highcharter::highchartOutput(ns("viewDistCV"), width = 600, height = 600)
  )
}



#'
#' @importFrom shiny NS tagList
#' @rdname plot-variance
#' @export
#' @return NA
#'
DaparViz_variance_server <- function(
    id,
    obj,
    pal.name = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(data = NULL)

    observe(
      {
        if (inherits(obj(), "DaparViz")) {
          rv$data <- obj()
        }

        shinyjs::toggle("badFormatMsg", condition = is.null(rv$data))
      },
      priority = 1000
    )

    output$viewDistCV <- renderHighchart({
      req(rv$data)
      withProgress(message = "Making plot", value = 100, {
        varDist <- CVDist(rv$data, pal.name)
      })
    })

    output$helpTxt <- renderUI({
      req(rv$data)
      tagList(
        helpText("Display the condition-wise distributions of the
          log-intensity CV (Coefficient of Variation) of the
                   protein/peptides."),
        helpText("For better visualization, it is possible to zoom in by
            click-and-drag.")
      )
    })
  })
}



#' @importFrom RColorBrewer brewer.pal
#' @import highcharter
#' @importFrom DT JS
#' @importFrom stats var
#'
#' @export
#'
#' @param obj xxx
#' @param pal.name xxx
#'
#' @rdname plot-variance
#'
#' @return A plot
#'
CVDist <- function(
    obj,
    pal.name = NULL) {
  stopifnot(inherits(obj, "DaparViz"))


  if (is.null(obj@conds)) {
    stop("'obj@conds' is NULL")
  }

  u_conds <- unique(obj@conds)

  myColors <- SampleColors(u_conds)

  h1 <- highcharter::highchart() %>%
    customChart(chartType = "spline", zoomType = "x") %>%
    highcharter::hc_colors(myColors) %>%
    highcharter::hc_legend(
      enabled = TRUE,
      categories = u_conds
    ) %>%
    highcharter::hc_xAxis(title = list(text = "CV(log(Intensity))")) %>%
    highcharter::hc_yAxis(title = list(text = "Density")) %>%
    highcharter::hc_tooltip(
      headerFormat = "",
      pointFormat = "<b>{series.name}</b>: {point.y} ",
      valueDecimals = 2
    ) %>%
    customExportMenu(fname = "logIntensity") %>%
    highcharter::hc_plotOptions(
      series = list(
        connectNulls = TRUE,
        marker = list(
          enabled = FALSE
        )
      )
    )

  minX <- maxX <- 0
  maxY <- 0
  for (i in seq_len(length(u_conds))) {
    if (length(which(obj@conds == u_conds[i])) > 1) {
      t <- apply(
        obj@qdata[, which(obj@conds == u_conds[i])], 1,
        function(x) {
          100 * stats::var(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
        }
      )
      tmp <- data.frame(
        x = density(t, na.rm = TRUE)$x,
        y = density(t, na.rm = TRUE)$y
      )

      ymaxY <- max(maxY, tmp$y)
      xmaxY <- tmp$x[which(tmp$y == max(tmp$y))]
      minX <- min(minX, tmp$x)
      maxX <- max(maxX, 10 * (xmaxY - minX))

      h1 <- h1 %>% hc_add_series(data = tmp, name = u_conds[i])
    }
  }

  h1 <- h1 %>%
    hc_chart(
      events = list(
        load = DT::JS(paste0("function(){
                         var chart = this;
                         this.xAxis[0].setExtremes(", minX, ",", maxX, ");
                         this.showResetZoom();}"))
      )
    )

  return(h1)
}




#' @import shiny
#' @rdname plot-variance
#' @export
#' @return A shiny app
#'
DaparViz_variance <- function(obj) {
  ui <- fluidPage(
    DaparViz_variance_ui("plot")
    )

  server <- function(input, output, session) {
    DaparViz_variance_server("plot", 
      obj = reactive({obj}))
  }

  shinyApp(ui, server)
}
