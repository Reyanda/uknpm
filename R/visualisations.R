#' ATNi and Vellum Scientific Plotting Themes and Palettes
#'
#' Consistent visual styling inspired by the Access to Nutrition Initiative (ATNi)
#' public reporting language and the Vellum academic publication geometry.
#'
#' @name visual_styles
#' @keywords internal
NULL

if (getRversion() >= "2.15.1") utils::globalVariables(c(".data"))

# ATNi Public Style Palette
atni_pal <- list(
  black = "#000000",
  white = "#FFFFFF",
  neutral_light = "#E4E4E4",
  neutral_mid = "#787878",
  neutral_pale = "#F2F2F2",
  purple = "#9658AD",
  blue = "#0099D9",
  green = "#3F783F",
  yellow = "#ECC441",
  orange = "#EE952F",
  red = "#B63735",
  pink = "#FC7984"
)

# Vellum Academic Publication Theme
theme_uknpm_vellum <- function(base_size = 11, base_family = "sans") {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        axis.line = ggplot2::element_line(colour = "#000000", linewidth = 0.5),
        axis.ticks = ggplot2::element_line(colour = "#000000", linewidth = 0.4),
        axis.title = ggplot2::element_text(colour = "#000000", face = "bold", size = ggplot2::rel(0.95)),
        axis.text = ggplot2::element_text(colour = "#000000", size = ggplot2::rel(0.85)),
        panel.grid.major.y = ggplot2::element_line(colour = "#F0F0F0", linewidth = 0.3),
        panel.grid.major.x = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        legend.title = ggplot2::element_text(colour = "#000000", face = "bold", size = ggplot2::rel(0.9)),
        legend.text = ggplot2::element_text(colour = "#000000", size = ggplot2::rel(0.85)),
        legend.background = ggplot2::element_blank(),
        legend.position = "bottom",
        strip.background = ggplot2::element_rect(fill = "#F8F8F8", colour = "#000000", linewidth = 0.4),
        strip.text = ggplot2::element_text(colour = "#000000", face = "bold", size = ggplot2::rel(0.9))
      )
  }
}

# ATNi Style Theme
theme_uknpm_atni <- function(base_size = 11, base_family = "sans") {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        axis.line = ggplot2::element_line(colour = "#787878", linewidth = 0.4),
        axis.ticks = ggplot2::element_blank(),
        axis.title = ggplot2::element_text(colour = "#000000", face = "bold", size = ggplot2::rel(0.95)),
        axis.text = ggplot2::element_text(colour = "#000000", size = ggplot2::rel(0.85)),
        panel.grid.major.x = ggplot2::element_line(colour = "#E4E4E4", linewidth = 0.3),
        panel.grid.major.y = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        legend.title = ggplot2::element_text(colour = "#000000", face = "bold", size = ggplot2::rel(0.9)),
        legend.text = ggplot2::element_text(colour = "#000000", size = ggplot2::rel(0.85)),
        legend.position = "bottom"
      )
  }
}

