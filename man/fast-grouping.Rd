\name{A2-fast-grouping}
\alias{A2-fast-grouping}
\title{Fast (Ordered) Grouping} % \emph{collapse}

\description{
\emph{collapse} provides the following functions to efficiently group (and order) data:
\itemize{
\item \code{\link{radixorder}}, provides fast radix-ordering (+ grouping information) through direct access to the method \code{base::order(..., method = "radix")}. The source code for both \code{\link{radixorder}} and \code{base::order(..., method = "radix")}, comes from \code{data.table:::forder}. \code{\link{radixorder}} was modified to optionally return either a vector of group starts, a vector of group sizes, or both as an attribute, and also an attribute providing the size of the largest group and a logical statement on whether the input was already ordered. The function \code{\link{radixorderv}} exists as a programmers alternative.

\item \code{\link{GRP}} creates \emph{collapse} grouping objects of class 'GRP' based on \code{\link{radixorderv}}. 'GRP' objects form the central building block for grouped operations and programming in \emph{collapse} and are very efficient inputs to all \emph{collapse} functions supporting grouped operations. A 'GRP' object provides information about (1) the number of groups, (2) which rows belong to which group, (3) the group sizes, (4) the unique groups, (5) the variables used for grouping, (6) whether the grouping and initial inputs were ordered and (7) (optionally) the output from \code{\link{radixorder}} containing the ordering vector with group starts and maximum group size attributes.

\item \code{\link{fgroup_by}} provides a fast replacement for \code{dplyr::group_by}, creating a grouped tibble with a 'GRP' object attached. This grouped tibble can however only be used for grouped operations using \emph{collapse} fast functions. \code{dplyr} functions will treat this tibble like an ordinary (non-grouped) one.

\item \code{\link{qF}}, shorthand for 'quick-factor' implements very fast (ordered) factor generation from atomic vectors using either radix ordering \code{method = "radix"} or index hashing \code{method = "hash"}. Factors can also be used for efficient grouped programming with collapse functions, especially if they are generated using \code{qF(x, na.exclude = FALSE)} which assigns a level to missing values and attaches a class 'na.included' ensuring that no additional missing value checks are executed by \emph{collapse} functions.

\item \code{\link{qG}}, shorthand for 'quick-group', generates a kind of factor-light without the levels attribute but instead an attribute providing the number of levels. Optionally the levels / groups can be attached, but without converting them to character. Objects have a class 'qG', which is also recognized in the collapse ecosystem.

\item \code{\link{finteraction}} is a fast alternative to \code{base::interaction} implemented as a wrapper around \code{as.factor.GRP(GRP(...))}. It can ge used to generate a factor from multiple vectors, factors or a list of vectors / factors. Unused factor levels are always dropped.

\item \code{\link{groupid}} is a generalization of \code{data.table::rleid} providing a run-length type group-id from atomic vectors. It is generalization as it also supports passing an ordering vector and skipping missing values. For example \code{\link{qF}} and \code{\link{qG}} with \code{method = "radix"} are essentially implemented using \code{groupid(x, radixorder(x))}.

\item \code{\link{seqid}} is a specialized function which creates a group-id from sequences of integer values. For any ordinary panel-dataset \code{groupid(id, order(id, time))} and \code{seqid(time, order(id, time))} provide the same id variable. \code{\link{seqid}} is especially useful for identifying discontinuities in time-sequences and helps to perform operations such as lags or differences on irregularly spaced time-series and panels.
}
}
\section{Table of Functions}{
  \tabular{lllll}{\emph{ Function / S3 Generic }   \tab\tab \emph{ Methods }   \tab\tab \emph{ Description }  \cr
                 \code{\link{radixorder}}, \code{\link{radixorderv}}  \tab\tab No methods, for data.frame's and vectors  \tab\tab radix based ordering + grouping information \cr
                 \code{\link{GRP}} \tab\tab \code{default, factor, qG, grouped_df, pseries, pdata.frame}  \tab\tab fast (ordered) grouping \cr
                 \code{\link{fgroup_by}} \tab\tab No methods, for data.frame's  \tab\tab fast grouped tibbles \cr
                 \code{\link{qF}} \tab\tab No methods, for vectors \tab\tab quick factor generation \cr
                 \code{\link{qG}} \tab\tab No methods, for vectors \tab\tab quick grouping \cr
                 \code{\link{finteraction}} \tab\tab No methods, for data.frame's and vectors \tab\tab faster interactions \cr
                 \code{\link{groupid}} \tab\tab No methods, for vectors \tab\tab run-length type group-id \cr
                 \code{\link{seqid}} \tab\tab No methods, for vectors \tab\tab run-length type integer sequence-id \cr
}
}
\seealso{
\link[=A1-fast-statistical-functions]{Fast Statistical Functions}, \link[=collapse-documentation]{Collapse Overview}
}
\keyword{manip}
\keyword{documentation}

