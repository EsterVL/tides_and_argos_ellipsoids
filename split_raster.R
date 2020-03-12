setMethod(
  "splitRaster",
  signature = signature(r = "RasterStack"),
  definition = function(r, nx, ny, buffer, path, cl, rType) {
    if (!is.numeric(nx) | !is.numeric(ny) | !is.numeric(buffer)) {
      stop("nx, ny, and buffer must be numeric")
    }
    if (!is.integer(nx)) nx <- as.integer(nx)
    if (!is.integer(ny)) ny <- as.integer(ny)
    if (is.integer(buffer)) buffer <- as.numeric(buffer)

    if (!is.na(path)) {
      checkPath(path, create = TRUE)
    }

    if (missing(cl)) {
      cl <- tryCatch(getCluster(), error = function(e) NULL)
      on.exit(if (!is.null(cl)) returnCluster(), add = TRUE)
    }

    if (length(buffer) > 2) {
      warning("buffer contains more than 2 elements - only the first two will be used.")
      buffer <- buffer[1:2]
    } else if (length(buffer) == 1) {
      buffer <- c(buffer, buffer)
    }
    if (buffer[1] < 1) {
      buffer[1] <- ceiling((buffer[1] * (xmax(r) - xmin(r)) / nx) / xres(r)) # nolint
    }
    if (buffer[2] < 1) {
      buffer[2] <- ceiling((buffer[2] * (ymax(r) - ymin(r)) / ny) / yres(r)) # nolint
    }

    ext <- extent(r)
    extents <- vector("list", length = nx * ny)
    n <- 1L
    for (i in seq_len(nx) - 1L) {
      for (j in seq_len(ny) - 1L) {
        x0 <- ext@xmin + i * ((ext@xmax - ext@xmin) / nx) - buffer[1] * xres(r) # nolint
        x1 <- ext@xmin + (i + 1L) * ((ext@xmax - ext@xmin) / nx) + buffer[1] * xres(r) # nolint
        y0 <- ext@ymin + j * ((ext@ymax - ext@ymin) / ny) - buffer[2] * yres(r) # nolint
        y1 <- ext@ymin + (j + 1L) * ((ext@ymax - ext@ymin) / ny) + buffer[2] * yres(r) # nolint
        extents[[n]] <- extent(x0, x1, y0, y1)
        n <- n + 1L
      }
    }

    tiles <- if (!is.null(cl)) {
      clusterApplyLB(cl = cl, x = seq_along(extents), fun = .croppy, e = extents, r = r, path = path, rType = rType)
    } else {
      lapply(X = seq_along(extents), FUN = .croppy, e = extents, r = r, path = path, rType = rType)
    }

    return(tiles)
})

#' @keywords internal
.croppy <- function(i, e, r, path, rType) {
  ri <- crop(r, e[[i]], datatype = rType)
  crs(ri) <- crs(r)
  if (is.na(path)) {
    return(ri)
  } else {
    filename <- file.path(path, paste0(names(r), "_tile", i, ".grd"))
    writeRaster(ri, filename, overwrite = TRUE, datatype = rType)
    return(raster(filename))
  }
}

setMethod(
  "splitRaster",
  signature = signature(r = "RasterBrick"),
  definition = function(r, nx, ny, buffer, path, cl, rType) {
    if (!is.numeric(nx) | !is.numeric(ny) | !is.numeric(buffer)) {
      stop("nx, ny, and buffer must be numeric")
    }
    if (!is.integer(nx)) nx <- as.integer(nx)
    if (!is.integer(ny)) ny <- as.integer(ny)
    if (is.integer(buffer)) buffer <- as.numeric(buffer)

    if (!is.na(path)) {
      checkPath(path, create = TRUE)
    }

    if (missing(cl)) {
      cl <- tryCatch(getCluster(), error = function(e) NULL)
      on.exit(if (!is.null(cl)) returnCluster(), add = TRUE)
    }

    if (length(buffer) > 2) {
      warning("buffer contains more than 2 elements - only the first two will be used.")
      buffer <- buffer[1:2]
    } else if (length(buffer) == 1) {
      buffer <- c(buffer, buffer)
    }
    if (buffer[1] < 1) {
      buffer[1] <- ceiling((buffer[1] * (xmax(r) - xmin(r)) / nx) / xres(r)) # nolint
    }
    if (buffer[2] < 1) {
      buffer[2] <- ceiling((buffer[2] * (ymax(r) - ymin(r)) / ny) / yres(r)) # nolint
    }

    ext <- extent(r)
    extents <- vector("list", length = nx * ny)
    n <- 1L
    for (i in seq_len(nx) - 1L) {
      for (j in seq_len(ny) - 1L) {
        x0 <- ext@xmin + i * ((ext@xmax - ext@xmin) / nx) - buffer[1] * xres(r) # nolint
        x1 <- ext@xmin + (i + 1L) * ((ext@xmax - ext@xmin) / nx) + buffer[1] * xres(r) # nolint
        y0 <- ext@ymin + j * ((ext@ymax - ext@ymin) / ny) - buffer[2] * yres(r) # nolint
        y1 <- ext@ymin + (j + 1L) * ((ext@ymax - ext@ymin) / ny) + buffer[2] * yres(r) # nolint
        extents[[n]] <- extent(x0, x1, y0, y1)
        n <- n + 1L
      }
    }

    tiles <- if (!is.null(cl)) {
      clusterApplyLB(cl = cl, x = seq_along(extents), fun = .croppy, e = extents, r = r, path = path, rType = rType)
    } else {
      lapply(X = seq_along(extents), FUN = .croppy, e = extents, r = r, path = path, rType = rType)
    }

    return(tiles)
})

#' @keywords internal
.croppy <- function(i, e, r, path, rType) {
  ri <- crop(r, e[[i]], datatype = rType)
  crs(ri) <- crs(r)
  if (is.na(path)) {
    return(ri)
  } else {
    filename <- file.path(path, paste0(names(r), "_tile", i, ".grd"))
    writeRaster(ri, filename, overwrite = TRUE, datatype = rType)
    return(raster(filename))
  }
}
