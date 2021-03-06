# Cuniqlengths <- data.table:::Cuniqlengths
# Cfrank <- data.table:::Cfrank
# forderv <- data.table:::forderv

GRP <- function(X, ...) UseMethod("GRP") # , X

radixorder <- function(..., na.last = TRUE, decreasing = FALSE, starts = FALSE, group.sizes = FALSE, sort = TRUE) {
  z <- pairlist(...)
  decreasing <- rep_len(as.logical(decreasing), length(z))
  .Call(C_radixsort, na.last, decreasing, starts, group.sizes, sort, z)
}

radixorderv <- function(x, na.last = TRUE, decreasing = FALSE, starts = FALSE, group.sizes = FALSE, sort = TRUE) {
  z <- if(is.atomic(x)) pairlist(x) else as.pairlist(unclass(x))
  decreasing <- rep_len(as.logical(decreasing), length(z))
  .Call(C_radixsort, na.last, decreasing, starts, group.sizes, sort, z)
}

# Added... could also do in GRP.default... but this is better, no match.call etc... match.call takes 4 microseconds. could do both ?? think about possible applications...
GRP.GRP <- function(X, ...) X

GRP.default <- function(X, by = NULL, sort = TRUE, decreasing = FALSE, na.last = TRUE,
                        return.groups = TRUE, return.order = FALSE, call = TRUE, ...) { # , gs = TRUE # o

  if(!missing(...)) {
    args <- list(...)
    namarg <- names(args)
    if(any(namarg == "order")) {
      decreasing <- args[["order"]] == 1L # ... == 1L
      warning("'order' has been replaced with 'decreasing' and now takes logical arguments. 'order' can still be used but may be removed at some point.")
      # if(length(args) > 1L && !(length(args) == 2L && any(namarg == "group.sizes")))
      #  unused_arg_action(match.call(), ...)
    } # else if(length(args) != 1L || !any(namarg == "group.sizes"))
      #  unused_arg_action(match.call(), ...)
  }

  if(is.na(na.last)) stop("here na.last needs to be TRUE or FALSE, otherwise the GRP object does not match the data dimensions.")

  if(is.list(X)) {
    if(inherits(X, "GRP")) return(X) # keep ??
    if(is.null(by)) {
      by <- seq_along(unclass(X))
      namby <- attr(X, "names")
      if(is.null(namby)) attr(X, "names") <- namby <- paste0("Group.", by)
      o <- radixorderv(X, na.last, decreasing, TRUE, TRUE, sort)
    } else {
      if(is.call(by)) {
        namby <- all.vars(by)
        by <- ckmatch(namby, attr(X, "names"))
      } else if(is.character(by)) {
        namby <- by
        by <- ckmatch(by, attr(X, "names"))
      } else if(is.numeric(by)) {
        by <- as.integer(by)
        namby <- attr(X, "names")[by]
        if(is.null(namby)) {
          namby <- paste0("Group.", seq_along(by))
          attr(X, "names") <- paste0("Group.", seq_along(unclass(X))) # best ?
        }
      } else stop("by needs to be either a one-sided formula, character column names or column indices!")
      o <- radixorderv(.subset(X, by), na.last, decreasing, TRUE, TRUE, sort)
    }
  } else {
   if(length(by)) stop("by can only be used to subset list / data.frame columns")
   namby <- l1orlst(as.character(substitute(X))) # paste(all.vars(call), collapse = ".") # good in all circumstances ?
   o <- radixorderv(X, na.last, decreasing, TRUE, TRUE, sort)
  }

  st <- attr(o, "starts")
  gs <- attr(o, "group.sizes")
  sorted <- attr(o, "sorted")

  if(return.groups) {
      ust <- if(sorted) st else o[st]
      groups <- if(is.list(X)) .Call(C_subsetDT, X, ust, by) else
        `names<-`(list(.Call(C_subsetVector, X, ust)), namby) # subsetVector preserves attributes (such as "label")
  } else groups <- NULL

  return(`oldClass<-`(list(N.groups = length(st),
                        group.id = .Call(C_frankds, o, st, gs, TRUE),
                        group.sizes = gs,
                        groups = groups,
                        group.vars = namby,
                        ordered = c(GRP.sort = sort, initially.ordered = sorted),
                        order = if(return.order) `attr<-`(o, "group.sizes", NULL) else NULL,
                        call = if(call) match.call() else NULL), "GRP"))
}

is_GRP <- function(x) inherits(x, "GRP")
is.GRP <- is_GRP

