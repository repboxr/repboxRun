This is an example project for the repbox toolchain.

You can try to run the analysis by adapting and running the `run_repbox.R` script.

If you want to run a repbox analysis to another article and reproduction package, best use the function `repbox_init_project` in the package `repboxRun`.

```
library(repboxRun)
repbox_init_project(
  project.dir = "C:\your_repbox_projects\projectname",
  sup.zip="FILE PATH TO ZIP OF SUPPLEMENT",
  
)



1. Copy your article PDF 
