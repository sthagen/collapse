
# For foundational changes to this code see fsum.R

fnobs <- function(x, ...) UseMethod("fnobs") # , x

fnobs.default <- function(x, g = NULL, TRA = NULL, use.g.names = TRUE, ...) {
  if(is.matrix(x) && !inherits(x, "matrix")) return(fnobs.matrix(x, g, TRA, use.g.names, ...))
  if(!missing(...)) unused_arg_action(match.call(), ...)
  if(is.null(TRA)) {
    if(is.null(g)) return(.Call(C_fnobs,x,0L,0L))
    if(is.atomic(g)) {
      if(use.g.names) {
        if(!is.nmfactor(g)) g <- qF(g, na.exclude = FALSE)
        lev <- attr(g, "levels")
        return(`names<-`(.Call(C_fnobs,x,length(lev),g), lev))
      }
      if(is.nmfactor(g)) return(.Call(C_fnobs,x,fnlevels(g),g))
      g <- qG(g, na.exclude = FALSE)
      return(.Call(C_fnobs,x,attr(g,"N.groups"),g))
    }
    if(!is_GRP(g)) g <- GRP.default(g, return.groups = use.g.names, call = FALSE)
    if(use.g.names) return(`names<-`(.Call(C_fnobs,x,g[[1L]],g[[2L]]), GRPnames(g)))
    return(.Call(C_fnobs,x,g[[1L]],g[[2L]]))
  }
  if(is.null(g)) return(.Call(Cpp_TRA,x,.Call(C_fnobs,x,0L,0L),0L,TtI(TRA)))
  if(is.atomic(g)) {
    if(is.nmfactor(g)) return(.Call(Cpp_TRA,x,.Call(C_fnobs,x,fnlevels(g),g),g,TtI(TRA)))
    g <- qG(g, na.exclude = FALSE)
    return(.Call(Cpp_TRA,x,.Call(C_fnobs,x,attr(g,"N.groups"),g),g,TtI(TRA)))
  }
  if(!is_GRP(g)) g <- GRP.default(g, return.groups = FALSE, call = FALSE)
  .Call(Cpp_TRA,x,.Call(C_fnobs,x,g[[1L]],g[[2L]]),g[[2L]],TtI(TRA))
}

fnobs.matrix <- function(x, g = NULL, TRA = NULL, use.g.names = TRUE, drop = TRUE, ...) {
  if(!missing(...)) unused_arg_action(match.call(), ...)
  if(is.null(TRA)) {
    if(is.null(g)) return(.Call(C_fnobsm,x,0L,0L,drop))
    if(is.atomic(g)) {
      if(use.g.names) {
        if(!is.nmfactor(g)) g <- qF(g, na.exclude = FALSE)
        lev <- attr(g, "levels")
        return(`dimnames<-`(.Call(C_fnobsm,x,length(lev),g,FALSE), list(lev, dimnames(x)[[2L]])))
      }
      if(is.nmfactor(g)) return(.Call(C_fnobsm,x,fnlevels(g),g,FALSE))
      g <- qG(g, na.exclude = FALSE)
      return(.Call(C_fnobsm,x,attr(g,"N.groups"),g,FALSE))
    }
    if(!is_GRP(g)) g <- GRP.default(g, return.groups = use.g.names, call = FALSE)
    if(use.g.names) return(`dimnames<-`(.Call(C_fnobsm,x,g[[1L]],g[[2L]],FALSE), list(GRPnames(g), dimnames(x)[[2L]])))
    return(.Call(C_fnobsm,x,g[[1L]],g[[2L]],FALSE))
  }
  if(is.null(g)) return(.Call(Cpp_TRAm,x,.Call(C_fnobsm,x,0L,0L,TRUE),0L,TtI(TRA)))
  if(is.atomic(g)) {
    if(is.nmfactor(g)) return(.Call(Cpp_TRAm,x,.Call(C_fnobsm,x,fnlevels(g),g,FALSE),g,TtI(TRA)))
    g <- qG(g, na.exclude = FALSE)
    return(.Call(Cpp_TRAm,x,.Call(C_fnobsm,x,attr(g,"N.groups"),g,FALSE),g,TtI(TRA)))
  }
  if(!is_GRP(g)) g <- GRP.default(g, return.groups = FALSE, call = FALSE)
  .Call(Cpp_TRAm,x,.Call(C_fnobsm,x,g[[1L]],g[[2L]],FALSE),g[[2L]],TtI(TRA))
}

