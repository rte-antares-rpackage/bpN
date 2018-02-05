require(shiny)
require(antaresRead)
require(bpNumerique2018)
require(manipulateWidget)
require(data.table)
require(RColorBrewer)
require(rAmCharts)

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

setProdStackAlias(
  name = "thermalFirst",
  variables = alist(
    "Pompage/turbinage" = PSP,
    "import/export" = -(BALANCE + `ROW BAL.`),
    "Nucléaire" = NUCLEAR,
    "Lignite" = LIGNITE,
    "Charbon" = COAL,
    "Gaz" = GAS,
    "Fioul" = OIL,
    "Autre thermique" = `MIX. FUEL`,
    "Effacement" = `MISC. DTG`,
    "Autre renouvelable" = `MISC. NDG`,
    "Eolien" = WIND,
    "Solaire" = SOLAR,
    "Hydraulique fil" = `H. ROR`,
    "Hydraulique lac" = `H. STOR`
  ),
  colors = c("#1147B9", "#969696", "#F5B300", "#B4822B", "#AC8C35", "#F30A0A", "#8356A2", "#7F549C", "#ADFF2F", "#166A57", "#74CDB9", "#F27406", "#3D607D", "#5497D0")
)


# map layout
ml_data <- tryCatch(readRDS("/home/benoit/bp2017/mapLayout-2018-01-19.RDS"), error = function(e) {NULL})

# get h5 data
h5_dir <- "/home/benoit/bp2017"

h5_files <- list.files(h5_dir, full.names = FALSE, pattern = ".h5$")

.list_data_all <- list(antaresDataList = list(), params = list(), 
                                have_links = c(), have_areas = c(), opts = list())

add_h5_file <- lapply(1:length(h5_files), function(x){
  params <- list(
    areas = "all", links = "all", 
    clusters = "all", districts = "all",
    select = NULL
  )
  
  # a .h5 file, so return opts...
  opts <- setSimulationPath(paste0(h5_dir, "/", h5_files[x]))
  .list_data_all$antaresDataList[[x]] <<- opts
  .list_data_all$params[[x]] <<- params
  .list_data_all$opts[[x]] <<- opts
  
  .list_data_all$have_links[x] <<- TRUE
  .list_data_all$have_areas[x] <<- TRUE

  names(.list_data_all$antaresDataList)[[x]] <<- h5_files[x]
  invisible()
})


# shared inputs
.is_shared_input <- TRUE
.ram_limit <- 10
antaresRead::setRam(.ram_limit)

.data_module <- 200
bpNumerique2018::limitSizeGraph(.data_module)

.global_shared_prodStack <- data.frame(
  module = "prodStack", 
  panel = "prodStack", 
  input = c("dateRange", "unit", "mcYear", "mcYearh", "timeSteph5", "legend", "drawPoints", "stepPlot"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput", "selectInput", 
           "checkboxInput", "checkboxInput", "checkboxInput"), stringsAsFactors = FALSE)

.global_shared_plotts <- data.frame(
  module = "plotts", 
  panel = "tsPlot", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5", "legend", "drawPoints", "stepPlot"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput", 
           "checkboxInput", "checkboxInput", "checkboxInput"), stringsAsFactors = FALSE)


.global_shared_plotMap <- data.frame(
  module = "plotMap", 
  panel = "Map", 
  input = c("dateRange", "mcYear", "mcYearh", "timeSteph5"),
  type = c("dateRangeInput", "selectInput", "selectInput", "selectInput"), stringsAsFactors = FALSE)

.global_shared_exchangesStack <- data.frame(
  module = "exchangesStack", 
  panel = "exchangesStack", 
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

.global_compare_prodstack <- c("mcYear", "main", "unit", "areas", "legend", 
                       "stack", "stepPlot", "drawPoints")

.global_compare_exchangesStack <- c("mcYear", "main", "unit", "area",
                            "legend", "stepPlot", "drawPoints")

.global_compare_tsPlot <- c("mcYear", "main", "variable", "type", "confInt", "elements", 
                    "aggregate", "legend", "highlight", "stepPlot", "drawPoints", "secondAxis")

.global_compare_plotMap <- c("mcYear", "type", "colAreaVar", "sizeAreaVars", "areaChartType", "showLabels",
  "popupAreaVars", "labelAreaVar","colLinkVar", "sizeLinkVar", "popupLinkVars")


#----- generate help for antaresRead function
# library(tools)
# add.html.help <- function(package, func, tempsave = paste0(getwd(), "/temp.html")) {
#   pkgRdDB = tools:::fetchRdDB(file.path(find.package(package), "help", package))
#   topics = names(pkgRdDB)
#   rdfunc <- pkgRdDB[[func]]
#   tools::Rd2HTML(pkgRdDB[[func]], out = tempsave)
# }
# add.html.help("antaresRead", "readAntares", "inst/application/www/readAntares.html")
# add.html.help("antaresRead", "removeVirtualAreas", "inst/application/www/removeVirtualAreas.html")
# add.html.help("antaresRead", "writeAntaresH5", "inst/application/www/writeAntaresH5.html")

#------------------
# hypothese

# bug with fread
hyp_prod <- data.table(read.table("/home/benoit/bp2017/BP2017_production_global.csv", dec = ",", 
                                  sep = ";", header = T, encoding = "Latin-1"))
hyp_prod$filiere2 <- as.character(hyp_prod$filiere2)
Encoding(hyp_prod$filiere2) <- "latin1"

getProductionHypothesis <- function(data, nodes = NULL, enr = NULL, thermal = NULL){
  
  if(is.null(enr)){
    enr <- hyp_prod[filiere1 %in% "enr", as.character(unique(trajectoire))]
  }
  
  if(is.null(thermal)){
    thermal <- hyp_prod[filiere1 %in% "thermal", as.character(unique(trajectoire))]
  }
  
  v_trajectoire <- c(enr, thermal)
  
  if(is.null(nodes)){
    res <- data[trajectoire %in% v_trajectoire, list(capa = sum(capacite)), by = list(date, filiere2)]
  } else {
    res <- data[node %in% nodes & trajectoire %in% v_trajectoire, list(capa = sum(capacite)), by = list(date, filiere2)]
  }
  
  res <- data.frame(dcast(res, date ~ filiere2, fun=sum, value.var = "capa"))
  res$date <- as.character(res$date)
  res
}

cl_hyp_prod <- c(brewer.pal(n = 12, name = "Set3"), brewer.pal(n = 5, name = "Set1"))
names(cl_hyp_prod) <- unique(hyp_prod$filiere2)
# 
# amBarplot(x = "date", y = colnames(res)[-1], data = res, 
#           stack_type = "regular", legend = TRUE,
#           groups_color = cl,
#           zoom = TRUE, export = TRUE, show_values = FALSE,
#           labelRotation = 45, legendPosition = "bottom", height = "800")
