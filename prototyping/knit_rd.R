# knitr::knit_rd
function (pkg, links = tools::findHTMLlinks(), frame = TRUE) 
{
    library(pkg, character.only = TRUE)
    optc = opts_chunk$get()
    on.exit(opts_chunk$set(optc))
    file.copy(system.file("misc", "R.css", package = "knitr"), 
              "./")
    pkgRdDB = getFromNamespace("fetchRdDB", "tools")(file.path(find.package(pkg), 
                                                               "help", pkg))
    force(links)
    topics = names(pkgRdDB)
    for (p in topics) {
        message("** knitting documentation of ", p)
        tools::Rd2HTML(pkgRdDB[[p]], f <- tempfile(), package = pkg, 
                       Links = links, no_links = is.null(links), stages = "render")
        txt = read_utf8(f)
        unlink(f)
        if (length(i <- grep("<h3>Examples</h3>", txt)) == 
            1L && length(grep("</pre>", txt[i:length(txt)]))) {
            i0 = grep("<pre>", txt)
            i0 = i0[i0 > i][1L] - 1L
            i1 = grep("</pre>", txt)
            i1 = i1[i1 > i0][1L] + 1L
            tools::Rd2ex(pkgRdDB[[p]], ef <- tempfile())
            ex = read_utf8(ef)
            unlink(ef)
            ex = ex[-(1L:grep("### ** Examples", ex, fixed = TRUE))]
            ex = c("```{r}", ex, "```")
            opts_chunk$set(fig.path = paste0("figure/", 
                                             p, "-"), tidy = FALSE)
            res = try(knit2html(text = ex, envir = parent.frame(2), 
                                fragment.only = TRUE, quiet = TRUE))
            if (inherits(res, "try-error")) {
                res = ex
                res[1] = "<pre><code class=\"r\">"
                res[length(res)] = "</code></pre>"
            }
            txt = c(txt[1:i0], res, txt[i1:length(txt)])
            txt = sub("</head>", "\n<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/styles/github.min.css\">\n<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/highlight.min.js\"></script>\n<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/languages/r.min.js\"></script>\n<script>hljs.initHighlightingOnLoad();</script>\n</head>", 
                      txt)
        }
        else message("no examples found for ", p)
        write_utf8(txt, paste0(p, ".html"))
    }
    unlink("figure/", recursive = TRUE)
    toc = sprintf("- <a href=\"%s\" target=\"content\">%s</a>", 
                  paste0(topics, ".html"), topics)
    toc = c(paste0("# ", pkg), "", toc, "", 
            paste("Generated with [knitr](https://yihui.org/knitr) ", 
                  packageVersion("knitr")))
    mark_html(text = toc, output = "00frame_toc.html", 
              meta = list(title = paste("R Documentation of", 
                                        pkg), css = "R.css"))
    txt = read_utf8(file.path(find.package(pkg), "html", 
                              "00Index.html"))
    unlink("00Index.html")
    write_utf8(gsub("../../../doc/html/", "http://stat.ethz.ch/R-manual/R-devel/doc/html/", 
                    txt, fixed = TRUE), "00Index.html")
    if (!frame) {
        unlink(c("00frame_toc.html", "index.html"))
        (if (is_windows()) 
            file.copy
            else file.symlink)("00Index.html", "index.html")
        return(invisible())
    }
    write_utf8(sprintf("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">\n<html>\n<head><title>Documentation of the %s package</title></head>\n<frameset cols=\"15%%,*\">\n  <frame src=\"00frame_toc.html\">\n  <frame src=\"00Index.html\" name=\"content\">\n</frameset>\n</html>\n", 
                       pkg), "index.html")
}
<bytecode: 0x000001fd87886b98>
    <environment: namespace:knitr>