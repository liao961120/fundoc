#' @DESCRIPTION
#' Package: pkgTest
#' Title: Some test
#' Version: 0.0.0.9000
#' Authors@R:
#'     person("First", "Last", , "first.last@example.com", role = c("aut", "cre"),
#'            comment = c(ORCID = "YOUR-ORCID-ID"))
#' Description: What the package does (one paragraph).

library(dplyr)

#' A Foo Function
#'
#' Gets species from iris
#'
#' @param species Character vector.
#' @return Data Frame.
#' @export
#' @importFrom dplyr filter
#' @examples
#' foo()
foo = function(species = "setosa") {
    iris |>
        filter( Species == {{ species }} ) |>
        head()
}

#' Foo2
#'
#' A plot
#'
#' @export
#' @examples
#' foo2()
foo2 = function() {
    plot(1:3, 1:3, pch=19)
}

