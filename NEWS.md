# uknpm 0.1.0

* Initial release of the `uknpm` package for UK food and beverage healthiness assessment.
* Implemented statutory UK Nutrient Profile Model (NPM 2004/2005 / DHSC 2011 Technical Guidance) and 2018 consultation draft (`calculate_npm()`, `npm_score()`, `is_hfss()`).
* Implemented calculation of Fruit, Vegetables, Nuts and Seeds (FVNS) percentage with statutory dried multiplier (`calculate_fvns()`).
* Implemented Multiple Traffic Light (MTL) Front-of-Pack Labelling System (DHSC 2013/2016 Guidance) with per-100g/ml criteria and per-portion Red overrides (`calculate_mtl()`).
* Implemented UK Calorie, Salt, and Sugar Reduction Programme targets and Soft Drinks Industry Levy (SDIL) thresholds (`calculate_sdil()`, `check_salt_target()`, `check_sugar_target()`, `check_calorie_guideline()`).
* Implemented multi-metric integrated healthiness evaluation engine (`assess_healthiness()`, `summarise_healthiness()`) reproducing the empirical methodology of Tan et al. (2025).
* Implemented publication-grade visualization suite (`plot_healthiness_comparison()`, `plot_mtl_profile()`, `plot_npm_scatter()`, `plot_npm_flowchart()`) inspired by ATNi, Vellum, and Flowchart design doctrines.
* Built-in datasets: `npm_worked_examples`, `sample_ooh_menu`, `ohid_salt_targets_2024`, `ohid_sugar_targets`, and `ohid_calorie_guidelines`.
* Complete test suite with 141 unit tests covering all DHSC official worked examples and edge cases.
