is.stan <- function(x) inherits(x, c("stanreg", "stanfit", "brmsfit"))

check_se_argument <- function(se, type = NULL) {
  if (!is.null(se) && !is.null(type) && type %in% c("std", "std2")) {
    warning("No robust standard errors for `type = \"std\"` or `type = \"std2\"`.")
    se <- NULL
  }
  
  if (!is.null(se) && !is.null(type) && type == "re") {
    warning("No robust standard errors for `type = \"re\"`.")
    se <- NULL
  }
  
  se
}

col_check2 <- function(geom.colors, collen) {
  # --------------------------------------------
  # check color argument
  # --------------------------------------------
  # check for corrct color argument
  if (!is.null(geom.colors)) {
    # check for color brewer palette
    if (is.brewer.pal(geom.colors[1])) {
      geom.colors <- scales::brewer_pal(palette = geom.colors[1])(collen)
    } else if (is.sjplot.pal(geom.colors[1])) {
      geom.colors <- get_sjplot_colorpalette(geom.colors[1], collen)
      # do we have correct amount of colours?
    } else if (geom.colors[1] == "gs") {
      geom.colors <- scales::grey_pal()(collen)
      # do we have correct amount of colours?
    } else if (geom.colors[1] == "bw") {
      geom.colors <- rep("black", times = collen)
      # do we have correct amount of colours?
    } else if (length(geom.colors) > collen) {
      # shorten palette
      geom.colors <- geom.colors[1:collen]
    } else if (length(geom.colors) < collen) {
      # repeat color palette
      geom.colors <- rep(geom.colors, times = collen)
      # shorten to required length
      geom.colors <- geom.colors[1:collen]
    }
  } else {
    geom.colors <- scales::brewer_pal(palette = "Set1")(collen)
  }
  
  geom.colors
}

# check whether a color value is indicating
# a color brewer palette
is.brewer.pal <- function(pal) {
  bp.seq <- c("BuGn", "BuPu", "GnBu", "OrRd", "PuBu", "PuBuGn", "PuRd", "RdPu",
              "YlGn", "YlGnBu", "YlOrBr", "YlOrRd", "Blues", "Greens", "Greys",
              "Oranges", "Purples", "Reds")
  bp.div <- c("BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu",
              "RdYlGn", "Spectral")
  bp.qul <- c("Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1",
              "Set2", "Set3")
  bp <- c(bp.seq, bp.div, bp.qul)
  pal %in% bp
}


is.sjplot.pal <- function(pal) {
  pal %in% names(sjplot_colors)
}


get_sjplot_colorpalette <- function(pal, len) {
  col <- sjplot_colors[[pal]]
  
  if (len > length(col)) {
    warning("More colors requested than length of color palette.", call. = F)
    len <- length(col)
  }
  
  col[1:len]
}

sjplot_colors <- list(
  `aqua` = c("#BAF5F3", "#46A9BE", "#8B7B88", "#BD7688", "#F2C29E"),
  `warm` = c("#072835", "#664458", "#C45B46", "#F1B749", "#F8EB85"),
  `dust` = c("#232126", "#7B5756", "#F7B98B", "#F8F7CF", "#AAAE9D"),
  `blambus` = c("#E02E1F", "#5D8191", "#BD772D", "#494949", "#F2DD26"),
  `simply` = c("#CD423F", "#0171D3", "#018F77", "#FCDA3B", "#F5C6AC"),
  `us` = c("#004D80", "#376C8E", "#37848E", "#9BC2B6", "#B5D2C0"),
  `reefs` = c("#43a9b6", "#218282", "#dbdcd1", "#44515c", "#517784"),
  `breakfast club` = c("#b6411a", "#4182dd", "#2d6328", "#eec3d8", "#ecf0c8"),
  `metro` = c("#d11141", "#00aedb", "#00b159", "#f37735", "#8c8c8c", "#ffc425", "#cccccc"),
  `viridis` = c("#440154", "#46337E", "#365C8D", "#277F8E", "#1FA187", "#4AC16D", "#9FDA3A", "#FDE725"),
  `ipsum` = c("#3f2d54", "#75b8d1", "#2d543d", "#d18975", "#8fd175", "#d175b8", "#758bd1", "#d1ab75", "#c9d175"),
  `quadro` = c("#ff0000", "#1f3c88", "#23a393", "#f79f24", "#625757"),
  `eight` = c("#003f5c", "#2f4b7c", "#665191", "#a05195", "#d45087", "#f95d6a", "#ff7c43", "#ffa600"),
  `circus` = c("#C1241E", "#0664C9", "#EBD90A", "#6F130D", "#111A79"),
  `system` = c("#0F2838", "#F96207", "#0DB0F3", "#04EC04", "#FCC44C"),
  `hero` = c("#D2292B", "#165E88", "#E0BD1C", "#D57028", "#A5CB39", "#8D8F70"),
  `flat` = c("#c0392b", "#2980b9", "#16a085", "#f39c12", "#8e44ad", "#7f8c8d", "#d35400"),
  `social` = c("#b92b27", "#0077B5", "#00b489", "#f57d00", "#410093", "#21759b", "#ff3300")
)

