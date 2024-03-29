#' @title Accessors functions
#' @description xxx
#' @return See individual method description for the return value.
#' @param object An object of
#' @param ... xxxx description
#' @name accessors
#'
#'
#' @aliases GetSlotMetadata, GetSlotMetacell, GetSlotQdata, GetSlotProteinID,
#' GetSlotColID, GetSlotConds, GetSlotAdjMat, GetSlotCc
#'
#' @return If exists, the slot value requested.
#' @examples
#'
#' ## -----------------------------------
#' ## Accessing slots from a MSnSet dataset
#' ## -----------------------------------
#' data(sub_Exp1_R2_prot_MSnSet)
#' obj <- sub_Exp1_R2_prot_MSnSet
#' metadata <- GetSlotMetadata(obj)
#' qdata <- GetSlotQdata(obj)
#' metacell <- GetSlotMetacell(obj)
#' id <- GetSlotColID(obj)
#' type <- GetSlotType(obj)
#' proteinID <- GetSlotProteinID(obj)
#' conds <- GetSlotConds(obj)
#'
NULL


#' @rdname accessors
#' @exportMethod GetSlotMetadata
setGeneric(
  "GetSlotMetadata",
  function(object, ...) standardGeneric("GetSlotMetadata")
)

#' @rdname accessors
#' @exportMethod GetSlotMetacell
setGeneric(
  "GetSlotMetacell",
  function(object, ...) standardGeneric("GetSlotMetacell")
)

#' @rdname accessors
#' @exportMethod GetSlotQdata
setGeneric(
  "GetSlotQdata",
  function(object, ...) standardGeneric("GetSlotQdata")
)

#' @rdname accessors
#' @exportMethod GetSlotProteinID
setGeneric(
  "GetSlotProteinID",
  function(object, ...) standardGeneric("GetSlotProteinID")
)


#' @rdname accessors
#' @exportMethod GetSlotColID
setGeneric(
  "GetSlotColID",
  function(object, ...) standardGeneric("GetSlotColID")
)

#' @rdname accessors
#' @exportMethod GetSlotConds
setGeneric(
  "GetSlotConds",
  function(object, ...) standardGeneric("GetSlotConds")
)


#' @rdname accessors
#' @exportMethod GetSlotType
setGeneric(
  "GetSlotType",
  function(object, ...) standardGeneric("GetSlotType")
)

#' @rdname accessors
#' @exportMethod GetSlotAdjMat
setGeneric(
  "GetSlotAdjMat",
  function(object, ...) standardGeneric("GetSlotAdjMat")
)

#' @rdname accessors
#' @exportMethod GetSlotCc
setGeneric(
  "GetSlotCc",
  function(object, ...) standardGeneric("GetSlotCc")
)

#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import QFeatures
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A data.frame containing the metadata of the dataset
#'
setMethod("GetSlotMetadata",
  signature = "SummarizedExperiment",
  function(object) {
    tryCatch(
      {
        SummarizedExperiment::rowData(object)
      },
      warning = function(w) NULL,
      error = function(e) NULL
    )
  }
)

#' @param object An instance of class `MSnSet`.
#' @rdname accessors
#' @import MSnbase
#' @return A data.frame
#'
setMethod("GetSlotMetadata",
  signature = "MSnSet",
  function(object) {
    tryCatch(
      {
        MSnbase::fData(object)
      },
      warning = function(w) NULL,
      error = function(e) NULL
    )
  }
)

#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A data.frame
#'
setMethod("GetSlotMetadata",
  signature = "DaparViz",
  function(object) object@metadata
)

#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import QFeatures
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A data.frame
#'
setMethod("GetSlotQdata",
  signature = "ANY",
  function(object) {
    NULL
  }
)

#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import QFeatures
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A data.frame
#'
setMethod("GetSlotQdata",
  signature = "SummarizedExperiment",
  function(object) {
    tryCatch(
      {
        SummarizedExperiment::assay(object)
      },
      warning = function(w) NULL,
      error = function(e) NULL
    )
  }
)

#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A data.frame
#'
setMethod("GetSlotQdata",
  signature = "DaparViz",
  function(object) object@qdata
)

#' @param object An instance of class `MSnSet`.
#' @rdname accessors
#' @import MSnbase
#' @return A data.frame
#'
setMethod("GetSlotQdata",
  signature = "MSnSet",
  function(object) {
    tryCatch(
      {
        MSnbase::exprs(object)
      },
      warning = function(w) NULL,
      error = function(e) NULL
    )
  }
)




#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A data.frame
#'
setMethod("GetSlotMetacell",
  signature = "DaparViz",
  function(object) object@metacell
)



#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import QFeatures
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A data.frame
#'
setMethod("GetSlotMetacell",
  signature = "SummarizedExperiment",
  function(object) {
    tryCatch(
      {
        (SummarizedExperiment::rowData(object))$qMetacell
      },
      warning = function(w) NULL,
      error = function(e) NULL
    )
  }
)

#' @param object An instance of class `MSnSet`.
#' @rdname accessors
#' @import MSnbase
#' @return A data.frame
#'
setMethod("GetSlotMetacell",
  signature = "MSnSet",
  function(object) {
    tryCatch(
      {
        # if ('names_metacell' %in% names(object@experimentData@other))
        .names <- object@experimentData@other$names_metacell
        MSnbase::fData(object)[, .names]
      },
      warning = function(w) NULL,
      error = function(e) NULL
    )
  }
)


