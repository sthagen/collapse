
roworder <- function(X, ..., na.last = TRUE) {
  ovars <- .c(...)
  if(!length(ovars)) stop("... needs to be comma-separated column names, optionally with a '-' prefix for descending order.")
  dec <- startsWith(ovars, "-")
  if(any(dec)) ovars[dec] <- substr(ovars[dec], 2L, 1000000L)
  z <- as.pairlist(.subset(X, ckmatch(ovars, attr(X, "names"))))
  o <- .Call(C_radixsort, na.last, dec, FALSE, FALSE, TRUE, z)
  if(!is.na(na.last) && attr(o, "sorted")) return(condalc(X, inherits(X, "data.table")))
  rn <- attr(X, "row.names")
  if(is.numeric(rn) || is.null(rn) || rn[1L] == "1") return(.Call(C_subsetDT, X, o, seq_along(unclass(X))))
  return(`attr<-`(.Call(C_subsetDT, X, o, seq_along(unclass(X))), "row.names", rn[o]))
}

posord <- function(sq, o, pos) switch(pos, front = c(o, sq[-o]), end = c(sq[-o], o),
                                      exchange = `[<-`(sq, o[forder.int(o)], value = o),
                                      stop("pos must be 'front', 'end' or 'exchange'."))

roworderv <- function(X, cols = NULL, neworder = NULL, decreasing = FALSE, na.last = TRUE, pos = c("front","end","exchange")) {
  if(is.null(neworder)) {
    if(is.null(cols)) {
      if(inherits(X, "sf")) {
        Xo <- X
        oldClass(Xo) <- NULL
        Xo[[attr(Xo, "sf_column")]] <- NULL
        neworder <- radixorderv(Xo, na.last, decreasing)
      } else neworder <- radixorderv(X, na.last, decreasing)
    } else neworder <- radixorderv(colsubset(X, cols), na.last, decreasing)
    if(!is.na(na.last) && attr(neworder, "sorted")) return(condalc(X, inherits(X, "data.table")))
  } else {
    if(!is.integer(neworder)) neworder <- if(is.numeric(neworder)) as.integer(neworder) else if(is.logical(neworder))
                                          which(neworder) else stop("neworder should be integer or logical.")
    if(length(neworder) != fnrow2(X)) neworder <- posord(seq_along(.subset2(X, 1L)), neworder, pos[1L])
  }
  rn <- attr(X, "row.names")
  if(is.numeric(rn) || is.null(rn) || rn[1L] == "1") return(.Call(C_subsetDT, X, neworder, seq_along(unclass(X))))
  return(`attr<-`(.Call(C_subsetDT, X, neworder, seq_along(unclass(X))), "row.names", rn[neworder]))
}

colorder <- function(X, ..., pos = c("front","end","exchange")) { # This also takes names and indices ....
  ax <- attributes(X)
  oldClass(X) <- NULL # attributes ?
  nam <- names(X)
  iX <- seq_along(X)
  nl <- `names<-`(as.vector(iX, "list"), nam)
  vars <- eval(substitute(c(...)), nl, parent.frame())
  if(!is.integer(vars)) stop(paste0("Unknown columns: ", .c(...)))
  if(length(vars) != length(iX)) vars <- posord(iX, vars, pos[1L])
  return(condalcSA(X[vars], `[[<-`(ax, "names", nam[vars]),
                   any(ax[["class"]] == "data.table")))
}

colorderv <- function(X, neworder = radixorder(names(X)), pos = c("front","end","exchange"), regex = FALSE, ...) { # This also takes names and indices ....
  ax <- attributes(X)
  oldClass(X) <- NULL # attributes ?
  nam <- names(X)
  if(regex) vars <- rgrep(neworder, nam, ..., sort = FALSE) else {
    if(!missing(...)) unused_arg_action(match.call(), ...)
    vars <- cols2int(neworder, X, nam)
  }
  if(length(vars) != length(X)) vars <- posord(seq_along(X), vars, pos[1L])
  return(condalcSA(X[vars], `[[<-`(ax, "names", nam[vars]),
                   any(ax[["class"]] == "data.table")))
}

frename <- function(.x, ..., cols = NULL) {
  args <- substitute(c(...))[-1L]
  nam <- attr(.x, "names")
  namarg <- names(args)
  if(is.null(namarg) || !all(nzchar(namarg))) {
    if(!is.function(..1)) stop("... needs to be expressions colname = newname, or a function to apply to the names of columns in cols.")
    FUN <- if(...length() == 1L) ..1 else # could do special case if ...length() == 2L
      function(x) do.call(..1, c(list(x), list(...)[-1L]))
    if(is.null(cols)) return(condalc(`attr<-`(.x, "names", FUN(nam)),
                                     inherits(.x, "data.table")))
    ind <- cols2int(cols, .x, nam, FALSE)
    nam[ind] <- FUN(nam[ind])
  } else nam[ckmatch(namarg, nam)] <- as.character(args)
  return(condalc(`attr<-`(.x, "names", nam), inherits(.x, "data.table")))
}

# rnm <- frename # clashes with 2 packages.., rme would work but is inconsistent

# A tiny bit faster than setrename <- function(.x, ..., cols = NULL) eval.parent(substitute(.x <- frename(.x, ..., cols = cols))), but not much...
setrename <- function(.x, ..., cols = NULL) {
  args <- substitute(c(...))[-1L]
  nam <- attr(.x, "names")
  namarg <- names(args)
  if(is.null(namarg) || !all(nzchar(namarg))) {
    if(!is.function(..1)) stop("... needs to be expressions colname = newname, or a function to apply to the names of columns in cols.")
    FUN <- if(...length() == 1L) ..1 else # could do special case if ...length() == 2L
      function(x) do.call(..1, c(list(x), list(...)[-1L]))
    if(is.null(cols)) nam <- FUN(nam) else {
      ind <- cols2int(cols, .x, nam, FALSE)
      nam[ind] <- FUN(nam[ind])
    }
  } else nam[ckmatch(namarg, nam)] <- as.character(args)
  if(inherits(.x, "data.table")) {
    eval.parent(substitute(.x <- get0("alc", getNamespace("collapse"))(`attr<-`(.x, "names", nam))))
  } else {
    eval.parent(substitute(attr(.x, "names") <- nam))
  }
}

# setrnm <- setrename
