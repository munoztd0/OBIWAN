
################################################
## HIERARCHICAL VARIABLE SCALING
################################################

library(plyr)
hscale <- function(v,h) {
 base <- aggregate(v~h,FUN=mean)
 v <- as.numeric(mapvalues(as.character(h),from=as.character(base$h),to=scale(base$v)))
 v
}


################################################
## TRANSFORMED LMER RESIDUALS
################################################

tdiagnostic <- function(merMod) {
  var.d <- crossprod(getME(merMod,"Lambdat"))
  Zt <- getME(merMod,"Zt")
  vr <- sigma(merMod)^2
  var.b <- vr*(t(Zt) %*% var.d %*% Zt)
  sI <- vr * Diagonal(nrow(merMod@frame))
  var.y <- var.b + sI
  Li <- t(chol(var.y))
  tres <- as.vector(solve(Li) %*% residuals(merMod))
  tfit <- as.vector(solve(Li) %*% fitted(merMod))
  data.frame(tres,tfit)
}


################################################
## RSQUAREDLME
################################################

#' R-squared and pseudo-rsquared for a list of (generalized) linear (mixed) models
#'
#' This function calls the generic \code{\link{r.squared}} function for each of the
#' models in the list and rbinds the outputs into one data frame
#'
#' @param a list of fitted (generalized) linear (mixed) model objects
#' @return a dataframe with one row per model, and "Class",
#'         "Family", "Marginal", "Conditional" and "AIC" columns
rsquared.glmm <- function(modlist) {
  # Iterate over each model in the list
  do.call(rbind, lapply(modlist, r.squared))
}
 
#' R-squared and pseudo-rsquared for (generalized) linear (mixed) models
#'
#' This generic function calculates the r squared and pseudo r-squared for
#' a variety of(generalized) linear (mixed) model fits.
#' Currently implemented for \code{\link{lm}}, \code{\link{lmerTest::merMod}},
#' and \code{\link{nlme::lme}} objects.
#' Implementing methods usually call \code{\link{.rsquared.glmm}}
#'
#' @param mdl a fitted (generalized) linear (mixed) model object
#' @return Implementing methods usually return a dataframe with "Class",
#'         "Family", "Marginal", "Conditional", and "AIC" columns
r.squared <- function(mdl){
  UseMethod("r.squared")
}
 
#' Marginal r-squared for lm objects
#'
#' This method uses r.squared from \code{\link{summary}} as the marginal.
#' Contrary to other \code{\link{r.squared}} methods, 
#' this one doesn't call \code{\link{.rsquared.glmm}}
#'
#' @param mdl an lm object (usually fit using \code{\link{lm}},
#' @return a dataframe with with "Class" = "lm", "Family" = "gaussian",
#'        "Marginal" = unadjusted r-squared, "Conditional" = NA, and "AIC" columns
r.squared.lm <- function(mdl){
  data.frame(Class=class(mdl), Family="gaussian", Link="identity",
             Marginal=summary(mdl)$r.squared,
             Conditional=NA, AIC=AIC(mdl))
}
 
