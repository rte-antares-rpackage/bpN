require(shiny)
require(antaresRead)
require(bpNumerique2018)
require(manipulateWidget)
require(data.table)
require(RColorBrewer)
require(rAmCharts)
require(magrittr)
require(rhdf5)

# manipulateWidget:::mwDebug()

#-------------
#  options
#-------------
.is_shared_input <- FALSE
.ram_limit <- 2
.data_module <- 200

antaresRead::setRam(.ram_limit)
bpNumerique2018::limitSizeGraph(.data_module)

#--------------
# data path
#--------------
data_dir <- "data"

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
    select = c("OV. COST", "OP. COST", "MRG. PRICE", "CO2 EMIS.", "BALANCE", "ROW BAL.", "PSP", "MISC. NDG",
               "LOAD", "H. ROR", "WIND", "SOLAR", "NUCLEAR", "LIGNITE", "COAL", "GAS", "OIL", "MIX. FUEL",
               "H. STOR", "UNSP. ENRG", "SPIL. ENRG", "LOLD", "LOLP", "AVL DTG", "DTG MRG", "MAX MRG",
               "NP COST", "NODU", "FLOW LIN.", "congestion", "effacement")
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


# add_h5_file <- lapply(1:length(h5_files), function(x){
#   
#   # a .h5 file, so return opts...
#   opts <- setSimulationPath(paste0(data_dir, "/", h5_files[x]))
#   
#   for(ts in c("hourly", "daily", "weekly", "monthly", "annual")){ 
#     # addProcessingH5(mcY = "mcAll",
#     #                 timeStep = ts,
#     #                 evalAreas = list(effacement = "`MISC. DTG` + `fr_dsr_4h` + `de_dsr_4h`  + `ie_dsr_4h`  + `ni_dsr_4h` + `gb_dsr_4h`"),
#     #                 evalLinks = list(congestion = "(`CONG. PROB +` + `CONG. PROB -`)/100"))
#     # 
#     # addProcessingH5(mcY = "mcInd",
#     #                 timeStep = ts,
#     #                 evalAreas = list(effacement = "`MISC. DTG` + `fr_dsr_4h` + `de_dsr_4h`  + `ie_dsr_4h`  + `ni_dsr_4h` + `gb_dsr_4h`"),
#     #                 evalLinks = list(congestion = "(`CONG. PROB +` + `CONG. PROB -`)/100"))
#     # 
#     addProcessingH5(mcY = "mcAll",
#                     timeStep = ts,
#                     evalAreas = list(effacement = "`MISC. DTG` + `fr_dsr_4h`"),
#                     evalLinks = list(congestion = "(`CONG. PROB +` + `CONG. PROB -`)/100"))
#     
#     addProcessingH5(mcY = "mcInd",
#                     timeStep = ts,
#                     evalAreas = list(effacement = "`MISC. DTG` + `fr_dsr_4h`"),
#                     evalLinks = list(congestion = "(`CONG. PROB +` + `CONG. PROB -`)/100"))
#   }
#   
# })

#--------------
# new prodStack alias
#--------------

