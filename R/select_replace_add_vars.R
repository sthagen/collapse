
# ind must be integer (not numeric) !!!
get_vars_ind <- function(x, ind, return = "data")
  switch(return,
         data = .Call(C_subsetCols, x, ind, TRUE),
         names = attr(x, "names")[ind],
         indices = ind,
         named_indices = `names<-`(ind, attr(x, "names")[ind]),
         logical = `[<-`(logical(length(unclass(x))), ind, value = TRUE),
         named_logical = `names<-`(`[<-`(logical(length(unclass(x))), ind, value = TRUE), attr(x, "names")),
         stop("Unknown return option!"))

# ind must be logical !!! (this used to be get_vars_FUN)
get_vars_indl <- function(x, indl, return = "data")
  switch(return,
         data = .Call(C_subsetCols, x, which(indl), TRUE),
         names = attr(x, "names")[indl],
         indices = which(indl),
         named_indices = which(`names<-`(indl, attr(x, "names"))),
         logical = indl,
         named_logical = `names<-`(indl, attr(x, "names")),
         stop("Unknown return option!"))

# ind can be integer or logical
"get_vars_ind<-" <- function(x, ind, value) {
  ind <- if(is.logical(ind)) which(ind) else as.integer(ind)
  if(is.null(value)) {
    if(!length(ind)) return(condalc(x, inherits(x, "data.table")))
    return(.Call(C_subsetCols, x, -ind, TRUE))
  }
  clx <- oldClass(x)
  oldClass(x) <- NULL
  if(is.list(value)) {
    oldClass(value) <- NULL # fastest ?? if(is.object(value)) oldClass(value) <- NULL ??
    if(length(value[[1L]]) != length(x[[1L]])) stop("NROW(value) must match nrow(x)")
    if(length(value) != length(ind)) stop("NCOL(value) must match selected variables") # length(num_vars(x))
    x[ind] <- value
    if(length(nam <- names(value))) names(x)[ind] <- nam #  == length(ind)
  } else {
    if(NROW(unclass(value)) != length(x[[1L]])) stop("NROW(value) must match nrow(x)")
    if(length(ind) != 1L) stop("NCOL(value) must match selected variables") # length(num_vars(x))
    x[[ind]] <- value
  }
  return(condalc(`oldClass<-`(x, clx), any(clx == "data.table")))
}


fselect <- function(x, ..., return = "data") { # This also takes names and indices ....
  # ax <- attributes(x)
  # oldClass(x) <- NULL # attributes ?
  nam <- attr(x, "names")
  # if(inherits(x, "data.table")) nam <- nam[seq_col(x)] # required because of overallocation... -> Should be solved now, always take shallow copy...
  nl <- `names<-`(as.vector(seq_along(nam), "list"), nam)
  vars <- eval(substitute(c(...)), nl, parent.frame())
  # if(!is.integer(vars)) stop(paste0("Unknown columns: ", .c(...))) # if(!is.integer(vars) || max(vars) > length(nam)) # nah, a bit redundant..
  if(!is.atomic(vars) || is.logical(vars)) stop("... needs to be expressions evaluating to integer or character")
  nam_vars <- names(vars)
  vars <- if(is.character(vars)) ckmatch(vars, nam) else as.integer(vars) # needed, otherwise selecting with doubles gives an error
  if(length(nam_vars)) { # Allow renaming during selection
    nonmiss <- nzchar(nam_vars)
    nam[vars[nonmiss]] <- nam_vars[nonmiss]
  }
  # if(!is.numeric(vars)) stop("... needs to be column names, or character / integer / logical vectors")
  switch(return, # need this for sf data.frame
         data = .Call(C_subsetCols, if(length(nam_vars)) `attr<-`(x, "names", nam) else x, vars, TRUE), # setAttributes(x[vars], `[[<-`(ax, "names", nam[vars])), # Also Improvements in code below ?
         names = nam[vars],
         indices = vars,
         named_indices = `names<-`(vars, nam[vars]),
         logical = `[<-`(logical(length(nam)), vars, TRUE),
         named_logical = `names<-`(`[<-`(logical(length(nam)), vars, TRUE), nam),
         stop("Unknown return option"))
}

# or slt sel, selt, sct -> shortcut ?
slt <- fselect # good, consistent

# fselect(GGDC10S, Country, AGR:SUM)
# fselect(GGDC10S, Variable == "VA" & Year > 1990, Country, Year, AGR:SUM) -> why no error ?? first argument is just ignored ... ??

