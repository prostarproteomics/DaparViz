#' @title plots_cc_ui and plots_cc_server
#'
#' @description  A shiny Module.
#'
#' @param id A `character(1)` which is the id of the shiny module.
#' @param obj An instance of `DaparViz` class
#'
#' @keywords internal
#'
#'
#' @examples
#' if (interactive()) {
#'   data(vData_ft)
#'   DaparViz_cc(vData_ft[[1]])
#' }
#'
#' @name ds-cc
#'
NULL



#' @importFrom shiny NS tagList
#' @importFrom shinyjs toggle hidden
#' @import shinyBS
#' @import highcharter
#'
#' @rdname ds-cc
#' @export
#' @return A shiny plot
#' @import visNetwork
#' @import shinyBS
#' @import shinyjs
#' @import highcharter
#'
DaparViz_cc_ui <- function(id) {
    ns <- NS(id)
    tagList(
        shinyjs::useShinyjs(),
        shinyjs::hidden(
          div(id = ns("badFormatMsg"), h3(bad_format_txt))
        ),
        shinyjs::hidden(
            div(id = ns("noCCMsg"), h3("The dataset contains no CC."))
        ),
        shinyjs::hidden(
            div(id = ns("mainUI"),
                tabPanel(title = "", value = "graphTab",
                    tabsetPanel(id = "graphsPanel",
                      tabPanel(
              "One-One Connected Components",
              tagList(
                fluidRow(
                  column(width = 4, tagList(
                    # dl_ui(ns("OneOneDT_DL_btns")),
                    uiOutput(ns("OneOneDT_UI"))
                  )),
                  column(width = 8, uiOutput(ns("OneOneDTDetailed_UI")))
                )
              )
            ),

            #---------------------------------------------------------
            tabPanel(
              "One-Multi Connected Components",
              tagList(
                fluidRow(
                  column(
                    width = 4,
                    tagList(
                      # dl_ui(ns("OneMultiDT_DL_btns")),
                      uiOutput(ns("OneMultiDT_UI"))
                    )
                  ),
                  column(width = 8, uiOutput(ns("OneMultiDTDetailed_UI")))
                )
              )
            ),

            #---------------------------------------------------------
            tabPanel(
              "Multi-Multi Connected Components",
              tagList(
                fluidRow(
                  column(
                    width = 4,
                    radioButtons(ns("searchCC"),
                      "Search for CC",
                      choices = c(
                        "Tabular view" = "tabular",
                        "Graphical view" = "graphical"
                      ),
                      width = "150px"
                    )
                  ),
                  column(width = 8, uiOutput(ns("pepInfo_ui")))
                ),
                fluidRow(
                  column(width = 6, tagList(
                    highcharter::highchartOutput(ns("jiji")),
                    # uiOutput(ns("CCMultiMulti_DL_btns_ui")),
                    shinyjs::hidden(uiOutput(ns("CCMultiMulti_UI")))
                  )),
                  column(
                    width = 6,
                    visNetwork::visNetworkOutput(ns("visNetCC"),
                      height = "600px"
                    )
                  )
                ),
                uiOutput(ns("CCDetailed"))
              )
            )
          )
        )
      )
    )
  )
}



