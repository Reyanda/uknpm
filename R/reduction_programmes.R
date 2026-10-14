#' Soft Drinks Industry Levy (SDIL) Classification and Rate
#'
#' Evaluates non-alcoholic beverages against the UK Soft Drinks Industry Levy (SDIL)
#' statutory thresholds.
#'
#' Under the Soft Drinks Industry Levy Regulations 2018, packaged soft drinks
#' containing added sugars are subject to a tiered levy:
#' \itemize{
#'   \item \strong{Exempt}: Less than 5.0g total sugars per 100ml, or products meeting
#'     statutory exemptions (such as 100\% pure fruit juice, milk-based drinks with at
#'     least 75\% milk content, and alcohol-replacement drinks).
#'   \item \strong{Tier 1 (Lower / Standard Rate)}: 5.0g to less than 8.0g total sugars per 100ml.
#'     Originally 18p per litre (updated to 19.4p/L).
#'   \item \strong{Tier 2 (Higher Rate)}: 8.0g or more total sugars per 100ml.
#'     Originally 24p per litre (updated to 25.9p/L).
#' }
#'
#' @param sugars_g_100ml Numeric vector of total sugars in grams per 100ml.
#' @param is_exempt Logical vector indicating whether the drink has a statutory exemption
#'   (e.g., 100\% pure fruit/vegetable juice, \eqn{\ge 75\%} milk drink). Default is \code{FALSE}.
#' @param rate_year Character or numeric specifying the levy fee schedule: \code{"2018"}
#'   (18p / 24p per litre) or \code{"2025"} (19.4p / 25.9p per litre). Default is \code{"2025"}.
#'
#' @return A \code{data.frame} containing:
#' \describe{
#'   \item{sugars_g_100ml}{Total sugars per 100ml.}
#'   \item{is_exempt}{Exemption flag.}
#'   \item{sdil_tier}{Character: \code{"Exempt"}, \code{"Tier 1 (Lower)"}, or \code{"Tier 2 (Higher)"}.}
#'   \item{is_levied}{Logical: \code{TRUE} if subject to the levy, \code{FALSE} if exempt.}
#'   \item{levy_rate_gbp_per_l}{Levy rate in GBP (pounds) per litre.}
#' }
#'
#' @references
#' HM Revenue & Customs (2018). \emph{Soft Drinks Industry Levy: guidance and rates}.
#' \url{https://www.gov.uk/guidance/soft-drinks-industry-levy}
#'
#' @examples
#' calculate_sdil(sugars_g_100ml = c(3.2, 5.5, 9.8, 11.0), is_exempt = c(FALSE, FALSE, FALSE, TRUE))
#'
#' @export
calculate_sdil <- function(sugars_g_100ml,
                           is_exempt = FALSE,
                           rate_year = c("2025", "2018")) {
  rate_year <- as.character(match.arg(rate_year))
  n <- max(length(sugars_g_100ml), length(is_exempt))

  sugars <- rep_len(as.numeric(sugars_g_100ml), n)
  sugars[is.na(sugars)] <- 0

  exempt <- rep_len(as.logical(is_exempt), n)
  exempt[is.na(exempt)] <- FALSE

  # Rates per litre
  t1_rate <- if (rate_year == "2018") 0.18 else 0.194
  t2_rate <- if (rate_year == "2018") 0.24 else 0.259

  tier <- character(n)
  levied <- logical(n)
  rate <- numeric(n)

  for (i in seq_len(n)) {
    if (exempt[i] || sugars[i] < 5.0) {
      tier[i] <- "Exempt"
      levied[i] <- FALSE
      rate[i] <- 0.0
    } else if (sugars[i] < 8.0) {
      tier[i] <- "Tier 1 (Lower)"
      levied[i] <- TRUE
      rate[i] <- t1_rate
    } else {
      tier[i] <- "Tier 2 (Higher)"
      levied[i] <- TRUE
      rate[i] <- t2_rate
    }
  }

  data.frame(
    sugars_g_100ml = sugars,
    is_exempt = exempt,
    sdil_tier = tier,
    is_levied = levied,
    levy_rate_gbp_per_l = rate,
    stringsAsFactors = FALSE
  )
}

