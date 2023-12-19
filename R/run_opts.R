#' Returns all steps of a repbox analysis
#'
#' Can be used as argument steps in repbox_run_project
repbox_all_steps = function() {
  repbox_run_steps_from(static_code=TRUE)
}

#' Returns steps of a repbox analysis specified by starting or ending steps
#'
#' Can be used as argument steps in repbox_run_project
#'
#' The arguments of this function are the diffent possible steps in a repbox analysis
repbox_steps_from = function(static_code=FALSE, art=static_code, reproduction=art, reg=reproduction, mr_base=reg, repbox_regdb = mr_base, map=repbox_regdb, html=map) {
  list(static_code = static_code, art=art, reproduction=reproduction, reg=reg, mr_base=mr_base,repbox_regdb = repbox_regdb, map=map, html=html)
}


repbox_run_opts = function(stop.on.error = FALSE, stata_version = 17, slimify = FALSE, slimify_org=slimify, store_data_caches=TRUE, timeout = 60*5, stata_opts = repbox.stata.opts(timeout = timeout,all.do.timeout = timeout),art_opts = repbox_art_opts(), map_opts=repbox_map_opts(), html_opts = repbox_html_opts()) {
  list(
    stop.on.error = stop.on.error,
    stata_version = stata_version,
    timeout = timeout,
    store_data_caches = store_data_caches,
    slimify = slimify,
    slimify_org = slimify,
    stata_opts = stata_opts,
    art_opts = art_opts,
    map_opts = map_opts,
    html_opts = html_opts
  )
}
