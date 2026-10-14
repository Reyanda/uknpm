# uknpm Interactive Healthiness Explorer
# Apple-inspired interface for UK food and beverage healthiness profiling

library(shiny)
library(ggplot2)
if (requireNamespace("DT", quietly = TRUE)) {
  library(DT)
}

# Ensure uknpm is available (either loaded from package or local files)
if (!requireNamespace("uknpm", quietly = TRUE)) {
  # If running in development source tree, load all R scripts
  pkg_r_files <- list.files("../../R", pattern = "\\.R$", full.names = TRUE)
  if (length(pkg_r_files) > 0) {
    invisible(lapply(pkg_r_files, source))
  }
} else {
  library(uknpm)
}

ui <- fluidPage(
  title = "UK Nutrient Profile Model & Healthiness Explorer",
  theme = bslib::bs_theme(version = 5, bg = "#f5f5f7", fg = "#1d1d1f", primary = "#0071e3"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "apple-style.css"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1, shrink-to-fit=no")
  ),

  # Header with frosted glass effect
  tags$header(
    class = "apple-header",
    div(
      class = "apple-header-title",
      div(class = "apple-logo-badge", "UK"),
      div(
        class = "apple-header-text",
        h1("Nutrient Profile Model & Healthiness Explorer"),
        p("Statutory UK NPM (2004/2005 & 2018), Multiple Traffic Lights, and Policy Reduction Targets")
      )
    ),
    div(
      class = "apple-header-badge",
      "uknpm v0.1.0"
    )
  ),

  # Main Content Container
  div(
    class = "apple-container",

    # Navigation Pills (Segmented control)
    tabsetPanel(
      id = "main_nav",
      type = "pills",

      # TAB 1: SINGLE PRODUCT PROFILER
      tabPanel(
        title = "Single Item Profiler",
        br(),
        # Preset Quick Pick Pills
        div(
          class = "apple-card",
          div(
            class = "apple-card-header",
            div(
              h3(class = "apple-card-title", "Quick Presets"),
              p(class = "apple-card-subtitle", "Load official DHSC technical guidance worked examples and restaurant benchmark items")
            )
          ),
          div(
            class = "preset-pills-row",
            actionButton("preset_fromage", "Fruit Fromage Frais (Ex. 1)", class = "btn-preset"),
            actionButton("preset_icecream", "Vanilla Ice Cream (Ex. 2)", class = "btn-preset"),
            actionButton("preset_soup", "Tomato Cup Soup (Ex. 4)", class = "btn-preset"),
            actionButton("preset_cereal_bar", "Dried Fruit Cereal Bar (Ex. 5)", class = "btn-preset"),
            actionButton("preset_burger", "Bacon Double Cheeseburger (OOH Menu)", class = "btn-preset"),
            actionButton("preset_cola", "Regular Cola Drink (SDIL Tier 2)", class = "btn-preset")
          )
        ),

        fluidRow(
          # Inputs Column
          column(
            width = 5,
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "Nutrition Composition (per 100g / 100ml)")
              ),

              fluidRow(
                column(6, selectInput("item_type", "Product Type", choices = c("Food" = "food", "Drink" = "drink"), selected = "food")),
                column(6, selectInput("npm_version", "Model Version", choices = c("2004/2005 (Statutory)" = "2004_2005", "2018 (Consultation)" = "2018"), selected = "2004_2005"))
              ),

              fluidRow(
                column(6, numericInput("energy_kj", "Energy (kJ)", value = 459, min = 0, max = 4000, step = 10)),
                column(6, numericInput("portion_g", "Portion Size (g / ml)", value = 125, min = 1, max = 1500, step = 5))
              ),

              fluidRow(
                column(6, numericInput("fat_g", "Total Fat (g)", value = 2.5, min = 0, max = 100, step = 0.1)),
                column(6, numericInput("sat_fat_g", "Saturated Fat (g)", value = 1.8, min = 0, max = 100, step = 0.1))
              ),

              fluidRow(
                column(6, numericInput("sugars_g", "Total Sugars (g)", value = 13.4, min = 0, max = 100, step = 0.1)),
                column(6, numericInput("salt_g", "Salt (g)", value = 0.10, min = 0, max = 30, step = 0.05))
              ),

              fluidRow(
                column(6, numericInput("fvns_pct", "FVNS Content (%)", value = 8, min = 0, max = 100, step = 1)),
                column(6, numericInput("fibre_g", "Fibre (g)", value = 0.6, min = 0, max = 50, step = 0.1))
              ),

              fluidRow(
                column(6, numericInput("protein_g", "Protein (g)", value = 6.5, min = 0, max = 100, step = 0.1)),
                column(6, selectInput("fibre_method", "Fibre Method", choices = c("AOAC" = "aoac", "NSP" = "nsp"), selected = "aoac"))
              ),

              checkboxInput("is_cheese", "Cheese Exception (exempt from protein cap)", value = FALSE)
            )
          ),

          # Results Column
          column(
            width = 7,
            # Top Score Tile
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "Statutory Classification"),
                uiOutput("hfss_badge_ui")
              ),
              div(
                class = "apple-metrics-grid",
                div(
                  class = "apple-metric-tile",
                  span(class = "apple-metric-label", "Final NPM Score"),
                  span(class = "apple-metric-value", textOutput("npm_score_text")),
                  span(class = "apple-metric-subtext", textOutput("threshold_note_text"))
                ),
                div(
                  class = "apple-metric-tile",
                  span(class = "apple-metric-label", "Total 'A' Points"),
                  span(class = "apple-metric-value", textOutput("a_points_text")),
                  span(class = "apple-metric-subtext", "Energy, SatFat, Sugar, Sodium")
                ),
                div(
                  class = "apple-metric-tile",
                  span(class = "apple-metric-label", "Total 'C' Points"),
                  span(class = "apple-metric-value", textOutput("c_points_text")),
                  span(class = "apple-metric-subtext", textOutput("protein_status_text"))
                )
              )
            ),

            # Front-of-Pack Multiple Traffic Light (MTL) Display
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "Front-of-Pack Multiple Traffic Light (MTL) Labelling"),
                span(class = "apple-card-subtitle", "DHSC (2013/2016) per-100g and portion size thresholds")
              ),
              uiOutput("mtl_lozenges_ui")
            ),

            # Public Health Policy Targets
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "Public Health Reduction Targets & SDIL Levy"),
                span(class = "apple-card-subtitle", "OHID 2024 targets and Soft Drinks Industry Levy")
              ),
              div(
                class = "apple-metrics-grid",
                div(
                  class = "apple-metric-tile",
                  span(class = "apple-metric-label", "SDIL Levy Tier"),
                  span(class = "apple-metric-value", style = "font-size: 20px;", textOutput("sdil_tier_text")),
                  span(class = "apple-metric-subtext", textOutput("sdil_rate_text"))
                ),
                div(
                  class = "apple-metric-tile",
                  span(class = "apple-metric-label", "Portion Calorie Impact"),
                  span(class = "apple-metric-value", style = "font-size: 20px;", textOutput("portion_calories_text")),
                  span(class = "apple-metric-subtext", textOutput("calorie_guideline_text"))
                ),
                div(
                  class = "apple-metric-tile",
                  span(class = "apple-metric-label", "Portion Salt Impact"),
                  span(class = "apple-metric-value", style = "font-size: 20px;", textOutput("portion_salt_text")),
                  span(class = "apple-metric-subtext", textOutput("salt_guideline_text"))
                )
              )
            )
          )
        )
      ),

      # TAB 2: PORTFOLIO & MENU BENCHMARKING
      tabPanel(
        title = "Portfolio & Menu Benchmarking",
        br(),
        div(
          class = "apple-card",
          div(
            class = "apple-card-header",
            div(
              h3(class = "apple-card-title", "Multi-Metric Healthiness Benchmark (Tan et al., 2025)"),
              p(class = "apple-card-subtitle", "Cross-sectional comparative evaluation of best-selling out-of-home menu items across candidate frameworks")
            ),
            div(
              downloadButton("download_assessment", "Download Assessment CSV", class = "btn-apple-secondary")
            )
          ),
          div(
            class = "apple-metrics-grid",
            div(
              class = "apple-metric-tile",
              span(class = "apple-metric-label", "Total Menu Items"),
              span(class = "apple-metric-value", textOutput("menu_total_items")),
              span(class = "apple-metric-subtext", "Sample OOH Menu")
            ),
            div(
              class = "apple-metric-tile",
              span(class = "apple-metric-label", "% Less Healthy (NPM)"),
              span(class = "apple-metric-value", textOutput("menu_npm_hfss_pct")),
              span(class = "apple-metric-subtext", "Statutory 2004/2005")
            ),
            div(
              class = "apple-metric-tile",
              span(class = "apple-metric-label", "% With Red Lights (MTL)"),
              span(class = "apple-metric-value", textOutput("menu_mtl_red_pct")),
              span(class = "apple-metric-subtext", "At least 1 Red Lozenge")
            ),
            div(
              class = "apple-metric-tile",
              span(class = "apple-metric-label", "% Salt Target Exceeded"),
              span(class = "apple-metric-value", textOutput("menu_salt_exceed_pct")),
              span(class = "apple-metric-subtext", "OHID 2024 Category Targets")
            )
          )
        ),

        # Charts Section
        fluidRow(
          column(
            width = 6,
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "Candidate Approaches Comparison"),
                span(class = "apple-card-subtitle", "ATNi Editorial Style")
              ),
              plotOutput("plot_comparison", height = "380px")
            )
          ),
          column(
            width = 6,
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "MTL Traffic Light Distribution"),
                span(class = "apple-card-subtitle", "Nutrient Profile Breakdown")
              ),
              plotOutput("plot_mtl", height = "380px")
            )
          )
        ),

        fluidRow(
          column(
            width = 12,
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "NPM Total A vs Total C Points Scatter"),
                span(class = "apple-card-subtitle", "Vellum Style with Statutory Food (A-C=4) & Drink (A-C=1) Decision Lines")
              ),
              plotOutput("plot_scatter", height = "420px")
            )
          )
        ),

        # Interactive Table
        div(
          class = "apple-card",
          div(
            class = "apple-card-header",
            h3(class = "apple-card-title", "Complete Portfolio Assessment Ledger"),
            span(class = "apple-card-subtitle", "Item-level classification across all candidate frameworks")
          ),
          DTOutput("menu_table")
        )
      ),

      # TAB 3: METHODOLOGY & STATUTORY THRESHOLDS
      tabPanel(
        title = "Statutory Standards & Flowchart",
        br(),
        div(
          class = "apple-card",
          div(
            class = "apple-card-header",
            h3(class = "apple-card-title", "Statutory UK NPM Decision Architecture"),
            span(class = "apple-card-subtitle", "Department of Health and Social Care scoring pipeline")
          ),
          plotOutput("plot_flowchart", height = "480px")
        ),
        fluidRow(
          column(
            width = 6,
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "OHID 2024 Salt Reduction Category Targets"),
                span(class = "apple-card-subtitle", "Sales-weighted average & maximum limits (g salt / 100g)")
              ),
              DTOutput("salt_targets_table")
            )
          ),
          column(
            width = 6,
            div(
              class = "apple-card",
              div(
                class = "apple-card-header",
                h3(class = "apple-card-title", "OHID Calorie Reduction Guidelines"),
                span(class = "apple-card-subtitle", "Single-serve category caps & meal campaign targets")
              ),
              DTOutput("calorie_targets_table")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Preset handlers
  observeEvent(input$preset_fromage, {
    updateSelectInput(session, "item_type", selected = "food")
    updateSelectInput(session, "npm_version", selected = "2004_2005")
    updateNumericInput(session, "energy_kj", value = 459)
    updateNumericInput(session, "portion_g", value = 100)
    updateNumericInput(session, "fat_g", value = 2.5)
    updateNumericInput(session, "sat_fat_g", value = 1.8)
    updateNumericInput(session, "sugars_g", value = 13.4)
    updateNumericInput(session, "salt_g", value = 0.05)
    updateNumericInput(session, "fvns_pct", value = 8)
    updateNumericInput(session, "fibre_g", value = 0.6)
    updateNumericInput(session, "protein_g", value = 6.5)
    updateCheckboxInput(session, "is_cheese", value = FALSE)
  })

  observeEvent(input$preset_icecream, {
    updateSelectInput(session, "item_type", selected = "food")
    updateSelectInput(session, "npm_version", selected = "2004_2005")
    updateNumericInput(session, "energy_kj", value = 741)
    updateNumericInput(session, "portion_g", value = 75)
    updateNumericInput(session, "fat_g", value = 10.2)
    updateNumericInput(session, "sat_fat_g", value = 6.1)
    updateNumericInput(session, "sugars_g", value = 18.7)
    updateNumericInput(session, "salt_g", value = 0.15)
    updateNumericInput(session, "fvns_pct", value = 0)
    updateNumericInput(session, "fibre_g", value = 0.0)
    updateNumericInput(session, "protein_g", value = 3.6)
    updateCheckboxInput(session, "is_cheese", value = FALSE)
  })

  observeEvent(input$preset_soup, {
    updateSelectInput(session, "item_type", selected = "food")
    updateSelectInput(session, "npm_version", selected = "2004_2005")
    updateNumericInput(session, "energy_kj", value = 155)
    updateNumericInput(session, "portion_g", value = 250)
    updateNumericInput(session, "fat_g", value = 0.8)
    updateNumericInput(session, "sat_fat_g", value = 0.4)
    updateNumericInput(session, "sugars_g", value = 3.6)
    updateNumericInput(session, "salt_g", value = 1.18)
    updateNumericInput(session, "fvns_pct", value = 0)
    updateNumericInput(session, "fibre_g", value = 0.2)
    updateNumericInput(session, "protein_g", value = 0.3)
    updateCheckboxInput(session, "is_cheese", value = FALSE)
  })

  observeEvent(input$preset_cereal_bar, {
    updateSelectInput(session, "item_type", selected = "food")
    updateSelectInput(session, "npm_version", selected = "2004_2005")
    updateNumericInput(session, "energy_kj", value = 1485)
    updateNumericInput(session, "portion_g", value = 35)
    updateNumericInput(session, "fat_g", value = 6.5)
    updateNumericInput(session, "sat_fat_g", value = 1.2)
    updateNumericInput(session, "sugars_g", value = 24.5)
    updateNumericInput(session, "salt_g", value = 0.35)
    updateNumericInput(session, "fvns_pct", value = 46.2)
    updateNumericInput(session, "fibre_g", value = 3.8)
    updateNumericInput(session, "protein_g", value = 4.2)
    updateCheckboxInput(session, "is_cheese", value = FALSE)
  })

  observeEvent(input$preset_burger, {
    updateSelectInput(session, "item_type", selected = "food")
    updateSelectInput(session, "npm_version", selected = "2004_2005")
    updateNumericInput(session, "energy_kj", value = 1120)
    updateNumericInput(session, "portion_g", value = 210)
    updateNumericInput(session, "fat_g", value = 16.0)
    updateNumericInput(session, "sat_fat_g", value = 7.5)
    updateNumericInput(session, "sugars_g", value = 4.8)
    updateNumericInput(session, "salt_g", value = 2.10)
    updateNumericInput(session, "fvns_pct", value = 5)
    updateNumericInput(session, "fibre_g", value = 1.8)
    updateNumericInput(session, "protein_g", value = 18.5)
    updateCheckboxInput(session, "is_cheese", value = FALSE)
  })

  observeEvent(input$preset_cola, {
    updateSelectInput(session, "item_type", selected = "drink")
    updateSelectInput(session, "npm_version", selected = "2004_2005")
    updateNumericInput(session, "energy_kj", value = 180)
    updateNumericInput(session, "portion_g", value = 330)
    updateNumericInput(session, "fat_g", value = 0.0)
    updateNumericInput(session, "sat_fat_g", value = 0.0)
    updateNumericInput(session, "sugars_g", value = 10.6)
    updateNumericInput(session, "salt_g", value = 0.0)
    updateNumericInput(session, "fvns_pct", value = 0)
    updateNumericInput(session, "fibre_g", value = 0.0)
    updateNumericInput(session, "protein_g", value = 0.0)
    updateCheckboxInput(session, "is_cheese", value = FALSE)
  })

  # Reactive single item scoring
  current_npm <- reactive({
    sodium_mg <- (input$salt_g / 2.5) * 1000
    is_drk <- input$item_type == "drink"
    model_choice <- if (input$npm_version == "2018") "2018" else "2004_2005"

    uknpm::calculate_npm(
      energy_kj = input$energy_kj,
      sat_fat_g = input$sat_fat_g,
      sugars_g = input$sugars_g,
      sodium_mg = sodium_mg,
      fvns_pct = input$fvns_pct,
      fibre_g = input$fibre_g,
      protein_g = input$protein_g,
      is_drink = is_drk,
      fibre_method = input$fibre_method,
      model = model_choice,
      is_cheese = input$is_cheese
    )
  })

  current_mtl <- reactive({
    is_drk <- input$item_type == "drink"
    uknpm::calculate_mtl(
      fat_g = input$fat_g,
      sat_fat_g = input$sat_fat_g,
      sugars_g = input$sugars_g,
      salt_g = input$salt_g,
      portion_g = input$portion_g,
      is_drink = is_drk
    )
  })

  # Single item outputs
  output$hfss_badge_ui <- renderUI({
    res <- current_npm()
    if (isTRUE(res$less_healthy[1])) {
      span(class = "badge-hfss", "● HFSS / Less Healthy (Advertising & Placement Restrictions Apply)")
    } else {
      span(class = "badge-healthy", "● Non-HFSS / Healthy (Compliant)")
    }
  })

  output$npm_score_text <- renderText({
    res <- current_npm()
    as.character(res$npm_score[1])
  })

  output$threshold_note_text <- renderText({
    if (input$item_type == "food") "Cutoff: Score ≥ 4 is HFSS" else "Cutoff: Score ≥ 1 is HFSS"
  })

  output$a_points_text <- renderText({
    res <- current_npm()
    paste0(res$points_a[1], " pts")
  })

  output$c_points_text <- renderText({
    res <- current_npm()
    paste0(res$points_c[1], " pts")
  })

  output$protein_status_text <- renderText({
    res <- current_npm()
    if (isTRUE(res$protein_allowed[1])) "Protein points included" else "Protein capped (A ≥ 11 and FVNS < 5)"
  })

  # MTL lozenges UI
  output$mtl_lozenges_ui <- renderUI({
    m <- current_mtl()
    portion <- input$portion_g
    cal_portion <- round((input$energy_kj / 4.184) * (portion / 100))
    fat_p <- round(input$fat_g * (portion / 100), 1)
    sat_p <- round(input$sat_fat_g * (portion / 100), 1)
    sug_p <- round(input$sugars_g * (portion / 100), 1)
    salt_p <- round(input$salt_g * (portion / 100), 2)

    get_class <- function(col) {
      tolower(col)
    }

    div(
      class = "mtl-lozenge-container",
      # Energy lozenge (white/neutral)
      div(
        class = "mtl-lozenge", style = "background: #ffffff; color: #1d1d1f;",
        div(class = "mtl-lozenge-nutrient", "Energy"),
        div(class = "mtl-lozenge-amount", cal_portion),
        div(class = "mtl-lozenge-unit", "kcal / portion"),
        div(class = "mtl-lozenge-traffic", style = "background: #e5e5ea; color: #1d1d1f;", paste0(round((cal_portion / 2000) * 100), "% RI"))
      ),
      # Fat lozenge
      div(
        class = paste("mtl-lozenge", paste0("mtl-", get_class(m$fat_color[1]))),
        div(class = "mtl-lozenge-nutrient", "Fat"),
        div(class = "mtl-lozenge-amount", paste0(fat_p, "g")),
        div(class = "mtl-lozenge-unit", paste0(input$fat_g, "g / 100g")),
        div(class = "mtl-lozenge-traffic", toupper(m$fat_color[1]))
      ),
      # Saturates lozenge
      div(
        class = paste("mtl-lozenge", paste0("mtl-", get_class(m$sat_fat_color[1]))),
        div(class = "mtl-lozenge-nutrient", "Saturates"),
        div(class = "mtl-lozenge-amount", paste0(sat_p, "g")),
        div(class = "mtl-lozenge-unit", paste0(input$sat_fat_g, "g / 100g")),
        div(class = "mtl-lozenge-traffic", toupper(m$sat_fat_color[1]))
      ),
      # Sugars lozenge
      div(
        class = paste("mtl-lozenge", paste0("mtl-", get_class(m$sugars_color[1]))),
        div(class = "mtl-lozenge-nutrient", "Sugars"),
        div(class = "mtl-lozenge-amount", paste0(sug_p, "g")),
        div(class = "mtl-lozenge-unit", paste0(input$sugars_g, "g / 100g")),
        div(class = "mtl-lozenge-traffic", toupper(m$sugars_color[1]))
      ),
      # Salt lozenge
      div(
        class = paste("mtl-lozenge", paste0("mtl-", get_class(m$salt_color[1]))),
        div(class = "mtl-lozenge-nutrient", "Salt"),
        div(class = "mtl-lozenge-amount", paste0(salt_p, "g")),
        div(class = "mtl-lozenge-unit", paste0(input$salt_g, "g / 100g")),
        div(class = "mtl-lozenge-traffic", toupper(m$salt_color[1]))
      )
    )
  })

  # Policy metrics
  output$sdil_tier_text <- renderText({
    if (input$item_type != "drink") {
      "Exempt (Food)"
    } else {
      sd <- uknpm::calculate_sdil(input$sugars_g)
      paste0(sd$sdil_tier[1], " (", input$sugars_g, "g/100ml)")
    }
  })

  output$sdil_rate_text <- renderText({
    if (input$item_type != "drink") {
      "Not applicable to solid food"
    } else {
      sd <- uknpm::calculate_sdil(input$sugars_g)
      paste0("Rate: £", sprintf("%.2f", sd$levy_rate_per_litre[1]), " / litre")
    }
  })

  output$portion_calories_text <- renderText({
    kcal <- round((input$energy_kj / 4.184) * (input$portion_g / 100))
    paste0(kcal, " kcal")
  })

  output$calorie_guideline_text <- renderText({
    kcal <- (input$energy_kj / 4.184) * (input$portion_g / 100)
    if (kcal > 600) {
      "> 600 kcal (Exceeds lunch/dinner cap)"
    } else if (kcal > 400) {
      "400–600 kcal (Within lunch/dinner cap)"
    } else {
      "≤ 400 kcal (Within breakfast guideline)"
    }
  })

  output$portion_salt_text <- renderText({
    salt_p <- round(input$salt_g * (input$portion_g / 100), 2)
    paste0(salt_p, " g")
  })

  output$salt_guideline_text <- renderText({
    salt_p <- input$salt_g * (input$portion_g / 100)
    pct_max <- round((salt_p / 6.0) * 100)
    paste0(pct_max, "% of adult 6g daily maximum")
  })

  # TAB 2: PORTFOLIO ASSESSMENT
  menu_data <- reactive({
    uknpm::sample_ooh_menu
  })

  assessment_results <- reactive({
    uknpm::assess_healthiness(menu_data())
  })

  output$menu_total_items <- renderText({
    nrow(menu_data())
  })

  output$menu_npm_hfss_pct <- renderText({
    res <- assessment_results()
    pct <- mean(res$npm_2004_hfss, na.rm = TRUE) * 100
    paste0(round(pct, 1), "%")
  })

  output$menu_mtl_red_pct <- renderText({
    res <- assessment_results()
    pct <- mean(res$mtl_has_red, na.rm = TRUE) * 100
    paste0(round(pct, 1), "%")
  })

  output$menu_salt_exceed_pct <- renderText({
    res <- assessment_results()
    pct <- mean(res$salt_target_exceeded, na.rm = TRUE) * 100
    paste0(round(pct, 1), "%")
  })

  # Plots
  output$plot_comparison <- renderPlot({
    uknpm::plot_healthiness_comparison(assessment_results(), style = "atni")
  })

  output$plot_mtl <- renderPlot({
    uknpm::plot_mtl_profile(assessment_results(), style = "atni")
  })

  output$plot_scatter <- renderPlot({
    uknpm::plot_npm_scatter(assessment_results(), style = "vellum")
  })

  output$plot_flowchart <- renderPlot({
    uknpm::plot_npm_flowchart(format = "ggplot")
  })

  # Table
  output$menu_table <- renderDT({
    res <- assessment_results()
    df <- data.frame(
      Item = res$item_name,
      Category = res$category,
      Type = ifelse(res$is_drink, "Drink", "Food"),
      `NPM 2004 Score` = res$npm_2004_score,
      `NPM 2004 HFSS` = ifelse(res$npm_2004_hfss, "Yes (HFSS)", "No (Healthy)"),
      `MTL Fat` = res$mtl_fat,
      `MTL SatFat` = res$mtl_sat_fat,
      `MTL Sugar` = res$mtl_sugars,
      `MTL Salt` = res$mtl_salt,
      `MTL Red Count` = res$mtl_red_count,
      `Salt Target Exceeded` = ifelse(res$salt_target_exceeded, "Exceeded", "Met / OK"),
      check.names = FALSE
    )

    datatable(
      df,
      options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE),
      rownames = FALSE,
      class = "display compact"
    )
  })

  # Download Handler
  output$download_assessment <- downloadHandler(
    filename = function() {
      paste0("uknpm_portfolio_assessment_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(assessment_results(), file, row.names = FALSE)
    }
  )

  # TAB 3: Reference Tables
  output$salt_targets_table <- renderDT({
    df <- uknpm::ohid_salt_targets_2024
    datatable(df, options = list(pageLength = 8, scrollX = TRUE), rownames = FALSE)
  })

  output$calorie_targets_table <- renderDT({
    df <- uknpm::ohid_calorie_guidelines
    datatable(df, options = list(pageLength = 8, scrollX = TRUE), rownames = FALSE)
  })
}

shinyApp(ui = ui, server = server)
