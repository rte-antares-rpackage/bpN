#Copyright © 2016 RTE Réseau de transport d’électricité

#' @import data.table
#' @import antaresRead
#' @import antaresProcessing
#' @import dygraphs
#' @import shiny
#' @import htmltools
#' @import manipulateWidget
#' @import leaflet
#' @import leaflet.minicharts
#' @import assertthat
#' @importFrom plotly plot_ly layout config add_bars add_heatmap add_text add_trace
#' @importFrom grDevices col2rgb colorRampPalette colors gray rainbow rgb
#' @importFrom graphics plot par
#' @importFrom methods is
#' @importFrom stats density quantile lm predict
#' @importFrom utils object.size
#' @importFrom stats as.formula
#' 
globalVariables(
  c("value", "element", "mcYear", "suffix", "time", "timeId", "dt", ".", 
    "x", "y", ".id", ".initial", ".session", "FLOW LIN.", "area", "direction", 
    "flow", "formulas", "link", ".output", "J", "ROW BAL.", "change", "to",
    "wdayId", "weekId")
)

.idCols <- antaresRead:::.idCols
.timeIdToDate <- antaresRead:::.timeIdToDate
.getTimeId <- antaresRead:::.getTimeId
.mergeByRef <- antaresRead:::.mergeByRef
.checkColumns <- antaresProcessing:::.checkColumns
.checkAttrs <- antaresProcessing:::.checkAttrs

DEFAULT_CAT_COLORS <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                      "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")

# Private variables accessible only by functions from the package
pkgEnv <- antaresRead:::pkgEnv

.onLoad <- function(libname, pkgname) {
  setInteractivity("auto")
  options(antaresVizSizeGraph = 200)
}

# Generate the list of aliases for function prodStack()
#
# The definition of the variables used in aliases is stored in file 
# "GraphicalCharter.csv"
graphicalCharter <- fread(input=system.file("GraphicalCharter.csv", package = "bpNumerique2018"))

formulas <- lapply(graphicalCharter$formula, function(s) parse(text = s))
names(formulas) <- graphicalCharter$name

colors <- graphicalCharter[, rgb(red, green, blue, maxColorValue = 255)]
names(colors) <- graphicalCharter$name


needed <- graphicalCharter$Needed_Col
names(needed) <- graphicalCharter$name
needed <- strsplit(needed, ",")
# Private function that generates a production stack alias, given a list of 
# variable names. The variable names need to be present in file 
# GraphicalCharter.csv
.getProdStackAlias <- function(description = "", var = NULL, lines = NULL) {
  list(
    description = description,
    nedded_col = unique(unlist(needed[var])),
    variables = formulas[var],
    colors = unname(colors[var]),
    lines = formulas[lines],
    lineColors = unname(colors[lines]),
    lineWidth = 3
  )
}

# List of aliases for parameter "variables" in function prodStack()
#
# Each element has five elements:
# - description: A concise description of the production stack.
# - variables:   Definition of the variables to draw
# - colors:      Vector of colors with same length as "variables"
# - lines:       (optional) Definition of curves to draw on top of the stack
# - lineColors:  Vector of colors with same length as lines. Mandatory only if
#                "lines" is set
#
pkgEnv$prodStackAliases <- list(
  
  eco2mix = .getProdStackAlias(
    description = "Production stack used on Eco2mix website: 
    http://www.rte-france.com/fr/eco2mix/eco2mix-mix-energetique",
    var = c("pumpedStorage", "import/export", "bioenergy", "wind", "solar", 
            "nuclear", "hydraulic", "gas", "coal", "lignite", "oil", "other"),
    lines = c("load", "totalProduction")
  ),
  
  thermalFirst = .getProdStackAlias(
    description = "thermal first",
    var = c("pumpedStorage", "import/export", "nuclear", "lignite", "coal", "gas",
            "oil", "mixFuel", "misc. DTG", "bioenergy", "wind", "solar", 
            "hydraulicRor", "hydraulicStor")
  ),
  
  netLoad = .getProdStackAlias(
    description = "netLoad",
    var = c("pumpedStorage", "import/export", "nuclear", "lignite", "coal", "gas",
            "oil", "mixFuel", "misc. DTG", "hydraulicStor"),
    lines = c("netLoad")
  ),
  
  mustRun = .getProdStackAlias(
    description = "must-run",
    var = c("pumpedStorage", "import/export", "mustRunTotal", "thermalDispatchable",
            "hydraulicDispatchable", "renewableNoDispatchable")
  )
)

