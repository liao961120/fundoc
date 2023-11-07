Quick and Dirty Function Documentation
======================================

<!-- 
To Do: add documentation for in-file DESCRIPTION
-->

A package to generate function documentation along with evaluated example code from a list of R scripts documented with Roxygen comments. 

The function documentation generated from the [R files][src] of this package can be found [here][doc]. To build the documentation, clone this repo, set it as the working directory, and execute the code below in R:

```r
library(fundoc)
fundoc("R",
       out_dir = "docs/reference/docs",
       proj_name = "fundoc",
       proj_title = "Quick and Dirty Function Documentation")
```

[src]: https://github.com/liao961120/fundoc
[doc]: https://yongfu.name/fundoc/reference/docs