#' Check Compliance with UK Salt Reduction Targets
#'
#' Compares product salt content against the UK Office for Health Improvement and
#' Disparities (OHID) and Public Health England (PHE) Salt Reduction Targets for 2024.
#'
#' The UK salt reduction programme defines category-specific \strong{sales-weighted average}
#' targets and \strong{maximum} targets per 100g for pre-packed retail foods, alongside
#' dish and meal per-serving caps for the out-of-home (OOH) sector.
#'
#' @param salt_g_100g Numeric vector of salt in grams (g) per 100g.
#' @param category Character vector of food categories corresponding to OHID salt target categories.
#' @param salt_portion_g Optional numeric vector of salt in grams per portion / serving.
#'   Particularly relevant for out-of-home dish targets.
#' @param target_table Optional custom target lookup table. Defaults to \code{\link{ohid_salt_targets_2024}}.
#'
#' @return A \code{data.frame} matching the input rows with target benchmarks and compliance flags:
#' \describe{
#'   \item{salt_g_100g}{Observed salt per 100g.}
#'   \item{category}{Matched food category.}
#'   \item{target_average_100g}{OHID average target per 100g.}
#'   \item{target_maximum_100g}{OHID maximum target per 100g.}
#'   \item{meets_average}{Logical: \code{TRUE} if salt \eqn{\le} average target.}
#'   \item{meets_maximum}{Logical: \code{TRUE} if salt \eqn{\le} maximum target.}
#'   \item{salt_compliant}{Overall salt target compliance (\code{meets_maximum} if defined, else \code{meets_average}).}
#' }
#'
#' @references
#' Office for Health Improvement and Disparities (2020/2024). \emph{Salt reduction targets for 2024}.
#' \url{https://www.gov.uk/government/publications/salt-reduction-targets-for-2024}
#'
#' @examples
#' # Bread category comparison (average target 0.85g, max target 1.01g):
#' check_salt_target(salt_g_100g = c(0.80, 0.95, 1.20), category = "Bread")
#'
#' @export
check_salt_target <- function(salt_g_100g,
                              category,
                              salt_portion_g = NULL,
                              target_table = NULL) {
  if (is.null(target_table)) {
    target_table <- uknpm::ohid_salt_targets_2024
  }

  n <- max(length(salt_g_100g), length(category))
  salt <- rep_len(as.numeric(salt_g_100g), n)
  cat_vec <- rep_len(as.character(category), n)

  # Match category case-insensitively
  norm_cats <- tolower(trimws(target_table$category))
  cat_lower <- tolower(trimws(cat_vec))

  idx <- match(cat_lower, norm_cats)

  # Fallback fuzzy matching if exact match not found
  unmatched <- which(is.na(idx))
  for (u in unmatched) {
    if (!is.na(cat_lower[u]) && nzchar(cat_lower[u])) {
      matches <- grep(cat_lower[u], norm_cats, fixed = TRUE)
      if (length(matches) > 0) {
        idx[u] <- matches[1]
      }
    }
  }

  tgt_avg <- target_table$target_average_100g[idx]
  tgt_max <- target_table$target_maximum_100g[idx]

  meets_avg <- ifelse(is.na(tgt_avg), NA, salt <= tgt_avg)
  meets_max <- ifelse(is.na(tgt_max), NA, salt <= tgt_max)

  compliant <- ifelse(!is.na(meets_max), meets_max, meets_avg)

  data.frame(
    salt_g_100g = salt,
    category = cat_vec,
    target_average_100g = tgt_avg,
    target_maximum_100g = tgt_max,
    meets_average = meets_avg,
    meets_maximum = meets_max,
    salt_compliant = compliant,
    stringsAsFactors = FALSE
  )
}

