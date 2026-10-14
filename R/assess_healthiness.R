#' Multi-Metric Healthiness Assessment for UK Foods and Out-of-Home Menus
#'
#' Evaluates food and drink products across candidate UK healthiness assessment
#' approaches:
#' \enumerate{
#'   \item \strong{UK Nutrient Profile Model (NPM)}: Statutory 2004/2005 (DHSC 2011) or 2018 model.
#'   \item \strong{Multiple Traffic Light Labelling (MTL)}: Front-of-pack green/amber/red criteria per 100g and per portion.
#'   \item \strong{UK Reduction Programmes and Levy}: Soft Drinks Industry Levy (SDIL), OHID 2024 salt reduction targets, sugar reduction targets, and calorie guidelines.
#'   \item \strong{Combined Approaches}: Hybrid NPM + MTL portion caps, reflecting recommendations from Tan et al. (2025) for out-of-home (OOH) food.
#' }
#'
#' @param data A \code{data.frame} containing product nutritional information. If \code{NULL},
#'   individual column vectors may be supplied.
#' @param energy_kj Numeric vector or column name for energy in kJ per 100g.
#' @param energy_kcal Numeric vector or column name for energy in kcal per 100g.
#' @param energy_kcal_portion Numeric vector or column name for energy in kcal per portion.
#' @param fat_g Numeric vector or column name for total fat in g per 100g.
#' @param sat_fat_g Numeric vector or column name for saturated fat in g per 100g.
#' @param sugars_g Numeric vector or column name for total sugars in g per 100g.
#' @param free_sugars_g Optional numeric vector or column name for free sugars in g per 100g.
#' @param salt_g Numeric vector or column name for salt in g per 100g.
#' @param sodium_mg Optional numeric vector or column name for sodium in mg per 100g.
#' @param fvns_pct Numeric vector or column name for fruit, veg, nuts (and seeds) percentage.
#' @param fibre_g Numeric vector or column name for fibre in g per 100g.
#' @param protein_g Numeric vector or column name for protein in g per 100g.
#' @param portion_g Optional numeric vector or column name for portion weight in g (or ml).
#' @param category Optional character vector or column name specifying food category.
#' @param is_drink Logical vector or column name indicating whether item is a drink (\code{TRUE}) or food (\code{FALSE}).
#' @param is_cheese Logical vector indicating whether item is cheese.
#' @param npm_model Character string for NPM version: \code{"2004_2005"} or \code{"2018"}.
#'
#' @return A \code{data.frame} augmented with all assessment metrics:
#' \describe{
#'   \item{npm_score}{NPM score.}
#'   \item{npm_is_hfss}{NPM HFSS flag (\code{TRUE} = less healthy).}
#'   \item{npm_healthiness}{\code{"healthier"} vs \code{"less healthy"}.}
#'   \item{mtl_fat}{Colour code for fat.}
#'   \item{mtl_sat_fat}{Colour code for saturated fat.}
#'   \item{mtl_sugars}{Colour code for sugars.}
#'   \item{mtl_salt}{Colour code for salt.}
#'   \item{mtl_n_red}{Count of Red traffic lights (0--4).}
#'   \item{mtl_has_red}{Logical indicating \eqn{\ge 1} Red lights.}
#'   \item{mtl_healthiness}{\code{"healthier"} (0 red) vs \code{"less healthy"} (\eqn{\ge 1} red).}
#'   \item{sdil_tier}{Levy tier for drinks.}
#'   \item{meets_salt_target}{Compliance with OHID salt targets (if category matched).}
#'   \item{meets_sugar_target}{Compliance with OHID sugar targets (if category matched).}
#'   \item{meets_calorie_guideline}{Compliance with calorie guidelines (if portion kcal provided).}
#'   \item{combined_npm_mtl_healthy}{Logical indicating healthy under both NPM and MTL (\code{!npm_is_hfss & !mtl_has_red}).}
#' }
#'
#' @references
#' Tan M, Pham H, Pombo-Rodrigues S, Hashem KM, Shiach A, Barakat NA (2025).
#' Nutritional composition and healthiness of out-of-home food and drink: cross-sectional
#' and retrospective longitudinal analyses of best-selling menu items in the UK, 2021-2023/24.
#' \emph{Proceedings of the Nutrition Society}, 84(OCE3), E208. \doi{10.1017/S0029665125100773}
#'
#' @examples
#' # Assess a sample meal (burger with 650 kcal, 25g fat, 8g sat fat, 5g sugar, 2.2g salt):
#' sample_burger <- data.frame(
#'   item = "Classic Cheeseburger",
#'   energy_kcal = 260,
#'   energy_kcal_portion = 650,
#'   fat_g = 12.0,
#'   sat_fat_g = 5.5,
#'   sugars_g = 3.5,
#'   salt_g = 1.3,
#'   fvns_pct = 5,
#'   fibre_g = 1.8,
#'   protein_g = 14.0,
#'   portion_g = 250,
#'   category = "Main meal",
#'   is_drink = FALSE
#' )
#' assess_healthiness(sample_burger)
#'
#' @export
assess_healthiness <- function(data = NULL,
                               energy_kj = NULL,
                               energy_kcal = NULL,
                               energy_kcal_portion = NULL,
                               fat_g = NULL,
                               sat_fat_g = NULL,
                               sugars_g = NULL,
                               free_sugars_g = NULL,
                               salt_g = NULL,
                               sodium_mg = NULL,
                               fvns_pct = NULL,
                               fibre_g = NULL,
                               protein_g = NULL,
                               portion_g = NULL,
                               category = NULL,
                               is_drink = FALSE,
                               is_cheese = FALSE,
                               npm_model = c("2004_2005", "2018")) {
  npm_model <- match.arg(npm_model)

  # Extract from data.frame if supplied
  resolve_col <- function(col_name, direct_val, df) {
    if (!is.null(direct_val)) return(direct_val)
    if (!is.null(df) && is.character(col_name) && length(col_name) == 1 && col_name %in% names(df)) {
      return(df[[col_name]])
    }
    NULL
  }

  e_kj <- resolve_col("energy_kj", energy_kj, data)
  e_kcal <- resolve_col("energy_kcal", energy_kcal, data)
  e_kcal_p <- resolve_col("energy_kcal_portion", energy_kcal_portion, data)
  fat <- resolve_col("fat_g", fat_g, data)
  sf <- resolve_col("sat_fat_g", sat_fat_g, data)
  sug <- resolve_col("sugars_g", sugars_g, data)
  fsug <- resolve_col("free_sugars_g", free_sugars_g, data)
  salt <- resolve_col("salt_g", salt_g, data)
  na <- resolve_col("sodium_mg", sodium_mg, data)
  fvns <- resolve_col("fvns_pct", fvns_pct, data)
  fib <- resolve_col("fibre_g", fibre_g, data)
  prot <- resolve_col("protein_g", protein_g, data)
  port <- resolve_col("portion_g", portion_g, data)
  cat_v <- resolve_col("category", category, data)
  drk <- resolve_col("is_drink", is_drink, data)
  chs <- resolve_col("is_cheese", is_cheese, data)

  if (is.null(fat)) fat <- 0
  if (is.null(sf)) sf <- 0
  if (is.null(sug)) sug <- 0
  if (is.null(fvns)) fvns <- 0
  if (is.null(fib)) fib <- 0
  if (is.null(prot)) prot <- 0
  if (is.null(drk)) drk <- FALSE
  if (is.null(chs)) chs <- FALSE

  # If energy_kcal_portion not provided but energy_kcal and portion_g are:
  if (is.null(e_kcal_p) && !is.null(e_kcal) && !is.null(port)) {
    e_kcal_p <- e_kcal * port / 100
  }

  # 1. NPM calculation
  npm_res <- calculate_npm(
    energy_kj = e_kj,
    energy_kcal = e_kcal,
    sat_fat_g = sf,
    sugars_g = sug,
    free_sugars_g = fsug,
    sodium_mg = na,
    salt_g = salt,
    fvns_pct = fvns,
    fibre_g = fib,
    protein_g = prot,
    is_drink = drk,
    is_cheese = chs,
    model = npm_model
  )

  # 2. MTL calculation
  mtl_res <- calculate_mtl(
    fat_g = fat,
    sat_fat_g = sf,
    sugars_g = sug,
    salt_g = salt,
    sodium_mg = na,
    portion_g = port,
    is_drink = drk
  )

  # 3. SDIL calculation (for drinks)
  sdil_res <- calculate_sdil(sugars_g_100ml = sug, is_exempt = !drk)

  # 4. Salt target check (if category provided)
  if (!is.null(cat_v)) {
    salt_chk <- check_salt_target(salt_g_100g = if (!is.null(salt)) salt else 0, category = cat_v)
    meets_salt <- salt_chk$salt_compliant
  } else {
    meets_salt <- rep(NA, nrow(npm_res))
  }

  # 5. Sugar target check (if category provided)
  if (!is.null(cat_v)) {
    sugar_chk <- check_sugar_target(sugars_g_100g = sug, category = cat_v)
    meets_sugar <- sugar_chk$sugar_compliant
  } else {
    meets_sugar <- rep(NA, nrow(npm_res))
  }

  # 6. Calorie guideline check (if portion kcal provided)
  if (!is.null(e_kcal_p)) {
    cal_chk <- check_calorie_guideline(energy_kcal_portion = e_kcal_p, category = cat_v)
    meets_cal <- cal_chk$meets_calorie_guideline
  } else {
    meets_cal <- rep(NA, nrow(npm_res))
  }

  # Combined metric (Tan et al. 2025): Healthy under both NPM and MTL portion flags
  combined_healthy <- (!npm_res$is_hfss) & (!mtl_res$has_red)

  out <- data.frame(
    npm_score = npm_res$npm_score,
    npm_is_hfss = npm_res$is_hfss,
    npm_healthiness = npm_res$healthiness,
    mtl_fat = mtl_res$fat_colour,
    mtl_sat_fat = mtl_res$sat_fat_colour,
    mtl_sugars = mtl_res$sugars_colour,
    mtl_salt = mtl_res$salt_colour,
    mtl_n_red = mtl_res$n_red,
    mtl_has_red = mtl_res$has_red,
    mtl_healthiness = mtl_res$mtl_healthiness,
    sdil_tier = ifelse(drk, sdil_res$sdil_tier, "Not applicable (Food)"),
    meets_salt_target = meets_salt,
    meets_sugar_target = meets_sugar,
    meets_calorie_guideline = meets_cal,
    combined_npm_mtl_healthy = combined_healthy,
    stringsAsFactors = FALSE
  )

  if (!is.null(data)) {
    return(cbind(data, out))
  }
  out
}