couleur_mix <- data.table(read.delim(paste0(data_dir, "/couleur_mix.csv"), dec = ",", 
                                     sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

couleur_mix[[1]] <- as.character(couleur_mix[[1]])
Encoding(couleur_mix[[1]] ) <- "latin1"

couleur_mix$color <- rgb(couleur_mix$R, couleur_mix$G, couleur_mix$B, maxColorValue = 255)

cl_mix <- couleur_mix$color
names(cl_mix) <- couleur_mix$Nom

# change eco2mix alias

# dans l'ordre, de bas en haut
tmp_var <- alist(
  "Pompage STEP" = - pmax(0, -PSP),
  "Export" = - pmax(0, BALANCE + pmax(0, -`ROW BAL.`)),
  "Déversement" = -(`SPIL. ENRG`),
  "Nucléaire" = NUCLEAR,
  "Charbon" = COAL,
  "Gaz" = GAS,
  "Autre renouvelable" = `MISC. NDG`,
  "Hydraulique" = `H. ROR` + `H. STOR`,
  "Turbinage STEP" = pmax(0, PSP),
  "Fioul" = OIL,
  "Import" = pmax(0, - (BALANCE) + pmax(0, `ROW BAL.`)),
  "Eolien" = WIND,
  "Solaire" = SOLAR,
  "Effacements" = effacement,
  "Défaillance" = `UNSP. ENRG`
)

setProdStackAlias(
  name = "eco2mix",
  variables = tmp_var,
  colors = unname(cl_mix[names(tmp_var)]),
  lines = alist(
    "Consommation" = LOAD
  ),
  lineColors = unname(cl_mix["Consommation"]),
  lineWidth = 2
)

# shared inputs
.global_shared_prodStack <- data.frame(
  module = "prodStack", 
  panel = "Production", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput"), stringsAsFactors = FALSE)

.global_shared_plotts <- data.frame(
  module = "plotts", 
  panel = "Chroniques", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput"), stringsAsFactors = FALSE)


.global_shared_plotMap <- data.frame(
  module = "plotMap", 
  panel = "Carte", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput"), stringsAsFactors = FALSE)

.global_shared_exchangesStack <- data.frame(
  module = "exchangesStack", 
  panel = "Echanges", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput"), stringsAsFactors = FALSE)

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
sce_prod <- fread(paste0(data_dir, "/correspondance_scenarios_V3.csv"), encoding = "Latin-1")

# bug with fread
hyp_prod <- data.table(read.table(paste0(data_dir, "/BP2017_production_hypothesis_v7_global.csv"), dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1"))

hyp_prod$filiere2 <- as.character(hyp_prod$filiere2)
Encoding(hyp_prod$filiere2) <- "latin1"

hyp_prod$filiere_BP_num <- as.character(hyp_prod$filiere_BP_num)
Encoding(hyp_prod$filiere_BP_num) <- "latin1"

hyp_prod <- hyp_prod[filiere_BP_num != "Autre thermique décentralisé EnR"]
# # renommage en francais
# unique(hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^other$", "autres_renouvelables", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^wind$", "éolien", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^solar$", "solaire", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^biogas$", "biogaz", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^biomass$", "biomasse", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^geothermal$", "géothermie", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^hydro$", "hydraulique", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^hydrokinetic$", "hydrolien", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^waste$", "déchets", hyp_prod$filiere2)
# hyp_prod$filiere2 <- gsub("^wave$", "houlomotrice", hyp_prod$filiere2)

# renommage en francais
unique(hyp_prod$filiere_BP_num)

# remove 2036
# hyp_prod <- hyp_prod[date != 2036]

# hyp_prod[, .N, list(filiere1, filiere2)]
# hyp_prod[, .N, list(filiere1, filiere2, filiere3)]
# data <- hyp_prod

couleur_prod <- data.table(read.delim(paste0(data_dir, "/couleur_prod.csv"), dec = ",", 
                                      sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

couleur_prod <- couleur_prod[Type %in% "production"]
couleur_prod[[1]] <- as.character(couleur_prod[[1]])
Encoding(couleur_prod[[1]] ) <- "latin1"

couleur_prod$color <- rgb(couleur_prod$R, couleur_prod$G, couleur_prod$B, maxColorValue = 255)

cl_hyp_prod <- couleur_prod$color
names(cl_hyp_prod) <- couleur_prod$Nom

order_hyp_prod <- couleur_prod[order(Ordre), Nom]

# data <- hyp_prod
getProductionHypothesis <- function(data, nodes = NULL, sce_prod = NULL, scenario = "Hertz"){
  
  enr_fr <- sce_prod[Pays %in% "France" & filiere1 %in% "enr" & filiere2 %in% c("", NA), get(scenario)]
  enr_ue <- sce_prod[Pays %in% "Europe" & filiere1 %in% "enr" & filiere2 %in% c("", NA), get(scenario)]
  
  nuclear_fr <- sce_prod[Pays %in% "France" & filiere1 %in% "nuclear", get(scenario)]
  nuclear_ue <- sce_prod[Pays %in% "Europe" & filiere1 %in% "nuclear", get(scenario)]
  
  thermal_fr <- sce_prod[Pays %in% "France" & filiere1 %in% "thermal", get(scenario)]
  thermal_ue <- sce_prod[Pays %in% "Europe" & filiere1 %in% "thermal", get(scenario)]
  
  enr_hydro_fr <- sce_prod[Pays %in% "France" & filiere3 %in% "hydro", get(scenario)]
  enr_step_fr <- sce_prod[Pays %in% "France" & filiere3 %in% "step", get(scenario)]
  
  enr_hydro_ue <- sce_prod[Pays %in% "Europe" & filiere3 %in% "hydro", get(scenario)]
  enr_step_ue <- sce_prod[Pays %in% "Europe" & filiere3 %in% "step", get(scenario)]
  
  # hors hydraulique
  data_no_hydro <- data[((node %in% "fr" & filiere1 %in% "enr" & !filiere2 %in% "hydro" & trajectoire %in% enr_fr) |
                           (!node %in% "fr" & filiere1 %in% "enr" & !filiere2 %in% "hydro" & trajectoire %in% enr_ue) |
                           (node %in% "fr" & filiere1 %in% "nuclear" & trajectoire %in% nuclear_fr) |
                           (!node %in% "fr" & filiere1 %in% "nuclear" & trajectoire %in% nuclear_ue) |
                           (node %in% "fr" & filiere1 %in% "thermal" & trajectoire %in% thermal_fr) |
                           (!node %in% "fr" & filiere1 %in% "thermal" & trajectoire %in% thermal_ue)) & !filiere2 %in% "hydraulique"]
  
  # hydro
  data_hydro <- data[(node %in% "fr" & filiere3 %in% "hydro" & trajectoire %in% enr_hydro_fr) |
                       (!node %in% "fr" & filiere3 %in% "hydro" & trajectoire %in% enr_hydro_ue) |
                       (node %in% "fr" & filiere3 %in% "step" & trajectoire %in% enr_step_fr) |
                       (!node %in% "fr" & filiere3 %in% "step" & trajectoire %in% enr_step_ue) ]
  
  data <- rbindlist(list(data_no_hydro, data_hydro))
  
  if(scenario %in% "Ohm"){
    data <- data[date_BP_num <= 2025]
  }
  if(is.null(nodes)){
    res <- data[, list(capa = sum(capacite)), by = list(date = date_BP_num, filiere_BP_num)]
  } else {
    res <- data[node %in% nodes, list(capa = sum(capacite)), by = list(date = date_BP_num, filiere_BP_num)]
  }
  
  res[, capa := round(capa/1000, 1)]
  
  col_names <- sort(unique(res$filiere_BP_num))
  res <- data.frame(dcast(res, date ~ filiere_BP_num, fun=sum, value.var = "capa"))
  
  colnames(res)[-1] <- col_names
  res$date <- as.character(res$date)
  res
}

# cl_hyp_prod <- c(brewer.pal(n = 12, name = "Set3"), brewer.pal(n = 5, name = "Set1"))
# names(cl_hyp_prod) <- unique(hyp_prod$filiere2)


# a <- amBarplot(x = "date", y = colnames(res)[-1], data = res,
#           stack_type = "regular", legend = TRUE,
#           zoom = TRUE, export = TRUE, show_values = FALSE,
#           labelRotation = 45, legendPosition = "bottom", height = "800")
# 
# a@legend$reversedOrder = TRUE
# a

#------------------
# interconnexion
#------------------
# bug with fread
hyp_inter<- data.table(read.table(paste0(data_dir, "/Links.csv"), dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

hyp_inter$hypothesis <- as.character(hyp_inter$hypothesis)
hyp_inter$hypothesis <- gsub("^low$", "Bas", hyp_inter$hypothesis)
hyp_inter$hypothesis <- gsub("^mid$", "Moyen", hyp_inter$hypothesis)
hyp_inter$hypothesis <- gsub("^high$", "Haute", hyp_inter$hypothesis)

# GW
hyp_inter[["2016"]] <- round(hyp_inter[["2016"]] / 1000, 1)
hyp_inter[["2022"]] <- round(hyp_inter[["2022"]] / 1000, 1)
hyp_inter[["2025"]] <- round(hyp_inter[["2025"]] / 1000, 1)
hyp_inter[["2030"]] <- round(hyp_inter[["2030"]] / 1000, 1)
hyp_inter[["2035"]] <- round(hyp_inter[["2035"]] / 1000, 1)

# subset de colonnes
hyp_inter <- hyp_inter[, c("from", "to", "concat", "hypothesis", "2016", "2022", "2025", "2030", "2035"), with = FALSE]

# couleur et ordre
couleur_inter <- data.table(read.delim(paste0(data_dir, "/couleur_interco.csv"), dec = ",", 
                                       sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

colnames(couleur_inter)[1] <- "Nom"
couleur_inter[["Nom"]] <- as.character(couleur_inter[["Nom"]])
Encoding(couleur_inter[["Nom"]] ) <- "latin1"

couleur_inter$color <- rgb(couleur_inter$R, couleur_inter$G, couleur_inter$B, maxColorValue = 255)

cl_hyp_interco <- couleur_inter$color
names(cl_hyp_interco) <- couleur_inter$Nom

order_hyp_interco <- couleur_inter[order(Ordre), Nom]

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
hyp_conso <- data.table(read.delim(paste0(data_dir, "/BP17_hypothese_consommation_flat_5.csv"), dec = ",", 
                                   sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

# encoding
for(v in c("Trajectoire", "Secteur", "Branche", "Branche2", "Usage", "Usage2")){
  hyp_conso[[v]] <- as.character(hyp_conso[[v]])
  Encoding(hyp_conso[[v]] ) <- "latin1"
}
Encoding(colnames(hyp_conso)) <- "latin1"

# remove 2036
hyp_conso <- hyp_conso[hyp_conso[["Année"]] != 2036]

# hyp_conso[, .N, Secteur]
# hyp_conso[, .N, Branche]
# hyp_conso[, .N, Usage]
# 
# hyp_conso[, .N, list(Secteur, Branche)]
# hyp_conso[, .N, list(Secteur, Usage)]

couleur_conso <- data.table(read.delim(paste0(data_dir, "/couleur_conso.csv"), dec = ",", 
                                       sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))
couleur_conso[["Nom"]] <- as.character(couleur_conso[["Nom"]])
Encoding(couleur_conso[["Nom"]] ) <- "latin1"

secteur_col <- couleur_conso[Type %in% "Secteur", rgb(R, G, B, maxColorValue = 255)]
names(secteur_col) <- couleur_conso[Type %in% "Secteur", Nom]

usage_col <- couleur_conso[Type %in% "Usage", rgb(R, G, B, maxColorValue = 255)]
names(usage_col) <- couleur_conso[Type %in% "Usage", Nom]

# data <- hyp_conso
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
  
  if(type == "Secteur"){
    setcolorder(res, c("date", "Industrie", "Tertiaire", "Résidentiel", "Transport, agriculture et énergie", "Pertes"))
  } else {
    setcolorder(res, c("date", "Autres usages", "Bureautique et autres usages tertiaires", "Autres usages résidentiels", 
                       "Produits gris & bruns résidentiels", "Lavage", "Froid", "Cuisson", "Eclairage intérieur", 
                       "Climatisation & ventilation", "Eau chaude sanitaire", "Chauffage", "VE & VHR", "Pertes"))
  }
  res
}

# amBarplot(x = "date", y = colnames(res)[-1], data = res,
#           stack_type = "regular", legend = TRUE,
#           main = paste0("Evolution des capacités d'import (scénario ", ")"),
#           zoom = TRUE, export = TRUE, show_values = FALSE,
#           ylab = "MWh", horiz = FALSE,
#           labelRotation = 45, legendPosition = "bottom", height = "800")

#------------------
# co2
#------------------
# bug with fread

hyp_co2 <- data.table(read.delim(paste0(data_dir, "/co2_V2.csv"), dec = ",", 
                                 sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))


hyp_co2$scenario <- as.character(hyp_co2$scenario)
Encoding(hyp_co2$scenario) <- "latin1"

# tmp <- data.frame(date = colnames(hyp_co2)[-1], historique = t(data.frame(hyp_co2[1, ][, scenario := NULL]))[, 1])
# tmp$scenario <- tmp$historique
# tmp$scenario[1:5] <- NA
# tmp$historique[6:8] <- NA
# 
# a <- amBarplot(x = "date", y = c("historique", "scenario"), data = tmp,
#                     stack_type = "regular", legend = TRUE,
#                     main = "Évolution des émissions de CO2 en France",
#                     zoom = TRUE, show_values = TRUE,
#                     ylab = "Millions de tonnes (Mt)", horiz = FALSE,
#                     labelRotation = 45, theme = "pattern", creditsPosition = "top-right") %>%
#   setExport(enabled = TRUE, menu = ramcharts_menu_obj)
# 
# a@graphs <- lapply(a@graphs, function(x){
#   x$fillColors <- NULL
#   x$legendColor <- NULL
#   x
# })

ramcharts_menu_obj <- list(list(class = "export-main",
                                menu = list(
                                  list(label = "Télécharger", menu = list("PNG", "JPG"))
                                )))

#----------
# Bilan
#----------


hyp_bilan <- data.table(read.delim(paste0(data_dir, "/bilans_energetiques_V2.csv"), dec = ",", 
                                   sep = ";", header = T, encoding = "Latin-1", check.names = FALSE))

hyp_bilan$Scenario <- as.character(hyp_bilan$Scenario)
Encoding(hyp_bilan$Scenario) <- "latin1"


hyp_bilan$TWh <- as.character(hyp_bilan$TWh)
Encoding(hyp_bilan$TWh) <- "latin1"

table_couleur_bilan <- read.delim(paste0(data_dir, "/couleur_prod.csv"), dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1", check.names = FALSE)

table_couleur_bilan[[1]] <- as.character(table_couleur_bilan[[1]])
Encoding(table_couleur_bilan[[1]] ) <- "latin1"

table_couleur_bilan$Couleur <- rgb(table_couleur_bilan$R, table_couleur_bilan$G, table_couleur_bilan$B, maxColorValue = 255)
table_couleur_bilan <- table_couleur_bilan[, c("Nom", "Couleur")]

getBilan <- function(data_bilan, data_co2, table_couleur_bilan, scenario = "Hertz"){
  
  bilan <- data_bilan[Scenario %in% scenario]
  
  bilan <- merge(bilan, table_couleur_bilan, by.x = "TWh", by.y = "Nom", all.x = T, sort = FALSE)
  
  # consommation
  bilan_conso <- bilan[ TWh %in% c("Consommation France", "Echanges", "Pompage", "Energie déversée")]
  
  pie_conso_2025 <- bilan_conso[, c("TWh", "2025", "Couleur")]
  colnames(pie_conso_2025) <- c("label", "value", "color")
  
  pie_conso_2030 <- bilan_conso[, c("TWh", "2030", "Couleur")]
  colnames(pie_conso_2030) <- c("label", "value", "color")
  
  pie_conso_2035 <- bilan_conso[, c("TWh", "2035", "Couleur")]
  colnames(pie_conso_2035) <- c("label", "value", "color")
  
  # production
  bilan_prod <- bilan[ TWh %in% c("Nucléaire", "Cycles combinés au gaz", "Turbines à combustion", "Cogénérations",
                                  "Autre thermique décentralisé", "Hydraulique", "Eolien", "Photovoltaïque", "Bioénergies", 
                                  "Charbon", "Energies marines")]
  
  pie_prod_2025 <- bilan_prod[, c("TWh", "2025", "Couleur")]
  colnames(pie_prod_2025) <- c("label", "value", "color")
  
  pie_prod_2030 <- bilan_prod[, c("TWh", "2030", "Couleur")]
  colnames(pie_prod_2030) <- c("label", "value", "color")
  
  pie_prod_2035 <- bilan_prod[, c("TWh", "2035", "Couleur")]
  colnames(pie_prod_2035) <- c("label", "value", "color")
  
  # somme
  twh_2025 <- as.data.frame(bilan[TWh %in% "Demande totale", c("2025")])[1, 1]
  twh_2030 <- as.data.frame(bilan[TWh %in% "Demande totale", c("2030")])[1, 1]
  twh_2035 <- as.data.frame(bilan[TWh %in% "Demande totale", c("2035")])[1, 1]
  
  # enr
  enr_2025 <- as.data.frame(bilan[TWh %in% "Pourcentage EnR", c("2025")])[1, 1]
  enr_2030 <- as.data.frame(bilan[TWh %in% "Pourcentage EnR", c("2030")])[1, 1]
  enr_2035 <- as.data.frame(bilan[TWh %in% "Pourcentage EnR", c("2035")])[1, 1]
  
  # nucleaire
  nuc_2025 <- round(as.data.frame(bilan[TWh %in% "Nucléaire", c("2025")])[1, 1] / twh_2025 * 100)
  nuc_2030 <- round(as.data.frame(bilan[TWh %in% "Nucléaire", c("2030")])[1, 1] / twh_2030 * 100)
  nuc_2035 <- round(as.data.frame(bilan[TWh %in% "Nucléaire", c("2035")])[1, 1] / twh_2035 * 100)
  
  # co2
  data_co2 <- as.data.frame(data_co2)
  co2_2025 <-  data_co2[data_co2$scenario %in% scenario, c("2025")]
  co2_2030 <-  data_co2[data_co2$scenario %in% scenario, c("2030")]
  co2_2035 <-  data_co2[data_co2$scenario %in% scenario, c("2035")]
  
  list(pie_conso_2025 = pie_conso_2025, pie_conso_2030 = pie_conso_2030, pie_conso_2035 = pie_conso_2035,
       pie_prod_2025 = pie_prod_2025, pie_prod_2030 = pie_prod_2030, pie_prod_2035 = pie_prod_2035,
       twh_2025 = twh_2025, twh_2030 = twh_2030, twh_2035 = twh_2035,
       enr_2025 = enr_2025, enr_2030 = enr_2030, enr_2035 = enr_2035,
       nuc_2025 = nuc_2025, nuc_2030 = nuc_2030, nuc_2035 = nuc_2035,
       co2_2025 = co2_2025, co2_2030 = co2_2030, co2_2035= co2_2035)
}
