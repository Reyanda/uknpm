test_that("DHSC 2011 Worked Example 1 (Fruit fromage frais) matches official score", {
  res <- calculate_npm(
    energy_kj = 459,
    sat_fat_g = 1.8,
    sugars_g = 13.4,
    sodium_mg = 0,
    fvns_pct = 8,
    fibre_g = 0.6,
    protein_g = 6.5,
    is_drink = FALSE,
    fibre_method = "aoac"
  )
  expect_equal(res$points_energy, 1)
  expect_equal(res$points_sat_fat, 1)
  expect_equal(res$points_sugars, 2)
  expect_equal(res$points_sodium_salt, 0)
  expect_equal(res$points_a, 4)
  expect_equal(res$points_fvns, 0)
  expect_equal(res$points_fibre, 0)
  expect_equal(res$points_protein, 4)
  expect_equal(res$points_c, 4)
  expect_equal(res$npm_score, 0)
  expect_false(res$is_hfss)
  expect_equal(res$healthiness, "healthier")
})

test_that("DHSC 2011 Worked Example 2 (Vanilla ice cream) applies protein cap", {
  res <- calculate_npm(
    energy_kj = 741,
    sat_fat_g = 6.1,
    sugars_g = 18.7,
    sodium_mg = 60,
    fvns_pct = 0,
    fibre_g = 0,
    protein_g = 3.6,
    is_drink = FALSE,
    fibre_method = "nsp"
  )
  expect_equal(res$points_energy, 2)
  expect_equal(res$points_sat_fat, 6)
  expect_equal(res$points_sugars, 4)
  expect_equal(res$points_sodium_salt, 0)
  expect_equal(res$points_a, 12)
  expect_equal(res$points_fvns, 0)
  expect_equal(res$points_fibre, 0)
  # A >= 11 and FVN < 5, so protein points capped to 0
  expect_false(res$protein_allowed)
  expect_equal(res$points_protein, 0)
  expect_equal(res$points_c, 0)
  expect_equal(res$npm_score, 12)
  expect_true(res$is_hfss)
  expect_equal(res$healthiness, "less healthy")
})

test_that("DHSC 2011 Worked Example 3 (Reconstituted milkshake) handles drinks", {
  res <- calculate_npm(
    energy_kj = 299,
    sat_fat_g = 1.0,
    sugars_g = 8.9,
    sodium_mg = 41,
    fvns_pct = 0,
    fibre_g = 0.5,
    protein_g = 3.2,
    is_drink = TRUE,
    fibre_method = "aoac"
  )
  expect_equal(res$points_a, 1)
  expect_equal(res$points_c, 1)
  expect_equal(res$npm_score, 0)
  # Drink threshold is >= 1 for HFSS; score is 0, so not HFSS
  expect_false(res$is_hfss)
})

test_that("DHSC 2011 Worked Example 4 (Tomato soup) matches official score", {
  res <- calculate_npm(
    energy_kj = 155,
    sat_fat_g = 0.4,
    sugars_g = 3.6,
    sodium_mg = 471,
    fvns_pct = 0,
    fibre_g = 0.2,
    protein_g = 0.3,
    is_drink = FALSE
  )
  expect_equal(res$points_energy, 0)
  expect_equal(res$points_sat_fat, 0)
  expect_equal(res$points_sugars, 0)
  expect_equal(res$points_sodium_salt, 5)
  expect_equal(res$points_a, 5)
  expect_equal(res$points_c, 0)
  expect_equal(res$npm_score, 5)
  expect_true(res$is_hfss)
})

test_that("DHSC 2011 Worked Example 5 (Cereal bar) calculates FVNS and protein cap", {
  # FVNS calculation check: 30g dried fruit in 100g product (70g other)
  fvns_calc <- calculate_fvns(weight_fvns = 0, weight_dried = 30, weight_other = 70)
  expect_equal(round(fvns_calc), 46)

  res <- calculate_npm(
    energy_kj = 1504,
    sat_fat_g = 1.4,
    sugars_g = 35.7,
    sodium_mg = 0,
    fvns_pct = 46,
    fibre_g = 4.8,
    protein_g = 4.3,
    is_drink = FALSE,
    fibre_method = "aoac"
  )
  expect_equal(res$points_energy, 4)
  expect_equal(res$points_sat_fat, 1)
  expect_equal(res$points_sugars, 7)
  expect_equal(res$points_sodium_salt, 0)
  expect_equal(res$points_a, 12)
  expect_equal(res$points_fvns, 1)
  expect_equal(res$points_fibre, 5)
  # Protein capped because A = 12 and FVNS points = 1 (<5)
  expect_equal(res$points_protein, 0)
  expect_equal(res$points_c, 6)
  expect_equal(res$npm_score, 6)
  expect_true(res$is_hfss)
})