GRPnames <- function(x, force.char = TRUE) { # , ...
  groups <- x[[4L]]
  if(is.null(groups)) return(NULL)
  if(length(unclass(groups)) > 1L) return(do.call(paste, c(groups, list(sep = "."))))
  if(force.char) tochar(.subset2(groups, 1L)) else .subset2(groups, 1L) # paste0(groups[[1L]]) prints "NA" but is slow, if assign with rownames<-, cannot have duplicate row names. But, attr<- "row.names" is fine !!
}

# group_names.GRP <- function(x, force.char = TRUE) {
#   .Deprecated("GRPnames")
#   GRPnames(x, force.char)
# }

print.GRP <- function(x, n = 6, ...) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  ord <- x[[6L]]
  cat(paste("collapse grouping object of length", length(x[[2L]]), "with",
            x[[1L]], if(any(ord)) "ordered" else "unordered", "groups"), fill = TRUE)
  cat("\nCall: ", paste0(deparse(x[[8L]]), ", X is ", if(ord[2L]) "ordered" else "unordered"), "\n\n", sep = "")
  cat("Distribution of group sizes: ", fill = TRUE)
  print.summaryDefault(summary.default(x[[3L]]), ...)
  if(!is.null(x[[4L]])) {
    ug <- unattrib(x[[4L]])
    cat("\nGroups with sizes: ", fill = TRUE)
    if(length(ug) == 1L) {
      ug <- ug[[1L]]
      if(length(ug) > 2L*n) {
        ind <- seq.int(x[[1L]]-n+1L, x[[1L]])
        print.default(setNames(x[[3L]][1:n], ug[1:n]), ...)
        cat("  ---", fill = TRUE)
        print.default(setNames(x[[3L]][ind], ug[ind]), ...)
      } else print.default(setNames(x[[3L]], ug), ...)
    } else {
      if(length(ug[[1L]]) > 2L*n) {
        ind <- seq.int(x[[1L]]-n+1L, x[[1L]])
        print.default(setNames(x[[3L]][1:n], do.call(paste, c(lapply(ug, function(x) x[1:n]), list(sep = ".")))), ...)
        cat("  ---", fill = TRUE)
        print.default(setNames(x[[3L]][ind], do.call(paste, c(lapply(ug, function(x) x[ind]), list(sep = ".")))), ...)
      } else print.default(setNames(x[[3L]], do.call(paste, c(ug, list(sep = ".")))), ...)
    }
  }
}

plot.GRP <- function(x, breaks = "auto", type = "s", horizontal = FALSE, ...) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  oldpar <- par(mfrow = if(horizontal) 1:2 else 2:1, mar = c(3.9,4.1,2.1,1), mgp = c(2.5,1,0))
  on.exit(par(oldpar))
  if(breaks == "auto") {
    ugs <- length(funique(x[[3L]]))
    breaks <- if(ugs > 80) 80 else ugs
  }
  plot(seq_len(x[[1L]]), x[[3L]], type = type, xlab = "Group id", ylab = "Group Size",
       main = paste0("Sizes of ", x[[1L]], " ", if(any(x[[6L]])) "Ordered" else "Unordered", " Groups"), frame.plot = FALSE, ...)
  # grid()
  if(breaks == 1L) plot(x[[3L]][1L], x[[1L]], type = "h", ylab = "Frequency", xlab = "Group Size",
                        main = "Histogram of Group Sizes", frame.plot = FALSE, ...) else
  hist(x[[3L]], breaks, xlab = "Group Size", main = "Histogram of Group Sizes", ...)
}

as_factor_GRP <- function(x, ordered = FALSE) { # , ...
  # if(is.factor(x)) return(x)
  # if(!is_GRP(x)) stop("x must be a 'GRP' object")
  f <- x[[2L]]
  gr <- unclass(x[[4L]])
  if(is.null(gr)) {
    attr(f, "levels") <- as.character(seq_len(x[[1L]]))
  } else {
    if(length(gr) == 1L) {
      attr(f, "levels") <- tochar(gr[[1L]]) # or formatC ?
    } else {
      attr(f, "levels") <- do.call(paste, c(gr, list(sep = ".")))
    }
  }
  oldClass(f) <- if(ordered) c("ordered","factor","na.included") else c("factor","na.included") # previously if any(x[[6L]])
  f
}

as.factor_GRP <- as_factor_GRP

# as.factor.GRP <- function(x, ordered = FALSE) {
#   .Deprecated("as_factor_GRP")
#   as_factor_GRP(x, ordered)
# }