#' Plot Healthiness Comparison Across Candidate Assessment Approaches
#'
#' Generates a publication-grade comparative horizontal bar chart illustrating
#' the percentage of products classified as healthy versus less healthy across
#' candidate UK nutritional assessment frameworks (reproducing the comparative
#' reporting format of Tan et al., 2025 and ATNi product portfolio audits).
#'
#' @param assessment_df A data frame returned by \code{\link{assess_healthiness}}
#'   or \code{\link{summarise_healthiness}}.
#' @param style Visual theme style: \code{"atni"} (Access to Nutrition Initiative
#'   editorial palette with ATNi blue and orange) or \code{"vellum"} (high-contrast
#'   academic publication styling). Default is \code{"atni"}.
#'
#' @return A \code{ggplot2} plot object.
#'
#' @references
#' Tan M, Pham H, Pombo-Rodrigues S, et al. (2025). Nutritional composition and healthiness of out-of-home food and drink.
#' \emph{Proceedings of the Nutrition Society}, 84(OCE3), E208.
#'
#' Access to Nutrition Initiative (2024). \emph{Global Access to Nutrition Index: Research and Scoring Methodology}.
#'
#' @examples
#' data("sample_ooh_menu")
#' assessment <- assess_healthiness(sample_ooh_menu)
#' plot_healthiness_comparison(assessment, style = "atni")
#'
#' @export
plot_healthiness_comparison <- function(assessment_df, style = c("atni", "vellum")) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for plotting.")
  }
  style <- match.arg(style)

  # Check if input is from assess_healthiness or summarise_healthiness
  if (!("approach" %in% names(assessment_df))) {
    summary_df <- summarise_healthiness(assessment_df)
  } else {
    summary_df <- assessment_df
  }

  # Build long format for stacked horizontal bar plot
  approaches <- rep(summary_df$approach, 2)
  status <- c(rep("Healthier", nrow(summary_df)), rep("Less Healthy", nrow(summary_df)))
  pct <- c(summary_df$pct_healthy, summary_df$pct_less_healthy)
  counts <- c(summary_df$n_healthy, summary_df$n_less_healthy)
  labels <- sprintf("%.1f%% (%d)", pct, counts)

  plot_data <- data.frame(
    approach = factor(approaches, levels = rev(unique(summary_df$approach))),
    status = factor(status, levels = c("Less Healthy", "Healthier")),
    percentage = pct,
    count = counts,
    label = labels,
    stringsAsFactors = FALSE
  )

  # Colors
  if (style == "atni") {
    fill_colors <- c("Healthier" = atni_pal$blue, "Less Healthy" = atni_pal$orange)
    thm <- theme_uknpm_atni()
  } else {
    fill_colors <- c("Healthier" = "#3F783F", "Less Healthy" = "#B63735")
    thm <- theme_uknpm_vellum()
  }

  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$approach, y = .data$percentage, fill = .data$status)) +
    ggplot2::geom_col(position = ggplot2::position_fill(reverse = TRUE), width = 0.65, colour = "#FFFFFF", linewidth = 0.5) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = function(x) paste0(x * 100, "%"), expand = c(0, 0, 0.05, 0)) +
    ggplot2::scale_fill_manual(values = fill_colors, name = "Classification") +
    ggplot2::labs(x = NULL, y = "Proportion of Items") +
    thm

  p
}

#' Plot Multiple Traffic Light (MTL) Nutrient Profile Breakdown
#'
#' Displays the distribution of Front-of-Pack Traffic Light ratings
#' (Green / Amber / Red) across the four core nutrients (Fat, Saturated Fat,
#' Total Sugars, and Salt) for an evaluated food or menu dataset.
#'
#' @param assessment_df A data frame returned by \code{\link{assess_healthiness}}
#'   or containing columns \code{mtl_fat}, \code{mtl_sat_fat}, \code{mtl_sugars}, \code{mtl_salt}.
#' @param style Visual theme style: \code{"atni"} or \code{"vellum"}.
#'
#' @return A \code{ggplot2} plot object.
#'
#' @examples
#' data("sample_ooh_menu")
#' assessment <- assess_healthiness(sample_ooh_menu)
#' plot_mtl_profile(assessment)
#'
#' @export
plot_mtl_profile <- function(assessment_df, style = c("atni", "vellum")) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for plotting.")
  }
  style <- match.arg(style)

  nutrients <- c("Total Fat", "Saturated Fat", "Total Sugars", "Salt")
  cols <- c("mtl_fat", "mtl_sat_fat", "mtl_sugars", "mtl_salt")

  rows_list <- list()
  for (k in seq_along(nutrients)) {
    col_name <- cols[k]
    if (col_name %in% names(assessment_df)) {
      vals <- assessment_df[[col_name]]
      tbl <- table(factor(vals, levels = c("Green", "Amber", "Red")))
      tot <- length(vals)
      rows_list[[k]] <- data.frame(
        nutrient = nutrients[k],
        colour = names(tbl),
        count = as.numeric(tbl),
        pct = as.numeric(tbl) / tot * 100,
        stringsAsFactors = FALSE
      )
    }
  }

  df_plot <- do.call(rbind, rows_list)
  df_plot$nutrient <- factor(df_plot$nutrient, levels = rev(nutrients))
  df_plot$colour <- factor(df_plot$colour, levels = c("Red", "Amber", "Green"))

  # Official UK Traffic Light colours
  tl_colors <- c("Green" = "#3F783F", "Amber" = "#ECC441", "Red" = "#B63735")

  thm <- if (style == "atni") theme_uknpm_atni() else theme_uknpm_vellum()

  p <- ggplot2::ggplot(df_plot, ggplot2::aes(x = .data$nutrient, y = .data$pct, fill = .data$colour)) +
    ggplot2::geom_col(position = "fill", width = 0.6, colour = "#FFFFFF", linewidth = 0.5) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = function(x) paste0(x * 100, "%"), expand = c(0, 0, 0.05, 0)) +
    ggplot2::scale_fill_manual(values = tl_colors, name = "Traffic Light") +
    ggplot2::labs(x = NULL, y = "Proportion of Items") +
    thm

  p
}