#_______
plot_type_eff <- function(type,
                          model,
                          terms,
                          ci.lvl,
                          pred.type,
                          facets,
                          show.data,
                          jitter,
                          geom.colors,
                          axis.title,
                          title,
                          legend.title,
                          axis.lim,
                          case,
                          show.legend,
                          dot.size,
                          line.size,
                          ...) {
  
  if (missing(facets) || is.null(facets)) facets <- FALSE
  
  if (type == "pred") {
    dat <- ggeffects::ggpredict(
      model = model,
      terms = terms,
      ci.lvl = ci.lvl,
      type = pred.type,
      ...
    )
  } else if (type == "emm") {
    dat <- ggeffects::ggemmeans(
      model = model,
      terms = terms,
      ci.lvl = ci.lvl,
      type = pred.type,
      ...
    )
  } else {
    dat <- ggeffects::ggeffect(
      model = model,
      terms = terms,
      ci.lvl = ci.lvl,
      ...
    )
  }
  
  
  if (is.null(dat)) return(NULL)
  
  # evaluate dots-arguments
  alpha <- 0.4
  dodge <- .2
  dot.alpha <- .1
  log.y <- FALSE
  
  # save number of terms, needed later
  n.terms <- length(insight::find_predictors(model, component = "conditional", flatten = TRUE))
  
  add.args <- lapply(match.call(expand.dots = F)$`...`, function(x) x)
  if ("alpha" %in% names(add.args)) alpha <- eval(add.args[["alpha"]])
  if ("dodge" %in% names(add.args)) dodge <- eval(add.args[["dodge"]])
  if ("dot.alpha" %in% names(add.args)) dot.alpha <- eval(add.args[["dot.alpha"]])
  if ("log.y" %in% names(add.args)) log.y <- eval(add.args[["log.y"]])
  
  
  # select color palette
  if (geom.colors[1] != "bw") {
    if (is.null(terms)) {
      if (facets) {
        geom.colors <- "bw"
        .ngrp <- n.terms
      } else {
        .ngrp <- 1
      }
    } else {
      .ngrp <- dplyr::n_distinct(dat$group)
    }
    geom.colors <- col_check2(geom.colors, .ngrp)
  }
  
  
  p <- graphics::plot(
    dat,
    ci = !is.na(ci.lvl),
    facets = facets,
    rawdata = show.data,
    colors = geom.colors,
    use.theme = FALSE,
    jitter = TRUE,
    case = case,
    show.legend = show.legend,
    dot.alpha = dot.alpha,
    alpha = alpha,
    dodge = dodge,
    log.y = log.y,
    dot.size = dot.size,
    line.size = line.size
  )
  
  
  # set axis and plot titles
  if (!is.null(axis.title) && !is.null(terms)) {
    if (length(axis.title) > 1) {
      p <- p + labs(x = axis.title[1], y = axis.title[2])
    } else {
      p <- p + labs(y = axis.title)
    }
  } else if (!is.null(axis.title) && is.null(terms)) {
    if (length(axis.title) > 1) {
      p <- purrr::map(p, ~ .x + labs(x = axis.title[1], y = axis.title[2]))
    } else {
      p <- purrr::map(p, ~ .x + labs(y = axis.title))
    }
  }
  
  # set axis and plot titles
  if (!is.null(title) && !is.null(terms))
    p <- p + ggtitle(title)
  else if (!is.null(title) && is.null(terms))
    p <- purrr::map(p, ~ .x + ggtitle(title))
  
  # set axis and plot titles
  if (!is.null(legend.title)) {
    if (geom.colors[1] == "bw") {
      p <- p +
        labs(linetype = legend.title) +
        guides(colour = "none")
    } else {
      p <- p + labs(colour = legend.title)
    }
  }
  
  
  # set axis limits
  if (!is.null(axis.lim)) {
    if (is.list(axis.lim))
      p <- p + xlim(axis.lim[[1]]) + ylim(axis.lim[[2]])
    else
      p <- p + ylim(axis.lim)
  }
  
  
  p
}