finteraction <- function(..., ordered = FALSE, sort = TRUE) { # does it drop levels ? -> Yes !
  if(...length() == 1L && is.list(...)) return(as_factor_GRP(GRP.default(..., sort = sort, call = FALSE), ordered))
  as_factor_GRP(GRP.default(list(...), sort = sort, call = FALSE), ordered)
}

GRP.qG <- function(X, ..., group.sizes = TRUE, return.groups = TRUE, call = TRUE) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  gvars <- l1orlst(as.character(substitute(X))) # paste(all.vars(call), collapse = ".") # good in all circumstances ?
  ng <- attr(X, "N.groups")
  grl <- return.groups && length(groups <- attr(X, "groups"))
  if(!inherits(X, "na.included")) if(anyNA(unclass(X))) {
    ng <- ng + 1L
    X[is.na(X)] <- ng
    if(grl) groups <- c(groups, NA)
  }
  ordered <- if(is.ordered(X)) c(TRUE,TRUE) else c(FALSE,FALSE)
  attributes(X) <- NULL
  return(`oldClass<-`(list(N.groups = ng,
                        group.id = X,
                        group.sizes = if(group.sizes) tabulate(X, ng) else NULL, # .Internal(tabulate(X, ng))
                        groups = if(grl) `names<-`(list(groups), gvars) else NULL,
                        group.vars = gvars,
                        ordered = ordered,
                        order = NULL,
                        call = if(call) match.call() else NULL), "GRP"))
}

GRP.factor <- function(X, ..., group.sizes = TRUE, drop = FALSE, return.groups = TRUE, call = TRUE) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  nam <- l1orlst(as.character(substitute(X))) # paste(all.vars(call), collapse = ".") # good in all circumstances ?
  if(!inherits(X, "na.included")) X <- addNA2(X)
  if(drop) X <- .Call(Cpp_fdroplevels, X, FALSE)
  lev <- attr(X, "levels")
  nl <- length(lev)
  ordered <- if(is.ordered(X)) c(TRUE, TRUE) else c(FALSE, FALSE)
  attributes(X) <- NULL
  return(`oldClass<-`(list(N.groups = nl,
                        group.id = X,
                        group.sizes = if(group.sizes) tabulate(X, nl) else NULL, # .Internal(tabulate(X, nl))
                        groups = if(return.groups) `names<-`(list(lev), nam) else NULL,
                        group.vars = nam,
                        ordered = ordered,
                        order = NULL,
                        call = if(call) match.call() else NULL), "GRP"))
}

GRP.pseries <- function(X, effect = 1L, ..., group.sizes = TRUE, return.groups = TRUE, call = TRUE) {
  g <- unclass(attr(X, "index")) # index cannot be atomic since plm always adds a time variable !
  if(length(effect) > 1L) return(GRP.default(g[effect], ...))
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  # if(length(g) > 2L) {
  #   mlg <- -length(g)
  #   nam <- paste(names(g)[mlg], collapse = ".")
  #   g <- interaction(g[mlg], drop = TRUE)
  # } else {
    nam <- if(is.character(effect)) effect else names(g)[effect]
    g <- g[[effect]] # Fastest way to do this ?
  # }
  lev <- attr(g, "levels")
  nl <- length(lev)
  ordered <- if(is.ordered(g)) c(TRUE,TRUE) else c(FALSE,FALSE)
  attributes(g) <- NULL
  return(`oldClass<-`(list(N.groups = nl,
                        group.id = g,
                        group.sizes = if(group.sizes) tabulate(g, nl) else NULL, # .Internal(tabulate(g, nl))
                        groups = if(return.groups) `names<-`(list(lev), nam) else NULL,
                        group.vars = nam,
                        ordered = ordered,
                        order = NULL,
                        call = if(call) match.call() else NULL), "GRP"))
}
GRP.pdata.frame <- function(X, effect = 1L, ..., group.sizes = TRUE, return.groups = TRUE, call = TRUE)
  GRP.pseries(X, effect, ..., group.sizes = group.sizes, return.groups = return.groups, call = call)

