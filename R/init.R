repbox_init_project = function(project.dir, sup.zip=NULL, pdf.files=NULL, html.files = NULL, remove.macosx.dirs=TRUE, overwrite.org = FALSE) {
  restore.point("repbox_init_project")

  project = basename(project.dir)
  org.dir = file.path(project.dir,"org")
  repbox.dir = file.path(project.dir, "repbox")

  if (!dir.exists(project.dir)) {
    dir.create(project.dir)
  }

  if (!dir.exists(file.path(project.dir,"meta"))) {
    dir.create(file.path(project.dir,"meta"))
  }

  # Set working directory.
  # Otherwise if working directory will be deleted we can get later an error:
  # sh: 0: getcwd() failed
  setwd(project.dir)

  # Copy supplement ZIP content into org.dir
  if (!is.null(sup.zip) & (overwrite.org | !(dir.exists(org.dir)))) {
    unzip(sup.zip, exdir=org.dir)
  }

  if (!dir.exists(org.dir)) {
    stop("You neither provided a working ZIP file nor had your project has no existing directory with the original data and code supplement.")
  }

  # AEA supplements often are dupplicated
  # in a separate "__MACOSX" directory
  # We will remove those by default
  if (remove.macosx.dirs) {
    remove.macosx.dirs(org.dir)
  }

  # We get an error if current working directory does not exist
  repbox_copy_art_pdf(project.dir, pdf.files)
  repbox_copy_art_html(project.dir, html.files)
}


repbox_copy_art_pdf = function(project.dir, pdf.files = NULL) {
  restore.point("copy.repbox.art")
  pdf.dir = file.path(project.dir, "art", "pdf")
  if (!is.null(pdf.files)) {
    clear.and.create.dir(pdf.dir)
    file.copy(pdf.files, pdf.dir,recursive = TRUE)
  }
}

repbox_copy_art_html = function(project.dir, html.files = NULL) {
  restore.point("repbox_copy_art_html")
  html.dir = file.path(project.dir, "art", "html")
  if (!is.null(html.files)) {
    clear.and.create.dir(html.dir)
    file.copy(html.files, html.dir,recursive = TRUE)
  }
}