"fselect<-" <- function(x, ..., value) {
  nam <- attr(x, "names")
  # if(inherits(x, "data.table")) nam <- nam[seq_col(x)] # required because of overallocation... Should be solved now -> always make shallow copy
  nl <- `names<-`(as.vector(seq_along(nam), "list"), nam)
  vars <- eval(substitute(c(...)), nl, parent.frame())
  if(!is.atomic(vars) || is.logical(vars)) stop("... needs to be expressions evaluating to integer or character")
  if(is.character(vars)) vars <- ckmatch(vars, nam)
  if(vars[1L] < 0L) vars <- seq_along(nam)[vars]
  # if(!is.numeric(vars)) stop("... needs to be column names, or character / integer / logical vectors")
  # if(!is.integer(vars)) stop(paste0("Unknown columns: ", .c(...)))
  `get_vars_ind<-`(x, vars, value)
}

"slt<-" <- `fselect<-`


# STD(fselect(GGDC10S, Country, Variable, Year, AGR:SUM))
# Idea: also do this for replacement functions, replacing characters renames, replacong number reorders, replacing 3 does renaming and reordering?

num_vars <- function(x, return = "data") get_vars_indl(x, vapply(`attributes<-`(x, NULL), is.numeric, TRUE), return)
nv <- num_vars

"num_vars<-" <- function(x, value) `get_vars_ind<-`(x, vapply(`attributes<-`(x, NULL), is.numeric, TRUE), value)
"nv<-" <- `num_vars<-`

char_vars <- function(x, return = "data") get_vars_indl(x, vapply(`attributes<-`(x, NULL), is.character, TRUE), return)
"char_vars<-" <- function(x, value) `get_vars_ind<-`(x, vapply(`attributes<-`(x, NULL), is.character, TRUE), value)

fact_vars <- function(x, return = "data") get_vars_indl(x, vapply(`attributes<-`(x, NULL), is.factor, TRUE), return)
"fact_vars<-" <- function(x, value) `get_vars_ind<-`(x, vapply(`attributes<-`(x, NULL), is.factor, TRUE), value)

logi_vars <- function(x, return = "data") get_vars_indl(x, vapply(`attributes<-`(x, NULL), is.logical, TRUE), return)
"logi_vars<-" <- function(x, value) `get_vars_ind<-`(x, vapply(`attributes<-`(x, NULL), is.logical, TRUE), value)

date_vars <- function(x, return = "data") get_vars_indl(x, vapply(`attributes<-`(x, NULL), is_date, TRUE), return)
"date_vars<-" <- function(x, value) `get_vars_ind<-`(x, vapply(`attributes<-`(x, NULL), is_date, TRUE), value)
Date_vars <- date_vars
"Date_vars<-" <- `date_vars<-`

cat_vars <- function(x, return = "data") get_vars_indl(x, !vapply(`attributes<-`(x, NULL), is.numeric, TRUE), return)
"cat_vars<-" <- function(x, value) `get_vars_ind<-`(x, !vapply(`attributes<-`(x, NULL), is.numeric, TRUE), value)


get_vars <- function(x, vars, return = "data", regex = FALSE, ...) {
 if(regex) {
   if(!is.character(vars)) stop("If regex = TRUE, vars must be character")
   ind <- rgrep(vars, attr(x, "names"), ...)
 } else {
   if(!missing(...)) unused_arg_action(match.call(), ...)
   ind <- cols2int(vars, x, attr(x, "names"))
 }
 get_vars_ind(x, ind, return)
}

gv <- function(x, vars, return = "data", ...) {
  if(!missing(...)) {
    warning("Please use the new shortcut 'gvr' for regex column selection.")
    return(get_vars(x, vars, return, ...))
  }
  ind <- cols2int(vars, x, attr(x, "names"))
  get_vars_ind(x, ind, return)
}

gvr <- function(x, vars, return = "data", ...) {
  if(!is.character(vars)) stop("If regex = TRUE, vars must be character")
  ind <- rgrep(vars, attr(x, "names"), ...)
  get_vars_ind(x, ind, return)
}



"get_vars<-" <- function(x, vars, regex = FALSE, ..., value) {
  if(regex) {
    if(!is.character(vars)) stop("If regex = TRUE, vars must be character")
    ind <- rgrep(vars, attr(x, "names"), ...)
  } else {
    if(!missing(...)) unused_arg_action(match.call(), ...)
    ind <- cols2int(vars, x, attr(x, "names"))
  }
  `get_vars_ind<-`(x, ind, value)
}

"gv<-" <- function(x, vars, ..., value) {
  if(!missing(...)) {
    warning("Please use the new shortcut 'gvr<-' for regex column replacement.")
    return(`get_vars<-`(x, vars, ..., value = value))
  }
  ind <- cols2int(vars, x, attr(x, "names"))
  `get_vars_ind<-`(x, ind, value)
}

