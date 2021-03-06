context("miscellaneous issues")

# rm(list = ls())

options(warn = -1)

if(identical(Sys.getenv("NCRAN"), "TRUE")) {

test_that("Using a factor with unused levels does not pose a problem to flag, fdiff or fgrowth (#25)", {
  wlddev2 <- subset(wlddev, iso3c %in% c("ALB", "AFG", "DZA"))
  wlddev3 <- droplevels(wlddev2)
  expect_identical(L(wlddev3, 1, LIFEEX~iso3c, ~year), L(wlddev3, 1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(L(wlddev3, -1:1, LIFEEX~iso3c, ~year), L(wlddev3, -1:1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(L(wlddev2, 1, ~iso3c, ~year, cols="LIFEEX")), L(wlddev3, 1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(L(wlddev2, -1:1, ~iso3c, ~year, cols="LIFEEX")), L(wlddev3, -1:1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(D(wlddev2, 1, 1, ~iso3c, ~year, cols="LIFEEX")), D(wlddev3, 1, 1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(D(wlddev2, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX")), D(wlddev3, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(Dlog(wlddev2, 1, 1, ~iso3c, ~year, cols="LIFEEX")), Dlog(wlddev3, 1, 1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(Dlog(wlddev2, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX")), Dlog(wlddev3, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(D(wlddev2, 1, 1, ~iso3c, ~year, cols="LIFEEX", rho = 0.95)), D(wlddev3, 1, 1, ~iso3c, ~year, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(D(wlddev2, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX", rho = 0.95)), D(wlddev3, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(Dlog(wlddev2, 1, 1, ~iso3c, ~year, cols="LIFEEX", rho = 0.95)), Dlog(wlddev3, 1, 1, ~iso3c, ~year, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(Dlog(wlddev2, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX", rho = 0.95)), Dlog(wlddev3, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(G(wlddev2, 1, 1, ~iso3c, ~year, cols="LIFEEX")), G(wlddev3, 1, 1, ~iso3c, ~year, cols="LIFEEX"))
  expect_identical(droplevels(G(wlddev2, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX")), G(wlddev3, -1:1, 1:2, ~iso3c, ~year, cols="LIFEEX"))

  expect_identical(L(wlddev3, 1, LIFEEX~iso3c), L(wlddev3, 1, ~iso3c, cols="LIFEEX"))
  expect_identical(L(wlddev3, -1:1, LIFEEX~iso3c), L(wlddev3, -1:1, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(L(wlddev2, 1, ~iso3c, cols="LIFEEX")), L(wlddev3, 1, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(L(wlddev2, -1:1, ~iso3c, cols="LIFEEX")), L(wlddev3, -1:1, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(D(wlddev2, 1, 1, ~iso3c, cols="LIFEEX")), D(wlddev3, 1, 1, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(D(wlddev2, -1:1, 1:2, ~iso3c, cols="LIFEEX")), D(wlddev3, -1:1, 1:2, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(Dlog(wlddev2, 1, 1, ~iso3c, cols="LIFEEX")), Dlog(wlddev3, 1, 1, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(Dlog(wlddev2, -1:1, 1:2, ~iso3c, cols="LIFEEX")), Dlog(wlddev3, -1:1, 1:2, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(D(wlddev2, 1, 1, ~iso3c, cols="LIFEEX", rho = 0.95)), D(wlddev3, 1, 1, ~iso3c, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(D(wlddev2, -1:1, 1:2, ~iso3c, cols="LIFEEX", rho = 0.95)), D(wlddev3, -1:1, 1:2, ~iso3c, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(Dlog(wlddev2, 1, 1, ~iso3c, cols="LIFEEX", rho = 0.95)), Dlog(wlddev3, 1, 1, ~iso3c, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(Dlog(wlddev2, -1:1, 1:2, ~iso3c, cols="LIFEEX", rho = 0.95)), Dlog(wlddev3, -1:1, 1:2, ~iso3c, cols="LIFEEX", rho = 0.95))
  expect_identical(droplevels(G(wlddev2, 1, 1, ~iso3c, cols="LIFEEX")), G(wlddev3, 1, 1, ~iso3c, cols="LIFEEX"))
  expect_identical(droplevels(G(wlddev2, -1:1, 1:2, ~iso3c, cols="LIFEEX")), G(wlddev3, -1:1, 1:2, ~iso3c, cols="LIFEEX"))

})



library(magrittr)
test_that("Testing grouped_df methods", {
  gdf <- wlddev %>% fsubset(year > 1990, region, income, PCGDP:ODA) %>% fgroup_by(region, income)
  gdf[["wgt"]] <- round(abs(10*rnorm(fnrow(gdf))), 1)
  expect_visible(gdf %>% fmean)
  expect_visible(gdf %>% fmean(wgt))
  expect_equal(gdf %>% fmean(wgt) %>% slt(-sum.wgt), gdf %>% fmean(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fmedian)
  expect_visible(gdf %>% fmedian(wgt))
  expect_equal(gdf %>% fmedian(wgt) %>% slt(-sum.wgt), gdf %>% fmedian(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fnth)
  expect_visible(gdf %>% fnth(0.75))
  expect_visible(gdf %>% fnth(0.75, wgt))
  expect_equal(gdf %>% fnth(0.75, wgt) %>% slt(-sum.wgt), gdf %>% fnth(0.75, wgt, keep.w = FALSE))
  expect_visible(gdf %>% fmode)
  expect_visible(gdf %>% fmode(wgt))
  expect_equal(gdf %>% fmode(wgt) %>% slt(-sum.wgt), gdf %>% fmode(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fsum)
  expect_visible(gdf %>% fsum(wgt))
  expect_equal(gdf %>% fsum(wgt) %>% slt(-sum.wgt), gdf %>% fsum(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fprod)
  expect_visible(gdf %>% fprod(wgt))
  expect_equal(gdf %>% fprod(wgt) %>% slt(-prod.wgt), gdf %>% fprod(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fsd)
  expect_visible(gdf %>% fsd(wgt))
  expect_equal(gdf %>% fsd(wgt) %>% slt(-sum.wgt), gdf %>% fsd(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fvar)
  expect_visible(gdf %>% fvar(wgt))
  expect_equal(gdf %>% fvar(wgt) %>% slt(-sum.wgt), gdf %>% fvar(wgt, keep.w = FALSE))
  expect_visible(gdf %>% fmin)
  expect_visible(gdf %>% fmax)
  expect_visible(gdf %>% ffirst)
  expect_visible(gdf %>% flast)
  expect_visible(gdf %>% fnobs)
  expect_visible(gdf %>% fndistinct)
  expect_visible(gdf %>% collapg)
  expect_visible(gdf %>% fmean(w = wgt)) # good?
  expect_equal(gdf %>% collapg(w = wgt) %>% slt(-wgt), gdf %>% collapg(w = wgt, keep.w = FALSE))
  expect_visible(gdf %>% fscale)
  expect_visible(gdf %>% fscale(wgt))
  expect_equal(gdf %>% fscale(wgt) %>% slt(-wgt), gdf %>% fscale(wgt, keep.w = FALSE))
  expect_visible(gdf %>% STD)
  expect_visible(gdf %>% STD(wgt))
  expect_equal(gdf %>% STD(wgt) %>% slt(-wgt), gdf %>% STD(wgt, keep.w = FALSE))
  expect_equal(gdf %>% fscale, gdf %>% STD(stub = FALSE))
  expect_visible(gdf %>% fbetween)
  expect_visible(gdf %>% fbetween(wgt))
  expect_equal(gdf %>% fbetween(wgt) %>% slt(-wgt), gdf %>% fbetween(wgt, keep.w = FALSE))
  expect_visible(gdf %>% B)
  expect_visible(gdf %>% B(wgt))
  expect_equal(gdf %>% B(wgt) %>% slt(-wgt), gdf %>% B(wgt, keep.w = FALSE))
  expect_equal(gdf %>% fbetween, gdf %>% B(stub = FALSE))
  expect_visible(gdf %>% fwithin)
  expect_visible(gdf %>% fwithin(wgt))
  expect_equal(gdf %>% fwithin(wgt) %>% slt(-wgt), gdf %>% fwithin(wgt, keep.w = FALSE))
  expect_visible(gdf %>% W)
  expect_visible(gdf %>% W(wgt))
  expect_equal(gdf %>% W(wgt) %>% slt(-wgt), gdf %>% W(wgt, keep.w = FALSE))
  expect_equal(gdf %>% fwithin, gdf %>% W(stub = FALSE))
  expect_visible(gdf %>% fcumsum)
  expect_visible(gdf %>% flag)
  expect_visible(gdf %>% L)
  expect_visible(gdf %>% F)
  expect_true(all_obj_equal(gdf %>% flag, gdf %>% L(stubs = FALSE), gdf %>% F(-1, stubs = FALSE)))
  expect_true(all_obj_equal(gdf %>% flag(-3:3), gdf %>% L(-3:3), gdf %>% F(3:-3)))
  expect_visible(gdf %>% fdiff)
  expect_visible(gdf %>% D)
  expect_true(all_obj_equal(gdf %>% fdiff, gdf %>% D(stubs = FALSE)))
  expect_equal(gdf %>% fdiff(-2:2, 1:2), gdf %>% D(-2:2, 1:2))
  expect_visible(gdf %>% fdiff(rho = 0.95))
  expect_visible(gdf %>% fdiff(-2:2, 1:2, rho = 0.95))
  expect_visible(gdf %>% fdiff(log = TRUE))
  expect_visible(gdf %>% fdiff(-2:2, 1:2, log = TRUE))
  expect_visible(gdf %>% fdiff(log = TRUE, rho = 0.95))
  expect_visible(gdf %>% fdiff(-2:2, 1:2, log = TRUE, rho = 0.95))
  expect_visible(gdf %>% fgrowth)
  expect_visible(gdf %>% G)
  expect_true(all_obj_equal(gdf %>% fgrowth, gdf %>% G(stubs = FALSE)))
  expect_equal(gdf %>% fgrowth(-2:2, 1:2), gdf %>% G(-2:2, 1:2))
  expect_visible(gdf %>% fgrowth(scale = 1))
  expect_visible(gdf %>% fgrowth(-2:2, 1:2, scale = 1))
  expect_visible(gdf %>% fgrowth(logdiff = TRUE))
  expect_visible(gdf %>% fgrowth(-2:2, 1:2, logdiff = TRUE))
  expect_visible(gdf %>% fgrowth(logdiff = TRUE, scale = 1))
  expect_visible(gdf %>% fgrowth(-2:2, 1:2, logdiff = TRUE, scale = 1))
})


# Also better not run on CRAN...
test_that("0-length vectors give expected output", {
  funs <- .c(fsum, fprod, fmean, fmedian, fmin, fmax, fnth, fcumsum, fbetween, fwithin, fscale)
  for(i in funs) {
    FUN <- match.fun(i)
    if(i %!in% .c(fsum, fmin, fmax, fcumsum)) {
      expect_true(all_identical(FUN(numeric(0)), FUN(integer(0)), numeric(0)))
    } else {
      expect_identical(FUN(numeric(0)), numeric(0))
      expect_identical(FUN(integer(0)), integer(0))
    }
  }
  funs <- .c(fmode, ffirst, flast)
  for(i in funs) {
    FUN <- match.fun(i)
    expect_identical(FUN(numeric(0)), numeric(0))
    expect_identical(FUN(integer(0)), integer(0))
    expect_identical(FUN(character(0)), character(0))
    expect_identical(FUN(logical(0)), logical(0))
    expect_identical(FUN(factor(0)), factor(0))
  }
  funs <- .c(fvar, fsd)
  for(i in funs) {
    FUN <- match.fun(i)
    expect_identical(FUN(numeric(0)), NA_real_)
    expect_identical(FUN(integer(0)), NA_real_)
  }
  funs <- .c(fnobs, fndistinct)
  for(i in funs) {
    FUN <- match.fun(i)
    expect_identical(FUN(numeric(0)), 0L)
    expect_identical(FUN(integer(0)), 0L)
  }
  funs <- .c(flag, fdiff, fgrowth)
  for(i in funs) {
    FUN <- match.fun(i)
    expect_error(FUN(numeric(0)))
    expect_error(FUN(integer(0)))
  }
  funs <- .c(groupid, seqid)
  for(i in funs) {
    FUN <- match.fun(i)
    expect_identical(FUN(numeric(0)), integer(0))
    expect_identical(FUN(integer(0)), integer(0))
  }
  expect_identical(varying(numeric(0)), FALSE)
  expect_identical(TRA(numeric(0), 1), numeric(0))
})

}

X <- matrix(rnorm(1000), ncol = 10)
g <- qG(sample.int(10, 100, TRUE))
gf <- as_factor_qG(g)
funs <- grep("hd|log", c(.FAST_FUN, .OPERATOR_FUN), ignore.case = TRUE, invert = TRUE, value = TRUE)

test_that("functions work on plain matrices", {
  for(i in funs) {
    expect_visible(match.fun(i)(X))
    expect_visible(match.fun(i)(X, g = g))
    expect_visible(match.fun(i)(X, g = gf))
    expect_visible(match.fun(i)(X, g = g, use.g.names = FALSE))
    expect_visible(match.fun(i)(X, g = gf, use.g.names = FALSE))
  }
})

Xl <- mctl(X)

test_that("functions work on plain lists", {
  for(i in funs) {
    expect_visible(match.fun(i)(Xl))
    expect_visible(match.fun(i)(Xl, g = g, by = g))
    expect_visible(match.fun(i)(Xl, g = gf, by = gf))
    expect_visible(match.fun(i)(X, g = g, by = g, use.g.names = FALSE))
    expect_visible(match.fun(i)(X, g = gf, by = gf, use.g.names = FALSE))
  }
})

test_that("time series functions work inside lm", {
  expect_equal(unname(coef(lm(mpg ~ L(cyl, 0:2), mtcars))), unname(coef(lm(mpg ~ cyl + L(cyl, 1) + L(cyl, 2), mtcars))))
  expect_equal(unname(coef(lm(mpg ~ F(cyl, 0:2), mtcars))), unname(coef(lm(mpg ~ cyl + F(cyl, 1) + F(cyl, 2), mtcars))))
  expect_equal(unname(coef(lm(mpg ~ D(cyl, 0:2), mtcars))), unname(coef(lm(mpg ~ cyl + D(cyl, 1) + D(cyl, 2), mtcars))))
  expect_equal(unname(coef(lm(mpg ~ G(cyl, 0:2), mtcars))), unname(coef(lm(mpg ~ cyl + G(cyl, 1) + G(cyl, 2), mtcars))))

  expect_equal(unname(coef(lm(mpg ~ L(L(cyl, 0:2)), mtcars))), unname(coef(lm(mpg ~ L(cyl) + L(cyl, 2) + L(cyl, 3), mtcars))))
  expect_equal(unname(coef(lm(mpg ~ L(F(cyl, 0:2)), mtcars))), unname(coef(lm(mpg ~ L(cyl) + cyl + F(cyl, 1), mtcars))))
  expect_equal(unname(coef(lm(mpg ~ L(D(cyl, 0:2)), mtcars))), unname(coef(lm(mpg ~ L(cyl) + L(D(cyl)) + L(D(cyl, 2)), mtcars))))
  expect_equal(unname(coef(lm(mpg ~ L(G(cyl, 0:2)), mtcars))), unname(coef(lm(mpg ~ L(cyl) + L(G(cyl)) + L(G(cyl, 2)), mtcars))))

})


options(warn = 1)