#' @importFrom tibble tibble
#' @importFrom shinyjs toggle hidden
#' @import highcharter
#' @rdname ds-cc
#'
#' @export
#' @return A shiny app
#'
#' @import visNetwork
#' @import highcharter
#'
DaparViz_cc_server <- function(id, obj) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      data = NULL,
      isValid = FALSE
    )



    observeEvent(obj(),
      ignoreInit = FALSE,
      {
        obj.valid <- inherits(obj(), "DaparViz")
        cc.exists <- length(obj()@cc) > 0

        if (obj.valid && cc.exists) {
          rv$data <- obj()
        }

        shinyjs::toggle("mainUI", condition = obj.valid && cc.exists)
        shinyjs::toggle("noCCMsg", condition = obj.valid && !cc.exists)
        shinyjs::toggle("badFormatMsg", condition = !obj.valid)
      },
      priority = 1000
    )



    rvCC <- reactiveValues(
      ## selected CC in global CC list (tab or plot)
      selectedCC = NULL,
      selectedNode = NULL,
      selectedNeighbors = NULL,
      selectedCCgraph = NULL,

      # when the user selects a node in the graph
      detailedselectedNode = list(
        sharedPepLabels = NULL,
        specPepLabels = NULL,
        protLabels = NULL
      ),
      OneOneDT_rows_selected = reactive({
        NULL
      }),
      OneMultiDT_rows_selected = reactive({
        NULL
      }),
      CCMultiMulti_rows_selected = reactive({
        NULL
      })
    )


    ## //////////////////////////////////////////////////////////////////
    ##
    ##    One One Connected Components
    ##
    ## //////////////////////////////////////////////////////////////////
    observeEvent(req(input$searchCC), {
      shinyjs::toggle("jiji",
        condition = input$searchCC == "graphical"
      )
      shinyjs::toggle("CCMultiMulti_UI",
        condition = input$searchCC == "tabular"
      )
    })


    output$pepInfo_ui <- renderUI({
      selectInput(ns("pepInfo"), "Peptide Info",
        choices = colnames(rv$data@metadata),
        multiple = TRUE
      )
    })


    # select a point in the grpah
    observeEvent(input$click, {
      rvCC$selectedNode <- input$click
    })


    # Get the id of selected neighbors in the graph
    observeEvent(input$visNetCC_highlight_color_id, {
      rvCC$selectedNeighbors <- input$visNetCC_highlight_color_id
    })


    ## //////////////////////////////////////////////////////////////////
    ##
    ##    One Multi Connected Components
    ##
    ## //////////////////////////////////////////////////////////////////

    # select a CC in the jitter plot
    observeEvent(req(input$eventPointClicked), {
      .str <- strsplit(input$eventPointClicked, "_")
      this.index <- as.integer(.str[[1]][1])
      rvCC$selectedCC <- this.index + 1
    })


    output$visNetCC <- visNetwork::renderVisNetwork({
      req(rvCC$selectedCC)
      input$pepInfo
      local <- (GetCCInfos(rv$data@cc))$Multi_Multi
      # m <- local[[rvCC$selectedCC]]

      rvCC$selectedCCgraph <- buildGraph(
        cc = local[[rvCC$selectedCC]],
        metadata = rv$data@metadata
      )

      display.CC.visNet(rvCC$selectedCCgraph) %>%
        visNetwork::visEvents(click = paste0(
          "function(nodes){Shiny.onInputChange('",
          ns("click"), "', nodes.nodes[0]);
                Shiny.onInputChange('", ns("node_selected"),
          "', nodes.nodes.length);;}"
        )) %>%
        visNetwork::visOptions(highlightNearest = TRUE)
    })

    ## //////////////////////////////////////////////////////////////////
    ##
    ##    Multi-Multi Connected Components
    ##
    ## //////////////////////////////////////////////////////////////////


    # Plots Multi_Multi CC
    output$jiji <- highcharter::renderHighchart({
      # tooltip <- 'Sequence'

      isolate({
        local <- (GetCCInfos(rv$data@cc))$Multi_Multi
        n.prot <- unlist(lapply(local, function(x) {ncol(x)}))
        n.pept <- unlist(lapply(local, function(x) {nrow(x)}))
        df <- tibble::tibble(
          x = jitter(n.pept),
          y = jitter(n.prot),
          index = seq_len(local)
        )
        colnames(df) <- gsub(".", "_", colnames(df), fixed = TRUE)

        clickFun <- JS(paste0(
          "function(event) {Shiny.onInputChange('",
          ns("eventPointClicked"), "', [this.index]+'_'+ [this.series.name]);}"
        ))
        plotCC <- plotCCJitter(df, clickFunction = clickFun)
      })
      plotCC
    })


    GetDataFor_CCMultiMulti <- reactive({
      req(length((GetCCInfos(rv$data@cc))$Multi_Multi) > 0)

      ll <- (GetCCInfos(rv$data@cc))$Multi_Multi

      ll.pep <- cbind(
        lapply(
          ll,
          function(x) {
            paste(rownames(x), collapse = ",")
          }
        )
      )

      ll.prot <- cbind(
        lapply(
          ll,
          function(x) {
            paste(colnames(x), collapse = ",")
          }
        )
      )

      df <- cbind(
        id = seq_len(ll),
        nProt = cbind(lapply(ll, function(x) {
          ncol(x)
        })),
        nPep = cbind(lapply(ll, function(x) {
          nrow(x)
        })),
        proteins = ll.prot,
        peptides = ll.pep
      )

      colnames(df) <- c("id", "nProt", "nPep", "Proteins Ids", "Peptides Ids")

      df
    })

    output$CCMultiMulti_DL_btns_ui <- renderUI({
      req(input$searchCC == "tabular")
      # dl_ui(ns("CCMultiMulti_DL_btns"))
    })

    # dl_server("CCMultiMulti_DL_btns",
    #                          df.data = reactive({GetDataFor_CCMultiMulti()}),
    #                          name = reactive({"CC_MultiMulti"}),
    #                          colors = reactive({NULL}),
    #                          df.tags = reactive({NULL})
    #                          )

    # Show the DT data table ans gets the selected items from it
    output$CCMultiMulti_UI <- renderUI({
      rvCC$CCMultiMulti_rows_selected <- formatDT_server("CCMultiMulti",
        data = reactive({
          GetDataFor_CCMultiMulti()
        })
      )

      formatDT_ui(ns("CCMultiMulti"))
    })



    # Catches the selected item in the CCMultiMulti table
    observeEvent(req(rvCC$CCMultiMulti_rows_selected()), {
      rvCC$selectedCC <- rvCC$CCMultiMulti_rows_selected()
    })


    observeEvent(c(
      rvCC$selectedNeighbors,
      input$node_selected,
      rvCC$selectedCCgraph
    ), {
      local <- (GetCCInfos(rv$data@cc))$Multi_Multi
      rvCC$selectedNeighbors

      nodes <- rvCC$selectedCCgraph$nodes

      if (!is.null(input$node_selected) && input$node_selected == 1) {
        # The DT table has not been used. Thus, it was the plot
        sharedPepIndices <- intersect(
          rvCC$selectedNeighbors,
          which(nodes[, "group"] == "shared.peptide")
        )
        specPepIndices <- intersect(
          rvCC$selectedNeighbors,
          which(nodes[, "group"] == "spec.peptide")
        )
        protIndices <- intersect(
          rvCC$selectedNeighbors,
          which(nodes[, "group"] == "protein")
        )
      } else {
        .shared <- "shared.peptide"
        .spec <- "spec.peptide"
        sharedPepIndices <- which(nodes[, "group"] == .shared)
        specPepIndices <- which(nodes[, "group"] == .spec)
        protIndices <- which(nodes[, "group"] == "protein")
      }

      # Finally, update reactive global variable
      rvCC$detailedselectedNode <- list(
        sharedPepLabels = nodes[sharedPepIndices, "label"],
        specPepLabels = nodes[specPepIndices, "label"],
        protLabels = nodes[protIndices, "label"]
      )
    })


    output$CCDetailed <- renderUI({
      req(rvCC$detailedselectedNode, rvCC$selectedCC)
      # req(rvCC$selectedCC)

      tagList(
        h4("Proteins"),
        uiOutput(ns("CCDetailedProt_UI")),
        h4("Specific peptides"),
        uiOutput(ns("CCDetailedSpecPep_UI")),
        h4("Shared peptides"),
        uiOutput(ns("CCDetailedSharedPep_UI"))
      )
    })

    # output$CCDetailedProt <- DT::renderDataTable(server = TRUE, {
    #   req(rvCC$selectedCC)
    #   rvCC$detailedselectedNode
    #   req(!is.null(rvCC$detailedselectedNode$protLabels))
    #   .protLabels <- rvCC$detailedselectedNode$protLabels
    #
    #   df <- data.frame(proteinId = unlist(.protLabels))
    #   colnames(df) <- c("Proteins Ids")
    #   dt <- DT::datatable(df,
    #                       extensions = c("Scroller"),
    #                       options = list(
    #                         initComplete = .initComplete(),
    #                         dom = "rt",
    #                         blengthChange = FALSE,
    #                         ordering = FALSE,
    #                         scrollX = 400,
    #                         scrollY = 100,
    #                         displayLength = 10,
    #                         scroller = TRUE,
    #                         header = FALSE,
    #                         server = FALSE
    #                       )
    #   )
    #   dt
    # })


    output$CCDetailedProt_UI <- renderUI({
      req(rvCC$selectedCC)
      rvCC$detailedselectedNode
      req(rvCC$detailedselectedNode$protLabels)

      .protLabels <- rvCC$detailedselectedNode$protLabels

      df <- data.frame(proteinId = unlist(.protLabels))
      colnames(df) <- c("Proteins Ids")

      formatDT_server("CCDetailedProt", data = reactive({
        df
      }))
      formatDT_ui(ns("CCDetailedProt"))
    })





    #-----------------------------------------------
    GetDataFor_CCDetailedSharedPep_UI <- reactive({
      rvCC$detailedselectedNode
      input$pepInfo

      req(rvCC$detailedselectedNode$sharedPepLabels)
      pepLine <- rvCC$detailedselectedNode$sharedPepLabels
      indices <- unlist(lapply(pepLine, function(x) {
        which(rownames(rv$data@qdata) == x)
      }))

      qdata <- convert2df(rv$data@qdata[indices, ])
      qmetacell <- convert2df(rv$data@metacell[indices, ])

      data_nostyle <- NULL
      if (!is.null(input$pepInfo)) {
        .arg <- (rv$data@metadata)[pepLine, input$pepInfo]
        data_nostyle <- as.data.frame(.arg)
        colnames(data_nostyle) <- input$pepInfo
      }

      list(
        qdata = qdata,
        data_nostyle = data_nostyle,
        qmetacell = qmetacell
      )
    })


    output$CCDetailedSharedPep_UI <- renderUI({
      req(c(rvCC$CCMultiMulti_rows_selected(), rvCC$detailedselectedNode))
      ll <- GetDataFor_CCDetailedSharedPep_UI()

      dt_style <- list(
        data = ll$qmetacell,
        colors = BuildColorStyles(rv$data@type)
      )

      formatDT_server("CCDetailedSharedPep",
        data = reactive({
          ll$qdata
        }),
        data_nostyle = reactive({
          ll$data_nostyle
        }),
        dt_style = reactive({
          dt_style
        })
      )

      formatDT_ui(ns("CCDetailedSharedPep"))
    })



    GetDataFor_CCDetailedSpecPep_UI <- reactive({
      rvCC$detailedselectedNode
      input$pepInfo

      req(rvCC$detailedselectedNode$specPepLabels)

      pepLine <- rvCC$detailedselectedNode$specPepLabels
      indices <- unlist(lapply(pepLine, function(x) {
        which(rownames(rv$data@qdata) == x)
      }))

      qdata <- convert2df(rv$data@qdata[indices, ])
      qmetacell <- convert2df(rv$data@metacell[indices, ])

      data_nostyle <- NULL
      if (!is.null(input$pepInfo)) {
        .arg <- (rv$data@metadata)[pepLine, input$pepInfo]
        data_nostyle <- as.data.frame(.arg)
        colnames(data_nostyle) <- input$pepInfo
      }

      list(
        qdata = qdata,
        data_nostyle = data_nostyle,
        qmetacell = qmetacell
      )
    })

    output$CCDetailedSpecPep_UI <- renderUI({
      req(rvCC$CCMultiMulti_rows_selected())
      ll <- GetDataFor_CCDetailedSpecPep_UI()

      dt_style <- list(
        data = ll$qmetacell,
        colors = BuildColorStyles(rv$data@type)
      )

      formatDT_server("CCDetailedSpecPep",
        data = reactive({
          ll$qdata
        }),
        data_nostyle = reactive({
          ll$data_nostyle
        }),
        dt_style = reactive({
          dt_style
        })
      )

      formatDT_ui(ns("CCDetailedSpecPep"))
    })




    BuildOne2OneTab <- reactive({
      # rv$data@cc
      ll <- (GetCCInfos(rv$data@cc))$One_One

      df <- cbind(
        cbind(lapply(ll, function(x) {colnames(x)})),
        cbind(lapply(ll, function(x) {rownames(x)}))
      )
      colnames(df) <- c("proteins", "peptides")
      df
    })

    BuildOne2MultiTab <- reactive({
      # rv$data@cc
      ll <- (GetCCInfos(rv$data@cc))$One_Multi
      df <- cbind(
        proteins = cbind(lapply(ll, function(x) {colnames(x)})),
        nPep = cbind(lapply(ll, function(x) {nrow(x)})),
        peptides = cbind(lapply(ll, function(x) {
          paste(rownames(x), collapse = ",")
        }))
      )
      colnames(df) <- c("proteins", "nPep", "peptides")

      df
    })


    BuildMulti2AnyTab <- reactive({
      # rv$data@cc

      ll <- (GetCCInfos(rv$data@cc))$Multi_Multi

      df <- cbind(
        id = seq_len(ll),
        proteins = cbind(lapply(ll, function(x) {
          colnames(x)
        })),
        nProt = cbind(lapply(ll, function(x) {
          ncol(x)
        })),
        nPep = cbind(lapply(ll, function(x) {
          nrow(x)
        })),
        peptides = cbind(lapply(ll, function(x) {
          paste(rownames(x), collapse = ",")
        }))
      )
      colnames(df) <- c("proteins", "nPep", "peptides")

      df
    })



    # dl_server("OneMultiDT_DL_btns",
    #                          df.data = reactive({
    #                            df <- BuildOne2MultiTab()
    #                            colnames(df) <- c("Proteins Ids", "nPep",
    # "Peptides Ids")
    #                            df
    #                          }),
    #                          name = reactive({"CC_OneMulti"}),
    #                          colors = reactive({NULL}),
    #                          df.tags = reactive({NULL})
    #                          )


    output$OneMultiDT_UI <- renderUI({
      # req(rv$isValid)
      df <- BuildOne2MultiTab()
      colnames(df) <- c("Proteins Ids", "nPep", "Peptides Ids")


      rvCC$OneMultiDT_rows_selected <- formatDT_server("OneMultiDT",
        data = reactive({
          df
        })
      )
      formatDT_ui(ns("OneMultiDT"))
    })


    GetDataFor_OneMultiDTDetailed <- reactive({
      input$pepInfo
      req(rvCC$OneMultiDT_rows_selected())


      line <- rvCC$OneMultiDT_rows_selected()
      pepLine <- unlist(strsplit(unlist(
        BuildOne2MultiTab()[line, "peptides"]
      ), split = ","))

      indices <- unlist(lapply(pepLine, function(x) {
        which(rownames(rv$data@qdata) == x)
      }))

      qdata <- rv$data@qdata[indices, ]
      qmetacell <- rv$data@metacell[indices, ]

      list(
        qdata = convert2df(qdata),
        qmetacell = convert2df(qmetacell)
      )
    })


    output$OneMultiDTDetailed_UI <- renderUI({
      input$pepInfo
      req(rvCC$OneMultiDT_rows_selected())

      ll <- GetDataFor_OneMultiDTDetailed()

      dt_style <- list(
        data = ll$qmetacell,
        colors = BuildColorStyles(rv$data@type)
      )

      formatDT_server("OneMultiDTDetailed",
        data = reactive({
          ll$qdata
        }),
        dt_style = reactive({
          dt_style
        })
      )

      formatDT_ui(ns("OneMultiDTDetailed"))
    })




    # dl_server("OneOneDT_DL_btns",
    #                          df.data = reactive({
    #                            df <- BuildOne2OneTab()
    #                            colnames(df) <- c("Proteins Ids",
    # "Peptides Ids")
    #                            df
    #                          }),
    #                          name = reactive({"CC_OneOne"}),
    #                          colors = reactive({NULL}),
    #                          df.tags = reactive({NULL})
    #                          )


    output$OneOneDT_UI <- renderUI({
      # req(rv$isValid)
      df <- BuildOne2OneTab()
      colnames(df) <- c("Proteins Ids", "Peptides Ids")
      rvCC$OneOneDT_rows_selected <- formatDT_server("OneOneDT",
        data = reactive({
          df
        })
      )

      formatDT_ui(ns("OneOneDT"))
    })



    GetDataFor_OneOneDTDetailed <- reactive({
      # req(rv$isValid)
      req(rvCC$OneOneDT_rows_selected())

      line <- rvCC$OneOneDT_rows_selected()
      pepLine <- BuildOne2OneTab()[line, "peptides"]

      indices <- unlist(lapply(pepLine, function(x) {
        which(rownames(rv$data@qdata) == x)
      }))
      qdata <- rv$data@qdata[indices, ]
      qmetacell <- rv$data@metacell[indices, ]

      list(
        qdata = convert2df(qdata),
        qmetacell = convert2df(qmetacell)
      )
    })

    convert2df <- function(obj) {
      if (is.vector(obj)) {
        data.frame(as.list(obj))
      } else {
        obj
      }
    }
    output$OneOneDTDetailed_UI <- renderUI({
      # req(rv$isValid)
      req(rvCC$OneOneDT_rows_selected())

      ll <- GetDataFor_OneOneDTDetailed()

      dt_style <- list(
        data = ll$qmetacell,
        colors = BuildColorStyles(rv$data@type)
      )
      formatDT_server("OneOneDTDetailed",
        data = reactive({
          ll$qdata
        }),
        dt_style = reactive({
          dt_style
        })
      )

      formatDT_ui(ns("OneOneDTDetailed"))
    })
  })
}



#' @import shiny
#' @rdname ds-cc
#'
#' @export
#' @return A shiny app
#'
DaparViz_cc <- function(obj) {
  ui <- DaparViz_cc_ui("plot")

  server <- function(input, output, session) {
    DaparViz_cc_server("plot", reactive({
      obj
    }))
  }

  shinyApp(ui = ui, server = server)
}
