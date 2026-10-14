#' Calculate Fruit, Vegetables, Nuts and Seeds (FVNS) Percentage
#'
#' Calculates the percentage of fruit, vegetables, nuts, and seeds (FVNS) in a
#' food or drink product according to the UK Department of Health and Social Care
#' (DHSC) Nutrient Profiling Technical Guidance (2011) and NPM 2018 guidance.
#'
#' Under the official guidance, dried fruits and vegetables are concentrated
#' and therefore their weight is multiplied by 2 when calculating the proportion
#' of FVNS in composite foods:
#' \deqn{\% \text{FVNS} = \frac{W_{\text{fresh}} + (2 \times W_{\text{dried}})}{W_{\text{fresh}} + (2 \times W_{\text{dried}}) + W_{\text{other}}} \times 100}
#'
#' Minimally processed fruit and vegetables (including fresh, frozen, cooked, canned,
#' 100\% pure juices, and purees) count towards FVNS. Concentrated fruit juice
#' sugars, powders, or leathers do not count. Potatoes and other starchy tubers
#' (such as yams and cassava) do not count.
#'
#' @param weight_fvns Numeric vector of weights (in grams) of intact, fresh,
#'   cooked, canned, or pureed fruit, vegetables, nuts (and seeds in 2018 model).
#'   Default is 0.
#' @param weight_dried Numeric vector of weights (in grams) of dried fruit, dried
#'   vegetables, or concentrated tomato puree (which receives the 2x multiplier).
#'   Default is 0.
#' @param weight_other Numeric vector of weights (in grams) of other ingredients
#'   in the product (e.g. cereals, flour, sugar, fat, water, meat, dairy).
#' @param total_weight Optional numeric vector of total product weight. If provided
#'   and `weight_other` is `NULL`, `weight_other` is inferred as
#'   `total_weight - weight_fvns - weight_dried`.
#'
#' @return A numeric vector representing the percentage (0 to 100) of FVNS in the product.
#' @references
#' Department of Health and Social Care (2011). \emph{Nutrient Profiling Technical Guidance}.
#' Department of Health and Social Care (2018). \emph{Nutrient Profiling Model 2018: Technical Guidance}.
#'
#' @examples
#' # Worked Example 5 from DHSC 2011 Guidance:
#' # Fruit and nut cereal bar containing 30g dried fruit per 100g (70g other ingredients):
#' calculate_fvns(weight_fvns = 0, weight_dried = 30, weight_other = 70)
#' # Expected output: 46.15% (rounds to 46% as in guidance)
#'
#' # Pure 100% fruit juice:
#' calculate_fvns(weight_fvns = 100, weight_other = 0)
#'
#' @export
calculate_fvns <- function(weight_fvns = 0,
                           weight_dried = 0,
                           weight_other = NULL,
                           total_weight = NULL) {
  # Normalize inputs to numeric vectors
  n <- max(length(weight_fvns), length(weight_dried),
           if (!is.null(weight_other)) length(weight_other) else 0,
           if (!is.null(total_weight)) length(total_weight) else 0)

  weight_fvns <- rep_len(as.numeric(weight_fvns), n)
  weight_dried <- rep_len(as.numeric(weight_dried), n)

  weight_fvns[is.na(weight_fvns)] <- 0
  weight_dried[is.na(weight_dried)] <- 0

  if (is.null(weight_other)) {
    if (is.null(total_weight)) {
      stop("Either `weight_other` or `total_weight` must be specified.")
    }
    total_weight <- rep_len(as.numeric(total_weight), n)
    weight_other <- total_weight - weight_fvns - weight_dried
    weight_other <- pmax(weight_other, 0)
  } else {
    weight_other <- rep_len(as.numeric(weight_other), n)
    weight_other[is.na(weight_other)] <- 0
  }

  numerator <- weight_fvns + (2 * weight_dried)
  denominator <- numerator + weight_other

  pct <- ifelse(denominator <= 0, 0, (numerator / denominator) * 100)
  pmin(pmax(pct, 0), 100)
}
