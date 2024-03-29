#' @title Bar plot of missing values per lines using highcharter.
#'
#' @description
#'
#' This method plots a bar plot which represents the distribution of the
#' number of missing values (NA) per lines (ie proteins).
#'
#' * `wrapper_pca()`: xxx
#' * `plotPCA_Eigen_hc()`: plots the eigen values of PCA with the highcharts
#'    library
#' * `plotPCA_Eigen()`: plots the eigen values of PCA
#' * `plotPCA_Var()`:
#' * `plotPCA_Ind()`:
#'
#' @param id A `character(1)` which is the id of the shiny module.
#' @param obj An instance of the class `DaparViz`.
#' @param var.scaling The dimensions to plot
#' @param ncp A `integer(1)` which represents the umber of dimensions kept in
#' the results.
#' @param res.pca Result of FactoMineR::PCA
#' @param chosen.axes The dimensions to plot
#'
#' @author Samuel Wieczorek, Enora Fremy
#'
#' @name ds-pca
#'
#'
#' @author Samuel Wieczorek, Enora Fremy
#'
#' @examples
#' if (interactive()) {
#'   data(vData_ft)
#'   obj <- vData_ft[[1]]
#'   # Replace missing values for the example
#'   qdata <- GetSlotQdata(obj)
#'   qdata[which(is.na(qdata))] <- 0
#'   DaparViz_pca(obj)
#' }
#'
NULL


#' @rdname ds-pca
#' @importFrom shiny NS tagList uiOutput
#' @export
#' @return NA
#'
DaparViz_pca_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shinyjs::useShinyjs(),
    shinyjs::hidden(div(id = ns("badFormatMsg"), h3(bad_format_txt))),
    uiOutput(ns("WarningNA_PCA")),
    uiOutput(ns("pcaOptions")),
    uiOutput(ns("pcaPlots"))
  )
}

#'
#' @rdname ds-pca
#'
#' @importFrom RColorBrewer brewer.pal
#' @importFrom highcharter renderHighchart
#' @import factoextra
#'
#' @export
#' @return NA
#'
DaparViz_pca_server <- function(
    id,
    obj) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv.pca <- reactiveValues(
      data = NULL,
      PCA_axes = NULL,
      res.pca = NULL,
      PCA_varScale = TRUE
    )


    observe(
      {
        is.DaparViz <- inherits(obj(), "DaparViz")
        if (is.DaparViz) {
          rv.pca$data <- as.matrix(obj()@qdata)
        }

        shinyjs::toggle("badFormatMsg", condition = !is.DaparViz)
      },
      priority = 1000
    )

    output$WarningNA_PCA <- renderUI({
      req(rv.pca$data)
      req(length(which(is.na(rv.pca$data))) > 0)

      tagList(
        tags$p(
          style = "color:red;font-size: 20px",
          "Warning: As your dataset contains missing values,
                the PCA cannot be computed. Please impute them first."
        )
      )
    })



    output$pcaOptions <- renderUI({
      req(rv.pca$data)
      req(length(which(is.na(rv.pca$data))) == 0)
      tagList(
        tags$div(
          tags$div(
            style = "display:inline-block;
                             vertical-align: middle; padding-right: 20px;",
            numericInput(ns("pca_axe1"), "Dimension 1",
              min = 1,
              max = Compute_PCA_dim(),
              value = 1,
              width = "100px"
            )
          ),
          tags$div(
            style = "display:inline-block; vertical-align: middle;",
            numericInput(ns("pca_axe2"), "Dimension 2",
              min = 1,
              max = Compute_PCA_dim(),
              value = 2,
              width = "100px"
            )
          ),
          tags$div(
            style = "display:inline-block;
                             vertical-align: middle; padding-right: 20px;",
            checkboxInput(ns("varScale_PCA"), "Variance scaling",
              value = rv.pca$PCA_varScale
            )
          )
        )
      )
    })


    observeEvent(c(input$pca_axe1, input$pca_axe2), {
      rv.pca$PCA_axes <- c(input$pca_axe1, input$pca_axe2)
    })


    observeEvent(input$varScale_PCA, ignoreInit = FALSE, {
      rv.pca$PCA_varScale <- input$varScale_PCA
      rv.pca$res.pca <- wrapper_pca(
        obj = obj(),
        var.scaling = rv.pca$PCA_varScale,
        ncp = Compute_PCA_dim()
      )
    })

    observe({
      req(length(which(is.na(rv.pca$data))) == 0)

      rv.pca$res.pca <- wrapper_pca(
        obj = obj(),
        var.scaling = rv.pca$PCA_varScale,
        ncp = Compute_PCA_dim()
      )
    })


    output$pcaPlots <- renderUI({
      req(rv.pca$data)
      req(length(which(is.na(rv.pca$data))) == 0)
      req(rv.pca$res.pca$var$coord)

      tagList(
        plotOutput(ns("pcaPlotVar")),
        plotOutput(ns("pcaPlotInd")),
        formatDT_ui(ns("PCAvarCoord")),
        highcharter::highchartOutput(ns("pcaPlotEigen"))
      )
    })

    observe({
      df <- as.data.frame(rv.pca$res.pca$var$coord)
      formatDT_server("PCAvarCoord",
        data = reactive({
          round(df, digits = 2)
        }),
        showRownames = TRUE
      )
    })



    output$pcaPlotVar <- renderPlot({
      req(c(rv.pca$PCA_axes, rv.pca$res.pca))
      withProgress(message = "Making plot", value = 100, {
        factoextra::fviz_pca_var(rv.pca$res.pca,
          axes = rv.pca$PCA_axes,
          col.var = "cos2",
          gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
          repel = TRUE
        )
      })
    })

    output$pcaPlotInd <- renderPlot({
      req(c(rv.pca$PCA_axes, rv.pca$res.pca))
      withProgress(message = "Making plot", value = 100, {
        factoextra::fviz_pca_ind(rv.pca$res.pca,
          axes = rv.pca$PCA_axes,
          geom = "point"
        )
      })
    })


    output$pcaPlotEigen <- highcharter::renderHighchart({
      req(rv.pca$res.pca)

      withProgress(message = "Making plot", value = 100, {
        plotPCA_Eigen(rv.pca$res.pca)
      })
    })



    Compute_PCA_dim <- reactive({
      req(rv.pca$data)
      nmax <- 12 # ncp should not be greater than...
      # for info, ncp = number of components or dimensions in PCA results

      y <- rv.pca$data
      nprot <- dim(y)[1]
      n <- dim(y)[2] # If too big, take the number of conditions.

      if (n > nmax) {
        n <- length(unique(obj()@conds))
      }

      ncp <- min(n, nmax)
      ncp
    })
  })
}


#' @import shiny
#' @export
#' @rdname ds-pca
#' @return A shiny app
#'
DaparViz_pca <- function(obj) {
  ui <- DaparViz_pca_ui("plot")

  server <- function(input, output, session) {
    DaparViz_pca_server("plot", obj = reactive({
      obj
    }))
  }
  shinyApp(ui = ui, server = server)
}
