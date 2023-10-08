% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_ds_cc.R
\name{ds-cc}
\alias{ds-cc}
\alias{mod_ds_cc_ui}
\alias{mod_ds_cc_server}
\alias{ds_cc}
\title{mod_plots_cc_ui and mod_plots_cc_server}
\usage{
mod_ds_cc_ui(id)

mod_ds_cc_server(id, obj)

ds_cc(obj)
}
\arguments{
\item{id}{A \code{character(1)} which is the id of the shiny module.}

\item{obj}{An instance of \code{DaparViz} class}
}
\value{
NA
}
\description{
A shiny Module.
}
\examples{
if(interactive()){
data(vData_ft)
ds_cc(vData_ft[[1]])
}


}
\keyword{internal}