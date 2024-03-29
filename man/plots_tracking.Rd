% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DaparViz_plots_tracking.R
\name{plots_tracking}
\alias{plots_tracking}
\alias{plots_tracking_ui}
\alias{plots_tracking_server}
\title{plots_tracking_ui and plots_tracking_server}
\usage{
plots_tracking_ui(id)

plots_tracking_server(
  id,
  obj = reactive({
     NULL
 }),
  resetBtn = reactive({
     FALSE
 })
)

plots_tracking(obj)
}
\arguments{
\item{id}{shiny id}

\item{obj}{An instance of the class \code{DaparViz}}

\item{resetBtn}{A \code{boolean(1)} which indicates whether to show the 'Reset'
button or not.}
}
\value{
NA

A \code{list} (same structure as the parameter \code{params})

A shiny app
}
\description{
This shiny module provides a tool to select
}
\examples{
if (interactive()) {
  data(vData_ft)
  plots_tracking(vData_ft[[1]])
}

}
\keyword{internal}
