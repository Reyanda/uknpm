test_that("calculate_mtl classifies solid food 100g thresholds correctly", {
  # All green product: low fat (2g <= 3), low sat fat (1g <= 1.5), low sugar (4g <= 5), low salt (0.2g <= 0.3)
  res_green <- calculate_mtl(fat_g = 2.0, sat_fat_g = 1.0, sugars_g = 4.0, salt_g = 0.2, is_drink = FALSE)
  expect_equal(res_green$fat_colour, "Green")
  expect_equal(res_green$sat_fat_colour, "Green")
  expect_equal(res_green$sugars_colour, "Green")
  expect_equal(res_green$salt_colour, "Green")
  expect_equal(res_green$n_green, 4)
  expect_equal(res_green$n_red, 0)
  expect_true(res_green$all_green)
  expect_false(res_green$has_red)
  expect_equal(res_green$mtl_healthiness, "healthier")

  # Amber product: medium values
  res_amber <- calculate_mtl(fat_g = 10.0, sat_fat_g = 3.5, sugars_g = 15.0, salt_g = 1.0, is_drink = FALSE)
  expect_equal(res_amber$fat_colour, "Amber")
  expect_equal(res_amber$sat_fat_colour, "Amber")
  expect_equal(res_amber$sugars_colour, "Amber")
  expect_equal(res_amber$salt_colour, "Amber")
  expect_equal(res_amber$n_amber, 4)
  expect_equal(res_amber$n_red, 0)
  expect_equal(res_amber$mtl_healthiness, "healthier")

  # Red product: high values
  res_red <- calculate_mtl(fat_g = 20.0, sat_fat_g = 7.0, sugars_g = 25.0, salt_g = 1.8, is_drink = FALSE)
  expect_equal(res_red$fat_colour, "Red")
  expect_equal(res_red$sat_fat_colour, "Red")
  expect_equal(res_red$sugars_colour, "Red")
  expect_equal(res_red$salt_colour, "Red")
  expect_equal(res_red$n_red, 4)
  expect_true(res_red$has_red)
  expect_equal(res_red$mtl_healthiness, "less healthy")
})

test_that("calculate_mtl classifies drinks 100ml thresholds correctly", {
  # Drink low thresholds: fat <= 1.5, sat fat <= 0.75, sugar <= 2.5, salt <= 0.3
  res_drink_green <- calculate_mtl(fat_g = 0.5, sat_fat_g = 0.2, sugars_g = 2.0, salt_g = 0.1, is_drink = TRUE)
  expect_equal(res_drink_green$fat_colour, "Green")
  expect_equal(res_drink_green$sat_fat_colour, "Green")
  expect_equal(res_drink_green$sugars_colour, "Green")
  expect_equal(res_drink_green$salt_colour, "Green")

  # High sugar drink (e.g. regular cola at 10.6g / 100ml -> Amber because <= 11.25g; at 12g -> Red)
  res_drink_amber <- calculate_mtl(fat_g = 0, sat_fat_g = 0, sugars_g = 10.6, salt_g = 0, is_drink = TRUE)
  expect_equal(res_drink_amber$sugars_colour, "Amber")

  res_drink_red <- calculate_mtl(fat_g = 0, sat_fat_g = 0, sugars_g = 12.0, salt_g = 0, is_drink = TRUE)
  expect_equal(res_drink_red$sugars_colour, "Red")
})

test_that("calculate_mtl portion size red threshold override works", {
  # Solid food: portion > 100g.
  # Fat is 15g / 100g (Amber on 100g basis <= 17.5g).
  # If portion is 150g: fat per portion = 22.5g (> 21g cap) -> Overrides to RED!
  res_override <- calculate_mtl(
    fat_g = 15.0,
    sat_fat_g = 3.0,
    sugars_g = 5.0,
    salt_g = 0.5,
    portion_g = 150,
    is_drink = FALSE
  )
  expect_equal(res_override$fat_colour, "Red")
  expect_true(res_override$has_red)

  # If portion is 120g: fat per portion = 18.0g (< 21g cap) -> Stays Amber
  res_no_override <- calculate_mtl(
    fat_g = 15.0,
    sat_fat_g = 3.0,
    sugars_g = 5.0,
    salt_g = 0.5,
    portion_g = 120,
    is_drink = FALSE
  )
  expect_equal(res_no_override$fat_colour, "Amber")
})
