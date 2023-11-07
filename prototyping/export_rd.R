f = glue::glue
sourcefile = "foo.R"

source_env = roxygen2::env_file(sourcefile)
rd_blocks = roxygen2::parse_file(sourcefile, source_env)
help_topics = roxygen2::roclet_process( roxygen2::rd_roclet(), rd_blocks, 
                                        source_env, dirname(sourcefile) )
rd_code = lapply(help_topics, format)

for ( fn in names(rd_code) )
    writeLines(rd_code[[fn]], fn)


CALLED = 1
FIG_DIM = c(1200,900)
#### Define Handler #####
# see `?evaluate::new_output_handler`
handler = evaluate::new_output_handler(
    text = function(x) {
        x = strsplit(x, "\n", fixed=T)[[1]]
        x = paste("#>", x)
        paste(x, collapse="\n")
    },
    graphics = function(x) {
        outfp = paste0(CALLED,".png")
        png(filename = outfp, 
            width=FIG_DIM[1], height=FIG_DIM[2])
        grDevices::replayPlot(x) 
        dev.off()
        return( paste0( "![", outfp, "](", outfp, ")") )
    }
)




#### Evaluate text output ####
# Evaluate @examples and capture output
#   1. A parser that searches for @examples tags in rd_blocks
#   2. A function to prepend comments to captured outputs
#   3. Plug in the commented output back to original `rd_blocks` locations
x = evaluate::evaluate( rd_blocks[[1]]$tags[[7]]$raw |> trimws(), 
                        envir = source_env, output_handler = handler )
x


rd_blocks[[1]]$tags[[7]]$val = x
help_topics = roxygen2::roclet_process( roxygen2::rd_roclet(), rd_blocks, 
                                        source_env, dirname(sourcefile) )
rd_code = lapply(help_topics, format)

for ( fn in names(rd_code) )
    writeLines(rd_code[[fn]], fn)


# Evaluate image
x = evaluate::evaluate( rd_blocks[[2]]$tags[[4]]$raw |> trimws(), 
                        envir = source_env, output_handler  = handler )




# # Extract example
# f = tempfile()
# tools::Rd2ex( "foo.Rd", out = f ) #"foo.ex.R"
# evaluate::evaluate( file(f) )

