

repbox_init_ejd_project = function(art=NULL,artid=NULL, projects.dir = "~/repbox/projects_reg",oi.download.dir = "~/selenium/downloads", dv.download.dir = "~/repbox/dv_ejd_zips", zip.download.dir = "~/downloads", ejd.db.dir = "~"
) {
  restore.point("repbox_init_ejd_project")
  library(EconJournalScrap)
  if (is.null(art) & !is.null(artid)) {
    db = get.articles.db(ejd.db.dir)
    art = dbGet(db, "article",list(id=artid))
  } else if (is.null(art)) {
    stop("Please provide artid or art.")
  }

  art = as.list(art)

  if (isTRUE(art$repo=="oi")) {
    type = "oi"
    art$oiid = str.between(art$data_url,"/project/","/")
    file = list.files(oi.download.dir, glob2rx(paste0(art$oiid,"-*.zip")),full.names = TRUE)
    if (length(file)==0) {
      cat("\n", art$id, " corresponding Open-ICPSR zip file was not yet downloaded.\n")
      return(FALSE)
    }
    art$zip.file = file[1]


  } else if (isTRUE(art$repo=="dv") | isTRUE(is.na(art$repo) & has.substr(art$data_url,"doi.org") & is.na(art$downloaded_file))) {
    type = "dv"

    doi1 = str.right.of(art$data_url,"doi:",not.found = NA)
    doi2 = str.right.of(art$data_url,"doi.org/",not.found = NA)
    art$doi = ifelse(is.na(doi1), doi2, doi1)
    art$dv.project = str.right.of(art$doi,"10.7910/DVN/",not.found = NA)
    if (is.na(art$dv.project)) {
      cat("\n", art$id, " DV project number could not be correctly extracted.\n")
      return(FALSE)
    }
    art$zip.file = paste0(dv.download.dir, "/", art$dv.project,".zip")
  } else if (!is.na(art$downloaded_file)) {
    type = "zip"
    art$zip.file = paste0(zip.download.dir, "/", art$downloaded_file)
  } else {
    cat("\nCannot init ", art$id, ": cannot determine how to assess the supplement.\n")
    return(FALSE)
  }

  if (!file.exists(art$zip.file)) {
    cat("\n", art$id, " ZIP file ", art$zip.file, " with supplement does not exist.\n")
    return(FALSE)
  }

  if (!has.col(art,"authors")) {
    db = get.articles.db(ejd.db.dir)
    authors = dbGet(db, "author",list(id=art$id))
    art$authors = paste0(authors$author, collapse=", ")
  }

  art$pdf.file = file.path("~/articles_pdf",art$journ,paste0(art$id,".pdf"))
  art$has.pdf = file.exists(art$pdf.file)

  project_dir = paste0(projects.dir,"/",art$id)
  cat("\n Init ", project_dir, "\n")
  repbox_init_project(project_dir = project_dir, sup.zip = art$zip.file,pdf.files = art$pdf.file)

  if (!dir.exists(file.path(project_dir,"meta"))) {
    dir.create(file.path(project_dir,"meta"))
  }
  saveRDS(as_tibble(art), file.path(project_dir, "meta","ejd_art.Rds"))
}

repbox_init_ejd_meta = function(project_dir, art=NULL, ejd.db.dir = "~") {
  if (is.null(art)) {
    db = get.articles.db(ejd.db.dir)
    artid = basename(project_dir)
    art = dbGet(db, "article",list(id=artid))
  }

  if (!has.col(art,"authors")) {
    db = get.articles.db(ejd.db.dir)
    authors = dbGet(db, "author",list(id=art$id))
    art$authors =paste0(authors$author, collape=", ")
  }

  art$pdf.file = file.path("~/articles_pdf",art$journ,paste0(art$id,".pdf"))
  art$has.pdf = file.exists(art$pdf.file)

  if (!dir.exists(file.path(project_dir,"meta"))) {
    dir.create(file.path(project_dir,"meta"))
  }
  saveRDS(as_tibble(art), file.path(project_dir, "meta","ejd_art.Rds"))

}

remove.macosx.dirs = function(parent.dir) {
  #parent.dir =  "~/statabox/supp"
  dirs = list.dirs(parent.dir)
  mac.dirs = dirs[has.substr(dirs, "__MACOSX")]
  for (mac.dir in mac.dirs) {
    remove.dir(mac.dir,recursive = TRUE)
  }
}
