# Script to build package datasets

# 1. OHID Salt Reduction Targets 2024
ohid_salt_targets_2024 <- data.frame(
  category = c(
    "Bread",
    "Morning goods",
    "Soups",
    "Ready meals",
    "Sausages",
    "Burgers",
    "Bacon",
    "Ham",
    "Cheese - Cheddar",
    "Cheese - Blue",
    "Cheese - Soft / Other",
    "Pasta sauces",
    "Pizza",
    "Potato crisps & savoury snacks",
    "Breakfast cereals",
    "Biscuits",
    "Cakes",
    "Sandwiches",
    "Out-of-home: Chips / fries portion",
    "Out-of-home: Burger dish",
    "Out-of-home: Curry dish with sides",
    "Out-of-home: Pizza dish",
    "Out-of-home: Sandwich / wrap meal"
  ),
  sector = c(
    rep("Retail / Pre-packed", 18),
    rep("Out-of-home (OOH)", 5)
  ),
  target_average_100g = c(
    0.85, 0.70, 0.53, 0.50, 1.14, 0.75, 2.45, 1.63, 1.75, 2.00, 1.20,
    0.63, 0.88, 1.05, 0.40, 0.40, 0.35, 0.75,
    NA, NA, NA, NA, NA
  ),
  target_maximum_100g = c(
    1.01, 0.88, 0.63, 0.68, 1.30, 0.90, 2.88, 2.00, 1.90, 2.20, 1.50,
    0.80, 1.00, 1.25, 0.70, 0.55, 0.45, 0.95,
    0.50, 2.20, 2.50, 2.80, 2.00
  ),
  target_unit = c(
    rep("g/100g", 18),
    rep("g/portion", 5)
  ),
  notes = c(
    rep("PHE/OHID 2024 salt reduction target", 18),
    rep("Out-of-home maximum per-serving dish target", 5)
  ),
  stringsAsFactors = FALSE
)

# 2. OHID Sugar Reduction Programme Targets
ohid_sugar_targets <- data.frame(
  category = c(
    "Biscuits",
    "Cakes",
    "Chocolate confectionery",
    "Sugar confectionery",
    "Ice cream & lollies",
    "Morning goods",
    "Puddings",
    "Yogurts & fromage frais",
    "Breakfast cereals",
    "Sweet spreads & sauces"
  ),
  target_sugars_100g = c(
    26.2, 33.7, 43.7, 50.8, 17.5, 15.3, 16.5, 11.0, 12.3, 49.3
  ),
  max_portion_cap_g = c(
    NA, NA, 30.0, 30.0, 20.0, NA, 22.0, 15.0, NA, NA
  ),
  max_portion_cap_kcal = c(
    NA, NA, 250, 250, 220, NA, 220, NA, NA, NA
  ),
  baseline_year = rep(2015, 10),
  target_year = rep(2020, 10),
  reduction_target_pct = rep(20, 10),
  stringsAsFactors = FALSE
)

# 3. OHID Calorie Reduction Programme Guidelines
ohid_calorie_guidelines <- data.frame(
  category = c(
    "Ready meals / meal centres",
    "Sandwiches / wraps / baguettes",
    "Single-serve pizzas",
    "Starters / sides / small plates",
    "Desserts / puddings",
    "General breakfast",
    "General lunch",
    "General dinner",
    "General snack"
  ),
  max_kcal_portion = c(
    600, 550, 1000, 250, 250, 400, 600, 600, 200
  ),
  benchmark_type = c(
    rep("Category Single-Serve Ceiling", 5),
    rep("400-600-600 Daily Campaign Guideline", 4)
  ),
  description = c(
    "Maximum recommended calories for a single-serve main meal / meal centre",
    "Maximum recommended calories for an on-the-go sandwich or wrap",
    "Maximum recommended calories for a complete single-serve pizza",
    "Maximum recommended calories for a side dish, starter, or small plate",
    "Maximum recommended calories for a single serving dessert or sweet pudding",
    "Recommended breakfast guide under 400-600-600 campaign",
    "Recommended lunch guide under 400-600-600 campaign",
    "Recommended dinner guide under 400-600-600 campaign",
    "Recommended daily snack allowance under 400-600-600 campaign"
  ),
  stringsAsFactors = FALSE
)

