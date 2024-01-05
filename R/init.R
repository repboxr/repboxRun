#' Call this function to initialize a new repbox project
#'
#' It will generate the new project directory and fill it with the
#' neccessary files to call repbox_run_project.
#'
#' @param project_dir The directory of the new project
#' @param sup_zip The ZIP file of the supplement
#' @param pdf_files The PDF file(s) of the article. Currently only a single PDF file works but in the future also support for multiple PDF files, e.g. article plus online appendix, will be added.
#' @param html_files Alternatively, the HTML file(s) of the article.
#' @param remove_macosx_dirs If TRUE, the "__MACOSX" directories will be removed from the supplement.
#' @export
repbox_init_project = function(project_dir, sup_zip=NULL, pdf_files=NULL, html_files = NULL, remove_macosx_dirs=TRUE, overwrite_org = FALSE) {
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
  if (!is.null(sup_zip) & (overwrite_org | !(dir.exists(org.dir)))) {
    unzip(sup_zip, exdir=org.dir,setTimes = TRUE)
  }

  if (!dir.exists(org.dir)) {
    stop("You neither provided a working ZIP file nor had your project has no existing directory with the original data and code supplement.")
  }

  # AEA supplements often are dupplicated
  # in a separate "__MACOSX" directory
  # We will remove those by default
  if (remove_macosx_dirs) {
    remove_macosx_dirs(org.dir)
  }

  # We get an error if current working directory does not exist
  repbox_copy_art_pdf(project_dir, pdf_files)
  repbox_copy_art_html(project_dir, html_files)
}


repbox_copy_art_pdf = function(project_dir, pdf_files = NULL) {
  restore.point("copy.repbox.art")
  pdf.dir = file.path(project_dir, "art", "pdf")
  if (!is.null(pdf_files)) {
    clear.and.create.dir(pdf.dir)
    file.copy(pdf_files, pdf.dir,recursive = TRUE)
  }
}

repbox_copy_art_html = function(project_dir, html_files = NULL) {
  restore.point("repbox_copy_art_html")
  html.dir = file.path(project_dir, "art", "html")
  if (!is.null(html_files)) {
    clear.and.create.dir(html.dir)
    file.copy(html_files, html.dir,recursive = TRUE)
  }
}


remove_macosx_dirs = function(parent.dir) {
  dirs = list.dirs(parent.dir)
  mac.dirs = dirs[has.substr(dirs, "__MACOSX")]
  for (mac.dir in mac.dirs) {
    remove.dir(mac.dir,recursive = TRUE)
  }
}


