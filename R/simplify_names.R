#' simplify names of PFB export
#' @param .data input data.frame-like entity
#' @export
simplify_names = function(.data) {
  names(.data) = gsub("^pfb:", "", names(.data))
  .data
}