# 4. NPM Official Worked Examples (DHSC 2011 and DHSC 2018)
npm_worked_examples <- data.frame(
  example_id = c(
    "DHSC_2011_Ex1",
    "DHSC_2011_Ex2",
    "DHSC_2011_Ex3",
    "DHSC_2011_Ex4",
    "DHSC_2011_Ex5",
    "DHSC_2011_Ex6",
    "DHSC_2018_Ex1",
    "DHSC_2018_Ex4"
  ),
  product_name = c(
    "Fruit fromage frais (50g pot)",
    "Vanilla dairy ice-cream",
    "Powdered milkshake (reconstituted with semi-skimmed milk)",
    "Cup soup, tomato flavour (reconstituted with water)",
    "Fruit and nut cereal bar",
    "Raspberry and cranberry juice drink",
    "Plant-based oat dairy-alternative drink",
    "Passion fruit yoghurt drink"
  ),
  model = c(
    rep("2004_2005", 6),
    rep("2018", 2)
  ),
  is_drink = c(FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE),
  energy_kj = c(459, 741, 299, 155, 1504, 184, 189, 200),
  sat_fat_g = c(1.8, 6.1, 1.0, 0.4, 1.4, 0.0, 0.3, 0.7),
  sugars_g = c(13.4, 18.7, 8.9, 3.6, 35.7, 10.3, 4.5, 9.4),
  free_sugars_g = c(NA, NA, NA, NA, NA, NA, 4.5, 6.07),
  sodium_mg = c(0, 60, 41, 471, 0, 0, NA, NA),
  salt_g = c(0.0, 0.15, 0.10, 1.18, 0.0, 0.0, 0.1, 0.1),
  fvns_pct = c(8, 0, 0, 0, 46, 15, 0, 10),
  fibre_g = c(0.6, 0.0, 0.5, 0.2, 4.8, 0.0, 0.5, 0.0),
  fibre_method = c("aoac", "nsp", "aoac", "aoac", "aoac", "aoac", "aoac", "aoac"),
  protein_g = c(6.5, 3.6, 3.2, 0.3, 4.3, 0.1, 1.3, 3.1),
  expected_points_a = c(4, 12, 1, 5, 12, 2, 4, 6),
  expected_points_c = c(4, 0, 1, 0, 6, 0, 0, 1),
  expected_score = c(0, 12, 0, 5, 6, 2, 4, 5),
  expected_hfss = c(FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

# 5. Sample Out-of-Home (OOH) Menu Dataset (Modeled on Tan et al. 2025)
sample_ooh_menu <- data.frame(
  item_id = sprintf("OOH_%02d", 1:20),
  company_type = c(
    rep("Fast Food Burger Chain", 4),
    rep("Coffee & Sandwich Chain", 4),
    rep("Casual Dining Italian Chain", 4),
    rep("Pub Restaurant Chain", 4),
    rep("Bakery & Grab-and-Go Chain", 4)
  ),
  item_name = c(
    "Double Bacon Cheeseburger",
    "Crispy Chicken Burger",
    "Large Salted French Fries",
    "Chocolate Thick Shake",
    "Chicken Salad Sandwich",
    "Ham and Cheddar Toastie",
    "Caramel Latte (Regular)",
    "Blueberry Muffin",
    "Margherita Pizza (11-inch)",
    "Spaghetti Bolognese",
    "Garlic Bread with Mozzarella",
    "Tiramisu Dessert",
    "Beer Battered Fish and Chips",
    "Chicken Tikka Masala with Rice",
    "Onion Rings Basket",
    "Sticky Toffee Pudding",
    "Sausage Roll",
    "Vegan Sausage Roll",
    "Cheese and Onion Pastie",
    "Iced Donut"
  ),
  category = c(
    "Main meal", "Main meal", "Starter/side", "Drink",
    "Sandwiches", "Sandwiches", "Drink", "Dessert",
    "Pizza", "Main meal", "Starter/side", "Dessert",
    "Main meal", "Main meal", "Starter/side", "Dessert",
    "Main meal", "Main meal", "Main meal", "Dessert"
  ),
  is_drink = c(
    FALSE, FALSE, FALSE, TRUE,
    FALSE, FALSE, TRUE, FALSE,
    FALSE, FALSE, FALSE, FALSE,
    FALSE, FALSE, FALSE, FALSE,
    FALSE, FALSE, FALSE, FALSE
  ),
  portion_g = c(
    280, 240, 160, 400,
    210, 190, 350, 120,
    420, 450, 180, 140,
    550, 520, 150, 180,
    140, 135, 175, 90
  ),
  energy_kcal = c(
    285, 260, 310, 125,
    195, 275, 75, 390,
    240, 155, 320, 280,
    190, 165, 315, 335,
    345, 290, 310, 410
  ),
  energy_kj = c(
    1192, 1088, 1297, 523,
    816, 1151, 314, 1632,
    1004, 649, 1339, 1172,
    795, 690, 1318, 1402,
    1443, 1213, 1297, 1715
  ),
  energy_kcal_portion = c(
    798, 624, 496, 500,
    410, 523, 263, 468,
    1008, 698, 576, 392,
    1045, 858, 473, 603,
    483, 392, 543, 369
  ),
  fat_g = c(
    16.5, 12.0, 15.0, 3.5,
    6.2, 14.5, 2.5, 18.0,
    9.5, 5.8, 16.0, 14.0,
    9.0, 7.5, 17.5, 13.0,
    23.0, 18.0, 19.5, 19.0
  ),
  sat_fat_g = c(
    7.8, 2.8, 1.8, 2.2,
    1.2, 7.5, 1.6, 3.2,
    4.5, 2.2, 8.2, 8.5,
    1.5, 3.2, 2.4, 7.2,
    10.5, 7.8, 9.2, 8.5
  ),
  sugars_g = c(
    4.5, 4.0, 0.4, 18.5,
    3.2, 2.8, 9.2, 28.5,
    3.8, 3.5, 2.5, 21.0,
    0.5, 4.2, 3.5, 36.0,
    1.2, 1.5, 2.4, 26.0
  ),
  salt_g = c(
    1.45, 1.20, 0.95, 0.25,
    0.85, 1.40, 0.15, 0.65,
    1.10, 0.75, 1.35, 0.30,
    0.80, 0.90, 1.10, 0.70,
    1.60, 1.35, 1.45, 0.55
  ),
  fvns_pct = c(
    5, 4, 0, 0,
    15, 0, 0, 5,
    18, 12, 2, 0,
    0, 10, 8, 0,
    0, 0, 8, 0
  ),
  fibre_g = c(
    1.8, 1.5, 3.5, 0.5,
    2.5, 2.0, 0.0, 1.6,
    2.4, 2.2, 2.0, 1.2,
    1.8, 2.0, 2.2, 1.5,
    1.8, 2.5, 2.1, 1.4
  ),
  protein_g = c(
    17.5, 14.5, 3.8, 4.2,
    12.0, 15.5, 3.2, 5.5,
    11.2, 9.0, 8.5, 5.0,
    10.5, 9.5, 4.0, 4.2,
    10.0, 8.5, 8.8, 4.8
  ),
  stringsAsFactors = FALSE
)

# Save datasets to data/
save(ohid_salt_targets_2024, file = "data/ohid_salt_targets_2024.rda", compress = "xz")
save(ohid_sugar_targets, file = "data/ohid_sugar_targets.rda", compress = "xz")
save(ohid_calorie_guidelines, file = "data/ohid_calorie_guidelines.rda", compress = "xz")
save(npm_worked_examples, file = "data/npm_worked_examples.rda", compress = "xz")
save(sample_ooh_menu, file = "data/sample_ooh_menu.rda", compress = "xz")

cat("Successfully generated and saved all datasets to data/\n")
