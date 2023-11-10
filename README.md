Quick and Dirty Function Documentation
======================================

<!-- 
To Do: add documentation for in-file DESCRIPTION
-->

`fundoc` generates function documentation from R scripts that are NOT structured as an R package. 

R packages provides a fantastic framework to document one's work. In reality, 
however, many R users are unfamiliar with the highly technical workflow of 
developing R packages.

This package tries to bridge the technical gap by exposing the benefits
of [roxygen2](https://roxygen2.r-lib.org) documentation to individual R
scripts. The purpose is not to provide a perfect tool but rather a
simple enough tool to get started with documenting scripts. There
is no need to worry about structuring the R scripts into a package.
Stick to your existing workflow, document the functions, and let
`fundoc::fundoc()` worry about generating the HTML documentation.
The only prerequisite is to learn the 
[basics of roxygen2](https://r-pkgs.org/man.html#roxygen2-basics).


### An Example

An example of function documentation generated from the [R files][src] of `fundoc` can be found [here][doc]. To build the documentation, clone this repo, set it as the working directory, and execute the code below in R:

```r
library(fundoc)
fundoc("R",
       out_dir = "docs/reference/docs",
       proj_name = "fundoc",
       proj_title = "Quick and Dirty Function Documentation")
```

[src]: https://github.com/liao961120/fundoc
[doc]: https://yongfu.name/fundoc/reference/docs


### Motivation

Many functions written for data analyses or works other than
package development are poorly documented. One of the reasons may
be the lack of a framework (and associated tools) for writing documentation
outside the world of package development. In addition, many R users are
simply unaware of the possibility of turning one's work into an R package
to enhance reproducibility by leveraging the documentation and testing
framework provided by the [devtools](https://devtools.r-lib.org) ecosystem.

Nonetheless, documentation is still of great importance for works besides
package development. `fundoc` leverages the conventions of the `devtools`
ecosystem to generate documentation. It is basically a wrapper around
`usethis::create_package()` and `knitr::knit_rd()` to set up a temporary
package template for generating an HTML documentation website. In doing so,
the fuss of automatically generating the documentation pages is abstracted
away, and users could focus on documenting their individual R scripts in
roxygen2 comments.

Note that since `fundoc` utilizes the devtools framework, the logic of
writing and documenting functions in R scripts must be consistent with
that of package development. This may conflict with users' existing
habits of organizing their scripts (e.g., mixing function definitions with
function calls in the same script or sourcing external scripts). Yet I would
suggest users adjust accordingly to the package development conventions
since there is a long-term benefit of doing so if you plan to stick to R.
Understanding the workflow of package development is a must for one to become a
serious R user.


### Tips to reduce hassles with roxygen documentation

Below I provide some tips that may help users bypass obstacles they can run
into when documenting R scripts without the knowledge of R package development.

1. Classify scripts into two types
   - Type-I scripts for function definition
   - Type-II scripts (or R Markdown) for analyses, communication, 
     producing results, etc.

2. Define and document (with roxygen2 comments) all the functions in Type-I scripts
   
   Do not source external scripts in these Type-I scripts.
   Functions defined in any of the Type-I scripts are available to all
   Type-I scripts. In fact, you can conceive these Type-I scripts
   as concatenating to form a single large script---you do not need to worry 
   about the dependencies between the defined functions when sourcing this
   script into the R console.

3. The previous tip suggests that in your Type-II scripts/Rmds, you
   have to import all the functions from the Type-I scripts by
   sourcing them all at the beginning, such as the R markdown example below:

   ````rmd
   ## Analysis

   ```{r}
   # Import Type-I scripts
   source("funcDef1.R")
   source("funcDef2.R")
   source("funcDef3.R")
   ```

   Blah blah blah

   ```{r}
   # Some analysis code (may call some functions defined in Type-I scripts)
   ```
   ````

4. Include an `@examples` tag for EVERY function
   
   When documenting the functions in Type-I scripts, you might want to
   include an `@examples` tag for each function. This would allow
   you to demonstrate how to use the function in verbatim code.
   `fundoc::fundoc()` helps you execute the code in the examples
   to record and insert the output in the generated HTML documentation.
   This amounts to the most rudimentary form of function testing.

5. Include an `@export` tag for EVERY function
   
   For self-defined functions to run properly in the `@examples`, 
   you need to use the `pkg:::func()` notation if the function docstring 
   does not include an `@export` tag. Why? Understanding this requires 
   detail knowledge of package development. For the current purpose, 
   you can simply attach `@export` to every function to keep things simple.

6. The workflow recommended here forces users to pack lots of code into functions. If you use `tidyverse` a lot, you may find the article [Programming with dplyr][u] helpful.


In-file DESCRIPTION
-------------------

When calling `fundoc::fundoc()`, users can pass in a project name (`proj_name`) and a short title for the project (`proj_title`). This information appears on the generated HTML documentation. An alternative is to include a block of metadata text---following the format of the [`DESCRIPTION`][desc] file in R packages---at the beginning of ONE of the scripts passed in to `fundoc::fundoc()`. This way, the call to `fundoc::fundoc()` becomes cleaner, and the R scripts would be self-contained with all necessary information documented.

This **in-file DESCRIPTION** is simply the text in a DESCRIPTION file prepended with roxygen comments `#' `. The DESCRIPTION text does not have to have all fields presented as in common R packages. For the DESCRIPTION text to take effect though, include at least these fields:

1. `Package` (corresponds to `proj_name` in `fundoc()`)
2. `Title` (corresponds to `proj_title` in `fundoc()`)
3. `Version` (corresponds to `version` in `fundoc()`)

Below is an example of the in-file DESCRIPTION in `fundoc`. Remember to include  `@DESCRIPTION` to mark the presence of such an in-file DESCRIPTION.

```r
#' @DESCRIPTION
#' Package: fundoc
#' Title: A one line description shown in the generated HTML documentation
#' Version: 0.0.1
#' Authors@R: 
#'     person("Jane", "Dow", , "jane@dow.org", role = c("aut", "cre"),
#'            comment = c(ORCID = "0000-0001-9999-8888"))
#' Description: Lorem ipsum dolor sit amet, in condimentum habitant eleifend ut
#'     urna ut. Leo, in sociis massa, sem sodales et in massa. 
#' License: MIT + file LICENSE
#' Encoding: UTF-8

#### R function definitions start below... ####
foo <- function() {
  # some code
}
```


[u]: https://cran.r-project.org/web/packages/dplyr/vignettes/programming.html
[desc]: https://r-pkgs.org/description.html