#' Marginal and conditional r-squared for merMod objects
#'
#' This method extracts the variance for fixed and random effects, residuals,
#' and the fixed effects for the null model (in the case of Poisson family),
#' and calls \code{\link{.rsquared.glmm}}
#'
#' @param mdl an merMod model (usually fit using \code{\link{lme4::lmer}},
#'        \code{\link{lme4::glmer}}, \code{\link{lmerTest::lmer}},
#'        \code{\link{blme::blmer}}, \code{\link{blme::bglmer}}, etc)
r.squared.merMod <- function(mdl){
  # Get variance of fixed effects by multiplying coefficients by design matrix
  VarF <- var(as.vector(lme4::fixef(mdl) %*% t(mdl@pp$X)))
  # Get variance of random effects by extracting variance components
  # Omit random effects at the observation level, variance is factored in later
  VarRand <- sum(
    sapply(
      VarCorr(mdl)[!sapply(unique(unlist(strsplit(names(ranef(mdl)),":|/"))), function(l) length(unique(mdl@frame[,l])) == nrow(mdl@frame))],
      function(Sigma) {
        X <- model.matrix(mdl)
        Z <- X[,rownames(Sigma)]
        sum(diag(Z %*% Sigma %*% t(Z)))/nrow(X) } ) )
  # Get the dispersion variance
  VarDisp <- unlist(VarCorr(mdl)[sapply(unique(unlist(strsplit(names(ranef(mdl)),":|/"))), function(l) length(unique(mdl@frame[,l])) == nrow(mdl@frame))])
  if(is.null(VarDisp)) VarDisp = 0 else VarDisp = VarDisp
  if(inherits(mdl, "lmerMod")){
    # Get residual variance
    VarResid <- attr(lme4::VarCorr(mdl), "sc")^2
    # Get ML model AIC
    mdl.aic <- AIC(update(mdl, REML=F))
    # Model family for lmer is gaussian
    family <- "gaussian"
    # Model link for lmer is identity
    link <- "identity"
  }
  else if(inherits(mdl, "glmerMod")){
    # Get the model summary
    mdl.summ <- summary(mdl)
    # Get the model's family, link and AIC
    family <- mdl.summ$family
    link <- mdl.summ$link
    mdl.aic <- AIC(mdl)
    # Pseudo-r-squared for poisson also requires the fixed effects of the null model
    if(family=="poisson") {
      # Get random effects names to generate null model
      rand.formula <- reformulate(sapply(findbars(formula(mdl)),
                                         function(x) paste0("(", deparse(x), ")")),
                                  response=".")
      # Generate null model (intercept and random effects only, no fixed effects)
      null.mdl <- update(mdl, rand.formula)
      # Get the fixed effects of the null model
      null.fixef <- as.numeric(lme4::fixef(null.mdl))
    }
  }
  # Call the internal function to do the pseudo r-squared calculations
  .rsquared.glmm(VarF, VarRand, VarResid, VarDisp, family = family, link = link,
                 mdl.aic = mdl.aic,
                 mdl.class = class(mdl),
                 null.fixef = null.fixef)
}
 
#' Marginal and conditional r-squared for lme objects
#'
#' This method extracts the variance for fixed and random effects,
#' as well as residuals, and calls \code{\link{.rsquared.glmm}}
#'
#' @param mdl an lme model (usually fit using \code{\link{nlme::lme}})
r.squared.lme <- function(mdl){
  # Get design matrix of fixed effects from model
  Fmat <- model.matrix(eval(mdl$call$fixed)[-2], mdl$data)
  # Get variance of fixed effects by multiplying coefficients by design matrix
  VarF <- var(as.vector(nlme::fixef(mdl) %*% t(Fmat)))
  # Get variance of random effects by extracting variance components
  VarRand <- sum(suppressWarnings(as.numeric(nlme::VarCorr(mdl)
                                             [rownames(nlme::VarCorr(mdl)) != "Residual",
                                              1])), na.rm=T)
  # Get residual variance
  VarResid <- as.numeric(nlme::VarCorr(mdl)[rownames(nlme::VarCorr(mdl))=="Residual", 1])
  # Call the internal function to do the pseudo r-squared calculations
  .rsquared.glmm(VarF, VarRand, VarResid, family = "gaussian", link = "identity",
                 mdl.aic = AIC(update(mdl, method="ML")),
                 mdl.class = class(mdl))
}
 
