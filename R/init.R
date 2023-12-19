#' Call this function to initialize a new repbox project
#' @param project_dir The directory of the new project
#' @param sup.zip The ZIP file of the supplement
#' @param pdf.files The PDF file(s) of the article. Currently only a single PDF file works but in the future also support for multiple PDF files, e.g. article plus online appendix, will be added.
#' @param html.files Alternatively, the HTML file(s) of the article.
#' @param remove.macosx.dirs If TRUE, the "__MACOSX" directories will be removed from the supplement.
repbox_init_project = function(project_dir, sup.zip=NULL, pdf.files=NULL, html.files = NULL, remove.macosx.dirs=TRUE, overwrite.org = FALSE) {
  restore.point("repbox_init_project")

  project = basename(project_dir)
  org.dir = file.path(project_dir,"org")
  repbox.dir = file.path(project_dir, "repbox")

  if (!dir.exists(project_dir)) {
    dir.create(project_dir)
  }

  if (!dir.exists(file.path(project_dir,"meta"))) {
    dir.create(file.path(project_dir,"meta"))
  }

  # Set working directory.
  # Otherwise if working directory will be deleted we can get later an error:
  # sh: 0: getcwd() failed
  setwd(project_dir)

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
  repbox_copy_art_pdf(project_dir, pdf.files)
  repbox_copy_art_html(project_dir, html.files)
}


repbox_copy_art_pdf = function(project_dir, pdf.files = NULL) {
  restore.point("copy.repbox.art")
  pdf.dir = file.path(project_dir, "art", "pdf")
  if (!is.null(pdf.files)) {
    clear.and.create.dir(pdf.dir)
    file.copy(pdf.files, pdf.dir,recursive = TRUE)
  }
}

repbox_copy_art_html = function(project_dir, html.files = NULL) {
  restore.point("repbox_copy_art_html")
  html.dir = file.path(project_dir, "art", "html")
  if (!is.null(html.files)) {
    clear.and.create.dir(html.dir)
    file.copy(html.files, html.dir,recursive = TRUE)
  }
}