#' Plot NPM Score Scatter and Statutory Cutoff Boundaries
#'
#' Displays product distribution across Total 'A' points (negative nutrients)
#' versus Total 'C' points (positive nutrients), highlighting statutory
#' HFSS decision thresholds (\eqn{\text{Score} \ge 4} for food, \eqn{\ge 1} for drinks).
#'
#' @param data_or_assessment A data frame from \code{\link{assess_healthiness}}
#'   or nutritional dataset.
#' @param style Visual theme style: \code{"atni"} or \code{"vellum"}.
#'
#' @return A \code{ggplot2} plot object.
#'
#' @examples
#' data("sample_ooh_menu")
#' assessment <- assess_healthiness(sample_ooh_menu)
#' plot_npm_scatter(assessment)
#'
#' @export
plot_npm_scatter <- function(data_or_assessment, style = c("atni", "vellum")) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for plotting.")
  }
  style <- match.arg(style)

  df <- data_or_assessment
  if (!("points_a" %in% names(df))) {
    npm_calc <- calculate_npm(
      energy_kj = df$energy_kj,
      energy_kcal = df$energy_kcal,
      sat_fat_g = df$sat_fat_g,
      sugars_g = df$sugars_g,
      salt_g = df$salt_g,
      sodium_mg = df$sodium_mg,
      fvns_pct = df$fvns_pct,
      fibre_g = df$fibre_g,
      protein_g = df$protein_g,
      is_drink = df$is_drink
    )
    df$points_a <- npm_calc$points_a
    df$points_c <- npm_calc$points_c
    df$npm_score <- npm_calc$npm_score
    df$npm_healthiness <- npm_calc$healthiness
  }

  thm <- if (style == "atni") theme_uknpm_atni() else theme_uknpm_vellum()
  point_colors <- if (style == "atni") {
    c("healthier" = atni_pal$blue, "less healthy" = atni_pal$red)
  } else {
    c("healthier" = "#3F783F", "less healthy" = "#B63735")
  }

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$points_c, y = .data$points_a, colour = .data$npm_healthiness)) +
    ggplot2::geom_abline(intercept = 4, slope = 1, linetype = "dashed", colour = "#787878", linewidth = 0.6) +
    ggplot2::geom_point(size = 3, alpha = 0.85) +
    ggplot2::scale_colour_manual(values = point_colors, name = "Classification") +
    ggplot2::scale_x_continuous(limits = c(0, 15), breaks = seq(0, 15, 3)) +
    ggplot2::scale_y_continuous(limits = c(0, 40), breaks = seq(0, 40, 5)) +
    ggplot2::labs(
      x = "Total 'C' Points (Beneficial: FVNS, Fibre, Protein)",
      y = "Total 'A' Points (Limiting: Energy, Sat Fat, Sugar, Sodium/Salt)"
    ) +
    ggplot2::annotate(
      "text", x = 11, y = 14, label = "Food Cutoff (A - C = 4)",
      angle = 32, colour = "#787878", size = 3.2, fontface = "italic"
    ) +
    thm

  p
}

