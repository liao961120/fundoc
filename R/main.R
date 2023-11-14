#' Generate documentation from R scripts
#'
#' @param scripts A character vector of paths. The vector can be a mix of either
#'        (1) directory paths, (2) file paths, or (3) glob expressions to
#'        R scripts. Note that (2) and (3) must end with `.R` or `.r`.
#'        See [expand_Rscript()] for details.
#' @param outdir Path to the generated documentation directory.
#' @param proj_name Character. The name of the project. Must conform to
#'        conventions of naming R packages. To check whether a name is valid,
#'        refer to \url{https://github.com/r-lib/available}. Defaults to `NULL`,
#'        which generates the name `Foo.{YYYY.MM.DD}` according to the current
#'        date.
#' @param proj_title Character. A one-sentence title of what the project does.
#'        Defaults to `NULL`, which generates a title of the format:
#'        `Function documentation of project {proj_name}`.
#' @param version Character. Version number of the project. Defaults to
#'        `"0.0.1"` when set to `NULL`.
#' @param quiet Logical. Whether to hide messages from the subprocess compiling
#'        the function documentation. Defaults to `FALSE`.
#' @examples
#' Rscript = "
#' #' A Foo function
#' #'
#' #' Just an example
#' #'
#' #' @param x Character. Calling `foo()` prints out `x`.
#' #' @export
#' #' @examples
#' #' foo('Hello World!')
#' foo <- function(x) print(x)
#' "
#' tmp <- paste0(tempfile(), ".R")
#' writeLines(Rscript, tmp)
#'
#' fundoc(scripts = tmp,
#'        out_dir = "docs",
#'        proj_name = "fundoc",
#'        proj_title = "Quick and Dirty Function Documentation",
#'        quiet = TRUE)
#' @export
fundoc = function(scripts = ".",
                  out_dir = "docs",
                  proj_name = NULL,
                  proj_title = NULL,
                  version = NULL,
                  quiet = FALSE) {
    scripts = expand_Rscript(scripts)
    message("Documenting functions in: \n",
            stack_fps(scripts), "\n")
    outdir = callr::r(fundoc_core, args=list(
        scripts = scripts,
        out_dir = out_dir,
        proj_name = proj_name,
        proj_title = proj_title,
        version = version
    ), package="fundoc", show=!quiet )
    message("Function documentation saved to ",outdir)
}


fundoc_core = function(scripts,
         out_dir = "docs",
         proj_name = NULL,
         proj_title = NULL,
         version = NULL) {

    # Generate defaults
    if (is.null(proj_name))
        proj_name = paste0( "Foo.",format.Date(Sys.Date(),"%Y.%m.%d") )
    if (is.null(proj_title))
        proj_title = paste("Function documentation of project",proj_name)
    if (is.null(version))
        version = "0.0.1"

    # Setup temporary directories to hold generated package
    DIR_PKG_INST = file.path( normalizePath(tempdir(), "/"),"INST" )
    DIR_PKG_DEV  = file.path( normalizePath(tempdir(), "/"),proj_name )
    dir.create(DIR_PKG_INST)
    CWD = getwd()

    devtools::dev_mode( on=TRUE, path=DIR_PKG_INST )  # DEV ON
    on.exit({
        devtools::dev_mode(on=FALSE, path=DIR_PKG_INST) # DEV OFF
        setwd(CWD)
    })

    # Create pkg template
    outfp = usethis::create_package(
        DIR_PKG_DEV,
        fields = list(  # @DESCRIPTION
            Package = proj_name,
            Title   = proj_title,
            Version = version
        ),
        rstudio = F, open = F, check_name = T
    )
    file.copy( scripts, file.path(outfp,"R"), recursive=T )
    # Use DESCRIPTION if exists
    DESC = locate_description(scripts)
    if (!is.null(DESC)) {
        message("DESCRIPTION will be used ",
                "instead of function arguments\n")
        fp = file.path( outfp,"DESCRIPTION")
        xfun::write_utf8( DESC, fp )
        DESC = desc::desc(fp)
        if ( DESC$has_fields("Package") )
            proj_name = DESC$get_field("Package")
    }

    # Build function docs
    devtools::document(pkg=DIR_PKG_DEV)
    devtools::install(pkg=DIR_PKG_DEV, reload=T, quick=T)

    # Run examples (knit) and copy the help files to current dir
    if (!dir.exists(out_dir)) dir.create(out_dir,recursive = T)
    out_dir = tools::file_path_as_absolute(out_dir)
    doc_src = system.file("html", package=proj_name)

    setwd(doc_src)
    knitr::knit_rd(pkg=proj_name)
    fix_links(Sys.glob("*.html"))
    src_files = list.files(doc_src, recursive=T, full.names=T)
    for ( fp in c(src_files,"../DESCRIPTION") )
        file.copy(fp, out_dir, recursive = T, overwrite = T)

    return( out_dir )  # return output dir
}

