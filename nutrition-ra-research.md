# Research Evidence Ledger: nutrition-ra-uknpm

## 1. Statutory & Policy Frameworks

### 1.1 UK Nutrient Profile Model (NPM 2004/2005; DHSC 2011 Technical Guidance)
- **Authority**: Food Standards Agency (2004/2005) & Department of Health and Social Care (January 2011).
- **Regulatory Use**: Statutory basis for Ofcom broadcast advertising restrictions (child-targeted TV), UK advertising watershed/online restrictions, and HFSS (High in Fat, Salt, or Sugar) retail promotion and placement regulations (The Food (Promotion and Placement) (England) Regulations 2021).
- **Scoring Unit**: Per 100g of food or drink (as sold or as consumed/reconstituted according to instructions).
- **'A' Points (Negative Nutrients)**:
  - Energy (kJ): Points 0 to 10 (steps of 335 kJ; 0: <=335, 10: >3350).
  - Saturated fat (g): Points 0 to 10 (steps of 1g; 0: <=1, 10: >10).
  - Total sugar (g): Points 0 to 10 (steps of 4.5g; 0: <=4.5, 10: >45).
  - Sodium (mg): Points 0 to 10 (steps of 90mg; 0: <=90, 10: >900). Salt (g) conversion: $\text{sodium (mg)} = \text{salt (g)} \times 1000 / 2.5$.
  - Total A Points = sum of 4 nutrient points (max 40).
- **'C' Points (Positive Nutrients)**:
  - Fruit, vegetables, and nuts (FVN, %): Points 0 (<=40%), 1 (>40%), 2 (>60%), 5 (>80%). Note: points 3 and 4 are not awarded.
  - Fibre: NSP fibre (0: <=0.7, 1: >0.7, 2: >1.4, 3: >2.1, 4: >2.8, 5: >3.5g) or AOAC fibre (0: <=0.9, 1: >0.9, 2: >1.9, 3: >2.8, 4: >3.7, 5: >4.7g). Max 5 points.
  - Protein (g): Points 0 (<=1.6) to 5 (>8.0) in steps of 1.6g. Max 5 points.
  - Total C Points = sum of 3 components (max 15).
- **Protein Cap Rule**:
  - If Total A < 11: Final Score = Total A - Total C.
  - If Total A >= 11:
    - If FVN Points == 5: Final Score = Total A - Total C (protein points allowed).
    - If FVN Points < 5: Final Score = Total A - (FVN Points + Fibre Points) (protein points stripped to 0).
  - **Cheese Exception**: In natural cheese products with high calcium density, protein points may be counted even if A >= 11 (optional parameter `is_cheese = TRUE`).
- **Classification Thresholds**:
  - Foods: Score >= 4 -> "less healthy" (HFSS); Score < 4 -> "healthier".
  - Drinks: Score >= 1 -> "less healthy" (HFSS); Score < 1 -> "healthier".

### 1.2 UK Nutrient Profile Model 2018 (DHSC 2018 Consultation Model)
- **Authority**: Department of Health and Social Care / Public Health England (2018).
- **Modifications**:
  - Free sugars evaluated instead of total sugars.
  - Salt (g) evaluated directly instead of sodium (mg).
  - AOAC fibre awarded up to 10 points (0: <=0.6g, 10: >6.0g in steps of 0.6g).
  - Energy: 315 kJ steps (0: <=315, 10: >3150).
  - Saturated fat: 0.9g / 0.95g steps (0: <=0.9, 10: >9.4).
  - Free sugars: 0.9g / 0.95g steps (0: <=0.9, 10: >9.3).
  - Salt: 0.2g to 2.3g (0: <=0.2, 10: >2.3).
  - Seeds added to beneficial food components (FVNS).
  - Same protein capping rule (A >= 11 requires FVNS = 5 to count protein).

