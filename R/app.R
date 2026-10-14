#' Launch the Interactive uknpm Shiny Application
#'
#' Launches an interactive Shiny web application styled with the Apple design
#' system. The application allows users to explore:
#' \itemize{
#'   \item \strong{Single Item Profiler}: Interactive computation of the UK
#'   Nutrient Profile Model (2004/2005 statutory & 2018 consultation), Front-of-Pack
#'   Multiple Traffic Light (MTL) lozenges, and OHID reduction target compliance.
#'   \item \strong{Portfolio & Menu Benchmarking}: Cross-sectional multi-metric
#'   evaluation of out-of-home menus reproducing the methodology of
#'   Tan et al. (2025).
#'   \item \strong{Statutory Standards & Flowchart}: Interactive lookup of OHID
#'   2024 salt reduction targets across 84 categories, calorie caps, and the
#'   statutory scoring flowchart.
#' }
#'
#' @param port Integer port number to listen on. Default is random/selected by Shiny.
#' @param launch.browser Logical; if \code{TRUE}, opens the default web browser. Default is \code{interactive()}.
#' @param host Character string specifying host IP address. Default is \code{"127.0.0.1"}.
#'
#' @return A Shiny app object (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#'   library(uknpm)
#'   run_app()
#' }
run_app <- function(port = NULL, launch.browser = interactive(), host = "127.0.0.1") {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to run the interactive explorer. Please install it with install.packages('shiny').", call. = FALSE)
  }

  app_dir <- system.file("shiny", package = "uknpm")
  if (app_dir == "" || !file.exists(file.path(app_dir, "app.R"))) {
    # Fallback to local source tree if running during development
    app_dir <- "inst/shiny"
  }

  if (!file.exists(file.path(app_dir, "app.R"))) {
    stop("Could not locate the uknpm Shiny app files. Ensure the package is installed properly.", call. = FALSE)
  }

  shiny::runApp(
    appDir = app_dir,
    port = port,
    launch.browser = launch.browser,
    host = host
  )
}
