#' #' #' @title Convert datasets to `DaparViz` class
#' #' #' @description These functions are converters for different data formats
#' #' #' to an object of class `DaparViz` which is the format used by functions
#' #' #' in the package `DaparViz`.
#' #' #'
#' #' #' @name DaparViz-converter
#' #' #'
#' #' #' @param object An instance of class `QFeatures`.
#' #' #'
#' #' #' @examples
#' #' #'
#' #' #' # Conversion of an object of class `MSnSet`
#' #' #' data(sub_Exp1_R2_pept_MSnSet)
#' #' #' obj <- convert2VizList(sub_Exp1_R2_pept_MSnSet)
#' #' #' obj
#' #' #'
#' #' #' # Conversion of an object of class `QFeatures`
#' #' #' data(sub_Exp1_R2_pept_qf)
#' #' #' obj <- convert2VizList(sub_Exp1_R2_pept_qf)
#' #' #' obj
#' #' #' 
#' #' #' @exportMethod convert2VizList
#' #' #' @export
#' #' #' @aliases convert2VizList
#' #' #'
#' #' #' @return An instance of class `DaparViz`
#' #' #'
#' #' #' @import QFeatures
#' #' #' @import MSnbase
#' #' #' @importFrom PSMatch makeAdjacencyMatrix ConnectedComponents
#' #' #'
#' #' setGeneric(
#' #'   "convert2VizList",
#' #'   function(object, ...) standardGeneric("convert2VizList")
#' #' )
#' 
#' #' 
#' #' #' @exportMethod convert2VizList
#' #' #' @export
#' #' #' @return An object of class `VizList`.
#' #' #' @rdname VizList-converter
#' #' setMethod("convert2VizList", signature = NULL,
#' #'   function(object) {
#' #'     NULL
#' #'   }
#' #' )
#' 
#' 
#' #' @exportMethod convert2VizList
#' #' @export
#' #' @return An object of class `VizList`.
#' #' @rdname VizList-converter
#' setMethod("convert2VizList", signature = 'list',
#'   function(object) {
#'     all.is.MSnSet <- all(unlist(lapply(object, 
#'       function(x) inherits(x, 'MSnSet')), 
#'       use.names=FALSE))
#'     
#'     if (all.is.MSnSet){
#'       ll <- VizList()
#'       lapply(object, function(x){
#'         
#'         
#'         args <- list(
#'           qdata = GetSlotQdata(object),
#'           metacell = GetSlotMetacell(object),
#'           metadata = GetSlotMetadata(object),
#'           colID = GetSlotColID(object),
#'           proteinID = GetSlotProteinID(object),
#'           conds = GetSlotConds(object),
#'           type = GetSlotType(object),
#'           adjMat = matrix(),
#'           cc = list()
#'         )
#'         
#'         if (args$type == "peptide") {
#'           .dat <- args$metadata[, args$proteinID]
#'           args$adjMat <- PSMatch::makeAdjacencyMatrix(.dat)
#'           rownames(args$adjMat) <- rownames(args$metadata)
#'           connectedComp <- PSMatch::ConnectedComponents(args$adjMat)
#'           args$cc <- connectedComp@adjMatrices
#'         }
#'         
#'         .name <- name <- paste0('object_', i)
#'         ll@ll.daparViz[[.name]] <- do.call(DaparViz, args)
#'       }
#' 
#'    else
#'      object <- NULL
#'    
#'    object
#'   }
#' )
#' 
#' 
#' #' 
#' #' #' @exportMethod convert2VizList
#' #' #' @export
#' #' #' @return An object of class `VizList`.
#' #' #' @rdname VizList-converter
#' #' setMethod("convert2VizList", signature = "MultiAssayExperiment",
#' #'   #' @title xxx
#' #'   #' @param object An instance of class `MultiAssayExperiment`.
#' #'   function(object) {
#' #'     object <- convertMAEtype(object)
#' #'     object
#' #'   }
#' #' )
#' 
#' #' 
#' #' #' @exportMethod convert2VizList
#' #' #' @export
#' #' #' @return An object of class `VizList`.
#' #' #' @rdname VizList-converter
#' #' setMethod("convert2VizList", signature = "QFeatures",
#' #'   #' @title xxx
#' #'   #' @param object An instance of class `MultiAssayExperiment`.
#' #'   function(object) {
#' #'     object <- convertMAEtype(object)
#' #'     object
#' #'   }
#' #' )
#' 
#' 
#' 
#' #' @exportMethod convert2VizList
#' #' @export
#' #' @rdname VizList-converter
#' #' @return An object of class `VizList`.
#' #' @import PSMatch
#' #'
#' setMethod("convert2VizList", signature = "SummarizedExperiment",
#'   #' @title xxx
#'   #' @param object An instance of class `MultiAssayExperiment`.
#'   function(object) {
#'     # ll <- list()
#'     # args <- list(
#'     #   qdata = GetSlotQdata(object),
#'     #   metacell = GetSlotMetacell(object),
#'     #   metadata = GetSlotMetadata(object),
#'     #   colID = GetSlotColID(object),
#'     #   proteinID = GetSlotProteinID(object),
#'     #   conds = GetSlotConds(object),
#'     #   type = GetSlotType(object),
#'     #   adjMat = matrix(),
#'     #   cc = list()
#'     # )
#'     # 
#'     # 
#'     # if (!is.null(args$metacell)) {
#'     #   ind <- which(names(args$metadata) == "qMetacell")
#'     #   args$metadata <- args$metadata[, -ind]
#'     # }
#'     # 
#'     # # Delete adjacency Matrix from whole metadata
#'     # if ("adjacencyMatrix" %in% names(args$metadata)) {
#'     #   ind <- which(names(args$metadata) == "adjacencyMatrix")
#'     #   args$metadata <- args$metadata[, -ind]
#'     # }
#'     # 
#'     # if (!is.null(args$proteinID) && args$proteinID != "") {
#'     #   .args <- args$metadata[, args$proteinID]
#'     #   args$adjMat <- PSMatch::makeAdjacencyMatrix(.args)
#'     #   rownames(args$adjMat) <- rownames(args$metadata)
#'     # 
#'     #   # Create the connected components
#'     #   # args$cc <- PSMatch::ConnectedComponents(args$adjMat)@adjMatrices
#'     # }
#'     # 
#'     # # Fix typos
#'     # 
#'     # args$metadata <- as.data.frame(args$metadata)
#'     # 
#'     # ll[["original"]] <- do.call(DaparViz, args)
#'     # ll <- VizList(ll)
#'     # ll
#'   }
#' )
#' 
#' 
#' #' 
#' #' #' @exportMethod convert2VizList
#' #' #' @export
#' #' #' @rdname VizList-converter
#' #' #' @return An object of class `VizList`.
#' #' #' @import PSMatch
#' #' #'
#' #' setMethod("convert2VizList", signature = "MSnSet",
#' #'   #' @title xxx
#' #'   #' @param object An instance of class `MSnSet`.
#' #'   #' @param ... xxx
#' #'   function(object, ...) {
#' #'     args <- list(
#' #'       qdata = GetSlotQdata(object),
#' #'       metacell = GetSlotMetacell(object),
#' #'       metadata = GetSlotMetadata(object),
#' #'       colID = GetSlotColID(object),
#' #'       proteinID = GetSlotProteinID(object),
#' #'       conds = GetSlotConds(object),
#' #'       type = GetSlotType(object),
#' #'       adjMat = matrix(),
#' #'       cc = list()
#' #'     )
#' #' 
#' #'     if (args$type == "peptide") {
#' #'       .dat <- args$metadata[, args$proteinID]
#' #'       args$adjMat <- PSMatch::makeAdjacencyMatrix(.dat)
#' #'       rownames(args$adjMat) <- rownames(args$metadata)
#' #'       connectedComp <- PSMatch::ConnectedComponents(args$adjMat)
#' #'       args$cc <- connectedComp@adjMatrices
#' #'     }
#' #' 
#' #'     ll.tmp <- list()
#' #'     ll.tmp[["original"]] <- do.call(DaparViz, args)
#' #'     ll.tmp <- VizList(ll.tmp)
#' #'     ll.tmp
#' #'   }
#' #' )
#' 
#' 
#' 
#' 
#' #' @title Formats available in DaparViz
#' #' @description
#' #' Gives the list of classes for the datasets which be can converted by the
#' #' function `convert2VizList()`.
#' #'
#' #' @return A vector of classes compliant with the package DaparViz.
#' #' @examples
#' #' FormatAvailables()
#' #'
#' #' @export
#' #'
#' FormatAvailables <- function() {
#'   c(
#'     "QFeatures",
#'     "MSnSet",
#'     "SummarizedExperiment",
#'     "MultiAssayExperment",
#'     "list"
#'   )
#' }
