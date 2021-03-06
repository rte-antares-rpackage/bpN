# Copyright © 2016 RTE Réseau de transport d’électricité

#' Display results of a simulation on a map
#' 
#' This function generates an interactive map that let the user visually explore
#' the results of an Antares simulation. By default the function starts a Shiny 
#' gadget that let the user which variables to represent.
#' 
#' @param x
#'   Object of class \code{antaresDataList} created with 
#'   \code{\link[antaresRead]{readAntares}} and containing areas and links data.
#'    It can be a list of \code{antaresData} objects. 
#'    In this case, one chart is created for each object.
#' @param mapLayout
#'   Object created with function \code{\link{mapLayout}}
#' @param colAreaVar
#'   Name of a variable present in \code{x$areas}. The values of this variable
#'   are represented by the color of the areas on the map. If \code{"none"}, then
#'   the default color is used for all areas. 
#' @param sizeAreaVars
#'   Vector of variables present in \code{x$areas} to associate with the size of 
#'   areas on the map. If this parameter has length equal to 0, all areas have the
#'   same size. If it has length equal to one, then the radius of the areas change
#'   depending on the values of the variable choosen. If it has length greater than
#'   1 then areas are represented by a polar area chart where the size of each section
#'   depends on the values of each variable.
#' @param areaChartType
#'   If parameter \code{sizeAreaVars} contains multiple variables, this parameter
#'   determines the type of representation. Possible values are \code{"bar"} for
#'   bar charts, \code{"pie"} for pie charts, \code{"polar-area"} and 
#'   \code{"polar-radius"} for polar area charts where the values are represented
#'   respectively by the area or the radius of the slices.
#' @param uniqueScale
#'   If the map contains polar or bar charts, should the different variables 
#'   represented use the same scale or should each variable have its own scale ?
#'   This parameter should be TRUE only if the variables have the same unit and 
#'   are comparable : for instance production variables. 
#' @param showLabels
#'   Used only when \code{sizeAreaVars} contains multiple variables. If it is 
#'   \code{TRUE}, then values of each variable are displayed. 
#' @param popupAreaVars
#'   Vector of variables to display when user clicks on an area.
#' @param labelAreaVar
#'   Variable to display inside the areas. This parameter is used only if 
#'   parameter \code{sizeAreaVars} contains zero or one variable.
#' @param colLinkVar
#'   Name of a variable present in \code{x$links}. The values of this variable
#'   are represented by the color of the links on the map. If \code{"none"}, then
#'   the default color is used for all links  
#' @param sizeLinkVar
#'   Name of a variable present in \code{x$links}. Its values are represented by
#'   the line width of the links on the map.
#' @param popupLinkVars
#'   Vector of variables to display when user clicks on a link.
#' @param type
#'   If \code{type="avg"}, the data is averaged by area/and or link and
#'   represented on the map. If it is equal to \code{"detail"}, only one time
#'   step at a time. In interactive mode, an input control permits to choose the
#'   time step shown.
#' @param timeId
#'   time id present in the data.
#' @param main
#'   Title of the map.
#' @param options
#'   List of parameters that override some default visual settings. See the
#'   help of \code{\link{plotMapOptions}}.
#' @param sizeMiniPlot \code{boolean} variable size for miniplot
#' @inheritParams prodStack
#'   
#'   
#' @details 
#' 
#' compare argument can take following values :
#' \itemize{
#'    \item "mcYear"
#'    \item "type"
#'    \item "colAreaVar"
#'    \item "sizeAreaVars"
#'    \item "areaChartType"
#'    \item "showLabels"
#'    \item "popupAreaVars"
#'    \item "labelAreaVar"
#'    \item "colLinkVar"
#'    \item "sizeLinkVar"
#'    \item "popupLinkVars"
#'    }
#' @return 
#' An htmlwidget of class "leaflet". It can be modified with package 
#' \code{leaflet}. By default the function starts a shiny gadget that lets the
#' user play with most of the parameters of the function. The function returns
#' a leaflet map when the user clicks on the button \code{"done"}.
#' 
#' @examples 
#' \dontrun{
#' mydata <- readAntares(areas = "all", links = "all", timeStep = "daily",
#'                       select = "nostat")
#' 
#' # Place areas on a map. Ths has to be done once for a given study. Then the
#' # object returned by "mapLayout" may be saved and reloaded with
#' # functions save and load
#' 
#' layout <- readLayout()
#' ml <- mapLayout(layout = layout)
#' save("ml", file = "ml.rda")
#' 
#' plotMap(x = mydata, mapLayout = ml)
#' 
#' # Specify the variables to use to control the color or size of elements.
#' plotMap(mydata, mapLayout =  ml, 
#'         sizeAreaVars = c("WIND", "SOLAR", "H. ROR"),
#'         sizeLinkVar = "FLOW LIN.")
#' 
#' # Change default graphical properties
#' plotMap(x = mydata, mapLayout = ml, options = list(colArea="red", colLink = "orange"))
#' plotMap(x = list(mydata, mydata), mapLayout =  ml)
#' 
#' # Use h5 for dynamic request / exploration in a study
#' # Set path of simulaiton
#' setSimulationPath(path = path1)
#' 
#' # Convert your study in h5 format
#' writeAntaresH5(path = mynewpath)
#' 
#' # Redefine sim path with h5 file
#' opts <- setSimulationPath(path = mynewpath)
#' plotMap(x = opts, mapLayout = ml)
#' 
#' # Compare elements in a single study
#' plotMap(x = opts, mapLayout = ml,  .compare = "mcYear")
#' 
#' # Compare 2 studies
#' plotMap(x = list(opts, opts2), mapLayout = ml)
#' 
#' }
#' 
#' @export
plotMap <- function(x, mapLayout, colAreaVar = "none", sizeAreaVars = c(),
                    areaChartType = c("bar", "pie", "polar-area", "polar-radius"),
                    uniqueScale = FALSE,
                    showLabels = FALSE,
                    popupAreaVars = c(),
                    labelAreaVar = "none",
                    colLinkVar = "none", sizeLinkVar = "none", 
                    popupLinkVars = c(),
                    type = c("detail", "avg"),
                    timeId = NULL,
                    mcYear = "average",
                    main = "",
                    compare = NULL,
                    compareOpts = list(),
                    interactive = getInteractivity(),
                    options = plotMapOptions(),
                    width = NULL, height = NULL, dateRange = NULL, xyCompare = c("union","intersect"),
                    h5requestFiltering = list(),
                    timeSteph5 = "hourly",
                    mcYearh5 = NULL,
                    tablesh5 = c("areas", "links"),
                    sizeMiniPlot = FALSE,language = "en", 
                    hidden = NULL, ...) {
  
  
  if(!is.null(compare) && !interactive){
    stop("You can't use compare in no interactive mode")
  }
  
  Column <- optionsT <- NULL
  tpMap <- plotMapOptions()
  
  # Check language
  if(!language %in% availableLanguages_labels){
    stop("Invalid 'language' argument. Must be in : ", paste(availableLanguages_labels, collapse = ", "))  
  }
  
  if(language != "en"){
    colAreaVar <- .getColumnsLanguage(colAreaVar, language)
    sizeAreaVars <- .getColumnsLanguage(sizeAreaVars, language)
    popupAreaVars <- .getColumnsLanguage(popupAreaVars, language)
    labelAreaVar <- .getColumnsLanguage(labelAreaVar, language)
    colLinkVar <- .getColumnsLanguage(colLinkVar, language)
    sizeLinkVar <- .getColumnsLanguage(sizeLinkVar, language)
    popupLinkVars <- .getColumnsLanguage(popupLinkVars, language)
  }
  
  # Check hidden
  .validHidden(hidden, c("H5request", "timeSteph5", "tables", "mcYearH5", "mcYear", "dateRange", "Areas", "colAreaVar", 
                         "sizeAreaVars", "miniPlot", "areaChartType", "sizeMiniPlot", "uniqueScale", "showLabels",
                         "popupAreaVars", "labelAreaVar", "Links", "colLinkVar", "sizeLinkVar", "popupLinkVars","type"))
  
  #Check compare
  .validCompare(compare,  c("mcYear", "type", "colAreaVar", "sizeAreaVars", "areaChartType", "showLabels",
                            "popupAreaVars", "labelAreaVar","colLinkVar", "sizeLinkVar", "popupLinkVars"))
  
  runScale <- ifelse(!identical(options[names(options)!="preprocess"] ,
                                tpMap[names(tpMap)!="preprocess"]), FALSE, TRUE)
  
  type <- match.arg(type)
  areaChartType <- match.arg(areaChartType)
  xyCompare <- match.arg(xyCompare)
  
  tmp_colAreaVar <- gsub("(_std$)|(_min$)|(_max$)", "", colAreaVar)
  if(tmp_colAreaVar != "none" & tmp_colAreaVar%in%colorsVars$Column & runScale)
  {
    raw <- colorsVars[Column == tmp_colAreaVar]
    options <- plotMapOptions(areaColorScaleOpts = colorScaleOptions(
      negCol = "#FF0000",
      # zeroCol = rgb(raw$red, raw$green, raw$blue,  maxColorValue = 255),
      # posCol = rgb(raw$red/2, raw$green/2, raw$blue/2, maxColorValue = 255)),
      # BP 2017
      zeroCol = "#FFFFFF", # BP 2017
      posCol = rgb(raw$red, raw$green, raw$blue, maxColorValue = 255)))
  }
  
  if (is.null(mcYear)) mcYear <- "average"
  
  if(!is.null(compare) && "list" %in% class(x)){
    if(length(x) == 1) x <- list(x[[1]], x[[1]])
  }
  if(!is.null(compare) && ("antaresData" %in% class(x)  | "simOptions" %in% class(x))){
    x <- list(x, x)
  }
  # .testXclassAndInteractive(x, interactive)
  
  h5requestFiltering <- .convertH5Filtering(h5requestFiltering = h5requestFiltering, x = x)
  
  
  compareOptions <- .compOpts(x, compare)
  if(is.null(compare)){
    if(compareOptions$ncharts > 1){
      compare <- ""
    }
  }
  
  group <- paste0("map-group-", sample(1e9, 1))
  
  # Check that parameters have the good class
  if (!is(mapLayout, "mapLayout")) stop("Argument 'mapLayout' must be an object of class 'mapLayout' created with function 'mapLayout'.")
  
  init_dateRange <- dateRange
  
  # new_env for save and control mapLayout
  env_plotFun <- new.env()
  
  processFun <- function(x, mapLayout) {
    if (!is(x, "antaresData")) {
      stop("Argument 'x' must be an object of class 'antaresData' created with function 'readAntares'.")
    } else {
      x <- as.antaresDataList(x)
      if(!is.null(x$areas)){
        if(nrow(x$areas) == 0){
          x$areas <- NULL
        }
      }
      if(!is.null(x$links)){
        if(nrow(x$links) == 0){
          x$links <- NULL
        }
      }
      if (is.null(x$areas) && is.null(x$links)) stop("Argument 'x' should contain at least area or link data.")
    }
    
    # Should parameter mcYear be shown in the UI ?
    showMcYear <- !attr(x, "synthesis") && length(unique(x[[1]]$mcYear)) > 1
    
    # Should links and/or areas be displayed ?
    areas <- !is.null(x$areas)
    links <- !is.null(x$links)
    
    # First and last time ids in data
    timeIdMin <- min(x[[1]]$timeId)
    timeIdMax <- max(x[[1]]$timeId)
    
    # Select first timeId if necessary
    if (is.null(timeId)){
      timeId <- timeIdMin
    }else{
      timeIdTp <- timeId
      if(!is.null(x$areas)){
        x$areas <- x$areas[timeId %in% timeIdTp]
      }
      
      if(!is.null(x$links)){
        x$links <- x$links[timeId %in% timeIdTp]
      }
      
      
    }
    
    # Keep only links and areas present in the data
    if (areas) {
      areaList <- unique(x$areas$area)
      mapLayout$coords <- mapLayout$coords[area %in% areaList]
      if(!is.null(mapLayout$map)){
        mapLayout$map <- mapLayout$map[match(mapLayout$coords$geoAreaId, mapLayout$map$geoAreaId), ]
      }
    }
    if (links) {
      linkList <- unique(x$links$link)
      mapLayout$links <- mapLayout$links[link %in% linkList]
    }
    
    # Precompute synthetic results and set keys for fast filtering
    syntx <- synthesize(x) 
    
    oldkeys <- lapply(x, key)
    
    if (attr(x, "synthesis")) {
      
      if(mcYear != "average"){
        .printWarningMcYear()
      }
      
      mcYear <- "average"
    } else {
      if (areas) setkeyv(x$areas, "mcYear")
      if (links) setkeyv(x$links, "mcYear")
    }
    
    opts <- simOptions(x)
    if(!is.null(x$areas)){
      x$areas[,time := .timeIdToDate(x$areas$timeId, attr(x, "timeStep"), opts)]
    }
    
    if(!is.null(x$links)){
      x$links[,time := .timeIdToDate(x$links$timeId, attr(x, "timeStep"), opts)]
    }
    
    if(is.null(init_dateRange)){
      if(!is.null(x$areas)){
        init_dateRange <- range(as.Date(x$areas$time))
      }else{
        init_dateRange <- range(as.Date(x$links$time))
      }
    }
    
    # Function that draws the final map when leaving the shiny gadget.
    plotFun <- function(t, colAreaVar, sizeAreaVars, popupAreaVars, areaChartType, 
                        uniqueScale, showLabels, labelAreaVar, colLinkVar, sizeLinkVar, 
                        popupLinkVars, 
                        type = c("detail", "avg"), mcYear,
                        initial = TRUE, session = NULL, outputId = "output1",
                        dateRange = NULL, sizeMiniPlot = FALSE, options = NULL) {
      type <- match.arg(type)
      if (type == "avg") t <- NULL
      else if (is.null(t)) t <- 0
      
      # Prepare data
      if (mcYear == "average") x <- syntx
      
      # print("dateRange")
      # print(dateRange)
      if(!is.null(dateRange)){
        dateRange <- sort(dateRange)
        # xx <<- copy(x)
        # dd <<- dateRange
        if(!is.null(x$areas))
        {
          # in case of missing transformation...
          if("character" %in% class(x$areas$time)){
            x$areas[,time := .timeIdToDate(x$areas$timeId, attr(x, "timeStep"), simOptions(x))]
          }
          if("Date" %in% class(x$areas$time)){
            x$areas[,time := as.POSIXct(time, tz = "UTC")]
          }
          x$areas  <- x$areas[time >= as.POSIXlt(dateRange[1], tz = "UTC") & time < as.POSIXlt(dateRange[2] + 1, tz = "UTC")]
        }
        if(!is.null(x$links))
        {
          # in case of missing transformation...
          if("character" %in% class(x$links$time)){
            x$links[,time := .timeIdToDate(x$links$timeId, attr(x, "timeStep"), simOptions(x))]
          }
          if("Date" %in% class(x$links$time)){
            x$links[,time := as.POSIXct(time, tz = "UTC")]
          }
          x$links <- x$links[time >= as.POSIXlt(dateRange[1], tz = "UTC") & time < as.POSIXlt(dateRange[2] + 1, tz = "UTC")]
        }
      }
      
      if (initial) {
        assign("currentMapLayout", mapLayout, envir = env_plotFun)
        map <- .initMap(x, mapLayout, options, language = language) %>% syncWith(group)
      } else if(!isTRUE(all.equal(mapLayout, get("currentMapLayout", envir = env_plotFun)))){
        assign("currentMapLayout", mapLayout)
        map <- .initMap(x, mapLayout, options, language = language) %>% syncWith(group)
      } else {
        # in some case, map doesn't existed yet....!
        if("output_1_zoom" %in% names(session$input)){
          map <- leafletProxy(outputId, session)
        } else {
          map <- .initMap(x, mapLayout, options, language = language) %>% syncWith(group)
        }
      }
      map <- map %>% 
        .redrawLinks(x, mapLayout, mcYear, t, colLinkVar, sizeLinkVar, popupLinkVars, options) %>% 
        .redrawCircles(x, mapLayout, mcYear, t, colAreaVar, sizeAreaVars, popupAreaVars, 
                       uniqueScale, showLabels, labelAreaVar, areaChartType, options, sizeMiniPlot)
      
      # combineWidgets(map, width = width, height = height) # bug
      map
      
    }
    
    
    # Create the interactive widget
    if(language != "en"){
      ind_to_change <- which(colnames(x$areas) %in% language_columns$en)
      if(length(ind_to_change) > 0){
        new_name <- language_columns[en %in% colnames(x$areas), ]
        v_new_name <- new_name[[language]]
        names(v_new_name) <- new_name[["en"]]
        setnames(x$areas, colnames(x$areas)[ind_to_change], unname(v_new_name[colnames(x$areas)[ind_to_change]]))
        
        # BP 2017
        # keep subset
        # ind_to_keep <- which(colnames(x$areas) %in% language_columns$en[language_columns$keep_bp])
        # x$areas <- x$areas[, c(.idCols(x$areas), colnames(x$areas)[ind_to_keep]), with = FALSE]
        # ind_to_change <- which(colnames(x$areas) %in% language_columns$en)
        # 
        # new_name <- language_columns[en %in% colnames(x$areas), ]
        # v_new_name <- new_name[["bp"]]
        # names(v_new_name) <- new_name[["en"]]
        # setnames(x$areas, colnames(x$areas)[ind_to_change], unname(v_new_name[colnames(x$areas)[ind_to_change]]))
      }
      
      ind_to_change <- which(colnames(syntx$areas) %in% language_columns$en)
      if(length(ind_to_change) > 0){
        new_name <- language_columns[en %in% colnames(syntx$areas), ]
        v_new_name <- new_name[[language]]
        names(v_new_name) <- new_name[["en"]]
        setnames(syntx$areas, colnames(syntx$areas)[ind_to_change], unname(v_new_name[colnames(syntx$areas)[ind_to_change]]))
        
        # BP 2017
        # keep subset
        # ind_to_keep <- which(colnames(syntx$areas) %in% language_columns$en[language_columns$keep_bp])
        # syntx$areas <- syntx$areas[, c(.idCols(syntx$areas), colnames(syntx$areas)[ind_to_keep]), with = FALSE]
        # ind_to_change <- which(colnames(syntx$areas) %in% language_columns$en)
        # 
        # new_name <- language_columns[en %in% colnames(syntx$areas), ]
        # v_new_name <- new_name[["bp"]]
        # names(v_new_name) <- new_name[["en"]]
        # setnames(syntx$areas, colnames(syntx$areas)[ind_to_change], unname(v_new_name[colnames(syntx$areas)[ind_to_change]]))
      }
      
      ind_to_change <- which(colnames(x$links) %in% language_columns$en)
      if(length(ind_to_change) > 0){
        # new_name <- language_columns[en %in% colnames(x$links), ]
        # v_new_name <- new_name[[language]]
        # names(v_new_name) <- new_name[["en"]]
        # setnames(x$links, colnames(x$links)[ind_to_change], unname(v_new_name[colnames(x$links)[ind_to_change]]))
        # 
        # BP 2017
        # keep subset
        ind_to_keep <- which(colnames(x$links) %in% language_columns$en[language_columns$keep_bp])
        x$links <- x$links[, c(.idCols(x$links), colnames(x$links)[ind_to_keep]), with = FALSE]
        ind_to_change <- which(colnames(x$links) %in% language_columns$en)
        
        new_name <- language_columns[en %in% colnames(x$links), ]
        v_new_name <- new_name[["bp"]]
        names(v_new_name) <- new_name[["en"]]
        setnames(x$links, colnames(x$links)[ind_to_change], unname(v_new_name[colnames(x$links)[ind_to_change]]))
      }
      
      ind_to_change <- which(colnames(syntx$links) %in% language_columns$en)
      if(length(ind_to_change) > 0){
        # new_name <- language_columns[en %in% colnames(syntx$links), ]
        # v_new_name <- new_name[[language]]
        # names(v_new_name) <- new_name[["en"]]
        # setnames(syntx$links, colnames(syntx$links)[ind_to_change], unname(v_new_name[colnames(syntx$links)[ind_to_change]]))
        # 
        # BP 2017
        # keep subset
        ind_to_keep <- which(colnames(syntx$links) %in% language_columns$en[language_columns$keep_bp])
        syntx$links <- syntx$links[, c(.idCols(syntx$links), colnames(syntx$links)[ind_to_keep]), with = FALSE]
        ind_to_change <- which(colnames(syntx$links) %in% language_columns$en)
        
        new_name <- language_columns[en %in% colnames(syntx$links), ]
        v_new_name <- new_name[["bp"]]
        names(v_new_name) <- new_name[["en"]]
        setnames(syntx$links, colnames(syntx$links)[ind_to_change], unname(v_new_name[colnames(syntx$links)[ind_to_change]]))
      }
    }
    
    areaValColumns <- setdiff(names(x$areas), .idCols(x$areas))
    areaValColumnsSynt <- setdiff(names(syntx$areas), .idCols(syntx$areas))
    
    areaNumValColumns <- sapply(x$areas, is.numeric)
    areaNumValColumns <- names(areaNumValColumns)[areaNumValColumns == TRUE]
    areaNumValColumns <- intersect(areaValColumns, areaNumValColumns)
    
    linkValColums <- setdiff(names(x$links), .idCols(x$links))
    
    linkNumValColumns <- sapply(x$links, is.numeric)
    linkNumValColumns <- names(linkNumValColumns)[linkNumValColumns == TRUE]
    linkNumValColumns <- intersect(linkValColums, linkNumValColumns)
    # We don't want to show the time id slider if there is only one time id
    hideTimeIdSlider <- timeIdMin == timeIdMax
    
    list(
      plotFun = plotFun,
      x = x,
      showMcYear = showMcYear,
      areaValColumns = areaValColumns,
      areaValColumnsSynt = areaValColumnsSynt,
      areaNumValColumns = areaNumValColumns,
      linkValColums = linkValColums,
      linkNumValColumns = linkNumValColumns,
      hideTimeIdSlider = hideTimeIdSlider,
      timeId = timeId,
      dateRange = init_dateRange
    )
  }
  
  if (!interactive) {
    x <- .cleanH5(x, timeSteph5, mcYearh5, tablesh5, h5requestFiltering)
    
    
    params <- .getDataForComp(.giveListFormat(x), NULL, compare, compareOpts, processFun = processFun, mapLayout = mapLayout)
    L_w <- lapply(params$x, function(X){
      X$plotFun(t = timeId, colAreaVar = colAreaVar, sizeAreaVars = sizeAreaVars,
                popupAreaVars = popupAreaVars, areaChartType = areaChartType,
                uniqueScale = uniqueScale, showLabels = showLabels,
                labelAreaVar = labelAreaVar, colLinkVar = colLinkVar, 
                sizeLinkVar = sizeLinkVar, popupLinkVars = popupLinkVars,
                type = type, mcYear = mcYear, dateRange = dateRange,
                sizeMiniPlot = sizeMiniPlot, options = options)
    })
    return(combineWidgets(list = L_w,  title = main, width = width, height = height))  
    
    
  }
  
  ##remove notes
  mcYearH5 <- NULL
  paramsH5 <- NULL
  sharerequest <- NULL
  timeStepdataload <- NULL
  timeSteph5 <- NULL
  x_in <- NULL
  x_tranform <- NULL
  
  manipulateWidget(
    {
      if(!is.null(params))
      {
        if(.id <= length(params$x)){
          .tryCloseH5()
          
          tmp_options <- optionsT
          if(is.null(tmp_options)){
            tmp_options <-  plotMapOptions()
          }
          
          widget <- params$x[[.id]]$plotFun(t = params$x[[.id]]$timeId,
                                            colAreaVar = colAreaVar,
                                            sizeAreaVars = sizeAreaVars,
                                            popupAreaVars = popupAreaVars,
                                            areaChartType = areaChartType,
                                            uniqueScale = uniqueScale,
                                            showLabels = showLabels,
                                            labelAreaVar = labelAreaVar,
                                            colLinkVar = colLinkVar,
                                            sizeLinkVar = sizeLinkVar, 
                                            popupLinkVars = popupLinkVars,
                                            type = type,
                                            mcYear = mcYear,
                                            initial = .initial,
                                            session = .session,
                                            outputId = .output,
                                            dateRange = dateRange,
                                            sizeMiniPlot = sizeMiniPlot,
                                            options = tmp_options)
          
          # controlWidgetSize(widget, language) # bug due to leaflet and widget
          widget
        } else {
          combineWidgets(switch(language, 
                                "fr" = "Pas de données pour cette sélection",
                                "No data for this selection"))
        }
      }else{
        combineWidgets()
      }
    },
    
    x = mwSharedValue({x}),
    x_in = mwSharedValue({
      .giveListFormat(x)
    }),
    
    h5requestFiltering = mwSharedValue({h5requestFiltering}),
    
    paramsH5 = mwSharedValue({
      paramsH5List <- .h5ParamList(X_I = x_in, xyCompare = xyCompare, h5requestFilter = h5requestFiltering)
      rhdf5::H5close()
      paramsH5List
    }),
    H5request = mwGroup(
      label = .getLabelLanguage("H5request", language),
      # BP 2017
      eventsH5 = mwSelect(choices =  {
        choix = c("By event", "By mcYear")
        names(choix) <- sapply(choix, function(tmp) .getLabelLanguage(tmp, language))
        choix
      }, value = "By event",
      multiple = FALSE, label = .getLabelLanguage("Selection", language), .display = !"eventsH5" %in% hidden),
      timeSteph5 = mwSelect(
        {
          if(length(paramsH5) > 0 & length(eventsH5) > 0){
            # choices = paramsH5$timeStepS
            # BP 2017
            if(eventsH5 %in% "By event"){
              choices = c("hourly")
            } else {
              choices = setdiff(paramsH5$timeStepS, "annual")
            }
            
            names(choices) <- sapply(choices, function(x) .getLabelLanguage(x, language))
            choices
          } else {
            NULL
          }
        }, 
        value =  if(.initial) {
          paramsH5$timeStepS[1]
        }else{NULL},
        label = .getLabelLanguage("timeStep", language), 
        multiple = FALSE, .display = !"timeSteph5" %in% hidden & length(intersect("By mcYear", eventsH5)) > 0
      ),
      tables = mwSelect( 
        {
          if(length(paramsH5) > 0){
            choices = paramsH5[["tabl"]][paramsH5[["tabl"]] %in% c("areas", "links")]
            names(choices) <- sapply(choices, function(x) .getLabelLanguage(x, language))
          } else {
            choices <- NULL
          }
          choices
        },
        value = {
          if(.initial) {paramsH5[["tabl"]][paramsH5[["tabl"]] %in% c("areas", "links")]} else {NULL}
        }, 
        label = .getLabelLanguage("table", language), multiple = TRUE, 
        .display = !"tables" %in% hidden
      ),
      # mcYearH5 = mwSelect(choices = c(paramsH5[["mcYearS"]]), 
      #                     value = {
      #                       if(.initial){paramsH5[["mcYearS"]][1]}else{NULL}
      #                     }, 
      #                     label = .getLabelLanguage("mcYears to be imported", language), multiple = TRUE, 
      #                     .display = !"mcYearH5" %in% hidden
      # ),
      mcYearH5 = mwSelect(choices = {
        if(length(eventsH5) > 0){
          if(eventsH5 %in% "By event"){
            bp_mcy_params_labels
          } else {
            paramsH5[["mcYearS"]]
          }
        } else {
          NULL
        }
      },
      value = "35",
      label = .getLabelLanguage("mcYears to be imported", language), 
      .display = (!"mcYearH5" %in% hidden & length(intersect("By mcYear", eventsH5)) > 0 & !meanYearH5) | 
        (!"mcYearH5" %in% hidden & length(intersect("By event", eventsH5)) > 0)
      ),
      meanYearH5 = mwCheckbox(value = FALSE, 
                              label = .getLabelLanguage("Average mcYear", language),
                              .display = !"meanYearH5" %in% hidden & length(intersect("By mcYear", eventsH5)) > 0),
      .display = {any(unlist(lapply(x_in, .isSimOpts))) &  !"H5request" %in% hidden}
    ),
    sharerequest = mwSharedValue({
      if(length(meanYearH5) > 0 & length(eventsH5) > 0){
        if(meanYearH5 & eventsH5 %in% "By mcYear"){
          list(timeSteph5_l = timeSteph5, mcYearh_l = NULL, tables_l = tables)
        } else {
          list(timeSteph5_l = timeSteph5, mcYearh_l = mcYearH5, tables_l = tables)
        }
      } else {
        list(timeSteph5_l = timeSteph5, mcYearh_l = mcYearH5, tables_l = tables)
      }
    }),
    x_tranform = mwSharedValue({
      sapply(1:length(x_in),function(zz){
        .loadH5Data(sharerequest, x_in[[zz]], h5requestFilter = paramsH5$h5requestFilter[[zz]])
      }, simplify = FALSE)
    }),
    
    ##Stop h5
    mcYear = mwSelect(
      {
        # allMcY <- c("average",  .compareOperation(lapply(params$x, function(vv){
        #   unique(c(vv$x$areas$mcYear, vv$x$links$mcYear))
        # }), xyCompare))
        # names(allMcY) <- c(.getLabelLanguage("average", language), allMcY[-1])
        # allMcY
        # BP 2017
        allMcY <- .compareOperation(lapply(params$x, function(vv){
          unique(c(vv$x$areas$mcYear, vv$x$links$mcYear))
        }), xyCompare)
        names(allMcY) <- allMcY
        if(is.null(allMcY)){
          allMcY <- "average"
          names(allMcY) <- .getLabelLanguage("average", language)
        }
        allMcY
        
      }, 
      value = { if(.initial) mcYear else NULL}, 
      .display = any(unlist(lapply(params$x, function(X){X$showMcYear}))) & !"mcYear" %in% hidden, 
      label = .getLabelLanguage("mcYear to be displayed", language)
    ),
    type = mwRadio(
      {
        choices <- c("detail", "avg")
        names(choices) <- c(.getLabelLanguage("By time id", language), .getLabelLanguage("Average", language))
        choices
      },
      value = type, 
      label = .getLabelLanguage("type", language), 
      .display = !"type" %in% hidden
    ),
    dateRange = mwDateRange(
      value = {
        # if(.initial) params$x[[1]]$dateRange
        # else NULL
        # BP 2017
        if(length(intersect("By event", eventsH5) > 0)){
          tmp_mcYear <- as.character(mcYear)
          c(bp_mcy_params[mcYear == tmp_mcYear, date_start], bp_mcy_params[mcYear == tmp_mcYear, date_end])
        } else if(.initial){
          c("2029-01-15", "2029-01-21")
        } else if(attr(params$x[[1]]$x, "timeStep") %in% c("daily", "weekly", "monthly")){
          c("2028-07-01", "2029-06-29")
        }
      },
      min = {
        params$x[[1]]$dateRange[1]
        # BP 17
        "2028-07-01"
      }, 
      max = {
        # params$x[[1]]$dateRange[2]
        
        # BP 17
        "2029-06-29"
      }, 
      language = eval(parse(text = "language")),
      # BP 2017
      format = "dd MM",
      separator = " : ",
      weekstart = 1,
      label = .getLabelLanguage("dateRange", language), 
      # .display = !"dateRange" %in% hidden
      # BP 17
      .display = !"dateRange" %in% hidden & eventsH5 %in% "By mcYear"
    ),
    
    Areas = mwGroup(
      label = .getLabelLanguage("Areas", language),
      colAreaVar = mwSelect(
        choices = {
          if(length(params) > 0){
            if (mcYear == "average") {
              tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
                unique(vv$areaValColumnsSynt)
              }), xyCompare)))
            }else{
              tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
                unique(vv$areaValColumns)
              }), xyCompare)))
            }
            names(tmp) <- c(.getLabelLanguage("none", language), tmp[-1])
            tmp
          } else {
            NULL
          }
        },
        value = {
          if(.initial) colAreaVar
          else NULL
        },
        label = .getLabelLanguage("Color", language), 
        .display = !"colAreaVar" %in% hidden
      ),
      sizeAreaVars = mwSelect(
        {
          if(length(params) > 0){
            as.character(.compareOperation(lapply(params$x, function(vv){
              unique(vv$areaNumValColumns)
            }), xyCompare))
          } else {
            NULL
          }
        }, 
        value = {
          if(.initial) sizeAreaVars
          else NULL
        }, 
        label = .getLabelLanguage("Size", language), 
        multiple = TRUE, .display = !"sizeAreaVars" %in% hidden
      ),
      miniPlot = mwGroup(
        label = .getLabelLanguage("miniPlot", language),
        areaChartType = mwSelect(
          {
            # choices <- c("bar", "pie", "polar-area", "polar-radius")
            # names(choices) <- c(.getLabelLanguage("bar chart", language), 
            #                     .getLabelLanguage("pie chart", language), 
            #                     .getLabelLanguage("polar (area)", language),
            #                     .getLabelLanguage("polar (radius)", language))
            # choices
            
            # BP 17
            choices <- c("bar", "pie")
            names(choices) <- c(.getLabelLanguage("bar chart", language), 
                                .getLabelLanguage("pie chart", language))
            choices
          },
          value = {
            if(.initial) areaChartType
            else NULL
          }, label = .getLabelLanguage("areaChartType", language), 
          .display = !"areaChartType" %in% hidden
        ),
        sizeMiniPlot = mwCheckbox(sizeMiniPlot, label = .getLabelLanguage("sizeMiniPlot", language)),
        .display = length(sizeAreaVars) >= 2 & !"miniPlot" %in% hidden
      ),
      uniqueScale = mwCheckbox(uniqueScale, label = .getLabelLanguage("Unique scale", language), 
                               .display = length(sizeAreaVars) >= 2 && areaChartType != "pie" & !"uniqueScale" %in% hidden
      ),
      showLabels = mwCheckbox(showLabels, label = .getLabelLanguage("Show labels", language), 
                              .display = length(sizeAreaVars) >= 2 & !"showLabels" %in% hidden
      ),
      popupAreaVars = mwSelect(
        choices = 
        {
          if(length(params) > 0){
            if (mcYear == "average") {
              tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
                unique(vv$areaValColumnsSynt)
              }), xyCompare))
              )
            }else{
              tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
                unique(vv$areaValColumns)
              }), xyCompare)))
            }
            names(tmp) <- c(.getLabelLanguage("none", language), tmp[-1])
            tmp
          } else {
            NULL
          }
        }, 
        value = {
          if(.initial) popupAreaVars
          else NULL
        }, 
        label = .getLabelLanguage("Popup", language), 
        multiple = TRUE, .display = !"popupAreaVars" %in% hidden
      ),
      labelAreaVar = mwSelect(
        choices = {
          if(length(params) > 0){
            if (mcYear == "average") {
              tmp <- c("none",
                       as.character(.compareOperation(lapply(params$x, function(vv){
                         unique(vv$areaValColumnsSynt)
                       }), xyCompare))
              )
            }else{
              tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
                unique(vv$areaValColumns)
              }), xyCompare)))
            }
            names(tmp) <- c(.getLabelLanguage("none", language), tmp[-1])
            tmp
          } else {
            NULL
          }
        }, 
        value = {
          if(.initial) labelAreaVar
          else NULL
        }, label = .getLabelLanguage("Label", language), 
        .display = length(sizeAreaVars) < 2 & !"labelAreaVar" %in% hidden
      ),
      .display = any(sapply(params$x, function(p) {"areas" %in% names(p$x)})) & !"Areas" %in% hidden
    ),
    
    Links = mwGroup(
      label = .getLabelLanguage("Links", language),
      colLinkVar = mwSelect(
        {
          if(length(params) > 0){
            tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
              unique(vv$linkValColums)
            }), xyCompare)))
            names(tmp) <- c(.getLabelLanguage("none", language), tmp[-1])
            tmp
          } else {
            NULL
          }
        }, 
        value = {
          if(.initial) colLinkVar
          else NULL
        }, label = .getLabelLanguage("Color", language), .display = !"colLinkVar" %in% hidden
      ),
      sizeLinkVar = mwSelect(
        {
          if(length(params) > 0){
            tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
              unique(vv$linkNumValColumns)
            }), xyCompare)))
            names(tmp) <- c(.getLabelLanguage("none", language), tmp[-1])
            tmp
          } else {
            NULL
          }
          
        }, 
        value = {
          if(.initial) sizeLinkVar
          else NULL
        }, label = .getLabelLanguage("Width", language), .display = !"sizeLinkVar" %in% hidden
      ),
      popupLinkVars = mwSelect(
        {
          if(length(params) > 0){
            tmp <- c("none", as.character(.compareOperation(lapply(params$x, function(vv){
              unique(vv$linkValColums)
            }), xyCompare)))
            names(tmp) <- c(.getLabelLanguage("none", language), tmp[-1])
            tmp
          } else {
            NULL
          }
        },
        value = {
          if(.initial) popupLinkVars
          else NULL
        }, label = .getLabelLanguage("Popup", language), multiple = TRUE, .display = !"popupLinkVars" %in% hidden
      ),
      .display = any(sapply(params$x, function(p) {"links" %in% names(p$x)})) & !"Links" %in% hidden
    ),
    mapLayout = mwSharedValue(mapLayout),
    params = mwSharedValue({
      if(length(x_tranform) > 0 & length(mapLayout) > 0){
        .getDataForComp(x_tranform, NULL, compare, compareOpts, 
                        processFun = processFun, mapLayout = mapLayout)
      } 
    }),
    options = mwSharedValue({options}),
    optionsT = mwSharedValue({
      if(length(colAreaVar) > 0){
        tmp_colAreaVar <- gsub("(_std$)|(_min$)|(_max$)", "", colAreaVar)
        if(tmp_colAreaVar %in% colorsVars$Column & runScale){
          raw <- colorsVars[Column == tmp_colAreaVar]
          plotMapOptions(areaColorScaleOpts = colorScaleOptions(
            negCol = "#FF0000",
            # zeroCol = rgb(raw$red, raw$green, raw$blue,  maxColorValue = 255),
            # posCol = rgb(raw$red/2, raw$green/2, raw$blue/2, maxColorValue = 255)),
            # BP 2017
            zeroCol = "#FFFFFF", # BP 2017
            posCol = rgb(raw$red, raw$green, raw$blue, maxColorValue = 255))
          )
        }else{
          options
        }
      }else{
        options
      }
    }),
    .width = width,
    .height = height,
    .compare = {
      compare
    },
    .compareOpts = {
      compareOptions
    },
    .return = function(w, e) {combineWidgets(w, title = main, width = width, height = height)},
    ...
  )
  
}

