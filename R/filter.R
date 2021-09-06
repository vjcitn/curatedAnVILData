#' S3 support for inline filter
#' @param .data DataFrame instance
#' @param \dots as needed
#' @export
filter.DataFrame = function(.data, ...) dplyr::filter(as.data.frame(.data), ...)

#' S3 support for inline filter
#' @param .data DataFrame instance
#' @param \dots as needed
#' @export
filter.DFrame = function(.data, ...) dplyr::filter(as.data.frame(.data), ...)
