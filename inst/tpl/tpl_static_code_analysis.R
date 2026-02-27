# Performs static analysis of Stata and R code
library(repboxRun)

# Should point to this project dir
project_dir = rb_get_project_dir("{{default_project_dir}}")

if (FALSE)
  rstudioapi::filesPaneNavigate(project_dir)

rb = rb_make_rb(project_dir, just_steps=NULL, ignore_steps=NULL)

rb = rb_update_static_code_analysis(rb, overwrite=FALSE)
