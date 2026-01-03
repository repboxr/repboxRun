example = function() {
  project_dir = "/home/rstudio/repbox/projects_gha_new/aejapp_1_2_4"
  if (FALSE)
    rstudioapi::filesPaneNavigate(project_dir)
}

# A central function to return the general status of a project,
# i.e. which steps have been run (successful or not) and when
# and which files are there
repbox_project_status = function(project_dir) {
  # project status will be a data.frame
  # the complete status shall consist of different states
  state_li = vector("list", 100)
  state_ind = 0
  project_dir = normalizePath(project_dir)

  fp = function(file) {
    file = normalizePath(file,mustWork = FALSE)
    ifelse(startsWith(file, project_dir), file, paste0(project_dir, "/", file))
  }
  has_file = function(...) {
    file.exists(fp(...))
  }
  add_state = function(stateid,has=if (!is.na(val)) TRUE else NA, timestamp = NA_POSIXct_,  val=NA_real_, mb=NA_real_, help="", ...) {
    state = data.frame(stateid,has, timestamp,val,mb, help, ...)
    state_ind <<- state_ind +1
    state_li[[state_ind]] <<- state
    state
  }
  add_file_state = function(stateid, file, ...) {
    file = fp(file)
    add_state(stateid, has = file.exists(file), timestamp=file.mtime(file),mb = file.size(file) / 1e6, ...)
  }
  add_dir_state = function(stateid, dir, first=FALSE,...) {
    restore.point("add_dir_state")
    if (length(dir)==0) {
      add_state(stateid, has = FALSE, ...)
      return()
    }
    if (first) dir = dir[1]
    if (!startsWith(dir,"/") & ! startsWith(dir,"~"))
      dir = file.path(project_dir, dir[1])
    files = list.files(dir, recursive = TRUE)
    if (length(files)==0) {
      add_state(stateid, has = FALSE, ...)
      return()
    }
    timestamp = max(file.mtime(dir))
    add_state(stateid, has=TRUE, timestamp = timestamp, ...)
  }

  # meta information
  add_file_state("meta_art","meta/art_meta.Rds")
  add_file_state("meta_sup","meta/sup_meta.Rds")
  add_file_state("meta_sup_files","meta/sup_files.Rds")


  # repboxDoc
  library(repboxDoc)
  doc_dirs = repboxDoc::repbox_doc_dirs(project_dir)
  doc_types = repboxDoc::rdoc_type(doc_dirs)
  doc_forms = repboxDoc::rdoc_form(doc_dirs)

  has_doc_app = length(app_prefix)>0


  add_state("doc_art",has=any(doc_types == "art"))
  add_state("doc_app",has=any(doc_types != "art"))
  add_dir_state("doc_art_pdf",doc_dirs[doc_types == "art" & doc_forms=="pdf"])
  add_dir_state("doc_art_mocr",doc_dirs[doc_types == "art" & doc_forms=="mocr"])
  add_dir_state("doc_art_html",doc_dirs[doc_types == "art" & doc_forms=="html"])
  add_dir_state("doc_app_mocr",doc_dirs[doc_types != "art" & doc_forms=="mocr"])


  # general repbox info
  add_file_state("mod_files_rds","repbox/mod_files.Rds")
  add_file_state("org_files_rds","repbox/org_files.Rds")
  add_file_state("stata_results","repbox/stata/repbox_results.Rds", help="Does file repbox/stata/repbox_results.Rds exist?")
  add_dir_state("stata_cmd_log","repbox/stata/cmd", help="Does any file in repbox/stata/cmd exist?")

  # metareg info
  if (has_file("metareg/base")) {
    add_dir_state("mr_base_dir","metareg/base")

    r_runtime = stata_runtime = NA_real_
    if (has_file("metareg/base/runtimes.Rds")) {
      rt = readRDS(fp("metareg/base/runtimes.Rds"))
      r_runtime = rt$total$r_runtime
      stata_runtime = rt$total$stata_runtime
    }
    add_state("mr_base_r_runtime", val=r_runtime)
    add_state("mr_base_stata_runtime", val=stata_runtime)

    num_infeasible_steps = length(list.files(fp("metareg/base/step_results"), glob2rx("infeasible*.Rds")))
    num_reg_results = length(list.files(fp("metareg/base/step_results"), glob2rx("infeasible*.Rds")))

    add_state("mr_base_num_infeasible_steps", val=num_infeasible_steps)
    add_state("mr_base_num_reg_results", val=num_reg_results)
  } else {
    add_state("mr_base_dir", has=FALSE)
  }

  # readme
  add_state("readme_dir",has=has_file("readme"))
  add_file_state("readme_ranks","readme/readme_ranks.Rds")
  add_dir_state("readme_txt","readme/txt")

  # gha
  if (has_file("gha/gha_status.txt")) {
    add_state("gha", has = TRUE, timestamp = file.mtime(fp("gha/gha_status.txt")), status=merge.lines(readLines(fp("gha/gha_status.txt"))),help="Was run on Github Actions")
  } else {
    add_state("gha", has = FALSE, help="Was not run on Github Actions")
  }

  # reports
  add_file_state("report_do_tab","reports/do_tab.html")


  # fp
  types = "art"
  if (has_doc_app) type = c(types, "app")

  for (type in types) {
    library(FuzzyProduction)
    app_types = setdiff(unique(doc_types),"art")

    type = "art"
    doc_type = type
    if (type=="app") doc_type = app_types
    fp_dir =paste0(fp("fp/prod_"),doc_type)
    ver_dirs = FuzzyProduction::fp_all_ok_ver_dirs(fp_dir)
    fp_df = FuzzyProduction::fp_ver_dir_to_ids(ver_dirs)

    fp_df$timestamp = file.mtime(file.path(fp_df$ver_dir, "prod_df.Rds"))
    p_df = fp_df %>%
      group_by(prod_id) %>%
      summarize(
        timestamp = max(timestamp, na.rm=TRUE),
        val = n()
      )
    if (NROW(p_df)>0) {
      add_state(paste0("fp_prod_", p_df$prod_id),has=TRUE, timestamp = p_df$timestamp, val=p_df$val, help="val: no. versions")
    }
    p_df = fp_df %>%
      group_by(prod_id, proc_id) %>%
      summarize(
        timestamp = max(timestamp, na.rm=TRUE),
        val = n()
      )
    if (NROW(p_df)>0) {
      add_state(paste0("fp_proc_",p_df$prod_id,"-", p_df$proc_id),has=TRUE, timestamp = p_df$timestamp, val=p_df$val, help="val: no. versions")
    }
  }


  repdb_files = list.files(fp("repdb"),glob2rx("*.Rds"), full.names = TRUE)
  timestamp = file.mtime(repdb_files)
  parcel = basename(repdb_files) %>% tools::file_path_sans_ext()
  add_state(paste0("repdb_", parcel), has=TRUE, timestamp=timestamp, mb = file.size(repdb_files) / 1e6)


  status = bind_rows(state_li)

}
