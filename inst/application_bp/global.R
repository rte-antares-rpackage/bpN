require(shiny)
require(antaresRead)
require(bpNumerique2018)
require(manipulateWidget)
require(data.table)
require(RColorBrewer)
require(rAmCharts)

# manipulateWidget:::mwDebug()

#-------------
#  options
#-------------
.is_shared_input <- TRUE
.ram_limit <- 2
.data_module <- 200

antaresRead::setRam(.ram_limit)
bpNumerique2018::limitSizeGraph(.data_module)

#--------------
# data path
#--------------
data_dir <- "/home/benoit/bp2017"

# map layout
# ml_data <- tryCatch(readRDS(paste0(data_dir, "/mapLayout-2018-01-19.RDS")), error = function(e) {NULL})
ml_data <- tryCatch(readRDS(paste0(data_dir, "/mapLayout-2018-02-09.RDS")), error = function(e) {NULL})

# .h5 files
h5_files <- list.files(data_dir, full.names = FALSE, pattern = ".h5$")

.list_data_all <- list(antaresDataList = list(), params = list(), 
                       have_links = c(), have_areas = c(), opts = list())

add_h5_file <- lapply(1:length(h5_files), function(x){
  params <- list(
    areas = "all", links = "all", 
    clusters = "all", districts = "all",
    select = NULL
  )
  
  # a .h5 file, so return opts...
  opts <- setSimulationPath(paste0(data_dir, "/", h5_files[x]))
  .list_data_all$antaresDataList[[x]] <<- opts
  .list_data_all$params[[x]] <<- params
  .list_data_all$opts[[x]] <<- opts
  
  .list_data_all$have_links[x] <<- TRUE
  .list_data_all$have_areas[x] <<- TRUE
  
  names(.list_data_all$antaresDataList)[[x]] <<- h5_files[x]
  invisible()
})

#--------------
# new prodStack alias
#--------------

# change eco2mix alias
setProdStackAlias(
  name = "eco2mix",
  variables = alist(
    "Pompage/turbinage" = PSP,
    "Import/export" = -(BALANCE + `ROW BAL.`),
    "Autre renouvelable" = `MISC. NDG`,
    "Eolien" = WIND,
    "Solaire" = SOLAR,
    "Nucléaire" = NUCLEAR,
    "Hydraulique" = `H. ROR` + `H. STOR`,
    "Gaz" = GAS,
    "Charbon" = COAL,
    "Lignite" = LIGNITE,
    "Fioul" = OIL,
    "Défaillance" = `UNSP. ENRG`,
    "Déversement" = `SPIL. ENRG`,
    "Effacement" = `MISC. DTG` + `MIX. FUEL`
  ),
  colors = c("#1147B9", "#969696", "#166A57", "#74CDB9", "#F27406", "#F5B300", "#2772B2", "#F30A0A", "#AC8C35", 
             "#B4822B", "#8356A2", "#DBA9A9",  "#FCD8B9", "#ADFF2F"),
  lines = alist(
    "Consommation" = LOAD + `SPIL. ENRG`,
    "Production" = NUCLEAR + LIGNITE + COAL + GAS + OIL + `MIX. FUEL` + `MISC. DTG` + WIND + SOLAR + `H. ROR` + `H. STOR` + `MISC. NDG` + pmax(0, PSP) + `UNSP. ENRG`
  ),
  lineColors = c("#875627", "#EB9BA6"),
  lineWidth = 2
)

# setProdStackAlias(
#   name = "thermalFirst",
#   variables = alist(
#     "Pompage/turbinage" = PSP,
#     "import/export" = -(BALANCE + `ROW BAL.`),
#     "Nucléaire" = NUCLEAR,
#     "Lignite" = LIGNITE,
#     "Charbon" = COAL,
#     "Gaz" = GAS,
#     "Fioul" = OIL,
#     "Autre thermique" = `MIX. FUEL`,
#     "Effacement" = `MISC. DTG`,
#     "Autre renouvelable" = `MISC. NDG`,
#     "Eolien" = WIND,
#     "Solaire" = SOLAR,
#     "Hydraulique fil" = `H. ROR`,
#     "Hydraulique lac" = `H. STOR`
#   ),
#   colors = c("#1147B9", "#969696", "#F5B300", "#B4822B", "#AC8C35", "#F30A0A", "#8356A2", "#7F549C", "#ADFF2F", "#166A57", "#74CDB9", "#F27406", "#3D607D", "#5497D0")
# )


# shared inputs
.global_shared_prodStack <- data.frame(
  module = "prodStack", 
  panel = "Production", 
  input = c("dateRange", "unit", "mcYear", "mcYearh", "timeSteph5", "legend", "drawPoints", "stepPlot"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput", "selectInput", 
           "checkboxInput", "checkboxInput", "checkboxInput"), stringsAsFactors = FALSE)

.global_shared_plotts <- data.frame(
  module = "plotts", 
  panel = "Chroniques", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5", "legend", "drawPoints", "stepPlot"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput", 
           "checkboxInput", "checkboxInput", "checkboxInput"), stringsAsFactors = FALSE)


