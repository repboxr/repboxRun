example = function() {
  library(repboxRun)
  artid = "aejpol_3_4_8"
  artid = "aejmic_6_3_9"
  projects.dir = "~/repbox/projects_reg"
  repbox_init_ejd_project(artid=artid, projects.dir=projects.dir)


  project.dir = "C:/libraries/repbox/projects_reg/testr"
  steps = repbox_run_steps_from(static_code=TRUE, art=FALSE)
  repbox_run_project(project.dir,lang=NULL, steps=steps)
  rstudioapi::filesPaneNavigate(project.dir)


  project.dir = "/home/rstudio/repbox/projects_reg/testsupp"

  steps = repbox_run_steps_from(static_code=TRUE, art=FALSE, reproduction = FALSE)
  repbox_run_project(project.dir, steps=steps)

  library(repboxRun)
  project.dir = "/home/rstudio/repbox/projects_reg/aejmac_6_3_1"
  project.dir = "/home/rstudio/repbox/projects_reg/testsupp"
  project.dir = "/home/rstudio/repbox/projects_reg/aejpol_3_4_8"
  project.dir = "/home/rstudio/repbox/projects_reg/aejpol_7_2_11"

  #steps = repbox_run_steps_from(art = TRUE)
  #restorepoint::restore.point.options(display.restore.point = !TRUE)
  steps = repbox_run_steps_from(reproduction =  TRUE,map=TRUE)
  opts = repbox_run_opts(art_opts = repbox_art_opts(overwrite=TRUE), html_opts = repbox_html_opts(add_art_source_tab = TRUE))
  repbox_run_project(project.dir, steps=steps, opts=opts)

  rstudioapi::filesPaneNavigate(project.dir)

}

repbox_run_project = function(project.dir, lang = "stata", steps = repbox_run_steps_all(), opts = repbox_run_opts()) {
  restore.point("repbox_run_project")

  options(dplyr.summarise.inform = FALSE)

  if (!dir.exists(project.dir)) {
    cat("\nProject directory", project.dir, "does not exist!\n")
    return(invisible(FALSE))
  }



  dap.file = paste0(project.dir,"/metareg/dap/stata/dap.Rds")

  show_title = function(str) {
    cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++\n",str,"\n+++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  }

  org.dir = file.path(project.dir,"org")
  sup.dir = file.path(project.dir,"mod")
  repbox.dir = file.path(project.dir, "repbox")
  repbox.stata.dir = file.path(project.dir, "repbox/stata")
  repbox.r.dir = file.path(project.dir, "repbox/r")

  parcels = list(.files = list())

  if (steps$static_code) {
    show_title("Static analysis of code and its comments")
    repbox_step_start(project.dir, "static_code", opts)

    if (!dir.exists(repbox.dir)) dir.create(repbox.dir)

    # Create file info from /org folder
    parcels$.files$org = make.project.files.info(project.dir,for.org=TRUE, for.mod = FALSE)$org
    # Save script content in Rds files in parcels
    parcels = repbox_make_script_parcel(project.dir, parcels)
    if ("stata" %in% lang) {
      cat("\n  Stata static code analysis...\n\n")
      parcels = repbox_stata_static_parcel(project.dir, parcels=parcels)
      parcels = repboxCodeText::code_project_find_refs(project.dir, parcels=parcels)
    }

    repbox_step_end(project.dir, "static_code")
  }


  if (steps$art) {
    show_title("Extract information from article text")
    repbox_step_start(project.dir, "art", opts)
    art_update_project(project.dir, opts=opts$art_opts)
    repbox_step_end(project.dir, "art")
  }

  # If we run the reproduction step again, we will clear most results
  if (steps$reproduction) {
    show_title("Reproduction of initial supplement")
    repbox_step_start(project.dir, "reproduction", opts)

    if (dir.exists(sup.dir)) remove.dir(sup.dir)
    # Keep file dates so that we can better
    # see which files are overwritten when comparing
    # original to modified supplement
    copy.dir(org.dir, sup.dir,copy.date=TRUE)
    unzip.zips(sup.dir)

    make.project.files.info(project.dir, for.mod = TRUE, for.org=TRUE)

    # Remove all files except for code files in org folder
    if (opts$slimify_org) {
      slimify.org.dir(project.dir)
    }


    if ("stata" %in% lang) {
      remove.dir(repbox.stata.dir)
      dir.create(repbox.stata.dir)

      dap_and_cache_remove_from_project(project.dir)
      res = stata.analyse.sup(project.dir,opts=opts$stata_opts)
    }
    if ("r" %in% lang) {
      stop("R reproduction not yet implemented.")
    }
    make.project.files.info(project.dir, for.mod = TRUE, for.org=FALSE)
    repbox_step_end(project.dir, "reproduction")
  }

  if (steps$reg & "stata" %in% lang) {
    show_title("Rerun Stata scripts to extract regression information")
    repbox_step_start(project.dir, "reg", opts)
    dap = get.project.dap(project.dir, make.if.missing = TRUE)

    if (opts$store_data_caches) {
      cache.dir = file.path(project.dir, "metareg/dap/stata/cache")
      if (!dir.exists(cache.dir)) dir.create(cache.dir,recursive = TRUE)
      store.data = dap.to.store.data(dap, cache.dir)
    } else {
      store.data = NULL
    }

    if (dir.exists(sup.dir)) remove.dir(sup.dir)
    copy.dir(org.dir, sup.dir,copy.date=TRUE)
    unzip.zips(sup.dir)

    stata_opts = opts$stata_opts
    stata_opts$extract.reg.info = TRUE
    stata_opts$store.data = store.data
    res = stata.analyse.sup(project.dir,opts=stata_opts)
    repbox_step_end(project.dir, "reg")
  }

  if (steps$mr_base & "stata" %in% lang) {
    show_title("Base Metareg")
    repbox_step_start(project.dir, "mr_base", opts)
    res = mr_base_run_study(project.dir, stop.on.error = opts$stop.on.error,create.regdb = TRUE,stata_version = opts$stata_version)
    repbox_step_end(project.dir, "mr_base")
  }

  parcels = NULL
  if (steps$repbox_regdb) {
    show_title("Store repbox regdb")
    repbox_step_start(project.dir, "repbox_regdb", opts)
    parcels = repbox_to_regdb(project.dir)
    repbox_step_end(project.dir, "repbox_regdb")
  }



  if (steps$map) {
    show_title("Create Mappings")
    repbox_step_start(project.dir, "map", opts)
    parcels = repboxMap::map_repbox_project(project.dir,parcels = parcels, opts = opts$map_opts)
    repbox_step_end(project.dir, "map")
  }

  if (steps$html) {
    show_title("Create HTML Reports")
    repbox_step_start(project.dir, "html", opts)
    repboxHtml::repbox_project_html(project.dir,parcels = parcels, opts = opts$html_opts)
    repbox_step_end(project.dir, "html")
  }
  return(TRUE)
}

repbox_step_start = function(project.dir, step, opts) {
  step.info.dir = file.path(project.dir,"steps")
  if (!dir.exists(step.info.dir)) dir.create(step.info.dir, recursive = TRUE)
  file = paste0(step.info.dir, "/",step,".start.Rds")
  saveRDS(list(start_time=Sys.time(), opts=opts), file)
}

repbox_step_end = function(project.dir, step) {
  step.info.dir = file.path(project.dir,"steps")
  file = paste0(step.info.dir, "/",step,".end.Rds")
  saveRDS(list(end_time = Sys.time()), file)
}
