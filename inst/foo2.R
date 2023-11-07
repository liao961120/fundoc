#' Foo3
#' @importFrom dplyr filter
#' @export
#' @examples
#' foo3()
foo3 = function(species = "setosa") {
    iris |>
        filter( Species == {{ species }} ) |>
        head()
}


#' Foo4
#' @importFrom dplyr filter
#' @export
#' @examples
#' foo4()
foo4 = function(species = "setosa") {
    iris |>
        filter( Species == {{ species }} ) |>
        head()
}


#' File path handler
#'
#' @param fps A character vector of paths. The vector can be a mix of paths
#'        of either (1) directory paths, (2) file paths, or (3) glob
#'        expressions to R scripts. Note that (2) and (3) must end with
#'        `.R` or `.r`.
#' @param debug Logical. Whether to return results as a list with `fps`
#'        as names.
#' @examples
#' dir_ = system.file(package = "fundoc")
#' (a_file = file.path(dir_, "foo.R"))
#' expand_Rscript(a_file)
#' (a_dir = file.path(dir_, "R"))
#' expand_Rscript(a_dir)
#' (a_glob = file.path(dir_, "*", "*.R"))
#' expand_Rscript(a_glob)
#' # Mix file paths
#' expand_Rscript( c(a_file, a_dir, a_glob) )
#' expand_Rscript( c(a_file, a_dir, a_glob), debug = T )
#' @export
expand_Rscript = function(fps, debug = F) {
    f = function(fp) {
        scripts = c()
        if (dir.exists(fp))
            scripts = c(
                scripts,
                list.files(fp, pattern = "\\.[Rr]$", full.names = T)
            )
        if (file.exists(fp) & grepl("\\.[Rr]$", fp))
            scripts = c(scripts, fp)
        if ( grepl("*", fp, fixed=T) & grepl("\\.[Rr]$", fp) )
            scripts = c(scripts, Sys.glob(fp))
        return(scripts)
    }
    out = sapply(fps, f, simplify = F, USE.NAMES = debug)
    if (!debug)
        out = unique( unlist(out) )
    out
}
