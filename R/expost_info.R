example = function() {
  parent_dir = "~/repbox/projects_static"
  project_dirs = list.dirs(parent_dir, recursive = FALSE)
  for (project_dir in project_dirs) {
    repbox_store_project_problems(project_dir)
  }

  for (project_dir in project_dirs) {
    repbox_store_step_timing(project_dir)
  }

  project_dir = project_dirs[1]
}

repbox_store_step_timing = function(project_dir, parcels=list()) {
  step_files = list.files(file.path(project_dir,"steps"), glob2rx("*.Rds"),full.names = TRUE)

  base = basename(step_files)
  df = data.frame(
    step = str.left.of(base, "."),
    start_end = str.between(base, ".","."),
    time = file.mtime(step_files)
  ) %>% arrange(step, start_end)

  step_timing = df %>%
    group_by(step) %>%
    summarize(
      sec = ifelse(n()==2, as.numeric(time[1])-as.numeric(time[2]), NA_real_)
    ) %>%
    mutate(artid = basename(project_dir))

  repdb_dir = file.path(project_dir,"repdb")
  parcels$step_timing = list(step_timing=step_timing)
  repdb_save_parcels(parcels["step_timing"],dir = repdb_dir)
  parcels
}

repbox_store_project_problems = function(project_dir, parcels=list()) {
  restore.point("repbox_store_project_problems")
  problem_dir = file.path(project_dir,"problems")
  repdb_dir = file.path(project_dir,"repdb")
  prob_files = list.files(problem_dir,full.names = TRUE)
  if (length(prob_files)==0) {
    problem_rds = file.path(repdb_dir,"problem.Rds")
    if (file.exists(problem_rds)) {
      file.remove(problem_rds)
    }
    return(parcels)
  }

  file = first(prob_files)
  prob_df = lapply(prob_files, function(file) {
    prob = readRDS(file)
    data.frame(problem_type = prob$type, problem_descr = prob$msg)
  }) %>% bind_rows()
  prob_df$artid = basename(project_dir)

  parcels$problem = list(problem=prob_df)
  repdb_save_parcels(parcels["problem"],dir = repdb_dir)
  parcels
}


repbox_store_step_info = function(project_dir) {

}

