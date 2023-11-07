fix_links = function(fps) {
    for ( fp in fps ) {
        fc = xfun::read_utf8(fp)
        fc = fix_func_ref_links(fc)
        fc = fix_description_links(fc)
        xfun::write_utf8(fc, fp)
    }
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