fnobs.data.frame <- function(x, g = NULL, TRA = NULL, use.g.names = TRUE, drop = TRUE, ...) {
  if(!missing(...)) unused_arg_action(match.call(), ...)
  if(is.null(TRA)) {
    if(is.null(g)) return(.Call(C_fnobsl,x,0L,0L,drop))
    if(is.atomic(g)) {
      if(use.g.names && !inherits(x, "data.table")) {
        if(!is.nmfactor(g)) g <- qF(g, na.exclude = FALSE)
        lev <- attr(g, "levels")
        return(setRnDF(.Call(C_fnobsl,x,length(lev),g,FALSE), lev))
      }
      if(is.nmfactor(g)) return(.Call(C_fnobsl,x,fnlevels(g),g,FALSE))
      g <- qG(g, na.exclude = FALSE)
      return(.Call(C_fnobsl,x,attr(g,"N.groups"),g,FALSE))
    }
    if(!is_GRP(g)) g <- GRP.default(g, return.groups = use.g.names, call = FALSE)
    if(use.g.names && !inherits(x, "data.table") && length(groups <- GRPnames(g)))
      return(setRnDF(.Call(C_fnobsl,x,g[[1L]],g[[2L]],FALSE), groups))
    return(.Call(C_fnobsl,x,g[[1L]],g[[2L]],FALSE))
  }
  if(is.null(g)) return(.Call(Cpp_TRAl,x,.Call(C_fnobsl,x,0L,0L,TRUE),0L,TtI(TRA)))
  if(is.atomic(g)) {
    if(is.nmfactor(g)) return(.Call(Cpp_TRAl,x,.Call(C_fnobsl,x,fnlevels(g),g,FALSE),g,TtI(TRA)))
    g <- qG(g, na.exclude = FALSE)
    return(.Call(Cpp_TRAl,x,.Call(C_fnobsl,x,attr(g,"N.groups"),g,FALSE),g,TtI(TRA)))
  }
  if(!is_GRP(g)) g <- GRP.default(g, return.groups = FALSE, call = FALSE)
  .Call(Cpp_TRAl,x,.Call(C_fnobsl,x,g[[1L]],g[[2L]],FALSE),g[[2L]],TtI(TRA))
}

fnobs.list <- function(x, g = NULL, TRA = NULL, use.g.names = TRUE, drop = TRUE, ...)
  fnobs.data.frame(x, g, TRA, use.g.names, drop, ...)

fnobs.grouped_df <- function(x, TRA = NULL, use.g.names = FALSE, keep.group_vars = TRUE, ...) {
  if(!missing(...)) unused_arg_action(match.call(), ...)
  g <- GRP.grouped_df(x, call = FALSE)
  nam <- attr(x, "names")
  gn <- which(nam %in% g[[5L]])
  nTRAl <- is.null(TRA)
  gl <- length(gn) > 0L
  if(gl || nTRAl) {
    ax <- attributes(x)
    attributes(x) <- NULL
    if(nTRAl) {
      ax[["groups"]] <- NULL
      ax[["class"]] <- fsetdiff(ax[["class"]], c("GRP_df", "grouped_df"))
      ax[["row.names"]] <- if(use.g.names) GRPnames(g) else .set_row_names(g[[1L]])
      if(gl) {
        if(keep.group_vars) {
          ax[["names"]] <- c(g[[5L]], nam[-gn])
          return(setAttributes(c(g[[4L]],.Call(C_fnobsl,x[-gn],g[[1L]],g[[2L]],FALSE)), ax))
        }
        ax[["names"]] <- nam[-gn]
        return(setAttributes(.Call(C_fnobsl,x[-gn],g[[1L]],g[[2L]],FALSE), ax))
      } else if(keep.group_vars) {
        ax[["names"]] <- c(g[[5L]], nam)
        return(setAttributes(c(g[[4L]],.Call(C_fnobsl,x,g[[1L]],g[[2L]],FALSE)), ax))
      } else return(setAttributes(.Call(C_fnobsl,x,g[[1L]],g[[2L]],FALSE), ax))
    } else if(keep.group_vars) {
      ax[["names"]] <- c(nam[gn], nam[-gn])
      return(setAttributes(c(x[gn],.Call(Cpp_TRAl,x[-gn],.Call(C_fnobsl,x[-gn],g[[1L]],g[[2L]],FALSE),g[[2L]],TtI(TRA))), ax))
    }
    ax[["names"]] <- nam[-gn]
    return(setAttributes(.Call(Cpp_TRAl,x[-gn],.Call(C_fnobsl,x[-gn],g[[1L]],g[[2L]],FALSE),g[[2L]],TtI(TRA)), ax))
  } else return(.Call(Cpp_TRAl,x,.Call(C_fnobsl,x,g[[1L]],g[[2L]],FALSE),g[[2L]],TtI(TRA)))
}

fNobs <- fnobs
fNobs.default <- function(x, ...) fnobs.default(x, ...)
fNobs.matrix <- function(x, ...) fnobs.matrix(x, ...)
fNobs.data.frame <- function(x, ...) fnobs.data.frame(x, ...)