rm(graphicalCharter, formulas, colors)


# message limit size
antaresVizSizeGraphError = "Too much data, please reduce selection. If you work with hourly data, you can reduce dateRange selection. 
You can also use 'limitSizeGraph' function in R or 'Memory Controls' panel in shiny (if present) to update this."

antaresVizSizeGraphError_fr = "Trop de données,veuillez réduire votre sélection. Si vous travaillez en données horaire, vous pouvez réduire la période de visualisation. 
Il est également possible d'utiliser la fonction 'limitSizeGraph' en R ou l'onglet 'Memory Controls' dans shiny (si présent) pour changer la limite."

# language for labels
language_labels <- fread(input=system.file("language_labels.csv", package = "bpNumerique2018"), encoding = "UTF-8")

availableLanguages_labels <- colnames(language_labels)

.getLabelLanguage <- function(label, language = "en"){
  if(language %in% colnames(language_labels)){
    up_label <- language_labels[en %in% label, get(language)]
    if(length(up_label) == 0){
      up_label <- label
    }
  } else {
    up_label <- label
  }
  up_label
}

# language for columns
language_columns <- fread(input=system.file("language_columns.csv", package = "bpNumerique2018"), encoding = "UTF-8")

language_columns$en <- as.character(language_columns$en)

language_columns$fr <- as.character(language_columns$fr)
Encoding(language_columns$fr) <- "latin1"

language_columns$bp <- as.character(language_columns$bp)
Encoding(language_columns$bp) <- "latin1"

expand_language_columns <- copy(language_columns)
#add _std _min _max
language_columns[, tmp_row := 1:nrow(language_columns)]

language_columns <- language_columns[, list(en = c(en, paste0(en, c("_std", "_min", "_max"))),
                        bp = c(bp, paste0(bp, c("_std", "_min", "_max"))),
                        fr = c(fr, paste0(fr, c("_std", "_min", "_max"))),
                        keep_bp = rep(keep_bp, 4)), by = tmp_row]

language_columns[, tmp_row := NULL]


.getColumnsLanguage <- function(columns, language = "en"){
  if(language %in% colnames(language_columns)){
    ind_match <- match(columns, language_columns$en)
    up_columns <- columns
    if(any(!is.na(ind_match))){
      up_columns[which(!is.na(ind_match))] <- language_columns[[language]][ind_match[!is.na(ind_match)]]
    }
  } else {
    up_columns <- columns
  }
  up_columns
}

# map color
colorsVars <- fread(input=system.file("color.csv", package = "bpNumerique2018"))
colorsVars <- unique(colorsVars, by = "Column")
colorsVars$colors <- rgb(colorsVars$red, colorsVars$green, colorsVars$blue, maxColorValue = 255)

# expand to bp / fr name
expand_language_columns <- expand_language_columns[en %in% colorsVars$Column]

ind_match <- match(expand_language_columns$en, colorsVars$Column)
rev_ind_match <- match(colorsVars$Column, expand_language_columns$en)

col_bp <- colorsVars[Column %in% expand_language_columns$en][, Column := expand_language_columns$bp[rev_ind_match[!is.na(rev_ind_match)]]]
col_fr <- colorsVars[Column %in% expand_language_columns$en][, Column := expand_language_columns$fr[rev_ind_match[!is.na(rev_ind_match)]]]
colorsVars <- unique(rbindlist(list(colorsVars, col_bp, col_fr)))

# BP 2017 : mcYear params
bp_mcy_params <- fread(input=system.file("bp_years_params.csv", package = "bpNumerique2018"))
bp_mcy_params[, c("Label", "mcYear", "date_start", "date_end") := list(
  as.character(Label), as.character(mcYear), as.Date(date_start), as.Date(date_end))]
Encoding(bp_mcy_params$Label) <- "UTF-8"

bp_mcy_params_labels <- bp_mcy_params$mcYear
names(bp_mcy_params_labels) <- bp_mcy_params$Label
