# These regressions will be shown in Table 1

reg1 = lm(y~x1,data = dat)
reg2 = lm(y~x1+d1,data = dat)

library(fixest)
reg3 = feols(y~x1|i1, dat)
summary(reg2)

library(AER)
reg4 = ivreg(y~x1|i1,data=dat)

options("modelsummary_format_numeric_latex" = "plain")
library(modelsummary)
modelsummary(list(reg1, reg2, reg3, reg4))

modelsummary(list(reg1, reg2, reg3, reg4),output = "code/tab1.tex")
