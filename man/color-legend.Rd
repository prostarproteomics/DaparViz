% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_colorLegend.R
\name{color-legend}
\alias{color-legend}
\alias{custom_metacell_colors}
\alias{colorLegend_ui}
\alias{colorLegend_server}
\alias{colorLegend}
\title{Color legend for DaparToolshed}
\usage{
custom_metacell_colors()

colorLegend_ui(id)

colorLegend_server(
  id,
  presentTags = reactive({
     NULL
 }),
  hide.white = TRUE
)

colorLegend(obj)
}
\arguments{
\item{id}{A \code{character(1)} which is the id of the shiny module.}

\item{presentTags}{A vector of \code{character()} which correspond to the tags.}

\item{hide.white}{A \code{boolean()} to indicate whether the white cells must be
hidden or not.}

\item{obj}{An instance of the class \code{DaparViz}.}
}
\value{
A vector

NA

NA

A shiny app
}
\description{
Shows xxx based on the tags in the package 'DaparToolshed'
}
\examples{
if (interactive()) {
  data(vData_ft)
  colorLegend(vData_ft[[1]])
}

}
