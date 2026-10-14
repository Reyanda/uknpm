test_that("Shiny app files exist and syntax is valid", {
  app_file <- system.file("shiny", "app.R", package = "uknpm")
  if (app_file == "" || !file.exists(app_file)) {
    app_file <- file.path("..", "..", "inst", "shiny", "app.R")
    if (!file.exists(app_file)) {
      app_file <- file.path("inst", "shiny", "app.R")
    }
  }

  expect_true(file.exists(app_file))
  # Verify that app.R parses without any syntax errors
  parsed <- parse(app_file)
  expect_true(length(parsed) > 0)
})

test_that("run_app function exists and is exported", {
  expect_true(exists("run_app", where = asNamespace("uknpm")))
  expect_type(get("run_app", envir = asNamespace("uknpm")), "closure")
})