#' Check Compliance with UK Sugar Reduction Programme Targets
#'
#' Compares product sugar content against OHID / PHE Sugar Reduction Programme
#' category targets and maximum portion caps.
#'
#' @param sugars_g_100g Numeric vector of total sugars in grams (g) per 100g.
#' @param category Character vector of product categories (e.g. \code{"Biscuits"}, \code{"Cakes"},
#'   \code{"Chocolate confectionery"}, \code{"Ice cream"}, \code{"Morning goods"},
#'   \code{"Puddings"}, \code{"Yogurts"}, \code{"Breakfast cereals"}, \code{"Sweet spreads"}).
#' @param sugars_portion_g Optional numeric vector of sugar per portion (g).
#' @param target_table Optional custom target lookup table. Defaults to \code{\link{ohid_sugar_targets}}.
#'
#' @return A \code{data.frame} with sugar benchmarks and compliance indicators:
#' \describe{
#'   \item{sugars_g_100g}{Observed sugars per 100g.}
#'   \item{category}{Matched sugar reduction category.}
#'   \item{target_sugars_100g}{OHID sugar reduction target per 100g.}
#'   \item{max_portion_cap_g}{Maximum portion sugar cap (if applicable).}
#'   \item{meets_sugar_target}{Logical indicating compliance with per-100g target.}
#'   \item{meets_portion_cap}{Logical indicating compliance with portion cap (if portion sugar supplied).}
#'   \item{sugar_compliant}{Overall sugar compliance.}
#' }
#'
#' @references
#' Public Health England / Office for Health Improvement and Disparities (2020).
#' \emph{Sugar reduction: industry progress 2015 to 2020}.
#' \url{https://www.gov.uk/government/collections/sugar-reduction}
#'
#' @examples
#' check_sugar_target(sugars_g_100g = c(22.0, 35.0), category = "Biscuits")
#'
#' @export
check_sugar_target <- function(sugars_g_100g,
                               category,
                               sugars_portion_g = NULL,
                               target_table = NULL) {
  if (is.null(target_table)) {
    target_table <- uknpm::ohid_sugar_targets
  }

  n <- max(length(sugars_g_100g), length(category))
  sugars <- rep_len(as.numeric(sugars_g_100g), n)
  cat_vec <- rep_len(as.character(category), n)

  norm_cats <- tolower(trimws(target_table$category))
  cat_lower <- tolower(trimws(cat_vec))

  idx <- match(cat_lower, norm_cats)
  unmatched <- which(is.na(idx))
  for (u in unmatched) {
    if (!is.na(cat_lower[u]) && nzchar(cat_lower[u])) {
      matches <- grep(cat_lower[u], norm_cats, fixed = TRUE)
      if (length(matches) > 0) idx[u] <- matches[1]
    }
  }

  tgt_sug <- target_table$target_sugars_100g[idx]
  cap_g <- target_table$max_portion_cap_g[idx]

  meets_tgt <- ifelse(is.na(tgt_sug), NA, sugars <= tgt_sug)

  has_portion_sug <- !is.null(sugars_portion_g)
  if (has_portion_sug) {
    p_sug <- rep_len(as.numeric(sugars_portion_g), n)
    meets_cap <- ifelse(is.na(cap_g), TRUE, p_sug <= cap_g)
  } else {
    meets_cap <- rep(NA, n)
  }

  compliant <- ifelse(is.na(meets_cap), meets_tgt, meets_tgt & meets_cap)

  data.frame(
    sugars_g_100g = sugars,
    category = cat_vec,
    target_sugars_100g = tgt_sug,
    max_portion_cap_g = cap_g,
    meets_sugar_target = meets_tgt,
    meets_portion_cap = meets_cap,
    sugar_compliant = compliant,
    stringsAsFactors = FALSE
  )
}

