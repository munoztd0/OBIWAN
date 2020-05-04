
plot_mod <- function(model,
                       type = c("est", "re", "eff", "emm", "pred", "int", "std", "std2", "slope", "resid", "diag"),
                       transform,
                       terms = NULL,
                       sort.est = NULL,
                       rm.terms = NULL,
                       group.terms = NULL,
                       order.terms = NULL,
                       pred.type = c("fe", "re"),
                       mdrt.values = c("minmax", "meansd", "zeromax", "quart", "all"),
                       ri.nr = NULL,
                       title = NULL,
                       axis.title = NULL,
                       axis.labels = NULL,
                       legend.title = NULL,
                       wrap.title = 50,
                       wrap.labels = 25,
                       axis.lim = NULL,
                       grid.breaks = NULL,
                       ci.lvl = NULL,
                       se = NULL,
                       robust = FALSE,
                       vcov.fun = NULL,
                       vcov.type = c("HC3", "const", "HC", "HC0", "HC1", "HC2", "HC4", "HC4m", "HC5"),
                       vcov.args = NULL,
                       colors = "Set1",
                       show.intercept = FALSE,
                       show.values = FALSE,
                       show.p = TRUE,
                       show.data = FALSE,
                       show.legend = TRUE,
                       show.zeroinf = TRUE,
                       value.offset = NULL,
                       value.size,
                       jitter = NULL,
                       digits = 2,
                       dot.size = NULL,
                       line.size = NULL,
                       vline.color = NULL,
                       p.threshold = c(0.05, 0.01, 0.001),
                       p.adjust = NULL,
                       grid,
                       case,
                       auto.label = TRUE,
                       prefix.labels = c("none", "varname", "label"),
                       bpe = "median",
                       bpe.style = "line",
                       bpe.color = "white",
                       ci.style = c("whisker", "bar"),
                       ...
) {
  
  type <- match.arg(type)
  pred.type <- match.arg(pred.type)
  mdrt.values <- match.arg(mdrt.values)
  prefix.labels <- match.arg(prefix.labels)
  vcov.type <- match.arg(vcov.type)
  ci.style <- match.arg(ci.style)
  
  # if we prefix labels, use different default for case conversion,
  # else the separating white spaces after colon are removed.
  if (missing(case)) {
    if (prefix.labels == "none")
      case <- "parsed"
    else
      case <- NULL
  }
  
  if (isTRUE(robust)) {
    vcov.type <- "HC3"
    vcov.fun <- "vcovHC"
  }
  
  # check se-argument
  vcov.fun <- check_se_argument(se = vcov.fun, type = type)
  
  
  # get info on model family
  fam.info <- insight::model_info(model)
  
  if (insight::is_multivariate(model))
    fam.info <- fam.info[[1]]
  
  # check whether estimates should be transformed or not
  
  if (missing(transform)) {
    if (fam.info$is_linear)
      transform <- NULL
    else
      transform <- "exp"
  }
  
  
  # get titles and labels for axis ----
  
  # this is not appropriate when plotting random effects,
  # so retrieve labels only for other plot types
  
  if (type %in% c("est", "std", "std2") && isTRUE(auto.label)) {
    
    # get labels of dependent variables, and wrap them if too long
    if (is.null(title)) title <- sjlabelled::response_labels(model, case = case, mv = fam.info$is_multivariate, ...)
    title <- sjmisc::word_wrap(title, wrap = wrap.title)
    
    # labels for axis with term names
    if (is.null(axis.labels)) {
      term_labels <- sjlabelled::term_labels(model, case = case, prefix = prefix.labels, ...)
      if (.labelled_model_data(model) || is.stan(model)) axis.labels <- term_labels
    }
    axis.labels <- sjmisc::word_wrap(axis.labels, wrap = wrap.labels)
    
    # title for axis with estimate values
    if (is.null(axis.title)) axis.title <- sjmisc::word_wrap(estimate_axis_title(fit = model, axis.title = axis.title, type = type, transform = transform, include.zeroinf = TRUE), wrap = wrap.title)
    axis.title <- sjmisc::word_wrap(axis.title, wrap = wrap.labels)
    
  }
  
  
  # check nr of estimates. if only one, plot slope
  if (type == "est" &&
      length(insight::find_predictors(model, component = "conditional", flatten = TRUE)) == 1 &&
      length(insight::find_predictors(model, component = "instruments", flatten = TRUE)) == 0 &&
      fam.info$is_linear && one_par(model)) type <- "slope"
  
  
  # set some default options for stan-models, which are not
  # available or appropriate for these
  
  if (is.stan(model)) {
    # no p-values
    show.p <- FALSE
    # no standardized coefficients
    if (type %in% c("std", "std2", "slope")) type <- "est"
  }
  
  
  # set defaults for arguments, depending on model ----
  
  if (is.null(ci.lvl)) ci.lvl <- dplyr::if_else(is.stan(model), .89, .95)
  if (is.null(dot.size)) dot.size <- dplyr::if_else(is.stan(model), 1, 2.5)
  if (is.null(line.size)) line.size <- dplyr::if_else(is.stan(model), .7, .7)
  if (is.null(value.offset)) value.offset <- dplyr::if_else(is.stan(model), .25, .15)
  
  
  # check if plot-type is applicable
  
  if (type == "slope" && !fam.info$is_linear) {
    type <- "est"
    message("Plot-type \"slope\" only available for linear models. Using `type = \"est\"` now.")
  }
  
  
  if (type %in% c("est", "std", "std2") || (is.stan(model) && type == "re")) {
    
    # plot estimates ----
    
    p <- plot_type_est(
      type = type,
      ci.lvl = ci.lvl,
      se = se,
      tf = transform,
      model = model,
      terms = terms,
      group.terms = group.terms,
      rm.terms = rm.terms,
      sort.est = sort.est,
      title = title,
      axis.title = axis.title,
      axis.labels = axis.labels,
      axis.lim = axis.lim,
      grid.breaks = grid.breaks,
      show.intercept = show.intercept,
      show.values = show.values,
      show.p = show.p,
      value.offset = value.offset,
      digits = digits,
      geom.colors = colors,
      geom.size = dot.size,
      line.size = line.size,
      order.terms = order.terms,
      vline.color = vline.color,
      value.size = value.size,
      bpe = bpe,
      bpe.style = bpe.style,
      bpe.color = bpe.color,
      facets = grid,
      show.zeroinf = show.zeroinf,
      p.threshold = p.threshold,
      vcov.fun = vcov.fun,
      vcov.type = vcov.type,
      vcov.args = vcov.args,
      ci.style = ci.style,
      p_adjust = p.adjust,
      ...
    )
    
  } else if (type == "re") {
    
    # plot random effects ----
    
    p <- plot_type_ranef(
      model = model,
      ri.nr = ri.nr,
      ci.lvl = ci.lvl,
      se = se,
      tf = transform,
      sort.est = sort.est,
      title = title,
      axis.labels = axis.labels,
      axis.lim = axis.lim,
      grid.breaks = grid.breaks,
      show.values = show.values,
      value.offset = value.offset,
      digits = digits,
      facets = grid,
      geom.colors = colors,
      geom.size = dot.size,
      line.size = line.size,
      vline.color = vline.color,
      value.size = value.size,
      bpe.color = bpe.color,
      ci.style = ci.style,
      ...
    )
    
  } else if (type %in% c("pred", "eff", "emm")) {
    
    # plot marginal effects ----
    
    p <- plot_type_eff(
      type = type,
      model = model,
      terms = terms,
      ci.lvl = ci.lvl,
      pred.type = pred.type,
      facets = grid,
      show.data = show.data,
      jitter = jitter,
      geom.colors = colors,
      axis.title = axis.title,
      title = title,
      legend.title = legend.title,
      axis.lim = axis.lim,
      case = case,
      show.legend = show.legend,
      dot.size = dot.size,
      line.size = line.size,
      ...
    )
    
  } else if (type == "int") {
    
    # plot interaction terms ----
    
    p <- plot_type_int(
      model = model,
      mdrt.values = mdrt.values,
      ci.lvl = ci.lvl,
      pred.type = pred.type,
      facets = grid,
      show.data = show.data,
      jitter = jitter,
      geom.colors = colors,
      axis.title = axis.title,
      title = title,
      legend.title = legend.title,
      axis.lim = axis.lim,
      case = case,
      show.legend = show.legend,
      dot.size = dot.size,
      line.size = line.size,
      ...
    )
    
    
  } else if (type %in% c("slope", "resid")) {
    
    # plot slopes of estimates ----
    
    p <- plot_type_slope(
      model = model,
      terms = terms,
      rm.terms = rm.terms,
      ci.lvl = ci.lvl,
      colors = colors,
      title = title,
      show.data = show.data,
      jitter = jitter,
      facets = grid,
      axis.title = axis.title,
      case = case,
      useResiduals = type == "resid",
      ...
    )
    
  } else if (type == "diag") {
    
    # plot diagnostic plots ----
    
    if (is.stan(model)) {
      
      p <- plot_diag_stan(
        model = model,
        geom.colors = colors,
        axis.lim = axis.lim,
        facets = grid,
        axis.labels = axis.labels,
        ...
      )
      
    } else if (fam.info$is_linear) {
      
      p <- plot_diag_linear(
        model = model,
        geom.colors = colors,
        dot.size = dot.size,
        line.size = line.size,
        ...
      )
      
    } else {
      
      p <- plot_diag_glm(
        model = model,
        geom.colors = colors,
        dot.size = dot.size,
        line.size = line.size,
        ...
      )
      
    }
    
  }
  
  p
}


