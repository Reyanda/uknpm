#' Calculate UK Nutrient Profile Model (NPM) Score and HFSS Classification
#'
#' Computes the nutrient profile score and High in Fat, Salt, or Sugar (HFSS)
#' classification under the official UK Nutrient Profile Model. Supports both
#' the statutory 2004/2005 model (DHSC 2011 Technical Guidance) used in Ofcom
#' broadcast restrictions and HFSS promotional/placement regulations, as well as
#' the updated NPM 2018 consultation model (DHSC 2018).
#'
#' Under the UK NPM, foods and drinks are scored based on nutrient content per 100g
#' (or 100ml converted by specific gravity). Points are allocated for "A" nutrients
#' to limit (energy, saturated fat, sugars, sodium/salt) and "C" components to
#' encourage (fruit, vegetables, nuts, seeds, fibre, protein).
#'
#' \strong{Protein Cap Rule:} If a food or drink scores 11 or more 'A' points,
#' it cannot score points for protein unless it also achieves 5 points for fruit,
#' vegetables, and nuts (or seeds in 2018). If the product is cheese, an exception
#' can be granted by setting \code{is_cheese = TRUE}, allowing protein points to
#' be retained.
#'
#' \strong{Classification Thresholds:}
#' \itemize{
#'   \item \strong{Food}: Score \eqn{\ge 4} is classified as \code{"less healthy"} (HFSS); score \eqn{< 4} is \code{"healthier"}.
#'   \item \strong{Drink}: Score \eqn{\ge 1} is classified as \code{"less healthy"} (HFSS); score \eqn{< 1} is \code{"healthier"}.
#' }
#'
#' @param energy_kj Numeric vector of energy in kilojoules (kJ) per 100g. If \code{NULL},
#'   can be derived from \code{energy_kcal} (\eqn{1\text{ kcal} = 4.184\text{ kJ}}).
#' @param energy_kcal Numeric vector of energy in kilocalories (kcal) per 100g. Used
#'   if \code{energy_kj} is not provided.
#' @param sat_fat_g Numeric vector of saturated fatty acids in grams (g) per 100g.
#' @param sugars_g Numeric vector of total sugars (in 2004/2005 model) or free sugars
#'   (in 2018 model) in grams (g) per 100g.
#' @param free_sugars_g Numeric vector of free sugars in grams (g) per 100g. Specifically
#'   utilised in the 2018 model. If \code{NULL} and \code{model = "2018"}, \code{sugars_g}
#'   is used.
#' @param sodium_mg Numeric vector of sodium in milligrams (mg) per 100g. If \code{NULL},
#'   calculated from \code{salt_g} (\eqn{\text{sodium (mg)} = \text{salt (g)} \times 1000 / 2.5}).
#' @param salt_g Numeric vector of salt (sodium chloride equivalent) in grams (g) per 100g.
#' @param fvns_pct Numeric vector of percentage of fruit, vegetables, nuts (and seeds in
#'   2018 model), between 0 and 100.
#' @param fibre_g Numeric vector of dietary fibre in grams (g) per 100g.
#' @param fibre_method Character string specifying the fibre measurement method:
#'   \code{"aoac"} (Association of Official Analytical Chemists) or \code{"nsp"}
#'   (Englyst Non-Starch Polysaccharide). Default is \code{"aoac"}. In the 2018 model,
#'   AOAC fibre is standard.
#' @param protein_g Numeric vector of protein in grams (g) per 100g.
#' @param is_drink Logical vector indicating whether the product is a beverage/drink
#'   (\code{TRUE}) or a food (\code{FALSE}). Default is \code{FALSE}.
#' @param is_cheese Logical vector indicating whether the product is cheese. If \code{TRUE},
#'   protein points are credited even if \eqn{\text{Total A} \ge 11}. Default is \code{FALSE}.
#' @param model Character string specifying the NPM version: \code{"2004_2005"}
#'   (statutory DHSC 2011 guidance) or \code{"2018"} (DHSC 2018 consultation model).
#'   Default is \code{"2004_2005"}.
#'
#' @return A \code{data.frame} containing:
#' \describe{
#'   \item{points_energy}{Points awarded for energy (0--10).}
#'   \item{points_sat_fat}{Points awarded for saturated fat (0--10).}
#'   \item{points_sugars}{Points awarded for sugars (0--10).}
#'   \item{points_sodium_salt}{Points awarded for sodium or salt (0--10).}
#'   \item{points_a}{Total 'A' points (0--40).}
#'   \item{points_fvns}{Points awarded for fruit, vegetables, nuts, seeds (0, 1, 2, or 5).}
#'   \item{points_fibre}{Points awarded for fibre (0--5 for 2004/2005; 0--10 for 2018).}
#'   \item{points_protein_raw}{Potential points from protein before capping (0--5).}
#'   \item{protein_allowed}{Logical indicating whether protein points are permitted.}
#'   \item{points_protein}{Actual points awarded for protein (0--5).}
#'   \item{points_c}{Total 'C' points.}
#'   \item{npm_score}{Final nutrient profile score (\code{points_a - points_c}).}
#'   \item{is_hfss}{Logical indicating if product is High in Fat, Salt, or Sugar (\code{TRUE} / \code{FALSE}).}
#'   \item{healthiness}{Character string: \code{"less healthy"} or \code{"healthier"}.}
#'   \item{model}{Model version applied.}
#' }
#'
#' @references
#' Department of Health and Social Care (2011). \emph{Nutrient Profiling Technical Guidance}.
#' \url{https://www.gov.uk/government/publications/the-nutrient-profiling-model}
#'
#' Department of Health and Social Care (2018). \emph{Nutrient Profiling Model 2018: Technical Guidance}.
#' \url{https://www.gov.uk/government/publications/nutrient-profiling-model-2018}
#'
#' @examples
#' # DHSC 2011 Worked Example 1: Fruit fromage frais per 100g
#' calculate_npm(
#'   energy_kj = 459,
#'   sat_fat_g = 1.8,
#'   sugars_g = 13.4,
#'   salt_g = 0.05,
#'   fvns_pct = 8,
#'   fibre_g = 0.6,
#'   protein_g = 6.5,
#'   is_drink = FALSE
#' )
#'
#' # DHSC 2011 Worked Example 2: Vanilla ice cream per 100g
#' calculate_npm(
#'   energy_kj = 741,
#'   sat_fat_g = 6.1,
#'   sugars_g = 18.7,
#'   sodium_mg = 60,
#'   fvns_pct = 0,
#'   fibre_g = 0,
#'   protein_g = 3.6,
#'   is_drink = FALSE
#' )
#'
#' @export
calculate_npm <- function(energy_kj = NULL,
                          energy_kcal = NULL,
                          sat_fat_g = 0,
                          sugars_g = 0,
                          free_sugars_g = NULL,
                          sodium_mg = NULL,
                          salt_g = NULL,
                          fvns_pct = 0,
                          fibre_g = 0,
                          fibre_method = c("aoac", "nsp"),
                          protein_g = 0,
                          is_drink = FALSE,
                          is_cheese = FALSE,
                          model = c("2004_2005", "2018")) {
  fibre_method <- match.arg(fibre_method)
  model <- match.arg(model)

  # Derive maximum vector length across all inputs
  lens <- c(
    if (!is.null(energy_kj)) length(energy_kj) else 0,
    if (!is.null(energy_kcal)) length(energy_kcal) else 0,
    length(sat_fat_g),
    length(sugars_g),
    if (!is.null(free_sugars_g)) length(free_sugars_g) else 0,
    if (!is.null(sodium_mg)) length(sodium_mg) else 0,
    if (!is.null(salt_g)) length(salt_g) else 0,
    length(fvns_pct),
    length(fibre_g),
    length(protein_g),
    length(is_drink),
    length(is_cheese)
  )
  n <- max(lens, 1)

  # Process energy (kJ vs kcal)
  if (is.null(energy_kj)) {
    if (is.null(energy_kcal)) {
      energy_kj <- rep_len(0, n)
    } else {
      energy_kcal <- rep_len(as.numeric(energy_kcal), n)
      energy_kj <- energy_kcal * 4.184
    }
  } else {
    energy_kj <- rep_len(as.numeric(energy_kj), n)
  }
  energy_kj[is.na(energy_kj)] <- 0

  # Saturated fat
  sat_fat_g <- rep_len(as.numeric(sat_fat_g), n)
  sat_fat_g[is.na(sat_fat_g)] <- 0

  # Sugars
  sugars_g <- rep_len(as.numeric(sugars_g), n)
  sugars_g[is.na(sugars_g)] <- 0

  if (!is.null(free_sugars_g)) {
    free_sugars_g <- rep_len(as.numeric(free_sugars_g), n)
    free_sugars_g[is.na(free_sugars_g)] <- 0
  }

  # Sodium and Salt
  if (is.null(sodium_mg)) {
    if (is.null(salt_g)) {
      sodium_mg <- rep_len(0, n)
      salt_g <- rep_len(0, n)
    } else {
      salt_g <- rep_len(as.numeric(salt_g), n)
      salt_g[is.na(salt_g)] <- 0
      sodium_mg <- salt_g * (1000 / 2.5)
    }
  } else {
    sodium_mg <- rep_len(as.numeric(sodium_mg), n)
    sodium_mg[is.na(sodium_mg)] <- 0
    if (is.null(salt_g)) {
      salt_g <- sodium_mg * 2.5 / 1000
    } else {
      salt_g <- rep_len(as.numeric(salt_g), n)
      salt_g[is.na(salt_g)] <- 0
    }
  }

  # Beneficial components
  fvns_pct <- rep_len(as.numeric(fvns_pct), n)
  fvns_pct[is.na(fvns_pct)] <- 0

  fibre_g <- rep_len(as.numeric(fibre_g), n)
  fibre_g[is.na(fibre_g)] <- 0

  protein_g <- rep_len(as.numeric(protein_g), n)
  protein_g[is.na(protein_g)] <- 0

  is_drink <- rep_len(as.logical(is_drink), n)
  is_drink[is.na(is_drink)] <- FALSE

  is_cheese <- rep_len(as.logical(is_cheese), n)
  is_cheese[is.na(is_cheese)] <- FALSE

  if (model == "2004_2005") {
    # Points Energy: 335 kJ steps
    # 0: <=335, 1: >335, 2: >670, 3: >1005, 4: >1340, 5: >1675, 6: >2010,
    # 7: >2345, 8: >2680, 9: >3015, 10: >3350
    e_breaks <- c(-Inf, 335 * (1:10), Inf)
    pts_energy <- findInterval(energy_kj, e_breaks, left.open = TRUE) - 1
    pts_energy <- pmin(pmax(pts_energy, 0), 10)

    # Points Sat Fat: 1g steps
    # 0: <=1, 1: >1, 2: >2, ..., 10: >10
    sf_breaks <- c(-Inf, 1:10, Inf)
    pts_sat_fat <- findInterval(sat_fat_g, sf_breaks, left.open = TRUE) - 1
    pts_sat_fat <- pmin(pmax(pts_sat_fat, 0), 10)

    # Points Total Sugars:
    # 0: <=4.5, 1: >4.5, 2: >9, 3: >13.5, 4: >18, 5: >22.5, 6: >27,
    # 7: >31, 8: >36, 9: >40, 10: >45
    sug_breaks <- c(-Inf, 4.5, 9, 13.5, 18, 22.5, 27, 31, 36, 40, 45, Inf)
    pts_sugars <- findInterval(sugars_g, sug_breaks, left.open = TRUE) - 1
    pts_sugars <- pmin(pmax(pts_sugars, 0), 10)

    # Points Sodium (mg):
    # 0: <=90, 1: >90, ..., 10: >900
    na_breaks <- c(-Inf, 90 * (1:10), Inf)
    pts_na <- findInterval(sodium_mg, na_breaks, left.open = TRUE) - 1
    pts_na <- pmin(pmax(pts_na, 0), 10)

    pts_a <- pts_energy + pts_sat_fat + pts_sugars + pts_na

    # Points FVN:
    # 0: <=40%, 1: >40%, 2: >60%, 5: >80%
    pts_fvns <- ifelse(fvns_pct > 80, 5,
                ifelse(fvns_pct > 60, 2,
                ifelse(fvns_pct > 40, 1, 0)))

    # Points Fibre:
    if (fibre_method == "nsp") {
      # 0: <=0.7, 1: >0.7, 2: >1.4, 3: >2.1, 4: >2.8, 5: >3.5
      fib_breaks <- c(-Inf, 0.7 * (1:5), Inf)
    } else {
      # AOAC: 0: <=0.9, 1: >0.9, 2: >1.9, 3: >2.8, 4: >3.7, 5: >4.7
      fib_breaks <- c(-Inf, 0.9, 1.9, 2.8, 3.7, 4.7, Inf)
    }
    pts_fibre <- findInterval(fibre_g, fib_breaks, left.open = TRUE) - 1
    pts_fibre <- pmin(pmax(pts_fibre, 0), 5)

    # Points Protein: 0: <=1.6, 1: >1.6, ..., 5: >8.0
    prot_breaks <- c(-Inf, 1.6 * (1:5), Inf)
    pts_prot_raw <- findInterval(protein_g, prot_breaks, left.open = TRUE) - 1
    pts_prot_raw <- pmin(pmax(pts_prot_raw, 0), 5)

    # Protein rule: if A < 11 OR fvns == 5 OR is_cheese == TRUE -> allowed
    prot_allowed <- (pts_a < 11) | (pts_fvns >= 5) | is_cheese
    pts_prot <- ifelse(prot_allowed, pts_prot_raw, 0)

    pts_c <- pts_fvns + pts_fibre + pts_prot
    score <- pts_a - pts_c

  } else {
    # 2018 Model
    # Points Energy: 315 kJ steps
    # 0: <=315, 1: >315, 2: >630, 3: >945, 4: >1260, 5: >1575, 6: >1890,
    # 7: >2205, 8: >2520, 9: >2835, 10: >3150
    e_breaks <- c(-Inf, 315 * (1:10), Inf)
    pts_energy <- findInterval(energy_kj, e_breaks, left.open = TRUE) - 1
    pts_energy <- pmin(pmax(pts_energy, 0), 10)

    # Points Sat Fat:
    # 0: <=0.9, 1: >0.9, 2: >1.9, 3: >2.8, 4: >3.7, 5: >4.7, 6: >5.6,
    # 7: >6.6, 8: >7.5, 9: >8.4, 10: >9.4
    sf_breaks <- c(-Inf, 0.9, 1.9, 2.8, 3.7, 4.7, 5.6, 6.6, 7.5, 8.4, 9.4, Inf)
    pts_sat_fat <- findInterval(sat_fat_g, sf_breaks, left.open = TRUE) - 1
    pts_sat_fat <- pmin(pmax(pts_sat_fat, 0), 10)

    # Free Sugars (use free_sugars_g if available, else sugars_g)
    sugar_use <- if (!is.null(free_sugars_g)) free_sugars_g else sugars_g
    # 0: <=0.9, 1: >0.9, 2: >1.9, 3: >2.8, 4: >3.7, 5: >4.6, 6: >5.6,
    # 7: >6.5, 8: >7.4, 9: >8.3, 10: >9.3
    sug_breaks <- c(-Inf, 0.9, 1.9, 2.8, 3.7, 4.6, 5.6, 6.5, 7.4, 8.3, 9.3, Inf)
    pts_sugars <- findInterval(sugar_use, sug_breaks, left.open = TRUE) - 1
    pts_sugars <- pmin(pmax(pts_sugars, 0), 10)

    # Points Salt (g):
    # 0: <=0.2, 1: >0.2, 2: >0.5, 3: >0.7, 4: >0.9, 5: >1.1, 6: >1.4,
    # 7: >1.6, 8: >1.8, 9: >2.0, 10: >2.3
    salt_breaks <- c(-Inf, 0.2, 0.5, 0.7, 0.9, 1.1, 1.4, 1.6, 1.8, 2.0, 2.3, Inf)
    pts_na <- findInterval(salt_g, salt_breaks, left.open = TRUE) - 1
    pts_na <- pmin(pmax(pts_na, 0), 10)

    pts_a <- pts_energy + pts_sat_fat + pts_sugars + pts_na

    # Points FVNS:
    pts_fvns <- ifelse(fvns_pct > 80, 5,
                ifelse(fvns_pct > 60, 2,
                ifelse(fvns_pct > 40, 1, 0)))

    # Points Fibre (AOAC up to 10 points!):
    # 0: <=0.6, 1: >0.6, 2: >1.2, ..., 10: >6.0
    fib_breaks <- c(-Inf, 0.6 * (1:10), Inf)
    pts_fibre <- findInterval(fibre_g, fib_breaks, left.open = TRUE) - 1
    pts_fibre <- pmin(pmax(pts_fibre, 0), 10)

    # Points Protein: 0: <=1.7, 1: >1.7, 2: >3.4, 3: >5.1, 4: >6.8, 5: >8.5
    prot_breaks <- c(-Inf, 1.7 * (1:5), Inf)
    pts_prot_raw <- findInterval(protein_g, prot_breaks, left.open = TRUE) - 1
    pts_prot_raw <- pmin(pmax(pts_prot_raw, 0), 5)

    prot_allowed <- (pts_a < 11) | (pts_fvns >= 5) | is_cheese
    pts_prot <- ifelse(prot_allowed, pts_prot_raw, 0)

    pts_c <- pts_fvns + pts_fibre + pts_prot
    score <- pts_a - pts_c
  }

  # HFSS classification
  is_hfss <- ifelse(is_drink, score >= 1, score >= 4)
  healthiness <- ifelse(is_hfss, "less healthy", "healthier")

  data.frame(
    points_energy = pts_energy,
    points_sat_fat = pts_sat_fat,
    points_sugars = pts_sugars,
    points_sodium_salt = pts_na,
    points_a = pts_a,
    points_fvns = pts_fvns,
    points_fibre = pts_fibre,
    points_protein_raw = pts_prot_raw,
    protein_allowed = prot_allowed,
    points_protein = pts_prot,
    points_c = pts_c,
    npm_score = score,
    is_hfss = is_hfss,
    healthiness = healthiness,
    model = rep_len(model, n),
    stringsAsFactors = FALSE
  )
}

#' Extract NPM Score
#'
#' Convenience wrapper around \code{\link{calculate_npm}} that returns solely
#' the final integer nutrient profile score vector.
#'
#' @param ... Arguments passed to \code{\link{calculate_npm}}.
#' @return An integer vector of nutrient profiling scores.
#' @export
npm_score <- function(...) {
  calculate_npm(...)$npm_score
}

#' Determine HFSS Status
#'
#' Convenience wrapper around \code{\link{calculate_npm}} that returns a logical
#' vector indicating whether each item is classified as High in Fat, Salt, or
#' Sugar (\code{TRUE} = less healthy / HFSS; \code{FALSE} = healthier).
#'
#' @param ... Arguments passed to \code{\link{calculate_npm}}.
#' @return A logical vector indicating HFSS status.
#' @export
is_hfss <- function(...) {
  calculate_npm(...)$is_hfss
}
