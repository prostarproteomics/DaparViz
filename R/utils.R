
#' 
#' #' @title xxx
#' #' @description xxx
#' #' 
#' #' @param object xxx
#' #' 
#' #' @return A boolean
#' #' @name DaparViz-class
#' #'
#' #' @examples
#' #' data(vData_ft)
#' #' is.ListOfDaparViz(vData_ft)
#' #' 
#' #' @export
#' #' 
#' is.ListOfDaparViz <- function(object){
#'   
#'   passed <- TRUE
#'   passed <- passed && inherits(object, 'list')
#'   passed <- passed && 
#'     all(unlist(lapply(object, function(x) inherits(x, 'DaparViz')), 
#'       use.names=FALSE))
#'   
#'   return(passed)
#' }






#' #' @title Customised contextual menu of highcharts plots
#'
#' @param hc A highcharter object
#' @param fname The filename under which the plot has to be saved
#'
#' @return A contextual menu for highcharts plots
#'
#' @author Samuel Wieczorek
#'
#' @rdname customExportMenu_HC
#'
#' @examples
#' NULL
#'
#' @export
#' @import highcharter
#'
customExportMenu <- function(hc, fname) {
  highcharter::hc_exporting(hc,
    enabled = TRUE,
    filename = fname,
    buttons = list(
      contextButton = list(
        menuItems = list(
          "downloadPNG",
          "downloadSVG",
          "downloadPDF"
        )
      )
    )
  )
  hc
}




#' @title Customised resetZoom Button of highcharts plots
#'
#' @param hc A highcharter object
#' @param chartType The type of the plot
#' @param zoomType The type of the zoom (one of "x", "y", "xy", "None")
#' @param width xxx
#' @param height xxx
#'
#' @return A highchart plot
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' if (interactive()) {
#'   hc <- highchart()
#'   hc_chart(hc, type = "line")
#'   hc_add_series(hc, data = c(29, 71, 40))
#'   customChart(hc)
#' }
#'
#' @export
#'
#' @import highcharter
#'
customChart <- function(
    hc,
    chartType = "scatter",
    zoomType = "None",
    width = 0,
    height = 0) {
  hc %>%
    hc_chart(
      type = chartType,
      zoomType = zoomType,
      showAxes = TRUE,
      width = width,
      height = height,
      resetZoomButton = list(
        position = list(
          align = "left",
          verticalAlign = "top"
        )
      )
    )
}



#' @noRd
#' @export
#' @return NA
#' 
.initComplete <- function() {
  return(DT::JS(
    "function(settings, json) {",
    "$(this.api().table().header()).css({
        'background-color': 'darkgrey',
        'color': 'black'});",
    "}"
  ))
}




#' @title Constructs a dataset suitable to use with the module format_DT.
#'
#' @description
#' This function builds the skeleton of a dataset which can be used by the
#' module formatDT. It creates additional columns to be used to style the table.
#' to colors cells.
#'
#' @param vizData An instance of the class `DaparViz`
#' @param digits An 'integer(1)' to specify the number of digits to display
#' in the tables for numerical values. Default is 2.
#'
#' @return A data.frame
#'
#' @export
#'
FormatDataForDT <- function(
    vizData,
    digits = 2) {
  test.table <- as.data.frame(round(vizData@qdata))
  if (!is.null(names(vizData@metacell))) {
    test.table <- cbind(round(vizData@qdata, digits = digits), vizData@metacell)
  } else {
    test.table <- cbind(
      test.table,
      as.data.frame(
        matrix(rep(NA, ncol(test.table) * nrow(test.table)),
          nrow = nrow(test.table)
        )
      )
    )
  }
  return(test.table)
}





#' @title
#' xxxx
#'
#' @description
#' xxxx
#'
#' @param type An instance of the class `DaparViz`
#'
#' @export
#'
#' @return A list
#'
BuildColorStyles <- function(type) {
  mc <- metacell.def(type)
  colors <- as.list(setNames(mc$color, mc$node))
  colors
}



#' @title xxx
#' @description xxxx
#' @param cc xxx
#' @return A `list` of three items:
#' * `One_One`: the number of cc composed of one protein and one peptide
#' * `One_Multi`: the number of cc composed of one protein and several peptides
#' * `Multi_Multi`: the number of cc composed of several proteins and
#' several (shared) peptides.
#'
#' @examples
#' data(vData_ft)
#' GetCCInfos(GetSlotCc(vData_ft[[1]]))
#'
#' @export
#'
GetCCInfos <- function(cc) {
  stopifnot(inherits(cc, "list"))
  cc.infos <- list(
    One_One = list(),
    One_Multi = list(),
    Multi_Multi = list()
  )


  ll.prot <- lapply(cc, function(x) {
    ncol(x)
  })
  ll.pept <- lapply(cc, function(x) {
    nrow(x)
  })
  ll.prot.one2one <- intersect(which(ll.prot == 1), which(ll.pept == 1))
  ll.prot.one2multi <- intersect(which(ll.prot == 1), which(ll.pept > 1))
  ll.prot.multi2any <- which(ll.prot > 1)

  cc.infos[["One_One"]] <- cc[ll.prot.one2one]
  cc.infos[["One_Multi"]] <- cc[ll.prot.one2multi]
  cc.infos[["Multi_Multi"]] <- cc[ll.prot.multi2any]

  cc.infos
}
