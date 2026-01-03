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

  has_file = function(...) {
    file.exists(file.path(project_dir, ...))
  }
  file_date = function(...) {
    file.mtime(file.path(project_dir, ...))
  }
  add_state = function(stateid,has=if (!is.na(val)) TRUE else NA, timestamp = NA_POSIXct_, help="", val=NA_real_, ...) {
    state = data.frame(stateid,has, timestamp,val, help, ...)
    state_ind <<- state_ind +1
    state_li[[state_ind]] <<- state
    state
  }
  add_file_state = function(stateid, file, ...) {
    add_state(stateid, has = has_file(file), timestamp=file_date(file), ...)
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

  add_state("doc_art",has=any(doc_types != "art"))
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
      rt = readRDS(file.path(project_dir,"metareg/base/runtimes.Rds"))
      r_runtime = rt$total$r_runtime
      stata_runtime = rt$total$stata_runtime
    }
    add_state("mr_base_r_runtime", val=r_runtime)
    add_state("mr_base_stata_runtime", val=stata_runtime)

    num_infeasible_steps = length(list.files(file.path(project_dir, "metareg/base/step_results"), glob2rx("infeasible*.Rds")))
    num_reg_results = length(list.files(file.path(project_dir, "metareg/base/step_results"), glob2rx("infeasible*.Rds")))

    add_state("mr_base_num_infeasible_steps", val=num_infeasible_steps)
    add_state("mr_base_num_reg_results", val=num_reg_results)
  } else {
    add_state("mr_base_dir", has=FALSE)
  }

  # readme
  add_state("readme_dir",has=has_file("readme"))
  add_file_state("readme_ranks",has=has_file("readme/readme_ranks"))
  add_dir_state("readme_txt","readme/txt")

  # gha
  if (has_file("gha/gha_status.txt")) {
    add_state("gha", has = TRUE, timestamp = file_date("gha/gha_status.txt"), status=merge.lines(readLines(file.path(project_dir, "gha/gha_status.txt"))),help="Was run on Github Actions")
  } else {
    add_state("gha", has = FALSE, help="Was not run on Github Actions")
  }

  # reports
  add_file_state("report_do_tab","reports/do_tab.html")








  status = bind_rows(state_li)

}
