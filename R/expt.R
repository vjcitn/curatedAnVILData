#' helper function for MAE filtering, just returns experiments(mae)[[tag]]
#' @param .data MultiAssayExperiment-like entity
#' @param tag character(1) should name an experiment in MAE
#' @export
expt = function(.data, tag) MultiAssayExperiment::experiments(.data)[[tag]]
