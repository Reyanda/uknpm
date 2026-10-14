test_that("calculate_sdil accurately assigns levy tiers and rates", {
  # Exempt (< 5g or exempt flag)
  sdil_ex <- calculate_sdil(sugars_g_100ml = 3.5, is_exempt = FALSE)
  expect_equal(sdil_ex$sdil_tier, "Exempt")
  expect_false(sdil_ex$is_levied)
  expect_equal(sdil_ex$levy_rate_gbp_per_l, 0)

  # Tier 1 (5.0 to < 8.0)
  sdil_t1 <- calculate_sdil(sugars_g_100ml = 6.5, is_exempt = FALSE, rate_year = "2025")
  expect_equal(sdil_t1$sdil_tier, "Tier 1 (Lower)")
  expect_true(sdil_t1$is_levied)
  expect_equal(sdil_t1$levy_rate_gbp_per_l, 0.194)

  # Tier 2 (>= 8.0)
  sdil_t2 <- calculate_sdil(sugars_g_100ml = 10.5, is_exempt = FALSE, rate_year = "2025")
  expect_equal(sdil_t2$sdil_tier, "Tier 2 (Higher)")
  expect_true(sdil_t2$is_levied)
  expect_equal(sdil_t2$levy_rate_gbp_per_l, 0.259)

  # 100% fruit juice exemption override
  sdil_juice <- calculate_sdil(sugars_g_100ml = 11.0, is_exempt = TRUE)
  expect_equal(sdil_juice$sdil_tier, "Exempt")
  expect_false(sdil_juice$is_levied)
})

test_that("check_salt_target verifies OHID 2024 benchmarks", {
  # Bread: average 0.85, max 1.01
  chk_bread <- check_salt_target(salt_g_100g = c(0.80, 0.95, 1.15), category = "Bread")
  expect_equal(chk_bread$target_average_100g, c(0.85, 0.85, 0.85))
  expect_equal(chk_bread$target_maximum_100g, c(1.01, 1.01, 1.01))
  expect_equal(chk_bread$meets_average, c(TRUE, FALSE, FALSE))
  expect_equal(chk_bread$meets_maximum, c(TRUE, TRUE, FALSE))
  expect_equal(chk_bread$salt_compliant, c(TRUE, TRUE, FALSE))
})

test_that("check_sugar_target evaluates categories and portion caps", {
  # Biscuits: target 26.2g/100g
  chk_bisc <- check_sugar_target(sugars_g_100g = c(22.0, 31.0), category = "Biscuits")
  expect_equal(chk_bisc$target_sugars_100g, c(26.2, 26.2))
  expect_equal(chk_bisc$meets_sugar_target, c(TRUE, FALSE))

  # Chocolate confectionery with portion cap: 30g sugar cap
  chk_choc <- check_sugar_target(
    sugars_g_100g = c(40.0, 40.0),
    category = "Chocolate confectionery",
    sugars_portion_g = c(25.0, 35.0)
  )
  expect_equal(chk_choc$meets_portion_cap, c(TRUE, FALSE))
})

test_that("check_calorie_guideline tests single-serve and 400-600-600 ceilings", {
  # Sandwich cap: 550 kcal
  chk_sand <- check_calorie_guideline(energy_kcal_portion = c(450, 620), category = "Sandwiches")
  expect_equal(chk_sand$guideline_kcal, c(550, 550))
  expect_equal(chk_sand$meets_calorie_guideline, c(TRUE, FALSE))

  # General lunch meal benchmark: 600 kcal
  chk_lunch <- check_calorie_guideline(energy_kcal_portion = c(550, 750), meal_type = "lunch")
  expect_equal(chk_lunch$guideline_kcal, c(600, 600))
  expect_equal(chk_lunch$meets_calorie_guideline, c(TRUE, FALSE))
})