#' Check Compliance with UK Calorie Reduction Guidelines
#'
#' Evaluates meal items, sandwiches, sides, and snacks against UK Calorie Reduction
#' Programme guidelines published by Public Health England / OHID.
#'
#' Frameworks included:
#' \itemize{
#'   \item \strong{400-600-600 Campaign Guidelines}: 400 kcal breakfast, 600 kcal lunch,
#'     600 kcal dinner, plus 200 kcal for drinks and snacks.
#'   \item \strong{Category Single-Serve Guidelines}:
#'     \itemize{
#'       \item Ready meals / meal centres: 550--600 kcal maximum.
#'       \item Sandwiches: 550 kcal maximum.
#'       \item Starters / sides / small plates: 250 kcal maximum.
#'       \item Puddings / desserts: 220--250 kcal maximum.
#'       \item Single-serve pizzas: 1000 kcal maximum (or 650 kcal per portion).
#'     }
#' }
#'
#' @param energy_kcal_portion Numeric vector of energy in kilocalories (kcal) per portion / serving.
#' @param category Optional character vector specifying the food category (e.g. \code{"Sandwiches"},
#'   \code{"Main meal"}, \code{"Pizza"}, \code{"Side"}, \code{"Dessert"}).
#' @param meal_type Character string specifying the meal benchmark: \code{"general"},
#'   \code{"breakfast"} (400 kcal), \code{"lunch"} (600 kcal), \code{"dinner"} (600 kcal),
#'   or \code{"snack"} (200 kcal). Default is \code{"general"}.
#' @param custom_cap_kcal Optional numeric value specifying an explicit calorie ceiling.
#'
#' @return A \code{data.frame} containing:
#' \describe{
#'   \item{energy_kcal_portion}{Reported calories per portion.}
#'   \item{guideline_kcal}{Applicable calorie guideline ceiling.}
#'   \item{excess_kcal}{Difference (\code{energy_kcal_portion - guideline_kcal}), where values > 0 indicate excess.}
#'   \item{meets_calorie_guideline}{Logical: \code{TRUE} if calories \eqn{\le} guideline.}
#' }
#'
#' @references
#' Public Health England / Office for Health Improvement and Disparities (2020).
#' \emph{Calorie reduction: criteria and guidelines for the food industry}.
#'
#' Tan M, Pham H, Pombo-Rodrigues S, et al. (2025). Nutritional composition and healthiness of out-of-home food and drink.
#' \emph{Proceedings of the Nutrition Society}, 84(OCE3), E208.
#'
#' @examples
#' # Assess a sandwich containing 620 kcal:
#' check_calorie_guideline(energy_kcal_portion = 620, category = "Sandwiches")
#'
#' # Assess main meals against the 600 kcal lunch/dinner guideline:
#' check_calorie_guideline(energy_kcal_portion = c(520, 680, 890), meal_type = "lunch")
#'
#' @export
check_calorie_guideline <- function(energy_kcal_portion,
                                    category = NULL,
                                    meal_type = c("general", "breakfast", "lunch", "dinner", "snack"),
                                    custom_cap_kcal = NULL) {
  meal_type <- match.arg(meal_type)
  n <- length(energy_kcal_portion)
  kcal <- as.numeric(energy_kcal_portion)

  guide_cap <- numeric(n)

  if (!is.null(custom_cap_kcal)) {
    guide_cap <- rep_len(as.numeric(custom_cap_kcal), n)
  } else if (!is.null(category)) {
    cat_lower <- tolower(trimws(rep_len(as.character(category), n)))
    for (i in seq_len(n)) {
      c_i <- cat_lower[i]
      if (grepl("sandwich|wrap|roll|baguette|panini", c_i)) {
        guide_cap[i] <- 550
      } else if (grepl("pizza", c_i)) {
        guide_cap[i] <- 1000
      } else if (grepl("starter|side|small plate|chip|fry|fries", c_i)) {
        guide_cap[i] <- 250
      } else if (grepl("dessert|pudding|cake|pastry|ice cream", c_i)) {
        guide_cap[i] <- 250
      } else if (grepl("main|meal|burger|curry|pie|pasta", c_i)) {
        guide_cap[i] <- 600
      } else {
        # Fallback to meal_type default
        guide_cap[i] <- switch(meal_type,
          breakfast = 400,
          lunch = 600,
          dinner = 600,
          snack = 200,
          general = 600
        )
      }
    }
  } else {
    default_val <- switch(meal_type,
      breakfast = 400,
      lunch = 600,
      dinner = 600,
      snack = 200,
      general = 600
    )
    guide_cap <- rep_len(default_val, n)
  }

  excess <- kcal - guide_cap
  meets <- (excess <= 0)

  data.frame(
    energy_kcal_portion = kcal,
    guideline_kcal = guide_cap,
    excess_kcal = excess,
    meets_calorie_guideline = meets,
    stringsAsFactors = FALSE
  )
}
