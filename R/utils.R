#' Locate DESCRIPTION content from a bunch of files
#'
#' Given a vector of file paths, this function tries to find
#' and parse the R script with DESCRIPTION content written as Roxygen
#' docstring at the beginning of the file. If more than one
#' file contain DESCRIPTION content, only the first one would
#' be parsed and returned.
#'
#' @param files A character vector of file paths.
locate_description = function(files) {
    for ( fp in files ) {
        D = parse_description_in_script(fp)
        if ( D != "" ) {
            message("Found DESCRIPTION in: ", fp)
            return(D)
        }
    }
    message("No DESCRIPTION found!")
    return(NULL)
}


#' Extract embedded DESCRIPTION content in an R script
#'
#' @examples
#' fp = system.file("foo.R", package="fundoc")
#' xfun::file_string(fp)
#' fundoc:::parse_description_in_script(fp) |> cat()
parse_description_in_script = function(fp) {
    DESC = ""
    f = trimws( xfun::read_utf8(fp) )
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


#' File path handler
#'
#' @param fps A character vector of paths. The vector can be a mix of paths
#'        of either (1) directory paths, (2) file paths, or (3) glob
#'        expressions to R scripts. Note that (2) and (3) must end with
#'        `.R` or `.r`.
#' @param debug Logical. Whether to return results as a list with `fps`
#'        as names.
#' @return A character vector or a list.
#' @examples
#' expand_Rscript = fundoc:::expand_Rscript
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
# dir_ =  "." #system.file(package = "fundoc")


#' Print vector of paths as lines
#'
#' @examples
#' fundoc:::stack_fps(LETTERS[1:3])
stack_fps = function(fps, indent="  ") {
    fps = paste0( indent, fps )
    paste( fps, collapse = "\n" )
}

