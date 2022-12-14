library("rstanarm")
library("tidyverse")
library("stargazer")
for (name in list("imputed", "non_imputed")){
  fit = readRDS(paste(name, ".rds", sep=""))
  plot(pp_check(fit, nreps=10, plotfun = "hist", binwidth=1, grid_args = list(top=paste(name, "Posterior Predicvtive", sep=""))))
  fit_sum=(as.data.frame(summary(fit)))
  fit_sum$mean <- round(fit_sum$mean, digits=2)
  relv_coeffs <- fit_sum[fit_sum$mean!=0, ]
  relv_coeffs <- relv_coeffs %>% select(mean)
  stargazer(relv_coeffs,
            summary = FALSE,
            type = "latex",
            title = paste(name, "Coefficent Values"),
            font.size = "footnotesize",
            out = name)
} 