#' Generate UK Nutrient Profile Model Scoring Decision Flowchart
#'
#' Generates the complete step-by-step decision algorithm flowchart for the UK
#' Nutrient Profile Model (DHSC 2011 & 2018), displaying nutrient accumulation,
#' the protein cap conditional branch, score subtraction, and the food vs drink
#' statutory classification thresholds.
#'
#' @param format Format to generate: \code{"mermaid"} (returns Markdown Mermaid diagram string)
#'   or \code{"ggplot"} (draws a publication-grade flow diagram). Default is \code{"mermaid"}.
#'
#' @return A character string of Mermaid diagram syntax (if \code{format = "mermaid"}),
#'   or a \code{ggplot2} plot object (if \code{format = "ggplot"}).
#'
#' @export
plot_npm_flowchart <- function(format = c("mermaid", "ggplot")) {
  format <- match.arg(format)

  if (format == "mermaid") {
    chart <- paste(
      "flowchart TD",
      "    classDef inputNode fill:#F2F2F2,stroke:#787878,stroke-width:1.5px,color:#000000;",
      "    classDef processNode fill:#EBF4FA,stroke:#0099D9,stroke-width:1.5px,color:#000000;",
      "    classDef decisionNode fill:#FEF9E7,stroke:#EE952F,stroke-width:1.5px,color:#000000;",
      "    classDef healthyNode fill:#EAF2EA,stroke:#3F783F,stroke-width:2px,color:#000000;",
      "    classDef unhealthyNode fill:#FBEBEB,stroke:#B63735,stroke-width:2px,color:#000000;",
      "",
      "    A1[\"Product Nutrition per 100g<br/>(Energy, Sat Fat, Sugars, Sodium/Salt)\"]:::inputNode --> B1[\"Step 1: Calculate 'A' Points<br/>(0-10 each, Max = 40)\"]:::processNode",
      "    A2[\"Product Beneficial Components<br/>(% FVNS, Fibre, Protein)\"]:::inputNode --> B2[\"Step 2: Calculate 'C' Points<br/>(FVNS: 0-5, Fibre: 0-5, Protein: 0-5)\"]:::processNode",
      "",
      "    B1 --> D1{\"Are 'A' Points &ge; 11?\"}:::decisionNode",
      "    D1 -- \"No ('A' &lt; 11)\" --> C1[\"Protein Points Allowed<br/>C = FVNS + Fibre + Protein\"]:::processNode",
      "    D1 -- \"Yes ('A' &ge; 11)\" --> D2{\"FVNS Points = 5<br/>(or Cheese Exception)?\"}:::decisionNode",
      "",
      "    D2 -- \"Yes (FVNS &gt; 80%)\" --> C1",
      "    D2 -- \"No (FVNS &le; 80%)\" --> C2[\"Protein Points Capped to 0<br/>C = FVNS + Fibre only\"]:::processNode",
      "",
      "    B2 -.-> C1",
      "    B2 -.-> C2",
      "",
      "    C1 --> F1[\"Step 3: Calculate Final Score<br/>Score = Total 'A' - Total 'C'\"]:::processNode",
      "    C2 --> F1",
      "",
      "    F1 --> D3{\"Product Type?\"}:::decisionNode",
      "    D3 -- \"Food\" --> D4{\"Score &ge; 4?\"}:::decisionNode",
      "    D3 -- \"Drink\" --> D5{\"Score &ge; 1?\"}:::decisionNode",
      "",
      "    D4 -- \"Yes\" --> H1[\"Less Healthy (HFSS)<br/>Subject to advertising & placement restrictions\"]:::unhealthyNode",
      "    D4 -- \"No\" --> H2[\"Healthier<br/>Permitted for promotion & advertising\"]:::healthyNode",
      "",
      "    D5 -- \"Yes\" --> H1",
      "    D5 -- \"No\" --> H2",
      sep = "\n"
    )
    return(chart)
  }

  # ggplot fallback
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for ggplot format.")
  }

  boxes <- data.frame(
    xmin = c(1, 1, 4.5, 4.5, 8, 8),
    xmax = c(3.5, 3.5, 7, 7, 10.5, 10.5),
    ymin = c(7, 3, 7, 3, 7, 3),
    ymax = c(9, 5, 9, 5, 9, 5),
    label = c(
      "1. 'A' Nutrients\nEnergy, Sat Fat,\nSugars, Sodium (0-40)",
      "2. 'C' Nutrients\nFVNS, Fibre,\nProtein (0-15)",
      "3. Protein Cap Rule\nIf A >= 11 and FVNS < 5,\nProtein = 0",
      "4. Final Score\nScore = Total A - Total C",
      "5. Food Classification\nScore >= 4: HFSS\nScore < 4: Healthier",
      "6. Drink Classification\nScore >= 1: HFSS\nScore < 1: Healthier"
    ),
    type = c("A", "C", "Rule", "Score", "Result", "Result")
  )

  p <- ggplot2::ggplot() +
    ggplot2::geom_rect(
      data = boxes,
      ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax, ymin = .data$ymin, ymax = .data$ymax),
      fill = "#F8F8F8", colour = "#000000", linewidth = 0.5
    ) +
    ggplot2::geom_text(
      data = boxes,
      ggplot2::aes(x = (.data$xmin + .data$xmax) / 2, y = (.data$ymin + .data$ymax) / 2, label = .data$label),
      size = 3.2, fontface = "bold"
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(x = 3.5, xend = 4.5, y = 8, yend = 8),
      arrow = ggplot2::arrow(length = ggplot2::unit(0.2, "cm")), linewidth = 0.6
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(x = 5.75, xend = 5.75, y = 7, yend = 5),
      arrow = ggplot2::arrow(length = ggplot2::unit(0.2, "cm")), linewidth = 0.6
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(x = 7, xend = 8, y = 4, yend = 4),
      arrow = ggplot2::arrow(length = ggplot2::unit(0.2, "cm")), linewidth = 0.6
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(x = 7, xend = 8, y = 4, yend = 8),
      arrow = ggplot2::arrow(length = ggplot2::unit(0.2, "cm")), linewidth = 0.6
    ) +
    ggplot2::coord_cartesian(xlim = c(0.5, 11), ylim = c(2, 10)) +
    ggplot2::theme_void()

  p
}
