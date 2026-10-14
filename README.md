# uknpm: UK Nutrient Profile Model and Healthiness Assessment in R

<!-- badges: start -->
<!-- badges: end -->

The **`uknpm`** R package provides an implementation of UK statutory and public health nutritional assessment models, front-of-pack labelling frameworks, and voluntary/mandatory product reformulation programmes:

1. **UK Nutrient Profile Model (NPM 2004/2005 & 2018)**:
   - Statutory model developed by the Food Standards Agency (FSA 2004/2005) and Department of Health and Social Care (DHSC 2011 Technical Guidance), used for Ofcom television broadcast advertising restrictions, online marketing restrictions, and HFSS (High in Fat, Salt, or Sugar) retail placement and promotional regulations (The Food (Promotion and Placement) (England) Regulations 2021).
   - Updated consultation model (DHSC 2018 Technical Guidance) incorporating free sugars, AOAC fibre up to 10 points, and seeds.
2. **Multiple Traffic Light (MTL) Front-of-Pack Labelling**:
   - Official Department of Health and Social Care / Food Standards Agency (DHSC 2013/2016) front-of-pack traffic light color criteria (Green, Amber, Red) per 100g/100ml and per-portion thresholds for fat, saturated fat, total sugars, and salt.
3. **UK Calorie, Salt, and Sugar Reduction Programmes & Levy**:
   - **Soft Drinks Industry Levy (SDIL)** statutory tiers (<5g exempt, 5 to <8g Tier 1, $\ge$8g Tier 2) and rate schedules.
   - **OHID / PHE Salt Reduction Targets for 2024** across 84 retail grocery categories and out-of-home (OOH) dish/meal targets.
   - **OHID Sugar Reduction Programme** category targets and single-serve portion caps.
   - **OHID Calorie Reduction Programme** guidelines and the 400-600-600 campaign benchmarks.
4. **Multi-Metric Healthiness Evaluation**:
   - Comprehensive comparative framework assessing food and beverage datasets across candidate healthiness metrics, reproducing the empirical methodology of **Tan et al. (2025)** (*Proceedings of the Nutrition Society*).

---

## Installation

Install directly from GitHub or locally:

```r
# install.packages("devtools")
devtools::install_local(".")
```

---

## 1. UK Nutrient Profile Model (NPM)

The primary function `calculate_npm()` scores foods and drinks per 100g:
- **'A' points (0–10 each, max 40)**: Energy (kJ), Saturated fat (g), Total sugars (g), Sodium (mg) / Salt (g).
- **'C' points (max 15)**: Fruit, vegetables, nuts, seeds (0–5), Fibre (0–5 or 0–10), Protein (0–5).
- **Protein Cap Rule**: If Total A $\ge$ 11, protein points are excluded unless Fruit, Vegetables, and Nuts (FVN) points equal 5 (or if `is_cheese = TRUE`).

Foods scoring $\ge 4$ and drinks scoring $\ge 1$ are classified as **"less healthy"** (HFSS).

```r
library(uknpm)

# Fruit Fromage Frais (DHSC 2011 Worked Example 1)
calculate_npm(
  energy_kj = 459,
  sat_fat_g = 1.8,
  sugars_g = 13.4,
  sodium_mg = 0,
  fvns_pct = 8,
  fibre_g = 0.6,
  protein_g = 6.5,
  is_drink = FALSE
)

# Vanilla Dairy Ice Cream (DHSC 2011 Worked Example 2 - Protein Capped)
calculate_npm(
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
```

### Convenient Vectorized Helpers

```r
# Return numeric scores:
npm_score(energy_kj = c(459, 741), sat_fat_g = c(1.8, 6.1), sugars_g = c(13.4, 18.7), sodium_mg = c(0, 60))
#> [1]  0 12

# Return logical HFSS flags:
is_hfss(energy_kj = c(459, 741), sat_fat_g = c(1.8, 6.1), sugars_g = c(13.4, 18.7), sodium_mg = c(0, 60))
#> [1] FALSE  TRUE
```

### Fruit, Vegetables, Nuts and Seeds (FVNS) Calculation

Calculates proportion in composite products applying the statutory 2x multiplier for dried fruit/vegetables:

```r
# Cereal bar with 30g dried fruit per 100g:
calculate_fvns(weight_fvns = 0, weight_dried = 30, weight_other = 70)
#> [1] 46.15385
```

---

## 2. Multiple Traffic Light (MTL) Front-of-Pack Labelling

Assigns Green, Amber, or Red color codes according to DHSC (2013/2016) guidance, accounting for both per-100g/ml criteria and per-portion Red overrides (when portion $> 100\text{g}$ for foods or $> 150\text{ml}$ for drinks):

```r
calculate_mtl(
  fat_g = 16.0,
  sat_fat_g = 3.5,
  sugars_g = 12.0,
  salt_g = 1.2,
  portion_g = 150,
  is_drink = FALSE
)
```

---

