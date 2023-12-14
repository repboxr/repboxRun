repbox_run_steps_all = function() {
  repbox_run_steps_except()
}
#
# repbox_run_steps_except = function(reproduction=TRUE, reg=TRUE,mr_base=TRUE, repbox_regdb = TRUE, art=TRUE,code_text=TRUE, map=TRUE, html=TRUE) {
#   list(reproduction=reproduction, reg=reg,mr_base=mr_base, repbox_regdb = repbox_regdb, art=art,code_text=code_text, map=map, html=html)
# }
#
# repbox_run_steps_just = function(reproduction=FALSE, reg=FALSE, mr_base=FALSE, repbox_regdb = FALSE, art=FALSE,code_text=FALSE, map=FALSE, html=FALSE) {
#   list(reproduction=reproduction, reg=reg, mr_base=mr_base,repbox_regdb = repbox_regdb, art=art,code_text=code_text, map=map, html=html)
# }

repbox_run_steps_from = function(static_code=FALSE, art=static_code, reproduction=art, reg=reproduction, mr_base=reg, repbox_regdb = mr_base, map=repbox_regdb, html=map) {
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