#' Marginal and conditional r-squared for glmm given fixed and random variances
#'
#' This function is based on Nakagawa and Schielzeth (2013). It returns the marginal
#' and conditional r-squared, as well as the AIC for each glmm.
#' Users should call the higher-level generic "r.squared", or implement a method for the
#' corresponding class to get varF, varRand and the family from the specific object
#'
#' @param varF Variance of fixed effects
#' @param varRand Variance of random effects
#' @param varResid Residual variance. Only necessary for "gaussian" family
#' @param family family of the glmm (currently works with gaussian, binomial and poisson)
#' @param link model link function. Working links are: gaussian: "identity" (default);
#'        binomial: "logit" (default), "probit"; poisson: "log" (default), "sqrt"
#' @param mdl.aic The model's AIC
#' @param mdl.class The name of the model's class
#' @param null.fixef Numeric vector containing the fixed effects of the null model.
#'        Only necessary for "poisson" family
#' @return A data frame with "Class", "Family", "Marginal", "Conditional", and "AIC" columns
.rsquared.glmm <- function(varF, varRand, varResid = NULL, varDisp = NULL, family, link,
                           mdl.aic, mdl.class, null.fixef = NULL){
  if(family == "gaussian"){
    # Only works with identity link
    if(link != "identity")
      family_link.stop(family, link)
    # Calculate marginal R-squared (fixed effects/total variance)
    Rm <- varF/(varF+varRand+varResid)
    # Calculate conditional R-squared (fixed effects+random effects/total variance)
    Rc <- (varF+varRand)/(varF+varRand+varResid)
  }
  else if(family == "binomial"){
    # Get the distribution-specific variance
    if(link == "logit")
      varDist <- (pi^2)/3
    else if(link == "probit")
      varDist <- 1
    else
      family_link.stop(family, link)
    # Calculate marginal R-squared
    Rm <- varF/(varF+varRand+varDist+varDisp)
    # Calculate conditional R-squared (fixed effects+random effects/total variance)
    Rc <- (varF+varRand)/(varF+varRand+varDist+varDisp)
  }
  else if(family == "poisson"){
    # Get the distribution-specific variance
    if(link == "log")
      varDist <- log(1+1/exp(null.fixef))
    else if(link == "sqrt")
      varDist <- 0.25
    else
      family_link.stop(family, link)
    # Calculate marginal R-squared
    Rm <- varF/(varF+varRand+varDist+varDisp)
    # Calculate conditional R-squared (fixed effects+random effects/total variance)
    Rc <- (varF+varRand)/(varF+varRand+varDist+varDisp)
  }
  else
    family_link.stop(family, link)
  # Bind R^2s into a matrix and return with AIC values
  data.frame(Class=mdl.class, Family = family, Link = link,
             Marginal=Rm, Conditional=Rc, AIC=mdl.aic)
}
 
#' stop execution if unable to calculate variance for a given family and link
family_link.stop <- function(family, link){
  stop(paste("Don't know how to calculate variance for",
             family, "family and", link, "link."))
}



################################################
## R2MLM
################################################