#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotColID",
  signature = "DaparViz",
  function(object) object@colID
)


#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import QFeatures
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A character(0)
#'
setMethod("GetSlotColID",
  signature = "SummarizedExperiment",
  function(object) {
    colID <- ""
    tryCatch(
      {
        colID <- SummarizedExperiment::metadata(object)$idcol
        if (is.null(colID)) colID <- ""
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(colID)
  }
)

#' @param object An instance of class `MSnSet`.
#' @import MSnbase
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotColID", signature = "MSnSet",
  function(object) {
    colID <- ""
    tryCatch(
      {
        colID <- object@experimentData@other$keyId
        if (is.null(colID)) colID <- ""

        colID
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(colID)
  }
)


#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotType",
  signature = "DaparViz",
  function(object) object@type
)


#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import SummarizedExperiment
#' @return A character(0)
#'
setMethod("GetSlotType",
  signature = "SummarizedExperiment",
  function(object) {
    type <- ""
    tryCatch(
      {
        type <- SummarizedExperiment::metadata(object)$typeDataset
        if (is.null(type)) type <- ""

        type
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(type)
  }
)

#' @param object An instance of class `MSnSet`.
#' @import MSnbase
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotType",
  signature = "MSnSet",
  function(object) {
    type <- ""
    tryCatch(
      {
        type <- object@experimentData@other$typeOfData
        if (is.null(type)) type <- ""
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(type)
  }
)


#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotProteinID",
  signature = "DaparViz",
  function(object) object@proteinID
)


#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @import QFeatures
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A character(0)
#'
setMethod("GetSlotProteinID",
  signature = "SummarizedExperiment",
  function(object) {
    proteinID <- ""
    tryCatch(
      {
        proteinID <- SummarizedExperiment::metadata(object)$parentProtId
        if (is.null(proteinID)) proteinID <- ""
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(proteinID)
  }
)

#' @param object An instance of class `MSnSet`.
#' @import MSnbase
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotProteinID",
  signature = "MSnSet",
  function(object) {
    proteinID <- ""
    tryCatch(
      {
        proteinID <- object@experimentData@other$proteinId
        if (is.null(proteinID)) proteinID <- ""
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(proteinID)
  }
)


#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotConds",
  signature = "DaparViz",
  function(object) object@conds
)


#' @param object An instance of class `MultiAssayExperiment`.
#' @rdname accessors
#' @import MultiAssayExperiment
#' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' @return A character(0)
#'
setMethod("GetSlotConds",
  signature = "MultiAssayExperiment",
  function(object) {
    conds <- ""
    tryCatch(
      {
        conds <- SummarizedExperiment::colData(object)$Condition
        if (is.null(conds)) conds <- ""
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(conds)
  }
)

#' @param object An instance of class `SummarizedExperiment`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotConds",
  signature = "ANY",
  function(object) {
    ""
  }
)

#' @param object An instance of class `MSnSet`.
#' @rdname accessors
#' @import MSnbase
#' @return A character(0)
#'
setMethod("GetSlotConds",
  signature = "MSnSet",
  function(object) {
    conds <- ""
    tryCatch(
      {
        conds <- MSnbase::pData(object)$Condition
        if (is.null(conds)) conds <- ""
      },
      warning = function(w) "",
      error = function(e) ""
    )
    return(conds)
  }
)


#' @param object An instance of class `ANY`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotCc",
  signature = "ANY",
  function(object) NULL
)

#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotCc", signature = "DaparViz",
  function(object) object@cc
)



#' @param object An instance of class `ANY`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotAdjMat", signature = "ANY",
  function(object) NULL
)

#' @param object An instance of class `DaparViz`.
#' @rdname accessors
#' @return A character(0)
#'
setMethod("GetSlotAdjMat", signature = "DaparViz",
  function(object) object@adjMat
)





#' @title xxx
#' @description xxx
#' @param object An object that inherits MultiAssayExperiment class
#' (e.g. MultiAssayExperiment, QFeatures)
#'
#' @return An object of class DaparViz.
#' @export
#' @examples
#' NULL
#'
ExtractInfos <- function(object) {
  
    args <- list(
        qdata = GetSlotQdata(object),
        metacell = GetSlotMetacell(object),
        metadata = GetSlotMetadata(object),
        colID = GetSlotColID(object),
        proteinID = GetSlotProteinID(object),
        conds = GetSlotConds(object),
        type = GetSlotType(object),
        adjMat = matrix(),
        cc = list()
      )

      if (!is.null(colnames(args$metacell))) {
        ind <- match(colnames(args$metacell), colnames(args$metadata))
          args$metadata <- args$metadata[, -ind]
      }

      # Delete adjacency Matrix from whole metadata
      if ("adjacencyMatrix" %in% names(args$metadata)) {
        .ind <- which(names(args$metadata) == "adjacencyMatrix")
        args$adjMat <- args$metadata[, "adjacencyMatrix"]
         args$metadata <- args$metadata[, -.ind]
      } else if (!is.null(args$proteinID) && args$proteinID != "") {
        .arg <- args$metadata[, args$proteinID]
        args$adjMat <- PSMatch::makeAdjacencyMatrix(.arg)
        rownames(args$adjMat) <- rownames(args$metadata)
      }

        if(!is.null(args$adjMat)){
          # Create the connected components
          args$cc <- PSMatch::ConnectedComponents(args$adjMat)@adjMatrices
        }

      # Fix typos
      args$metadata <- as.data.frame(args$metadata)


  return(args)
}