fgroup_by <- function(X, ..., sort = TRUE, decreasing = FALSE, na.last = TRUE, return.order = FALSE) {          #   e <- substitute(list(...)) # faster but does not preserve attributes of unique groups !
  clx <- oldClass(X)
  m <- match(c("GRP_df", "grouped_df", "data.frame"), clx, nomatch = 0L)
  if(any(clx == "sf")) oldClass(X) <- clx[clx != "sf"]
  attr(X, "groups") <- GRP.default(fselect(if(m[2L]) fungroup(X) else X, ...), NULL, sort, decreasing, na.last, TRUE, return.order, FALSE)
  # Needed: wlddev %>% fgroup_by(country) gives error if dplyr is loaded. Also sf objects etc..
  # .rows needs to be list(), NULL won't work !! Note: attaching a data.frame class calls data frame methods, even if "list" in front! -> Need GRP.grouped_df to restore object !
  # attr(X, "groups") <- `oldClass<-`(c(g, list(.rows = list())), c("GRP", "data.frame")) # `names<-`(eval(e, X, parent.frame()), all.vars(e))
  oldClass(X) <- c("GRP_df",  if(length(mp <- m[m != 0L])) clx[-mp] else clx, "grouped_df", if(m[3L]) "data.frame") # clx[-m] doesn't work if clx is only "data.table" for example
  # simplest, but X is coerced to data.frame. Through the above solution it can be a list and only receive the 'grouped_df' class
  # add_cl <- c("grouped_df", "data.frame")
  # oldClass(X) <- c(fsetdiff(oldClass(X), add_cl), add_cl)
  if(any(clx == "data.table")) return(alc(X))
  X
}

gby <- fgroup_by

print.GRP_df <- function(x, ...) {
  print(fungroup(x)) # better !! (the method could still print groups attribute etc. ) And can also get rid of .rows() in fgroup_by and other fuzz..
  # but better keep for now, other functions in dplyr might check this and only preserve attributes if they exist. -> Nah. select(UGA_sf, addr_cname) doesn't work anyway..
  # NextMethod()
  g <- attr(x, "groups")
  if(is_GRP(g)) { # Issue Patrice flagged !
    # oldClass(g) <- NULL # could get rid of this if get rid of "data.frame" class.
    stats <- if(length(g[[3L]]))
      paste0(" [", g[[1L]], " | ", round(length(g[[2L]]) / g[[1L]]), " (", round(fsd.default(g[[3L]]), 1L), ")]") else
        paste0(" [", g[[1L]], " | ", round(length(g[[2L]]) / g[[1L]]), "]")
    # Groups: # if(any(g[[6L]])) "ordered groups" else "unordered groups", -> ordered 99% of times...
    cat("\nGrouped by: ", paste(g[[5L]], collapse = ", "), stats, "\n")
    if(inherits(x, "pdata.frame"))
      message("\nNote: 'pdata.frame' methods for flag, fdiff, fgrowth, fbetween, fwithin and varying\n      take precedence over the 'grouped_df' methods for these functions.")
  }
}

print.invisible <- function(x, ...) cat("")

# Still solve this properly for data.table...
`[.GRP_df` <- function(x, ...) {
  clx <- oldClass(x)
  if(any(clx == "data.table")) {
    res <- NextMethod()
    if(any(clx == "invisible")) { # for chaining...
      clx <- clx[clx != "invisible"]
      oldClass(res) <- clx # in case of early return (reduced rows)...
    }
    if(any(grepl(":=", .c(...)))) {
      eval.parent(substitute(x <- res))
      oldClass(res) <- c("invisible", clx) # return(invisible(res)) -> doesn't work here for some reason
    } else {
      if(!(is.list(res) && fnrow2(res) == fnrow2(x))) return(fungroup(res))
      if(is.null(attr(res, "groups"))) attr(res, "groups") <- attr(x, "groups")
      oldClass(res) <- clx
    }
  } else {
    res <- `[`(fungroup(x), ...) # does not respect data.table properties, but better for sf data frame and others which check validity of "groups" attribute
    if(!(is.list(res) && fnrow2(res) == fnrow2(x))) return(res)
    attr(res, "groups") <- attr(x, "groups")
    oldClass(res) <- clx
  }
  res
}

# missing doesn't work, its invidible return...
# `[.GRP_df` <- function(x, ...) {
#   tstop <- function(x) if(missing(x)) NULL else x
#   res <- tstop(NextMethod()) # better than above (problems with data.table method, but do further checks...)
#   if(is.null(res)) return(NULL)
#   if(!(is.list(res) && fnrow2(res) == fnrow2(x))) return(fungroup(res))
#   if(is.null(g <- attr(res, "groups"))) attr(res, "groups") <- g
#   oldClass(res) <- oldClass(x)
#   return(res)
# }

