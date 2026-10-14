test_that("assess_healthiness runs seamlessly on menu dataset", {
  # Create a miniature 3-item test dataframe
  mini_menu <- data.frame(
    item = c("Salad Bowl", "Cheeseburger", "Cola"),
    energy_kcal = c(80, 280, 42),
    energy_kcal_portion = c(200, 700, 140),
    fat_g = c(2.0, 14.0, 0),
    sat_fat_g = c(0.5, 6.0, 0),
    sugars_g = c(2.0, 4.0, 10.6),
    salt_g = c(0.2, 1.4, 0),
    fvns_pct = c(85, 5, 0),
    fibre_g = c(3.5, 1.5, 0),
    protein_g = c(4.0, 15.0, 0),
    portion_g = c(250, 250, 330),
    category = c("Main meal", "Main meal", "Drink"),
    is_drink = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  res <- assess_healthiness(mini_menu)

  expect_equal(nrow(res), 3)
  expect_true("npm_score" %in% names(res))
  expect_true("mtl_healthiness" %in% names(res))
  expect_true("combined_npm_mtl_healthy" %in% names(res))

  # Salad should be healthy across NPM, MTL, and Combined
  expect_false(res$npm_is_hfss[1])
  expect_false(res$mtl_has_red[1])
  expect_true(res$combined_npm_mtl_healthy[1])

  # Burger: high sat fat (6g > 5g) -> Red MTL; portion kcal 700 > 600 -> fails calorie guideline
  expect_true(res$mtl_has_red[2])
  expect_false(res$meets_calorie_guideline[2])

  # Summary table
  summary_tab <- summarise_healthiness(res)
  expect_equal(summary_tab$total_items[1], 3)
  expect_true("UK Nutrient Profile Model (NPM)" %in% summary_tab$approach)
  expect_true("Multiple Traffic Light (MTL, No Red Lights)" %in% summary_tab$approach)
})
