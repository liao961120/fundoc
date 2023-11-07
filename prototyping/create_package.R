# PKGNAME/PKGTITLE/PKGVERSION
#   located from (1) script @DESCRIPTION (2) func args (3) fall back to defaults
PKGNAME  = paste0( "Foo.", format.Date(Sys.Date(),"%Y.%m.%d") )
PKGTITLE = paste( "Function documentation of project", PKGNAME )
PKGVERSION = "0.0.1"

R_FILE_VEC = c( "foo.R" )  # paths to file for creating docs
OUTDIR = "docs"            # output document dirname

# Prepare for parsing DESCRIPTION from script and replace the default
# DESCRIPTION file
parse_description_in_script = function(fp) {
    DESC = ""
    f = trimws( readLines(fp) )
    f = f[f != ""]
    # @DESCRIPTION must occur at the first block (precede any code)
    if (f[1] == "#' @DESCRIPTION") {
        idx_desc_end = which( !startsWith(f, "#' ") )[1] - 1
        if (!is.na(idx_desc_end) & idx_desc_end > 2)
            DESC = substring( f[2:idx_desc_end], 4L )
    }
    DESC = paste(DESC, collapse="\n")
    return(DESC)
}


DIR_PKG_INST = normalizePath( file.path(tempdir(),"INST") , "/" )
DIR_PKG_DEV  = normalizePath( file.path(tempdir(),PKGNAME), "/" )
dir.create(DIR_PKG_INST)
CWD = getwd()

devtools::dev_mode( on=TRUE, path=DIR_PKG_INST )

# Create pkg template
outfp = usethis::create_package(
    DIR_PKG_DEV,
    fields = list(  # @DESCRIPTION
        Package = PKGNAME,
        Title   = PKGTITLE,
        Version = PKGVERSION
    ),
    rstudio = F, open = F, check_name = T
)
file.copy( R_FILE_VEC, file.path(outfp,"R"), recursive=T )

# Build function docs
devtools::document(pkg=DIR_PKG_DEV)
devtools::install(pkg=DIR_PKG_DEV, reload = T, quick = T)

# Run examples (knit) and copy the help files to current dir
if (!dir.exists(OUTDIR)) dir.create(OUTDIR,recursive = T)
doc_src = system.file( "html", package=PKGNAME )
setwd( doc_src )
knitr::knit_rd( pkg=PKGNAME )
setwd("..")
file.rename( basename(doc_src), basename(OUTDIR) )
doc_src = file.path(getwd(),basename(OUTDIR))
setwd(CWD)
file.copy( doc_src, CWD, recursive = T, overwrite = T )


devtools::dev_mode(on=FALSE, path=DIR_PKG_INST)