test_that("DHSC 2011 Worked Example 6 (Fruit juice drink) matches official score", {
  res <- calculate_npm(
    energy_kj = 184,
    sat_fat_g = 0,
    sugars_g = 10.3,
    sodium_mg = 0,
    fvns_pct = 15,
    fibre_g = 0,
    protein_g = 0.1,
    is_drink = TRUE
  )
  expect_equal(res$points_a, 2)
  expect_equal(res$points_c, 0)
  expect_equal(res$npm_score, 2)
  expect_true(res$is_hfss)
})

test_that("DHSC 2018 consultation model worked examples match official guidance", {
  # 2018 Ex 1: Plant-based oat drink
  ex1 <- calculate_npm(
    energy_kj = 189,
    sat_fat_g = 0.3,
    free_sugars_g = 4.5,
    salt_g = 0.1,
    fvns_pct = 0,
    fibre_g = 0.5,
    protein_g = 1.3,
    is_drink = TRUE,
    model = "2018"
  )
  expect_equal(ex1$points_a, 4)
  expect_equal(ex1$points_c, 0)
  expect_equal(ex1$npm_score, 4)
  expect_true(ex1$is_hfss)

  # 2018 Ex 4: Passion fruit yoghurt drink
  ex4 <- calculate_npm(
    energy_kj = 200,
    sat_fat_g = 0.7,
    free_sugars_g = 6.07,
    salt_g = 0.1,
    fvns_pct = 10,
    fibre_g = 0,
    protein_g = 3.1,
    is_drink = TRUE,
    model = "2018"
  )
  expect_equal(ex4$points_a, 6)
  expect_equal(ex4$points_c, 1)
  expect_equal(ex4$npm_score, 5)
  expect_true(ex4$is_hfss)
})

test_that("Cheese exception permits protein points when A >= 11", {
  # Cheddar cheese example: high sat fat and salt, but high protein
  # Without cheese exception: protein is 0
  res_standard <- calculate_npm(
    energy_kj = 1700,
    sat_fat_g = 21.0,
    sugars_g = 0.1,
    salt_g = 1.8,
    fvns_pct = 0,
    fibre_g = 0,
    protein_g = 25.0,
    is_cheese = FALSE
  )
  expect_equal(res_standard$points_protein, 0)

  # With cheese exception: protein points (5) are credited
  res_cheese <- calculate_npm(
    energy_kj = 1700,
    sat_fat_g = 21.0,
    sugars_g = 0.1,
    salt_g = 1.8,
    fvns_pct = 0,
    fibre_g = 0,
    protein_g = 25.0,
    is_cheese = TRUE
  )
  expect_equal(res_cheese$points_protein, 5)
  expect_equal(res_cheese$npm_score, res_standard$npm_score - 5)
})

test_that("Vectorization and helper functions work correctly", {
  energies <- c(459, 741, 155)
  scores <- npm_score(
    energy_kj = energies,
    sat_fat_g = c(1.8, 6.1, 0.4),
    sugars_g = c(13.4, 18.7, 3.6),
    sodium_mg = c(0, 60, 471),
    fvns_pct = c(8, 0, 0),
    fibre_g = c(0.6, 0, 0.2),
    protein_g = c(6.5, 3.6, 0.3)
  )
  expect_equal(scores, c(0, 12, 5))

  hfss_flags <- is_hfss(
    energy_kj = energies,
    sat_fat_g = c(1.8, 6.1, 0.4),
    sugars_g = c(13.4, 18.7, 3.6),
    sodium_mg = c(0, 60, 471),
    fvns_pct = c(8, 0, 0),
    fibre_g = c(0.6, 0, 0.2),
    protein_g = c(6.5, 3.6, 0.3)
  )
  expect_equal(hfss_flags, c(FALSE, TRUE, TRUE))
})
