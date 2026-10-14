#' Calculate UK Multiple Traffic Light (MTL) Front-of-Pack Nutrition Labels
#'
#' Evaluates food and drink products according to the official UK Department of Health
#' and Social Care (DHSC), Food Standards Agency (FSA), and devolved administrations'
#' Front-of-Pack (FoP) Multiple Traffic Light guidance (2013, updated 2016).
#'
#' The UK Front-of-Pack traffic light labelling scheme applies color codes
#' (\strong{Green} / Low, \strong{Amber} / Medium, \strong{Red} / High) to four
#' key nutrients of public health concern:
#' \itemize{
#'   \item Total Fat
#'   \item Saturated Fatty Acids (Saturates)
#'   \item Total Sugars
#'   \item Salt (or Sodium converted to salt)
#' }
#'
#' \strong{Criteria for Foods (per 100g):}
#' \itemize{
#'   \item \strong{Fat}: Green \eqn{\le 3.0\text{g}}, Amber \eqn{> 3.0\text{g}} and \eqn{\le 17.5\text{g}}, Red \eqn{> 17.5\text{g}} (or \eqn{> 21\text{g/portion}} when portion \eqn{> 100\text{g}}).
#'   \item \strong{Saturates}: Green \eqn{\le 1.5\text{g}}, Amber \eqn{> 1.5\text{g}} and \eqn{\le 5.0\text{g}}, Red \eqn{> 5.0\text{g}} (or \eqn{> 6.0\text{g/portion}} when portion \eqn{> 100\text{g}}).
#'   \item \strong{Sugars}: Green \eqn{\le 5.0\text{g}}, Amber \eqn{> 5.0\text{g}} and \eqn{\le 22.5\text{g}}, Red \eqn{> 22.5\text{g}} (or \eqn{> 27.0\text{g/portion}} when portion \eqn{> 100\text{g}}).
#'   \item \strong{Salt}: Green \eqn{\le 0.3\text{g}}, Amber \eqn{> 0.3\text{g}} and \eqn{\le 1.5\text{g}}, Red \eqn{> 1.5\text{g}} (or \eqn{> 1.8\text{g/portion}} when portion \eqn{> 100\text{g}}).
#' }
#'
#' \strong{Criteria for Drinks (per 100ml):}
#' \itemize{
#'   \item \strong{Fat}: Green \eqn{\le 1.5\text{g}}, Amber \eqn{> 1.5\text{g}} and \eqn{\le 8.75\text{g}}, Red \eqn{> 8.75\text{g}} (or \eqn{> 10.5\text{g/portion}} when portion \eqn{> 150\text{ml}}).
#'   \item \strong{Saturates}: Green \eqn{\le 0.75\text{g}}, Amber \eqn{> 0.75\text{g}} and \eqn{\le 2.5\text{g}}, Red \eqn{> 2.5\text{g}} (or \eqn{> 3.0\text{g/portion}} when portion \eqn{> 150\text{ml}}).
#'   \item \strong{Sugars}: Green \eqn{\le 2.5\text{g}}, Amber \eqn{> 2.5\text{g}} and \eqn{\le 11.25\text{g}}, Red \eqn{> 11.25\text{g}} (or \eqn{> 13.5\text{g/portion}} when portion \eqn{> 150\text{ml}}).
#'   \item \strong{Salt}: Green \eqn{\le 0.3\text{g}}, Amber \eqn{> 0.3\text{g}} and \eqn{\le 0.75\text{g}}, Red \eqn{> 0.75\text{g}} (or \eqn{> 0.9\text{g/portion}} when portion \eqn{> 150\text{ml}}).
#' }
#'
#' @param fat_g Numeric vector of total fat in grams (g) per 100g/ml.
#' @param sat_fat_g Numeric vector of saturated fat in grams (g) per 100g/ml.
#' @param sugars_g Numeric vector of total sugars in grams (g) per 100g/ml.
#' @param salt_g Numeric vector of salt in grams (g) per 100g/ml. If \code{NULL},
#'   calculated from \code{sodium_mg}.
#' @param sodium_mg Optional numeric vector of sodium in milligrams (mg) per 100g/ml.
#' @param portion_g Optional numeric vector of portion / serving size in grams (or ml).
#' @param fat_portion_g Optional numeric vector of fat per portion. If \code{NULL}
#'   and \code{portion_g} is supplied, computed automatically as \code{fat_g * portion_g / 100}.
#' @param sat_fat_portion_g Optional numeric vector of saturated fat per portion.
#' @param sugars_portion_g Optional numeric vector of total sugars per portion.
#' @param salt_portion_g Optional numeric vector of salt per portion.
#' @param is_drink Logical vector indicating whether the product is a drink/liquid
#'   (\code{TRUE}) or a solid food (\code{FALSE}). Default is \code{FALSE}.
#'
#' @return A \code{data.frame} containing:
#' \describe{
#'   \item{fat_colour}{Colour code for fat (\code{"Green"}, \code{"Amber"}, \code{"Red"}).}
#'   \item{sat_fat_colour}{Colour code for saturated fat.}
#'   \item{sugars_colour}{Colour code for total sugars.}
#'   \item{salt_colour}{Colour code for salt.}
#'   \item{n_green}{Count of green lights (0 to 4).}
#'   \item{n_amber}{Count of amber lights (0 to 4).}
#'   \item{n_red}{Count of red lights (0 to 4).}
#'   \item{has_red}{Logical indicating whether the item has at least one Red light.}
#'   \item{all_green}{Logical indicating whether all four lights are Green.}
#'   \item{mtl_healthiness}{Classification: \code{"healthier"} (0 red lights) or \code{"less healthy"} (\eqn{\ge 1} red lights), following public health research standards (Tan et al., 2025).}
#' }
#'
#' @references
#' Department of Health, Food Standards Agency, Welsh Government, and Food Standards Scotland (2016).
#' \emph{Guide to creating a front of pack (FoP) nutrition label for pre-packed products sold through retail outlets}.
#' \url{https://www.gov.uk/government/publications/front-of-pack-nutrition-labelling-guidance}
#'
#' Tan M, Pham H, Pombo-Rodrigues S, et al. (2025). Nutritional composition and healthiness of out-of-home food and drink.
#' \emph{Proceedings of the Nutrition Society}, 84(OCE3), E208.
#'
#' @examples
#' # Solid food example (e.g. snack bar):
#' calculate_mtl(
#'   fat_g = 18.0,
#'   sat_fat_g = 4.2,
#'   sugars_g = 24.0,
#'   salt_g = 0.5,
#'   portion_g = 60
#' )
#'
#' # Large portion food triggering per-portion Red threshold:
#' # 120g portion with 16g/100g fat -> portion fat = 19.2g (<21g cap)
#' # 150g portion with 16g/100g fat -> portion fat = 24.0g (>21g cap -> Red!)
#' calculate_mtl(
#'   fat_g = 16.0,
#'   sat_fat_g = 3.0,
#'   sugars_g = 10.0,
#'   salt_g = 0.8,
#'   portion_g = 150
#' )
#'
#' @export
calculate_mtl <- function(fat_g = 0,
                          sat_fat_g = 0,
                          sugars_g = 0,
                          salt_g = NULL,
                          sodium_mg = NULL,
                          portion_g = NULL,
                          fat_portion_g = NULL,
                          sat_fat_portion_g = NULL,
                          sugars_portion_g = NULL,
                          salt_portion_g = NULL,
                          is_drink = FALSE) {
  # Determine vector length
  lens <- c(
    length(fat_g),
    length(sat_fat_g),
    length(sugars_g),
    if (!is.null(salt_g)) length(salt_g) else 0,
    if (!is.null(sodium_mg)) length(sodium_mg) else 0,
    if (!is.null(portion_g)) length(portion_g) else 0,
    length(is_drink)
  )
  n <- max(lens, 1)

  fat_g <- rep_len(as.numeric(fat_g), n)
  sat_fat_g <- rep_len(as.numeric(sat_fat_g), n)
  sugars_g <- rep_len(as.numeric(sugars_g), n)
  is_drink <- rep_len(as.logical(is_drink), n)

  fat_g[is.na(fat_g)] <- 0
  sat_fat_g[is.na(sat_fat_g)] <- 0
  sugars_g[is.na(sugars_g)] <- 0
  is_drink[is.na(is_drink)] <- FALSE

  # Salt vs Sodium
  if (is.null(salt_g)) {
    if (is.null(sodium_mg)) {
      salt_g <- rep_len(0, n)
    } else {
      sodium_mg <- rep_len(as.numeric(sodium_mg), n)
      sodium_mg[is.na(sodium_mg)] <- 0
      salt_g <- sodium_mg * 2.5 / 1000
    }
  } else {
    salt_g <- rep_len(as.numeric(salt_g), n)
    salt_g[is.na(salt_g)] <- 0
  }

  # Portion calculations
  has_portion <- !is.null(portion_g)
  if (has_portion) {
    portion_g <- rep_len(as.numeric(portion_g), n)
    if (is.null(fat_portion_g)) fat_portion_g <- fat_g * portion_g / 100
    if (is.null(sat_fat_portion_g)) sat_fat_portion_g <- sat_fat_g * portion_g / 100
    if (is.null(sugars_portion_g)) sugars_portion_g <- sugars_g * portion_g / 100
    if (is.null(salt_portion_g)) salt_portion_g <- salt_g * portion_g / 100
  }

  if (!is.null(fat_portion_g)) fat_portion_g <- rep_len(as.numeric(fat_portion_g), n)
  if (!is.null(sat_fat_portion_g)) sat_fat_portion_g <- rep_len(as.numeric(sat_fat_portion_g), n)
  if (!is.null(sugars_portion_g)) sugars_portion_g <- rep_len(as.numeric(sugars_portion_g), n)
  if (!is.null(salt_portion_g)) salt_portion_g <- rep_len(as.numeric(salt_portion_g), n)

  # Initialize colours
  fat_col <- character(n)
  sat_fat_col <- character(n)
  sugars_col <- character(n)
  salt_col <- character(n)

  for (i in seq_len(n)) {
    if (!is_drink[i]) {
      # SOLID FOODS
      # Fat: Green <= 3.0, Amber > 3.0 & <= 17.5, Red > 17.5
      f_val <- fat_g[i]
      if (f_val <= 3.0) {
        fat_col[i] <- "Green"
      } else if (f_val <= 17.5) {
        fat_col[i] <- "Amber"
      } else {
        fat_col[i] <- "Red"
      }
      # Portion cap for Red (>21g/portion when portion > 100g)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 100) {
        if (!is.null(fat_portion_g) && !is.na(fat_portion_g[i]) && fat_portion_g[i] > 21.0) {
          fat_col[i] <- "Red"
        }
      }

      # Sat Fat: Green <= 1.5, Amber > 1.5 & <= 5.0, Red > 5.0
      sf_val <- sat_fat_g[i]
      if (sf_val <= 1.5) {
        sat_fat_col[i] <- "Green"
      } else if (sf_val <= 5.0) {
        sat_fat_col[i] <- "Amber"
      } else {
        sat_fat_col[i] <- "Red"
      }
      # Portion cap for Red (>6.0g/portion when portion > 100g)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 100) {
        if (!is.null(sat_fat_portion_g) && !is.na(sat_fat_portion_g[i]) && sat_fat_portion_g[i] > 6.0) {
          sat_fat_col[i] <- "Red"
        }
      }

      # Total Sugars: Green <= 5.0, Amber > 5.0 & <= 22.5, Red > 22.5
      sug_val <- sugars_g[i]
      if (sug_val <= 5.0) {
        sugars_col[i] <- "Green"
      } else if (sug_val <= 22.5) {
        sugars_col[i] <- "Amber"
      } else {
        sugars_col[i] <- "Red"
      }
      # Portion cap for Red (>27.0g/portion when portion > 100g)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 100) {
        if (!is.null(sugars_portion_g) && !is.na(sugars_portion_g[i]) && sugars_portion_g[i] > 27.0) {
          sugars_col[i] <- "Red"
        }
      }

      # Salt: Green <= 0.3, Amber > 0.3 & <= 1.5, Red > 1.5
      salt_val <- salt_g[i]
      if (salt_val <= 0.3) {
        salt_col[i] <- "Green"
      } else if (salt_val <= 1.5) {
        salt_col[i] <- "Amber"
      } else {
        salt_col[i] <- "Red"
      }
      # Portion cap for Red (>1.8g/portion when portion > 100g)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 100) {
        if (!is.null(salt_portion_g) && !is.na(salt_portion_g[i]) && salt_portion_g[i] > 1.8) {
          salt_col[i] <- "Red"
        }
      }

    } else {
      # DRINKS / LIQUIDS
      # Fat: Green <= 1.5, Amber > 1.5 & <= 8.75, Red > 8.75
      f_val <- fat_g[i]
      if (f_val <= 1.5) {
        fat_col[i] <- "Green"
      } else if (f_val <= 8.75) {
        fat_col[i] <- "Amber"
      } else {
        fat_col[i] <- "Red"
      }
      # Portion cap for Red (>10.5g/portion when portion > 150ml)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 150) {
        if (!is.null(fat_portion_g) && !is.na(fat_portion_g[i]) && fat_portion_g[i] > 10.5) {
          fat_col[i] <- "Red"
        }
      }

      # Sat Fat: Green <= 0.75, Amber > 0.75 & <= 2.5, Red > 2.5
      sf_val <- sat_fat_g[i]
      if (sf_val <= 0.75) {
        sat_fat_col[i] <- "Green"
      } else if (sf_val <= 2.5) {
        sat_fat_col[i] <- "Amber"
      } else {
        sat_fat_col[i] <- "Red"
      }
      # Portion cap for Red (>3.0g/portion when portion > 150ml)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 150) {
        if (!is.null(sat_fat_portion_g) && !is.na(sat_fat_portion_g[i]) && sat_fat_portion_g[i] > 3.0) {
          sat_fat_col[i] <- "Red"
        }
      }

      # Total Sugars: Green <= 2.5, Amber > 2.5 & <= 11.25, Red > 11.25
      sug_val <- sugars_g[i]
      if (sug_val <= 2.5) {
        sugars_col[i] <- "Green"
      } else if (sug_val <= 11.25) {
        sugars_col[i] <- "Amber"
      } else {
        sugars_col[i] <- "Red"
      }
      # Portion cap for Red (>13.5g/portion when portion > 150ml)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 150) {
        if (!is.null(sugars_portion_g) && !is.na(sugars_portion_g[i]) && sugars_portion_g[i] > 13.5) {
          sugars_col[i] <- "Red"
        }
      }

      # Salt: Green <= 0.3, Amber > 0.3 & <= 0.75, Red > 0.75
      salt_val <- salt_g[i]
      if (salt_val <= 0.3) {
        salt_col[i] <- "Green"
      } else if (salt_val <= 0.75) {
        salt_col[i] <- "Amber"
      } else {
        salt_col[i] <- "Red"
      }
      # Portion cap for Red (>0.9g/portion when portion > 150ml)
      if (!is.null(portion_g) && !is.na(portion_g[i]) && portion_g[i] > 150) {
        if (!is.null(salt_portion_g) && !is.na(salt_portion_g[i]) && salt_portion_g[i] > 0.9) {
          salt_col[i] <- "Red"
        }
      }
    }
  }

  all_cols <- cbind(fat_col, sat_fat_col, sugars_col, salt_col)
  n_red <- rowSums(all_cols == "Red")
  n_amber <- rowSums(all_cols == "Amber")
  n_green <- rowSums(all_cols == "Green")
  has_red <- (n_red > 0)
  all_green <- (n_green == 4)

  healthiness <- ifelse(has_red, "less healthy", "healthier")

  data.frame(
    fat_colour = fat_col,
    sat_fat_colour = sat_fat_col,
    sugars_colour = sugars_col,
    salt_colour = salt_col,
    n_green = n_green,
    n_amber = n_amber,
    n_red = n_red,
    has_red = has_red,
    all_green = all_green,
    mtl_healthiness = healthiness,
    stringsAsFactors = FALSE
  )
}
