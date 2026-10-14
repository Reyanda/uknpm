test_that("plot_healthiness_comparison generates a ggplot object in ATNi and Vellum styles", {
  data("sample_ooh_menu")
  assessment <- assess_healthiness(sample_ooh_menu)

  p_atni <- plot_healthiness_comparison(assessment, style = "atni")
  expect_s3_class(p_atni, "ggplot")

  p_vellum <- plot_healthiness_comparison(assessment, style = "vellum")
  expect_s3_class(p_vellum, "ggplot")
})

test_that("plot_mtl_profile generates a valid ggplot object", {
  data("sample_ooh_menu")
  assessment <- assess_healthiness(sample_ooh_menu)

  p_mtl <- plot_mtl_profile(assessment, style = "atni")
  expect_s3_class(p_mtl, "ggplot")
})

test_that("plot_npm_scatter generates a valid ggplot object with decision line", {
  data("sample_ooh_menu")
  assessment <- assess_healthiness(sample_ooh_menu)

  p_scatter <- plot_npm_scatter(assessment, style = "vellum")
  expect_s3_class(p_scatter, "ggplot")
})

test_that("plot_npm_flowchart generates mermaid string and ggplot object", {
  chart_mermaid <- plot_npm_flowchart(format = "mermaid")
  expect_true(is.character(chart_mermaid))
  expect_true(grepl("flowchart TD", chart_mermaid))
  expect_true(grepl("HFSS", chart_mermaid))

  chart_ggplot <- plot_npm_flowchart(format = "ggplot")
  expect_s3_class(chart_ggplot, "ggplot")
})