#' Summarise Healthiness Across Candidate Assessment Approaches
#'
#' Generates comparative summary statistics (% classified as healthy vs less healthy)
#' across all candidate assessment approaches evaluated by \code{\link{assess_healthiness}},
#' replicating the comparative reporting methodology of Tan et al. (2025).
#'
#' @param assessment_df A data frame returned by \code{\link{assess_healthiness}}.
#'
#' @return A \code{data.frame} summarizing each candidate approach:
#' \describe{
#'   \item{approach}{Candidate healthiness assessment framework.}
#'   \item{total_items}{Total evaluated items.}
#'   \item{n_healthy}{Count of items classified as healthy / compliant.}
#'   \item{pct_healthy}{Percentage of items classified as healthy.}
#'   \item{n_less_healthy}{Count of items classified as less healthy / non-compliant.}
#'   \item{pct_less_healthy}{Percentage of items classified as less healthy.}
#' }
#'
#' @references
#' Tan M, Pham H, Pombo-Rodrigues S, et al. (2025). Nutritional composition and healthiness of out-of-home food and drink.
#' \emph{Proceedings of the Nutrition Society}, 84(OCE3), E208.
#'
#' @export
summarise_healthiness <- function(assessment_df) {
  n_total <- nrow(assessment_df)

  # Approaches:
  # 1. NPM (Healthier = !npm_is_hfss)
  npm_healthy <- sum(!assessment_df$npm_is_hfss, na.rm = TRUE)

  # 2. MTL (Healthier = !mtl_has_red, i.e. 0 red lights)
  mtl_healthy <- sum(!assessment_df$mtl_has_red, na.rm = TRUE)

  # 3. Combined NPM + MTL
  comb_healthy <- sum(assessment_df$combined_npm_mtl_healthy, na.rm = TRUE)

  approaches <- c(
    "UK Nutrient Profile Model (NPM)",
    "Multiple Traffic Light (MTL, No Red Lights)",
    "Combined NPM + MTL Portion Caps"
  )
  healthy_counts <- c(npm_healthy, mtl_healthy, comb_healthy)

  # Add reduction programmes if present
  if (any(!is.na(assessment_df$meets_calorie_guideline))) {
    approaches <- c(approaches, "UK Calorie Reduction Guidelines")
    healthy_counts <- c(healthy_counts, sum(assessment_df$meets_calorie_guideline == TRUE, na.rm = TRUE))
  }
  if (any(!is.na(assessment_df$meets_salt_target))) {
    approaches <- c(approaches, "UK Salt Reduction 2024 Targets")
    healthy_counts <- c(healthy_counts, sum(assessment_df$meets_salt_target == TRUE, na.rm = TRUE))
  }
  if (any(!is.na(assessment_df$meets_sugar_target))) {
    approaches <- c(approaches, "UK Sugar Reduction Targets")
    healthy_counts <- c(healthy_counts, sum(assessment_df$meets_sugar_target == TRUE, na.rm = TRUE))
  }

  less_healthy_counts <- n_total - healthy_counts
  pct_h <- round((healthy_counts / n_total) * 100, 1)
  pct_lh <- round((less_healthy_counts / n_total) * 100, 1)

  data.frame(
    approach = approaches,
    total_items = rep(n_total, length(approaches)),
    n_healthy = healthy_counts,
    pct_healthy = pct_h,
    n_less_healthy = less_healthy_counts,
    pct_less_healthy = pct_lh,
    stringsAsFactors = FALSE
  )
}