# also needed to sort out errors with dplyr ...
`[[.GRP_df` <-  function(x, ...) UseMethod("[[", fungroup(x)) # function(x, ..., exact = TRUE) .subset2(x, ..., exact = exact)
`[<-.GRP_df` <- function(x, ..., value) UseMethod("[<-", fungroup(x))
`[[<-.GRP_df` <- function(x, ..., value) UseMethod("[[<-", fungroup(x))

# Produce errors...
# print_GRP_df_core <- function(x) {
#   g <- attr(x, "groups")
#   cat("\nGrouped by: ", paste(g[[5L]], collapse = ", "),
#       # if(any(g[[6L]])) "ordered groups" else "unordered groups", -> ordered 99% of times...
#       paste0(" [", g[[1L]], " | ", round(length(g[[2L]]) / g[[1L]]), " (", round(fsd.default(g[[3L]]), 1), ")]"))
#   if(inherits(x, "pdata.frame"))
#     message("\nNote: 'pdata.frame' methods for flag, fdiff, fgrowth, fbetween, fwithin and varying\n      take precedence over the 'grouped_df' methods for these functions.")
# }
#
# head.GRP_df <- function(x, ...) {
#   NextMethod()
#   print_GRP_df_core(x)
# }
#
# tail.GRP_df <- function(x, ...) {
#   NextMethod()
#   print_GRP_df_core(x)
# }


# "[117 ordered groups | mean(N): 64 | sd(N): 29.7]"
# "[117 ordered groups | Avg. N: 64 (SD: 29.7)]"

fungroup <- function(X, ...) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  # clx <- oldClass(X)
  attr(X, "groups") <- NULL
  oldClass(X) <- fsetdiff(oldClass(X), c("GRP_df", "grouped_df"))  # clx[clx != "grouped_df"]
  X
}

# collapse 1.3.2 versions:
# fgroup_by <- function(X, ..., sort = TRUE, decreasing = FALSE, na.last = TRUE, return.order = FALSE) {      #   e <- substitute(list(...)) # faster but does not preserve attributes of unique groups !!
#   clx <- oldClass(X)
#   attr(X, "groups") <- GRP.default(fselect(X, ...), NULL, sort, decreasing, na.last, TRUE, return.order, FALSE) # `names<-`(eval(e, X, parent.frame()), all.vars(e))
#   attr(X, "was.tibble") <- any(clx == "tbl_df")
#   add_cl <- if(any(clx == "data.table")) c("data.table", "tbl_df", "tbl", "grouped_df") else c("tbl_df", "tbl", "grouped_df")
#   oldClass(X) <- c(add_cl, fsetdiff(clx, add_cl)) # necesssary to avoid printing errors... (i.e. wrong group object etc...)
#   X
# }
#
# fungroup <- function(X, untibble = isFALSE(attr(X, "was.tibble"))) {
#   clx <- oldClass(X)
#   attr(X, "groups") <- NULL
#   if(untibble) {
#     oldClass(X) <- fsetdiff(clx, c("tbl_df", "tbl", "grouped_df"))
#     attr(X, "was.tibble") <- NULL
#   } else oldClass(X) <- clx[clx != "grouped_df"]
#   X
# }


fgroup_vars <- function(X, return = "data") {
  g <- attr(X, "groups")
  if(!is.list(g)) stop("attr(X, 'groups') is not a grouping object")
  vars <- if(is_GRP(g)) g[[5L]] else attr(g, "names")[-length(unclass(g))]
  switch(return[1L],
    data = .Call(C_subsetCols, fungroup(X), ckmatch(vars, attr(X, "names")), TRUE),
    unique = if(is_GRP(g)) g[[4L]] else .Call(C_subsetCols, g, -length(unclass(g)), FALSE), # what about attr(*, ".drop") ??
    names = vars,
    indices = ckmatch(vars, attr(X, "names")),
    named_indices = `names<-`(ckmatch(vars, attr(X, "names")), vars),
    logical = `[<-`(logical(length(unclass(X))), ckmatch(vars, attr(X, "names")), TRUE),
    named_logical = {
      nam <- attr(X, "names")
      `names<-`(`[<-`(logical(length(nam)), ckmatch(vars, nam), TRUE), nam)
    },
    stop("Unknown return option!"))
}