.global_shared_plotMap <- data.frame(
  module = "plotMap", 
  panel = "Carte", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput"), stringsAsFactors = FALSE)

.global_shared_exchangesStack <- data.frame(
  module = "exchangesStack", 
  panel = "Echanges", 
  input = c("dateRange", "unit", "mcYear", "mcYearh", "timeSteph5", "legend", "drawPoints", "stepPlot"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput", "selectInput", 
           "checkboxInput", "checkboxInput", "checkboxInput"), stringsAsFactors = FALSE)

.global_shared_input <- rbind(.global_shared_prodStack, .global_shared_plotts, .global_shared_plotMap, .global_shared_exchangesStack)


.global_build_input_data <- function(data){
  data$input_id <- paste0(data$module, "-shared_", data$input)
  data$last_update <- NA
  data$update_call <- ""
  class(data$last_update) <- c("character")
  data <- data.table(data)
  data
}

#------------
# compare
#-----------

.global_compare <- c("mcYear", "areas")

# .global_compare_prodstack <- c("mcYear", "main", "unit", "areas", "legend", 
#                        "stack", "stepPlot", "drawPoints")
# 
# .global_compare_exchangesStack <- c("mcYear", "main", "unit", "area",
#                             "legend", "stepPlot", "drawPoints")
# 
# .global_compare_tsPlot <- c("mcYear", "main", "variable", "type", "confInt", "elements", 
#                     "aggregate", "legend", "highlight", "stepPlot", "drawPoints", "secondAxis")
# 
# .global_compare_plotMap <- c("mcYear", "type", "colAreaVar", "sizeAreaVars", "areaChartType", "showLabels",
#   "popupAreaVars", "labelAreaVar","colLinkVar", "sizeLinkVar", "popupLinkVars")

#------------------
# hypothese
#------------------

# production
sce_prod <- fread(paste0(data_dir, "/Correspondance_scenarios.csv"), encoding = "Latin-1")

# bug with fread
hyp_prod <- data.table(read.table(paste0(data_dir, "/BP2017_production_global.csv"), dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1"))

hyp_prod$filiere2 <- as.character(hyp_prod$filiere2)
Encoding(hyp_prod$filiere2) <- "latin1"

# renommage en francais
unique(hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^other$", "Autre renouvelables", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^wind$", "éolien", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^solar$", "solaire", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^biogas$", "biogaz", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^biomass$", "biomasse", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^geothermal$", "géothermie", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^hydro$", "hydraulique", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^hydrokinetic$", "hydrolien", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^waste$", "déchets", hyp_prod$filiere2)
hyp_prod$filiere2 <- gsub("^wave$", "houlomotrice", hyp_prod$filiere2)

# hyp_prod[, .N, list(filiere1, filiere2)]
# hyp_prod[, .N, list(filiere1, trajectoire)]
# data <- hyp_prod

getProductionHypothesis <- function(data, nodes = NULL, sce_prod = NULL, scenario = "Hertz"){
  

  enr_fr <- sce_prod[Pays %in% "France" & filiere1 %in% "enr", get(scenario)]
  enr_ue <- sce_prod[Pays %in% "Europe" & filiere1 %in% "enr", get(scenario)]
  
  nuclear_fr <- sce_prod[Pays %in% "France" & filiere1 %in% "nuclear", get(scenario)]
  nuclear_ue <- sce_prod[Pays %in% "Europe" & filiere1 %in% "nuclear", get(scenario)]
  
  thermal_fr <- sce_prod[Pays %in% "France" & filiere1 %in% "thermal", get(scenario)]
  thermal_ue <- sce_prod[Pays %in% "Europe" & filiere1 %in% "thermal", get(scenario)]
  
  data <- data[(node %in% "fr" & filiere1 %in% "enr" & trajectoire %in% enr_fr) |
              (!node %in% "fr" & filiere1 %in% "enr" & trajectoire %in% enr_ue) |
                (node %in% "fr" & filiere1 %in% "nuclear" & trajectoire %in% nuclear_fr) |
                (!node %in% "fr" & filiere1 %in% "nuclear" & trajectoire %in% nuclear_ue) |
                (node %in% "fr" & filiere1 %in% "thermal" & trajectoire %in% thermal_fr) |
                (!node %in% "fr" & filiere1 %in% "thermal" & trajectoire %in% thermal_ue)]
  
  if(is.null(nodes)){
    res <- data[, list(capa = sum(capacite)), by = list(date, filiere2)]
  } else {
    res <- data[node %in% nodes, list(capa = sum(capacite)), by = list(date, filiere2)]
  }
  
  # GW ?
  # res[, capa := round(capa/1000)]
  
  res[, capa := round(capa)]
  
  res <- data.frame(dcast(res, date ~ filiere2, fun=sum, value.var = "capa"))
  res$date <- as.character(res$date)
  res
}

cl_hyp_prod <- c(brewer.pal(n = 12, name = "Set3"), brewer.pal(n = 5, name = "Set1"))
names(cl_hyp_prod) <- unique(hyp_prod$filiere2)


# amBarplot(x = "date", y = colnames(res)[-1], data = res,
#           stack_type = "regular", legend = TRUE,
#           zoom = TRUE, export = TRUE, show_values = FALSE,
#           labelRotation = 45, legendPosition = "bottom", height = "800")


#------------------
# interconnexion
#------------------
# bug with fread
hyp_inter<- data.table(read.table(paste0(data_dir, "/Links.csv"), dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

getIntercoHypothesis <- function(data, sce_prod = NULL, scenario = "Hertz"){
  
  trj <- sce_prod[Pays %in% "France" & filiere1 %in% "interconnexions", get(scenario)]
  
  res_import <- data[hypothesis %in% trj & to %in% "fr",]
  
  res_import <- melt(res_import, id = 1:4, measure.vars = 5:ncol(res_import))
  
  
  res_import <- data.frame(dcast(res_import, variable ~ from, fun=sum, value.var = "value"))
  res_import$variable <- as.character(res_import$variable)
  colnames(res_import)[1] <- "date"
  colnames(res_import) <- gsub("^be$", "Belgique", colnames(res_import))
  colnames(res_import) <- gsub("^ch$", "Suisse", colnames(res_import))
  colnames(res_import) <- gsub("^de$", "Allemagne", colnames(res_import))
  colnames(res_import) <- gsub("^es$", "Espagne", colnames(res_import))
  colnames(res_import) <- gsub("^gb$", "Royaume-Uni", colnames(res_import))
  colnames(res_import) <- gsub("^ie$", "Irlande", colnames(res_import))
  colnames(res_import) <- gsub("^it$", "Italie", colnames(res_import))
  
  res_export <- data[hypothesis %in% trj & from %in% "fr",]
  
  res_export <- melt(res_export, id = 1:4, measure.vars = 5:ncol(res_export))
  
  res_export <- data.frame(dcast(res_export, variable ~ to, fun=sum, value.var = "value"))
  res_export$variable <- as.character(res_export$variable)
  colnames(res_export)[1] <- "date"
  colnames(res_export) <- gsub("^be$", "Belgique", colnames(res_export))
  colnames(res_export) <- gsub("^ch$", "Suisse", colnames(res_export))
  colnames(res_export) <- gsub("^de$", "Allemagne", colnames(res_export))
  colnames(res_export) <- gsub("^es$", "Espagne", colnames(res_export))
  colnames(res_export) <- gsub("^gb$", "Royaume-Uni", colnames(res_export))
  colnames(res_export) <- gsub("^ie$", "Irlande", colnames(res_export))
  colnames(res_export) <- gsub("^it$", "Italie", colnames(res_export))
  
  list(import = res_import, export = res_export)
  
}


cl_hyp_interco <- c("#886A08", "#FE9A2E", "#190707", "#FFFF00", "#B40431", "#BFFF00", "#298A08")
names(cl_hyp_interco) <- c("Belgique", "Suisse", "Allemagne", "Espagne", "Royaume-Uni", "Irlande", "Italie")

# amBarplot(x = "date", y = colnames(res_import)[-1], data = res_import,
#           stack_type = "regular", legend = TRUE,
#           groups_color = unname(cl_hyp_interco[1:(ncol(res_import) - 1)]),
#           main = paste0("Evolution des capacités d'import (scénario ", ")"),
#           zoom = TRUE, export = TRUE, show_values = FALSE,
#           ylab = "MWh", horiz = TRUE,
#           labelRotation = 45, legendPosition = "bottom", height = "800")

#------------------
# consommation
#------------------
# bug with fread
hyp_conso <- data.table(read.delim(paste0(data_dir, "/BP17_hypothese_consommation_flat_3.csv"), dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

# encoding
for(v in c("Trajectoire", "Secteur", "Branche", "Branche2", "Usage", "Usage2")){
  hyp_conso[[v]] <- as.character(hyp_conso[[v]])
  Encoding(hyp_conso[[v]] ) <- "latin1"
}
Encoding(colnames(hyp_conso)) <- "latin1"

# hyp_conso[, .N, Secteur]
# hyp_conso[, .N, Branche]
# hyp_conso[, .N, Usage]
# 
# hyp_conso[, .N, list(Secteur, Branche)]
# hyp_conso[, .N, list(Secteur, Usage)]

data <- hyp_conso
  
getConsoHypothesis <- function(data, type = "Secteur", sce_prod = NULL, scenario = "Hertz"){
  
  trj <- sce_prod[Pays %in% "France" & filiere1 %in% "consommation", get(scenario)]
  
  res <- data[Trajectoire %in% trj, list(conso = sum(Consommation)), by = c("Année", type)]
  colnames(res)[1:2] <- c("date", "type")
  
  # TWh
  res[, conso := round(conso/1000)]
  
  label <- sort(unique(res$type))
  
  res <- data.frame(dcast(res, date ~ type, fun=sum, value.var = "conso"))
  res$date <- as.character(res$date)
  
  colnames(res)[-1] <- label
  
  res
}