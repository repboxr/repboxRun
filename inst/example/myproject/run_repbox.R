library(repboxRun)

# Adapt the project_dir
project_dir = "C:/libraries/repbox/projects_reg/myproject"


# If you use Stata please set the approbriate paths
# If a path is set to NULL we use defaults
# On windows you typically have to specify paths manually
# on linux the defaults work typically well.
set_stata_paths(
  # Name of the Stata binary like StataSE-64.exe
  stata_bin = NULL, 
  # Possibly custom ado directories on your computer
  ado_dirs = NULL, 
  # If stata_bin has no path, you can specify here its directory
  stata_dir = NULL
)

# Possibly customize repbox options
opts = repbox_run_opts()

# Define analysis steps
steps = repbox_steps_from(static_code=TRUE)
unlist(steps)

# Run the analysis steps
repbox_run_project(project_dir, lang = c("stata","r"), steps=steps, opts=opts)

# Now best take a look at the generated HTML reports in the 
# reports folder.

