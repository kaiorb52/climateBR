#'
#' @export
read_inmet <- function(
    path = NULL,
    years = NULL,
    stations = NULL,
    variables = NULL,
    collect = FALSE
  ) 
{
  
  ds <- arrow::open_dataset(
    path
  )

  if (!is.null(years))
    ds <- dplyr::filter(
      ds,
      ano %in% years
    )
  
  if (!is.null(stations))
    ds <- dplyr::filter(
      ds,
      codigo_wmo %in% stations
    )
  
  if (!is.null(variables))
    ds <- dplyr::select(
      ds,
      dplyr::all_of(variables)
    )
  
  if (collect)
    dplyr::collect(ds)
  else
    ds
}