### 1.3 Multiple Traffic Light (MTL) Front-of-Pack Labelling
- **Authority**: Department of Health and Social Care, Food Standards Agency, Food Standards Scotland, Welsh Government (2013, updated 2016).
- **Thresholds for Solid Foods**:
  - Fat: Green (<= 3.0g/100g), Amber (> 3.0 and <= 17.5g/100g), Red (> 17.5g/100g OR > 21g/portion if portion > 100g).
  - Saturates: Green (<= 1.5g/100g), Amber (> 1.5 and <= 5.0g/100g), Red (> 5.0g/100g OR > 6.0g/portion if portion > 100g).
  - Sugars: Green (<= 5.0g/100g), Amber (> 5.0 and <= 22.5g/100g), Red (> 22.5g/100g OR > 27g/portion if portion > 100g).
  - Salt: Green (<= 0.3g/100g), Amber (> 0.3 and <= 1.5g/100g), Red (> 1.5g/100g OR > 1.8g/portion if portion > 100g).
- **Thresholds for Drinks**:
  - Fat: Green (<= 1.5g/100ml), Amber (> 1.5 and <= 8.75g/100ml), Red (> 8.75g/100ml OR > 10.5g/portion if portion > 150ml).
  - Saturates: Green (<= 0.75g/100ml), Amber (> 0.75 and <= 2.5g/100ml), Red (> 2.5g/100ml OR > 3.0g/portion if portion > 150ml).
  - Sugars: Green (<= 2.5g/100ml), Amber (> 2.5 and <= 11.25g/100ml), Red (> 11.25g/100ml OR > 13.5g/portion if portion > 150ml).
  - Salt: Green (<= 0.3g/100ml), Amber (> 0.3 and <= 0.75g/100ml), Red (> 0.75g/100ml OR > 0.9g/portion if portion > 150ml).
- **Healthiness Metric in Literature**: "Any red" ($\ge 1$ Red indicator) vs "No red", and total Red count ($0-4$).

### 1.4 UK Calorie, Salt, and Sugar Reduction Programmes & SDIL
- **Soft Drinks Industry Levy (SDIL)**:
  - < 5.0 g total sugar / 100 ml: Exempt.
  - 5.0 to < 8.0 g total sugar / 100 ml: Lower rate (Tier 1).
  - >= 8.0 g total sugar / 100 ml: Higher rate (Tier 2).
- **Salt Reduction Targets (PHE / OHID 2024)**:
  - Comprehensive category average and maximum salt targets (g/100g) for pre-packed retail and out-of-home (OOH) dish/meal targets.
- **Sugar Reduction Programme (PHE / OHID)**:
  - 20% reduction targets across 10 top sugar categories (cakes, biscuits, chocolate confectionery, sugar confectionery, ice creams, puddings, yogurts, morning goods, breakfast cereals, sweet spreads) plus maximum portion caps.
- **Calorie Reduction Programme (PHE / OHID)**:
  - 400-600-600 meal guideline (400 kcal breakfast, 600 kcal lunch, 600 kcal dinner).
  - Category single-serve caps (e.g., 550 kcal sandwiches, 550/600 kcal main meals, 250 kcal sides/starters, 1000 kcal single-serve pizzas).

### 1.5 Methodological Synthesis from Tan et al. (2025)
- **Reference**: Tan M, Pham H, Pombo-Rodrigues S, Hashem KM, Shiach A, Barakat NA (2025). *Nutritional composition and healthiness of out-of-home food and drink: cross-sectional and retrospective longitudinal analyses of best-selling menu items in the UK, 2021-2023/24*. Proceedings of the Nutrition Society, 84(OCE3), E208.
- **Key Finding**: The NPM alone yields the most lenient healthiness assessment for out-of-home menu items because it is based strictly per 100g and does not penalize excessive portion sizes. Combining NPM with per-serving maximum thresholds (or MTL portion caps) provides a much more robust assessment of dietary quality in the out-of-home sector.
