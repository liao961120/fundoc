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
#' foo5()
foo5 = function(species = "setosa") {
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
#' foo6()
foo6 = function() {
    plot(1:3, 1:3, pch=19)
}