"gvr<-" <- function(x, vars, ..., value) {
  ind <- rgrep(vars, attr(x, "names"), ...)
  `get_vars_ind<-`(x, ind, value)
}

# Make faster ?
"add_vars<-" <- function(x, pos = "end", value) {
  ax <- attributes(x)
  attributes(x) <- NULL
  lx <- length(x)
  if(is.list(value)) {
    oldClass(value) <- NULL # fastest ?
    if(length(value[[1L]]) != length(x[[1L]])) stop("NROW(value) must match nrow(x)")
    # res <- c(x, value)  # FASTER than commented out below
    if(is.character(pos)) {
      if(pos == "end") {
        ax[["names"]] <- if(length(nam <- names(value)))  c(ax[["names"]], nam) else
          c(ax[["names"]], paste0("V", seq(lx+1L, lx+length(value))))
        return(condalcSA(c(x, value), ax, any(ax[["class"]] == "data.table")))
      } else if(pos != "front") stop("pos needs to be 'end', 'front' or a suitable numeric / integer vector of positions!")
        ax[["names"]] <- if(length(nam <- names(value)))  c(nam, ax[["names"]]) else
          c(paste0("V", seq_along(value)), ax[["names"]])
        return(condalcSA(c(value, x), ax, any(ax[["class"]] == "data.table")))
    }
    lv <- length(value)
    tl <- lv+lx
    if(!is.numeric(pos) || length(pos) != lv || max(pos) > tl) stop("pos needs to be 'end', 'front' or a suitable numeric / integer vector of positions!")
    o <- forder.int(c(seq_len(tl)[-pos], pos))
    ax[["names"]] <- if(length(nam <- names(value)))  c(ax[["names"]], nam)[o] else
        c(ax[["names"]], paste0("V", pos))[o] # FASTER THIS WAY? -> It seems so...
    return(condalcSA(c(x, value)[o], ax, any(ax[["class"]] == "data.table"))) # fastest ?? use setcolorder ? (probably not )
    # ind <- seq(lx+1L, lx+length(value))
    # x[ind] <- value  # FASTER than simply using x[names(value)] <- value ? -> Yes !
    # ax[["names"]] <- if(length(nam <- names(value)))  c(ax[["names"]], nam) else
    #   c(ax[["names"]], paste0("V", ind))
  } else {
    if(NROW(value) != length(x[[1L]])) stop("NROW(value) must match nrow(x)")
    # res <- c(x, list(value)) # FASTER than below ? -> Nope
    # ax[["names"]] <- c(ax[["names"]], paste0("V", lx+1L))
    nam <- l1orlst(as.character(substitute(value)))
    if(is.character(pos)) {
      if(pos == "end") {
        x[[lx+1L]] <- value
        ax[["names"]] <- c(ax[["names"]], nam) # paste0("V", lx+1L)
        return(condalcSA(x, ax, any(ax[["class"]] == "data.table")))
      } else if(pos != "front") stop("pos needs to be 'end', 'front' or a suitable numeric / integer vector of positions!")
      ax[["names"]] <- c(nam, ax[["names"]])
      return(condalcSA(c(list(value), x), ax, any(ax[["class"]] == "data.table")))
    }
    if(!is.numeric(pos) || length(pos) > 1L || pos > lx+1L) stop("pos needs to be 'end', 'front' or a suitable numeric / integer vector of positions!")
    o <- forder.int(c(1:lx, pos-1L))
    ax[["names"]] <- c(ax[["names"]], nam)[o]
    return(condalcSA(c(x, list(value))[o], ax, any(ax[["class"]] == "data.table")))
  }
}
"av<-" <- `add_vars<-`

add_vars <- function(x, ..., pos = "end") {
  if(...length() == 1L) return(`add_vars<-`(x, pos, ...))
  l <- c(...)
  if(!all(fnrow2(x) == lengths(l, FALSE))) stop("if multiple arguments are passed to '...', each needs to be a data.frame/list with column-lengths matching nrow(x)")
  return(`add_vars<-`(x, pos, l)) # very minimal ! Doesn't work for vectors etc !
}
av <- add_vars



# Exercises:
# repl <- function(x)x
# `repl<-` <- function(x, value) {
#   x <- value
#   x
# }
# repl(x)[2] <- 4 # Works!!
# http://adv-r.had.co.nz/Functions.html#special-calls

# This works because the expression names(x)[2] <- "two" is evaluated as if you had written:

#`*tmp*` <- names(x)
#`*tmp*`[2] <- "two"
#names(x) <- `*tmp*`