GRP.grouped_df <- function(X, ..., return.groups = TRUE, call = TRUE) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  # g <- unclass(attr(X, "groups"))
  g <- attr(X, "groups")
  if(is_GRP(g)) return(g) # return(`oldClass<-`(.subset(g, 1:8), "GRP")) # To avoid data.frame methods being called
  if(!is.list(g)) stop("attr(X, 'groups') is not a grouping object")
  oldClass(g) <- NULL
  lg <- length(g)
  gr <- g[[lg]]
  ng <- length(gr)
  gs <- lengths(gr, FALSE)
  return(`oldClass<-`(list(N.groups = ng, # The C code here speeds up things a lot !!
                        group.id = .Call(C_groups2GRP, gr, fnrow2(X), gs),  # Old: rep(seq_len(ng), gs)[order(unlist(gr, FALSE, FALSE))], # .Internal(radixsort(TRUE, FALSE, FALSE, TRUE, .Internal(unlist(gr, FALSE, FALSE))))
                        group.sizes = gs,
                        groups = if(return.groups) g[-lg] else NULL, # better reclass afterwards ?
                        group.vars = names(g)[-lg],
                        ordered = c(TRUE, TRUE),
                        order = NULL,
                        call = if(call) match.call() else NULL), "GRP"))
}

is_qG <- function(x) inherits(x, "qG")
is.qG <- is_qG

# TODO: fix na_rm speed for character data...
na_rm2 <- function(x, sort) {
  if(sort) return(if(is.na(x[length(x)])) x[-length(x)] else x)
  if(anyNA(x)) x[!is.na(x)] else x # use na_rm here when speed fixed.. (get rid of anyNA then ...)
}

# What about NA last option to radixsort ? -> Nah, vector o becomes too short...

radixfact <- function(x, sort, ord, fact, naincl, keep, retgrp = FALSE) {
  o <- .Call(C_radixsort, TRUE, FALSE, fact || naincl || retgrp, naincl, sort, pairlist(x))
  st <- attr(o, "starts")
  f <- if(naincl) .Call(C_frankds, o, st, attr(o, "group.sizes"), TRUE) else # Fastest? -> Seems so..
        .Call(Cpp_groupid, x, o, 1L, TRUE, FALSE)
  if(fact) {
    if(keep) duplattributes(f, x) else attributes(f) <- NULL
    if(naincl) {
      attr(f, "levels") <- if(attr(o, "sorted")) unattrib(tochar(.Call(C_subsetVector, x, st))) else
            unattrib(tochar(.Call(C_subsetVector, x, o[st]))) # use C_subsetvector ?
    } else {
      attr(f, "levels") <- if(attr(o, "sorted")) unattrib(tochar(na_rm2(.Call(C_subsetVector, x, st), sort))) else
            unattrib(tochar(na_rm2(.Call(C_subsetVector, x, o[st]), sort)))
    }
    oldClass(f) <- c(if(ord) "ordered", "factor", if(naincl) "na.included")
  } else {
    if(naincl) attr(f, "N.groups") <- length(st) # the order is important, this before retgrp !!
    if(retgrp) {
      if(naincl) {
         attr(f, "groups") <- if(attr(o, "sorted")) .Call(C_subsetVector, x, st) else .Call(C_subsetVector, x, o[st])
      } else {
         attr(f, "groups") <- if(attr(o, "sorted")) na_rm2(.Call(C_subsetVector, x, st), sort) else na_rm2(.Call(C_subsetVector, x, o[st]), sort)
      }
    }
    oldClass(f) <- c(if(ord) "ordered", "qG", if(naincl) "na.included")
  }
  f
}

as_factor_qG <- function(x, ordered = FALSE, na.exclude = TRUE) {
  groups <- if(is.null(attr(x, "groups"))) as.character(seq_len(attr(x, "N.groups"))) else tochar(attr(x, "groups"))
  nainc <- inherits(x, "na.included")
  if(na.exclude || nainc) {
    clx <- c(if(ordered) "ordered", "factor", if(nainc) "na.included") # can set unordered ??
  } else {
    if(anyNA(unclass(x))) {
      x[is.na(x)] <- attr(x, "N.groups") + 1L
      groups <- c(groups, NA_character_) # faster doing groups[length(groups)+1] <- NA? -> Nope, what you have is fastest !
    }
    clx <- c(if(ordered) "ordered", "factor", "na.included")
  }
  return(`attributes<-`(x, list(levels = groups, class = clx)))
}

as.factor_qG <- as_factor_qG

