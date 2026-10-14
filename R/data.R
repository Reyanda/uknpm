#' OHID Salt Reduction Targets for 2024
#'
#' Category-specific salt reduction targets published by the Office for Health
#' Improvement and Disparities (OHID) and Public Health England (PHE) for 2024,
#' covering both pre-packed retail groceries and out-of-home (OOH) dish caps.
#'
#' @format A data frame with 23 rows and 6 variables:
#' \describe{
#'   \item{category}{Food or out-of-home category name.}
#'   \item{sector}{Sector classification (\code{"Retail / Pre-packed"} or \code{"Out-of-home (OOH)"}).}
#'   \item{target_average_100g}{Sales-weighted average salt target per 100g (in grams).}
#'   \item{target_maximum_100g}{Maximum salt target per 100g (or per portion for out-of-home dishes).}
#'   \item{target_unit}{Unit of measurement (\code{"g/100g"} or \code{"g/portion"}).}
#'   \item{notes}{Regulatory and technical notes.}
#' }
#' @source Office for Health Improvement and Disparities (2020). \emph{Salt reduction targets for 2024}.
#'   \url{https://www.gov.uk/government/publications/salt-reduction-targets-for-2024}
"ohid_salt_targets_2024"

#' OHID Sugar Reduction Programme Targets
#'
#' Targets and maximum portion caps for the top sugar-contributing food categories
#' established under the UK Government's Sugar Reduction Programme.
#'
#' @format A data frame with 10 rows and 7 variables:
#' \describe{
#'   \item{category}{Sugar reduction food category.}
#'   \item{target_sugars_100g}{Target sugar level per 100g (in grams).}
#'   \item{max_portion_cap_g}{Maximum recommended sugar content per portion (in grams).}
#'   \item{max_portion_cap_kcal}{Maximum recommended calories per portion for single-serve items (in kcal).}
#'   \item{baseline_year}{Programme baseline year (2015).}
#'   \item{target_year}{Programme target achievement year (2020).}
#'   \item{reduction_target_pct}{Target percentage reduction in sugar (20\%).}
#' }
#' @source Public Health England (2020). \emph{Sugar reduction: report on progress between 2015 and 2020}.
#'   \url{https://www.gov.uk/government/collections/sugar-reduction}
"ohid_sugar_targets"

#' OHID Calorie Reduction Programme Guidelines
#'
#' Recommended maximum calorie ceilings for single-serve items and campaign meal
#' guidelines under the UK Calorie Reduction Programme.
#'
#' @format A data frame with 9 rows and 4 variables:
#' \describe{
#'   \item{category}{Food category or meal occasion.}
#'   \item{max_kcal_portion}{Maximum recommended calories per serving.}
#'   \item{benchmark_type}{Guideline type (\code{"Category Single-Serve Ceiling"} or \code{"400-600-600 Daily Campaign Guideline"}).}
#'   \item{description}{Detailed description of the guidance recommendation.}
#' }
#' @source Public Health England (2020). \emph{Calorie reduction: criteria and guidelines for the food industry}.
"ohid_calorie_guidelines"

#' Official UK Nutrient Profile Model Worked Examples
#'
#' Nutritional data, official scores, and HFSS classifications for all worked examples
#' published in the Department of Health and Social Care 2011 and 2018 Technical Guidance.
#'
#' @format A data frame with 8 rows and 18 variables:
#' \describe{
#'   \item{example_id}{Official guidance example identifier.}
#'   \item{product_name}{Product description.}
#'   \item{model}{NPM model version (\code{"2004_2005"} or \code{"2018"}).}
#'   \item{is_drink}{Drink indicator flag.}
#'   \item{energy_kj}{Energy in kJ per 100g.}
#'   \item{sat_fat_g}{Saturated fat in g per 100g.}
#'   \item{sugars_g}{Total sugars in g per 100g.}
#'   \item{free_sugars_g}{Free sugars in g per 100g.}
#'   \item{sodium_mg}{Sodium in mg per 100g.}
#'   \item{salt_g}{Salt in g per 100g.}
#'   \item{fvns_pct}{Fruit, vegetables, nuts, seeds percentage.}
#'   \item{fibre_g}{Fibre in g per 100g.}
#'   \item{fibre_method}{Fibre measurement method (\code{"aoac"} or \code{"nsp"}).}
#'   \item{protein_g}{Protein in g per 100g.}
#'   \item{expected_points_a}{Official total 'A' points.}
#'   \item{expected_points_c}{Official total 'C' points.}
#'   \item{expected_score}{Official final nutrient profile score.}
#'   \item{expected_hfss}{Official HFSS classification.}
#' }
#' @source
#' Department of Health and Social Care (2011). \emph{Nutrient Profiling Technical Guidance}.
#' Department of Health and Social Care (2018). \emph{Nutrient Profiling Model 2018: Technical Guidance}.
"npm_worked_examples"

#' Sample Out-of-Home Menu Nutrition Dataset
#'
#' A representative cross-sectional dataset of 20 menu items from leading UK
#' out-of-home chains, modeled after the empirical survey methodology in Tan et al. (2025).
#'
#' @format A data frame with 20 rows and 15 variables:
#' \describe{
#'   \item{item_id}{Unique menu item identifier.}
#'   \item{company_type}{Out-of-home company sector.}
#'   \item{item_name}{Name of menu item.}
#'   \item{category}{Food category.}
#'   \item{is_drink}{Drink indicator flag.}
#'   \item{portion_g}{Portion weight in grams (or volume in ml).}
#'   \item{energy_kcal}{Energy in kcal per 100g.}
#'   \item{energy_kj}{Energy in kJ per 100g.}
#'   \item{energy_kcal_portion}{Total energy in kcal per serving.}
#'   \item{fat_g}{Total fat in g per 100g.}
#'   \item{sat_fat_g}{Saturated fat in g per 100g.}
#'   \item{sugars_g}{Total sugars in g per 100g.}
#'   \item{salt_g}{Salt in g per 100g.}
#'   \item{fvns_pct}{Estimated fruit, veg, nuts percentage.}
#'   \item{fibre_g}{Dietary fibre in g per 100g.}
#'   \item{protein_g}{Protein in g per 100g.}
#' }
#' @references
#' Tan M, Pham H, Pombo-Rodrigues S, Hashem KM, Shiach A, Barakat NA (2025).
#' Nutritional composition and healthiness of out-of-home food and drink: cross-sectional
#' and retrospective longitudinal analyses of best-selling menu items in the UK, 2021-2023/24.
#' \emph{Proceedings of the Nutrition Society}, 84(OCE3), E208. \doi{10.1017/S0029665125100773}
"sample_ooh_menu"