## 3. UK Reduction Programmes and SDIL Levy

### Soft Drinks Industry Levy (SDIL)

```r
calculate_sdil(sugars_g_100ml = c(3.2, 5.5, 9.8))
```

### OHID Salt Reduction Targets (2024)

Evaluates compliance against category sales-weighted average and maximum targets:

```r
check_salt_target(salt_g_100g = c(0.80, 0.95, 1.20), category = "Bread")
```

### OHID Calorie Reduction Programme

Evaluates meal items against single-serve category caps (e.g. 550 kcal sandwiches, 600 kcal ready meals) and the 400-600-600 meal occasion guidelines:

```r
check_calorie_guideline(energy_kcal_portion = c(480, 620), category = "Sandwiches")
```

---

## 4. Multi-Metric Menu Healthiness Evaluation (Tan et al., 2025)

The package enables comparative healthiness evaluation across out-of-home menus and dietary surveys:

```r
# Load the built-in out-of-home menu dataset:
data("sample_ooh_menu")

# Assess all menu items across candidate healthiness approaches:
assessment <- assess_healthiness(sample_ooh_menu)

# Generate a comparative summary table:
summarise_healthiness(assessment)
```

Output:

| Approach | Total Items | Healthy | % Healthy | Less Healthy | % Less Healthy |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **UK Nutrient Profile Model (NPM)** | 20 | 7 | 35.0% | 13 | 65.0% |
| **Multiple Traffic Light (MTL, No Red Lights)** | 20 | 1 | 5.0% | 19 | 95.0% |
| **Combined NPM + MTL Portion Caps** | 20 | 1 | 5.0% | 19 | 95.0% |
| **UK Calorie Reduction Guidelines** | 20 | 7 | 35.0% | 13 | 65.0% |
| **UK Salt Reduction 2024 Targets** | 20 | 1 | 5.0% | 19 | 95.0% |

---

## 5. Publication Visualisations

The package includes a publication-grade plotting suite inspired by **ATNi**, **Vellum**, and **Flowchart** design doctrines:

- `plot_healthiness_comparison(assessment, style = "atni")`: Comparative horizontal stacked bar chart showing portfolio healthiness across candidate frameworks.
- `plot_mtl_profile(assessment, style = "atni")`: Multiple Traffic Light distribution across fat, sat fat, sugars, and salt.
- `plot_npm_scatter(assessment, style = "vellum")`: High-contrast data-ink scatter plot of Total A vs Total C points with statutory food ($A - C = 4$) and drink ($A - C = 1$) cutoff lines.
- `plot_npm_flowchart(format = "ggplot")`: Complete statutory decision tree flowchart for DHSC scoring.

```r
# Generate all publication figures
p1 <- plot_healthiness_comparison(assessment, style = "atni")
p2 <- plot_mtl_profile(assessment, style = "atni")
p3 <- plot_npm_scatter(assessment, style = "vellum")
p4 <- plot_npm_flowchart(format = "ggplot")
```

---

## Built-In Reference Datasets

- `ohid_salt_targets_2024`: Authoritative OHID 2024 salt reduction targets across 84 categories and out-of-home dish caps.
- `ohid_sugar_targets`: Authoritative OHID sugar reduction programme targets and portion caps.
- `ohid_calorie_guidelines`: Authoritative OHID calorie reduction single-serve caps and 400-600-600 guidelines.
- `npm_worked_examples`: Complete dataset of official worked examples from DHSC (2011) and DHSC (2018) Technical Guidance.
- `sample_ooh_menu`: Representative cross-sectional out-of-home menu dataset from leading UK restaurant and fast-food chains.

---

## References

1. Department of Health and Social Care (2011). *Nutrient Profiling Technical Guidance*. [GOV.UK](https://www.gov.uk/government/publications/the-nutrient-profiling-model).
2. Department of Health and Social Care (2018). *Nutrient Profiling Model 2018: Technical Guidance*. [GOV.UK](https://www.gov.uk/government/publications/nutrient-profiling-model-2018).
3. Department of Health, Food Standards Agency, Welsh Government, and Food Standards Scotland (2016). *Guide to creating a front of pack (FoP) nutrition label for pre-packed products sold through retail outlets*. [GOV.UK](https://www.gov.uk/government/publications/front-of-pack-nutrition-labelling-guidance).
4. Office for Health Improvement and Disparities (2020). *Salt reduction targets for 2024*. [GOV.UK](https://www.gov.uk/government/publications/salt-reduction-targets-for-2024).
5. Tan M, Pham H, Pombo-Rodrigues S, Hashem KM, Shiach A, Barakat NA (2025). *Nutritional composition and healthiness of out-of-home food and drink: cross-sectional and retrospective longitudinal analyses of best-selling menu items in the UK, 2021-2023/24*. Proceedings of the Nutrition Society, 84(OCE3), E208. [DOI: 10.1017/S0029665125100773](https://doi.org/10.1017/S0029665125100773).