qF <- function(x, ordered = FALSE, na.exclude = TRUE, sort = TRUE, drop = FALSE,
               keep.attr = TRUE, method = c("auto", "radix", "hash")) {
  if(is.factor(x)) {
    if(!keep.attr && !all(names(ax <- attributes(x)) == c("levels", "class")))
      attributes(x) <- ax[c("levels", "class")]
    if(na.exclude || inherits(x, "na.included")) {
      clx <- oldClass(x)
      if(ordered && !any(clx == "ordered")) oldClass(x) <- c("ordered", clx) else # can set unordered ??
      if(!ordered && any(clx == "ordered")) oldClass(x) <- clx[clx != "ordered"]
      if(drop) return(.Call(Cpp_fdroplevels, x, !inherits(x, "na.included"))) else return(x)
    }
    x <- addNA2(x)
    oldClass(x) <- c(if(ordered) "ordered", "factor", "na.included")
    if(drop) return(.Call(Cpp_fdroplevels, x, FALSE)) else return(x)
  }
  if(is_qG(x)) return(as_factor_qG(x, ordered, na.exclude))
  switch(method[1L], # if((is.character(x) && !na.exclude) || (length(x) < 500 && !(is.character(x) && na.exclude)))
         auto  = if(is.character(x) || is.logical(x) || length(x) < 500L) .Call(Cpp_qF, x, sort, ordered, na.exclude, keep.attr, 1L) else
           radixfact(x, sort, ordered, TRUE, !na.exclude, keep.attr),
         radix = radixfact(x, sort, ordered, TRUE, !na.exclude, keep.attr),
         hash = .Call(Cpp_qF, x, sort, ordered, na.exclude, keep.attr, 1L),
         stop("Unknown method"))
}

# TODO: Keep if(ordered) "ordered" ?
qG <- function(x, ordered = FALSE, na.exclude = TRUE, sort = TRUE, return.groups = FALSE, method = c("auto", "radix", "hash")) {
  if(inherits(x, c("factor", "qG"))) {
    nainc <- inherits(x, "na.included")
    if(na.exclude || nainc || !anyNA(unclass(x))) {
      newclx <- c(if(ordered) "ordered", "qG", if(nainc || !na.exclude) "na.included")
      if(is.factor(x)) {
        ax <- if(return.groups) list(N.groups = fnlevels(x), groups = attr(x, "levels"), class = newclx) else
          list(N.groups = fnlevels(x), class = newclx)
      } else {
        ax <- if(return.groups) list(N.groups = attr(x, "N.groups"), groups = attr(x, "groups"), class = newclx) else
          list(N.groups = attr(x, "N.groups"), class = newclx)
      }
      return(`attributes<-`(x, ax))
    }
    newclx <- c(if(ordered) "ordered", "qG", "na.included")
    if(is.factor(x)) {
      lev <- attr(x, "levels")
      if(anyNA(lev)) ng <- length(lev) else {
        ng <- length(lev) + 1L
        if(return.groups) lev <- c(lev, NA_character_)
      }
      attributes(x) <- NULL # factor method seems faster, however cannot assign integer, must assign factor level...
    } else {
      if(return.groups && length(lev <- attr(x, "groups"))) lev <- c(lev, NA)
      ng <- attr(x, "N.groups") + 1L
    }
    ax <- if(return.groups) list(N.groups = ng, groups = lev, class = newclx) else
      list(N.groups = ng, class = newclx)
    x[is.na(x)] <- ng
    return(`attributes<-`(x, ax))
  }
  switch(method[1L], # if((is.character(x) && !na.exclude) || (length(x) < 500 && !(is.character(x) && na.exclude)))
         auto  = if(is.character(x) || is.logical(x) || length(x) < 500L) .Call(Cpp_qF, x, sort, ordered, na.exclude, FALSE, 2L+return.groups) else
           radixfact(x, sort, ordered, FALSE, !na.exclude, FALSE, return.groups),
         radix = radixfact(x, sort, ordered, FALSE, !na.exclude, FALSE, return.groups),
         hash =  .Call(Cpp_qF, x, sort, ordered, na.exclude, FALSE, 2L+return.groups),
         stop("Unknown method"))
}


radixuniquevec <- function(x, sort, na.last = TRUE, decreasing = FALSE) {
  o <- .Call(C_radixsort, na.last, decreasing, TRUE, FALSE, sort, pairlist(x))
  if(attr(o, "maxgrpn") == 1L && (!sort || attr(o, "sorted"))) return(x)
  if(attr(o, "sorted")) .Call(C_subsetVector, x, attr(o, "starts")) else
    .Call(C_subsetVector, x, o[attr(o, "starts")])
}

