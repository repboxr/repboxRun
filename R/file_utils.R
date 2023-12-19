remove.dir = function(dir.to.be.removed, recursive=TRUE, must.contain = "/projects") {
  if (!has.substr(dir.to.be.removed,must.contain)) {
    stop(paste0("Sorry, for security reasons currently only directories that contain the path ", must.contain, " can be removed."))
  }
  if (!dir.exists(dir.to.be.removed)) return()
  unlink(dir.to.be.removed,recursive = recursive)
}

unzip.zips = function(dir, remove=TRUE) {
  zip.files = list.files(dir, glob2rx("*.zip"), ignore.case=TRUE,full.names=TRUE,recursive = TRUE)
  for (zip.file in zip.files) {
    try(unzip(zip.file, exdir = dirname(zip.file)))
  }
  gz.files = list.files(dir, glob2rx("*.gz"), ignore.case=TRUE,full.names=TRUE,recursive = TRUE)
  for (gz.file in gz.files) {
    try(R.utils::gunzip(gz.file,remove=remove))
  }
  bz.files = list.files(dir, glob2rx("*.bz2"), ignore.case=TRUE,full.names=TRUE,recursive = TRUE)
  for (bz.file in bz.files) {
    try(R.utils::bunzip2(bz.file,remove=remove))
  }

  tar.files = list.files(dir, glob2rx("*.tar"), ignore.case=TRUE,full.names=TRUE,recursive = TRUE)
  for (tar.file in tar.files) {
    try(utils::untar(tar.file,exdir = dirname(tar.file)))
  }

}

make.project.files.info = function(project_dir, for.org = TRUE, for.mod=TRUE) {
  restore.point("make.project.files.info")
  oldwd = getwd()
  org.fi = mod.fi = NULL

  if (for.org) {
    dir = file.path(project_dir,"org")

    setwd(dir)
    files = list.files(dir,recursive = TRUE,include.dirs = FALSE)
    fi = as.data.frame(file.info(files))
    rownames(fi) = NULL
    fi$file = files
    fi$base = basename(files)
    fi$ext = tools::file_ext(files)
    fi
    org.fi = fi
    saveRDS(fi,file.path(project_dir,"repbox/org_files.Rds"))
  }

  if (for.mod) {
    dir = file.path(project_dir,"mod")
    setwd(dir)
    files = list.files(dir,recursive = TRUE,include.dirs = FALSE)
    fi = as.data.frame(file.info(files))
    rownames(fi) = NULL
    fi$file = files
    fi$base = basename(files)
    fi$ext = tools::file_ext(files)
    mod.fi = fi
    saveRDS(fi,file.path(project_dir,"repbox/mod_files.Rds"))
  }

  if (!is.null(oldwd)) setwd(oldwd)
  list(org = org.fi, mod=mod.fi)
}


repbox_make_script_parcel = function(project_dir, parcels) {
  restore.point("repbox_parcel_script")
  org.fi = parcels$.files$org

  script_df = org.fi %>%
    mutate(file_type = tolower(ext)) %>%
    filter(file_type %in% c("do","r")) %>%
    arrange(file_type, file) %>%
    mutate(
      artid=basename(project_dir),
      file_path=file,
      file_name = basename(file),
      sup_dir = paste0(project_dir, "/org"),
      long_path = paste0(sup_dir,"/", file),
      script_num = seq_len(n()),
      file_exists = file.exists(long_path),
      source_added = file_exists
    )
  text = rep(NA_character_, NROW(script_df))
  num_lines = rep(NA_integer_, NROW(script_df))

  for (i in seq_len(NROW(script_df))) {
    if (script_df$file_exists[i]) {
      txt = readLines(script_df$long_path[i],encoding = "UTF-8",warn = FALSE)
      text[i] = merge.lines(txt)
      num_lines[i] = length(txt)
    }
  }
  script_df$num_lines = num_lines

  # To avoid possible encoding errors later
  text = iconv(text,sub="?",from="UTF-8",to="UTF-8")

  script_df$text = text

  do_df = script_df %>% filter(file_type=="do")
  r_df = script_df %>% filter(file_type == "r")

  parcels = list(
    stata_file = list(script_file=do_df),
    stata_source = list(script_source = do_df),
    r_file = list(script_file = r_df),
    r_source = list(script_source = r_df)
  )
  regdb_save_parcels(parcels, dir = file.path(project_dir, "repbox", "regdb") )
  return(parcels)
}