r2MLM <- function(data,within_covs,between_covs,random_covs,gamma_w,gamma_b,Tau,sigma2,has_intercept=T,clustermeancentered=T){
  
  if(has_intercept==T){
    if(length(gamma_b)>1) gamma <-c(1,gamma_w,gamma_b[2:length(gamma_b)])
    if(length(gamma_b)==1) gamma <-c(1,gamma_w)
    if(is.null(within_covs)==T) gamma_w <-0
  }
  if(has_intercept==F){
    gamma <-c(gamma_w,gamma_b)
    if(is.null(within_covs)==T) gamma_w <-0
    if(is.null(between_covs)==T) gamma_b <-0
  }
  if(is.null(gamma)) gamma <-0
  
  ##compute phi
  phi <-var(cbind(1,data[,c(within_covs)],data[,c(between_covs)]),na.rm=T)
  if(has_intercept==F) phi <-var(cbind(data[,c(within_covs)],data[,c(between_covs)]),na.rm=T)
  if(is.null(within_covs)==T & is.null(within_covs)==T & has_intercept==F) phi <-0
  phi_w <-var(data[,within_covs],na.rm=T)
  if(is.null(within_covs)==T) phi_w <-0
  phi_b <-var(cbind(1,data[,between_covs]),na.rm=T)
  if(is.null(between_covs)==T) phi_b <-0

  ##compute psi and kappa
  var_randomcovs <-var(cbind(1,data[,c(random_covs)]),na.rm=T)
  if(length(Tau)>1) psi <-matrix(c(diag(Tau)),ncol=1)
  if(length(Tau)==1) psi <-Tau
  if(length(Tau)>1) kappa <-matrix(c(Tau[lower.tri(Tau)==TRUE]),ncol=1)
  if(length(Tau)==1) kappa <-0
  v <-matrix(c(diag(var_randomcovs)),ncol=1)
  r <-matrix(c(var_randomcovs[lower.tri(var_randomcovs)==TRUE]),ncol=1)
  if(is.null(random_covs)==TRUE){
    v <-0
    r <-0
    m <-matrix(1,ncol=1)
  }
  if(length(random_covs)>0) m <-matrix(c(colMeans(cbind(1,data[,c(random_covs)]),na.rm=T)),ncol=1)

  ##total variance
  totalvar_notdecomp <-t(v)%*%psi+ 2*(t(r)%*%kappa) + t(gamma)%*%phi%*%gamma + t(m)%*%Tau%*%m + sigma2
  totalwithinvar <-(t(gamma_w)%*%phi_w%*%gamma_w) + (t(v)%*%psi + 2*(t(r)%*%kappa)) + sigma2
  totalbetweenvar <-(t(gamma_b)%*%phi_b%*%gamma_b) + Tau[1]
  totalvar <-totalwithinvar +totalbetweenvar

  ##total decomp
  decomp_fixed_notdecomp <-(t(gamma)%*%phi%*%gamma) / totalvar
  decomp_fixed_within <-(t(gamma_w)%*%phi_w%*%gamma_w) / totalvar
  decomp_fixed_between <-(t(gamma_b)%*%phi_b%*%gamma_b) / totalvar
  decomp_fixed <-decomp_fixed_within + decomp_fixed_between
  decomp_varslopes <-(t(v)%*%psi + 2*(t(r)%*%kappa)) / totalvar
  decomp_varmeans <-(t(m)%*%Tau%*%m) / totalvar
  decomp_sigma <-sigma2/totalvar

  ##within decomp
  decomp_fixed_within_w <-(t(gamma_w)%*%phi_w%*%gamma_w) / totalwithinvar
  decomp_varslopes_w <-(t(v)%*%psi + 2*(t(r)%*%kappa)) / totalwithinvar
  decomp_sigma_w <-sigma2/totalwithinvar

  ##between decomp
  decomp_fixed_between_b <-(t(gamma_b)%*%phi_b%*%gamma_b) / totalbetweenvar
  decomp_varmeans_b <-Tau[1] / totalbetweenvar

  #NEW measures
  if (clustermeancentered==TRUE){
    R2_f <-decomp_fixed
    R2_f1 <-decomp_fixed_within 
    R2_f2 <-decomp_fixed_between 
    R2_fv <-decomp_fixed + decomp_varslopes
    R2_fvm <-decomp_fixed + decomp_varslopes + decomp_varmeans
    R2_v <-decomp_varslopes
    R2_m <-decomp_varmeans
    R2_f_w <-decomp_fixed_within_w
    R2_f_b <-decomp_fixed_between_b
    R2_fv_w <-decomp_fixed_within_w + decomp_varslopes_w
    R2_v_w <-decomp_varslopes_w
    R2_m_b <-decomp_varmeans_b
  }
  if (clustermeancentered==FALSE){
    R2_f <-decomp_fixed_notdecomp
    R2_fv <-decomp_fixed_notdecomp + decomp_varslopes
    R2_fvm <-decomp_fixed_notdecomp + decomp_varslopes + decomp_varmeans
    R2_v <-decomp_varslopes
    R2_m <-decomp_varmeans
  }
  if(clustermeancentered==TRUE){
    decomp_table <-matrix(c(decomp_fixed_within,decomp_fixed_between,decomp_varslopes,decomp_varmeans,decomp_sigma,
      decomp_fixed_within_w,"NA",decomp_varslopes_w,"NA",decomp_sigma_w,
      "NA",decomp_fixed_between_b,"NA",decomp_varmeans_b,"NA"),ncol=3)
    rownames(decomp_table) <-c("fixed, within","fixed, between","slope variation","mean variation","sigma2")
    colnames(decomp_table) <-c("total","within","between")
    R2_table <-matrix(c(R2_f1,R2_f2,R2_v,R2_m,R2_f,R2_fv,R2_fvm,
      R2_f_w,"NA",R2_v_w,"NA","NA",R2_fv_w,"NA","NA",R2_f_b,"NA",R2_m_b,"NA","NA","NA"),ncol=3)
    rownames(R2_table) <-c("f1","f2","v","m","f","fv","fvm")
    colnames(R2_table) <-c("total","within","between")
  }

  ##barchart
  if(clustermeancentered==TRUE){
    contributions_stacked <-matrix(c(decomp_fixed_within,decomp_fixed_between,decomp_varslopes,decomp_varmeans,decomp_sigma,
      decomp_fixed_within_w,0,decomp_varslopes_w,0,decomp_sigma_w,0,decomp_fixed_between_b,0,decomp_varmeans_b,0),5,3)
    colnames(contributions_stacked) <-c("total","within","between")
    rownames(contributions_stacked) <-c("fixed slopes (within)","fixed slopes (between)","slope variation (within)","intercept variation (between)","residual (within)")
    barplot(contributions_stacked, main="Decomposition", horiz=FALSE,
      ylim=c(0,1),col=c("darkred","steelblue","darkred","midnightblue","white"),ylab="proportion of variance",
      density=c(NA,NA,30,40,NA),angle=c(0,45,0,135,0),xlim=c(0,1),width=c(.3,.3))
    legend(.30,-.1,legend=rownames(contributions_stacked),fill=c("darkred","steelblue","darkred","midnightblue","white"),
      cex=.7, pt.cex = 1,xpd=T,density=c(NA,NA,30,40,NA),angle=c(0,45,0,135,0))
  }
  if(clustermeancentered==FALSE){
    decomp_table <-matrix(c(decomp_fixed_notdecomp,decomp_varslopes,decomp_varmeans,decomp_sigma),ncol=1)
    rownames(decomp_table) <-c("fixed","slope variation","mean variation","sigma2")
    colnames(decomp_table) <-c("total")
    R2_table <-matrix(c(R2_f,R2_v,R2_m,R2_fv,R2_fvm),ncol=1)
    rownames(R2_table) <-c("f","v","m","fv","fvm")
    colnames(R2_table) <-c("total")

    ##barchar
    contributions_stacked <-matrix(c(decomp_fixed_notdecomp,decomp_varslopes,decomp_varmeans,decomp_sigma),4,1)
    colnames(contributions_stacked) <-c("total")
    rownames(contributions_stacked) <-c("fixed slopes","slope variation","intercept variation","residual")
    barplot(contributions_stacked, main="Decomposition",horiz=FALSE,ylim=c(0,1),col=c("darkblue","darkblue","darkblue","white"),
      ylab="proportion of variance",density=c(NA,30,40,NA),angle=c(0,0,135,0),xlim=c(0,1),width=c(.6))
    legend(.30,-.1,legend=rownames(contributions_stacked),fill=c("darkblue","darkblue","darkblue","white"),cex=.7, 
      pt.cex = 1,xpd=TRUE,density=c(NA,30,40,NA),angle=c(0,0,135,0))
  }
  Output <-list(noquote(decomp_table),noquote(R2_table))
  names(Output) <-c("Decompositions","R2s")
  return(Output)
}