funique <- function(x, ...) UseMethod("funique")

funique.default <- function(x, sort = FALSE, method = c("auto", "radix", "hash"), ...) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  if(is.array(x)) stop("funique currently only supports atomic vectors and data.frames")
  switch(method[1L],
         auto = if(is.numeric(x) && length(x) > 500L) radixuniquevec(x, sort, ...) else
           .Call(Cpp_funique, x, sort),
         radix = radixuniquevec(x, sort, ...),
         hash = .Call(Cpp_funique, x, sort)) # , ... adding dots gives error message too strict, package default is warning..
}

# could make faster still... not using colsubset but something more simple... no attributes needed...
# Enable by formula use ?? by or cols ?? -> cols is clearer !! also with na_omit, by could imply by-group uniqueness check...
funique.data.frame <- function(x, cols = NULL, sort = FALSE, ...) {
  # if(!missing(...)) unused_arg_action(match.call(), ...)
  o <- if(is.null(cols)) radixorderv(x, starts = TRUE, sort = sort, ...) else
       radixorderv(colsubset(x, cols), starts = TRUE, sort = sort, ...) # if(is.call(by)) .subset(x, ckmatch(attr(x, "names"), all.vars(by)))
  if(attr(o, "maxgrpn") == 1L && (!sort || attr(o, "sorted"))) # return(x)
     return(if(inherits(x, "data.table")) alc(x) else x)
  st <- if(attr(o, "sorted")) attr(o, "starts") else o[attr(o, "starts")]
  rn <- attr(x, "row.names")
  if(is.numeric(rn) || is.null(rn) || rn[1L] == "1") return(.Call(C_subsetDT, x, st, seq_along(unclass(x))))
  return(`attr<-`(.Call(C_subsetDT, x, st, seq_along(unclass(x))), "row.names", rn[st]))
}

funique.list <- function(x, cols = NULL, sort = FALSE, ...) funique.data.frame(x, cols, sort, ...)

funique.sf <- function(x, cols = NULL, sort = FALSE, ...) {
  cols <- if(is.null(cols)) which(attr(x, "names") != attr(x, "sf_column")) else
                            cols2int(cols, x, attr(x, "names"), FALSE)
  o <- radixorderv(.subset(x, cols), starts = TRUE, sort = sort, ...)
  if(attr(o, "maxgrpn") == 1L && (!sort || attr(o, "sorted"))) return(x)
  st <- if(attr(o, "sorted")) attr(o, "starts") else o[attr(o, "starts")]
  rn <- attr(x, "row.names")
  if(is.numeric(rn) || is.null(rn) || rn[1L] == "1") return(.Call(C_subsetDT, x, st, seq_along(unclass(x))))
  return(`attr<-`(.Call(C_subsetDT, x, st, seq_along(unclass(x))), "row.names", rn[st]))
}

fdroplevels <- function(x, ...) UseMethod("fdroplevels")

fdroplevels.default <- function(x, ...) {
  message("Trying to drop levels from an unsupported object: returning object")
  x
}


fdroplevels.factor <- function(x, ...) {
  if(!missing(...)) unused_arg_action(match.call(), ...)
  clx <- class(x)
  if(!any(clx == "factor")) stop("x needs to be a factor")
  .Call(Cpp_fdroplevels, x, !any(clx == "na.included"))
}

fdroplevels.data.frame <- function(x, ...) {
  if(!missing(...)) unused_arg_action(match.call(), ...)
  res <- duplAttributes(lapply(unattrib(x), function(y)
    if(is.factor(y)) .Call(Cpp_fdroplevels, y, !inherits(y, "na.included")) else y), x)
  if(inherits(x, "data.table")) return(alc(res))
  res
}

fdroplevels.list <- fdroplevels.data.frame

# Old R-based trial
# fdroplevels.factor <- function(x, ...) {
#   if(!missing(...)) unused_arg_action(match.call(), ...)
#   lev <- attr(x, "levels")
#   ul <- .Call(Cpp_funique, unclass(x), TRUE)
#   lul <- length(ul)
#   if(!is.na(ul[lul])) { # NA always comes last
#     if(lul == length(lev)) return(x)
#     f <- match(unclass(x), ul) # use Rcpp match ??
#     attr(f, "levels") <- lev[ul]
#     return(f)
#   }
#   if(lul-1L == length(lev)) return(x)
#   f <- match(unclass(x), ul[-lul]) # use Rcpp match ??
#   attr(f, "levels") <- lev[ul[-lul]]
#   f
# }
