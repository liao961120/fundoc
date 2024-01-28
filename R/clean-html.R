fix_links = function(fps) {
    fix_all = function(x) {
        x = fix_func_ref_links(x)
        x = fix_description_links(x)
        x
    }
    for ( fp in fps ) xfun::process_file(fp, fix_all)
}


fix_func_ref_links = function(lines) {
    sapply(lines, function(line) {
        gsub('href="../../[a-zA-Z0-9.]+/help/([a-zA-Z0-9_.]+\\.html)"',
             'href="\\1"',
             line)
    })
}


fix_description_links = function(lines) {
    sapply(lines, function(line) {
        gsub('href="../DESCRIPTION"',
             'href="DESCRIPTION"', line, fixed = T)
    })
}
