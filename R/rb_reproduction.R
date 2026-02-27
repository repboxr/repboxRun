rb_create_mod_dir = function(rb) {
  restore.point("rb_update_mod_dir")
  rb_require_complete_org_dir(rb)

  project_dir = rb$project_dir
  if (is.null(project_dir)) stop("No project_dir")

  mod_dir = file.path(project_dir, "mod")
  org_dir = file.path(project_dir, "org")
  if (dir.exists(mod_dir))
    remove.dir(mod_dir,must.contain = project_dir)


  # Keep file dates so that we can better
  # see which files are overwritten when comparing
  # original to modified supplement

  copy.dir(org_dir, mod_dir,copy.date=TRUE)
  unzip.zips(mod_dir)
  make.project.files.info(project_dir, for.mod = TRUE, for.org=TRUE)
  rb
}

rb_slimify_org_dir = function(rb) {
  slimify.org.dir(rb$project_dir)
}

rb_has_stata_reproduction = function(rb, project_dir=rb$project_dir) {
  file.exists(file.path(project_dir, "repdb/stata_run_info.Rds"))
}

rb_run_stata_reproduction = function(rb, overwrite = FALSE, create_mod_dir = TRUE, stata_opts = repbox_stata_opts(extract.reg.info=store_reg_info, extract.scalar.vals = store_reg_info), store_reg_info=TRUE) {
  restore.point("rb_run_stata_reproduction")

  if (!rb_has_lang(rb, "stata")) {
    cat("The reproduction package has no Stata scripts.")
    return(rb)
  }
  if (!overwrite) {
    if (rb_has_stata_reproduction(rb)) {
      cat("\nState reproduction already exists. Thus skipped.")
      return(rb)
    }
  }

  if (create_mod_dir) {
    rb = rb_create_mod_dir(rb)
  }

  rb_require_complete_mod_dir(rb)
  project_dir = rb$project_dir
  if (is.null(project_dir)) stop("No project_dir")
  rb_log_step_start(rb, "stata_reproduction")

  repbox_stata_dir = file.path(project_dir, "repbox/stata")

  if (!overwrite & dir.exists(repbox_stata_dir)) {
    return(rb)
  }


  # To do: Check overwrite
  rb_remove_dir(rb=rb, sub_dir = "repbox/stata")
  dir.create(repbox_stata_dir)

  res = repbox_project_run_stata(project_dir,opts=stata_opts)
  parcels = rb$parcels
  parcels = repbox_save_stata_run_parcels(project_dir, parcels)
  parcels = make_parcel_stata_do_run_info(project_dir, parcels)
  if (store_reg_info) {
    parcels = repbox_save_stata_reg_run_parcels(project_dir, parcels)

  }

  rb$parcels = parcels
  rb_log_step_end(rb, "stata_reproduction")
  rb
}


rb_run_r_reproduction = function(rb, overwrite = FALSE, r_opts = repbox_r_opts()) {
  restore.point("rb_run_r_reproduction")
  rb_require_complete_mod_dir(rb)
  project_dir = rb$project_dir
  if (is.null(project_dir)) stop("No project_dir")
  rb_log_step_start(rb, "r_reproduction")

  parcels = rb$parcels
  parcels = repbox_project_run_r(project_dir, opts=opts$r_opts,parcels = parcels)
  parcels = repbox_project_extract_r_results(project_dir, parcels, opts=opts$r_opts)
  rb_log_step_end(rb, "r_reproduction")

  rb$parcels = parcels
  rb
}