#' @importFrom purrr map
#' @rdname plot_model
#' @export
get_model_data <- function(model,
                           type = c("est", "re", "eff", "pred", "int", "std", "std2", "slope", "resid", "diag"),
                           transform,
                           terms = NULL,
                           sort.est = NULL,
                           rm.terms = NULL,
                           group.terms = NULL,
                           order.terms = NULL,
                           pred.type = c("fe", "re"),
                           ri.nr = NULL,
                           ci.lvl = NULL,
                           colors = "Set1",
                           grid,
                           case = "parsed",
                           digits = 2,
                           ...) {
  p <- plot_model(
    model = model,
    type = type,
    transform = transform,
    terms = terms,
    sort.est = sort.est,
    rm.terms = rm.terms,
    group.terms = group.terms,
    order.terms = order.terms,
    pred.type = pred.type,
    ri.nr = ri.nr,
    ci.lvl = ci.lvl,
    colors = colors,
    grid = grid,
    case = case,
    digits = digits,
    auto.label = FALSE,
    ...
  )
  
  
  if (inherits(p, "list"))
    purrr::map(p, ~ .x$data)
  else
    p$data
}


one_par <- function(model) {
  tryCatch(
    {
      length(stats::coef(model)) <= 2
    },
    error = function(x) { FALSE }
  )
}