plot_type_int <- function(model,
                          mdrt.values,
                          ci.lvl,
                          pred.type,
                          facets,
                          show.data,
                          jitter,
                          geom.colors,
                          axis.title,
                          title,
                          legend.title,
                          axis.lim,
                          case,
                          show.legend,
                          dot.size,
                          line.size,
                          ...) {
  
  # find right hand side of formula, to extract interaction terms
  rhs <- unlist(strsplit(as.character(stats::formula(model))[3], "+", fixed = TRUE))
  
  # interaction terms are separated with ":"
  int.terms <- purrr::map_lgl(rhs, ~ sjmisc::str_contains(x = .x, pattern = c("*", ":"), logic = "|"))
  
  
  # stop if no interaction found
  
  if (!any(int.terms))
    stop("No interaction term found in model.", call. = F)
  
  
  # get interaction terms and model frame
  
  ia.terms <- purrr::map(rhs[int.terms], ~ sjmisc::trim(unlist(strsplit(.x, "[\\*:]"))))
  mf <- insight::get_data(model)
  
  pl <- list()
  
  # intertate interaction terms
  
  for (i in 1:length(ia.terms)) {
    
    ia <- ia.terms[[i]]
    find.fac <- purrr::map_lgl(ia, ~ is_categorical(mf[[.x]]))
    
    
    # find all non-categorical variables, except first
    # term, which is considered as being along the x-axis
    
    check_cont <- ia[-1][!find.fac[2:length(find.fac)]]
    
    
    # if we have just categorical as interaction terms,
    # we plot all category values
    
    if (!sjmisc::is_empty(check_cont)) {
      
      # get data from continuous interaction terms. we
      # need this to compute the specific values that
      # should be used as group characteristic for the plot
      
      cont_terms <- dplyr::select(mf, !! check_cont)
      
      
      # for quartiles used as moderator values, make sure
      # that the variable's range is large enough to compute
      # quartiles
      
      mdrt.val <- mv_check(mdrt.values = mdrt.values, cont_terms)
      
      # prepare terms for ggpredict()-call. terms is a character-vector
      # with term name and values to plot in square brackets
      
      terms <- purrr::map_chr(check_cont, function(x) {
        if (mdrt.val == "minmax") {
          ct.min <- min(cont_terms[[x]], na.rm = TRUE)
          ct.max <- max(cont_terms[[x]], na.rm = TRUE)
          if (sjmisc::is_float(ct.min) || sjmisc::is_float(ct.max))
            sprintf("%s [%.2f,%.2f]", x, ct.min, ct.max)
          else
            sprintf("%s [%i,%i]", x, ct.min, ct.max)
        } else if (mdrt.val == "meansd") {
          mw <- mean(cont_terms[[x]], na.rm = TRUE)
          sabw <- stats::sd(cont_terms[[x]], na.rm = TRUE)
          sprintf("%s [%.2f,%.2f,%.2f]", x, mw, mw - sabw, mw + sabw)
        } else if (mdrt.val == "zeromax") {
          ct.max <- max(cont_terms[[x]], na.rm = TRUE)
          if (sjmisc::is_float(ct.max))
            sprintf("%s [0,%.2f]", x, ct.max)
          else
            sprintf("%s [0,%i]", x, ct.max)
        } else if (mdrt.val == "quart") {
          qu <- as.vector(stats::quantile(cont_terms[[x]], na.rm = T))
          sprintf("%s [%.2f,%.2f,%.2f]", x, qu[3], qu[2], qu[4])
        } else {
          x
        }
      })
      
      ia[match(check_cont, ia)] <- terms
    }
    
    
    # compute marginal effects for interaction terms
    
    dat <- ggeffects::ggpredict(
      model = model,
      terms = ia,
      ci.lvl = ci.lvl,
      type = pred.type,
      full.data = FALSE,
      ...
    )
    
    
    # evaluate dots-arguments
    
    alpha <- .15
    dodge <- .1
    dot.alpha <- .2
    log.y <- FALSE
    
    add.args <- lapply(match.call(expand.dots = F)$`...`, function(x) x)
    if ("alpha" %in% names(add.args)) alpha <- eval(add.args[["alpha"]])
    if ("dodge" %in% names(add.args)) dodge <- eval(add.args[["dodge"]])
    if ("dot.alpha" %in% names(add.args)) dot.alpha <- eval(add.args[["dot.alpha"]])
    if ("log.y" %in% names(add.args)) log.y <- eval(add.args[["log.y"]])
    
    
    # select color palette
    if (is.null(geom.colors) || geom.colors[1] != "bw")
      geom.colors <- col_check2(geom.colors, dplyr::n_distinct(dat$group))
    
    
    # save plot of marginal effects for interaction terms
    
    p <- graphics::plot(
      dat,
      ci = !is.na(ci.lvl),
      facets = facets,
      rawdata = show.data,
      colors = geom.colors,
      jitter = jitter,
      use.theme = FALSE,
      case = case,
      show.legend = show.legend,
      dot.alpha = dot.alpha,
      alpha = alpha,
      dodge = dodge,
      log.y = log.y,
      dot.size = dot.size,
      line.size = line.size
    )
    
    # set axis and plot titles
    if (!is.null(axis.title)) {
      if (length(axis.title) > 1) {
        p <- p + labs(x = axis.title[1], y = axis.title[2])
      } else {
        p <- p + labs(y = axis.title)
      }
    }
    
    # set axis and plot titles
    if (!is.null(title))
      p <- p + ggtitle(title)
    
    # set axis and plot titles
    if (!is.null(legend.title))
      p <- p + labs(colour = legend.title)
    
    # set axis limits
    if (!is.null(axis.lim)) {
      if (is.list(axis.lim))
        p <- p + xlim(axis.lim[[1]]) + ylim(axis.lim[[2]])
      else
        p <- p + ylim(axis.lim)
    }
    
    
    # add plot result to final return value
    
    if (length(ia.terms) == 1)
      pl <- p
    else
      pl[[length(pl) + 1]] <- p
  }
  
  pl
}


#' @importFrom stats na.omit
is_categorical <- function(x) {
  is.factor(x) || (length(unique(stats::na.omit(x))) < 3)
}


#' @importFrom stats quantile
#' @importFrom purrr map_dbl
mv_check <- function(mdrt.values, x) {
  
  # for quartiles used as moderator values, make sure
  # that the variable's range is large enough to compute
  # quartiles
  
  if (mdrt.values == "quart") {
    
    if (!is.data.frame(x)) x <- as.data.frame(x)
    
    mvc <- purrr::map_dbl(x, ~ length(unique(as.vector(stats::quantile(.x, na.rm = T)))))
    
    if (any(mvc < 3)) {
      # tell user that quart won't work
      message("Could not compute quartiles, too small range of moderator variable. Defaulting `mdrt.values` to `minmax`.")
      mdrt.values <- "minmax"
    }
    
  }
  
  mdrt.values
}
