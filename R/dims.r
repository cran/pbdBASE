#' descinit
#'
#' Creates ScaLAPACK descriptor array.
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' @param dim
#' Global dim.
#' @param bldim
#' Blocking dim.
#' @param ldim
#' Local dim.
#' @param ICTXT
#' BLACS context.
#' @return A descriptor array.
#'
#' @examples
#' spmd.code <- "
#'   suppressMessages(library(pbdMPI))
#'   suppressMessages(library(pbdBASE))
#'   init.grid()
#'
#'   ### Set desc.
#'   dim <- c(6L, 5L)
#'   bldim <- c(3L, 3L)
#'   ldim <- base.numroc(dim = dim, bldim = bldim)
#'   descx <- base.descinit(dim = dim, bldim = bldim, ldim = ldim)
#'   comm.print(descx)
#'
#'   finalize()
#' "
#' pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)
#'
#' @useDynLib pbdBASE R_descinit
#' @export
base.descinit <- function(dim, bldim, ldim, ICTXT=0)
{
###  desc[1L] <- 1L                    # matrix type
###  desc[2L] <- ICTXT                 # CTXT_A
###  desc[3L] <- max(0, dim[1L])       # M_A
###  desc[4L] <- max(0, dim[2L])       # N_A
###  desc[5L] <- max(1, bldim[1L])     # MB_A
###  desc[6L] <- max(1, bldim[2L])     # NB_A
###  desc[7L] <- 0L                    # RSRC_A
###  desc[8L] <- 0L                    # CSRC_A
###  desc[9L] <- max(1L, ldim[1L])     # LLD_A
###  desc[9L] <- max(ldim[1L], max(1L, NUMROC(dim[1L], bldim[1L], grid$MYROW, grid$NPROW)))
  grid <- base.blacs(ICTXT=ICTXT)
  lld <- NUMROC(dim[1L], bldim[1L], grid$MYROW, grid$NPROW)
  lld <- max(lld, 1L)
  
  desc <- .Call("R_descinit", as.integer(dim), as.integer(bldim), as.integer(ICTXT), as.integer(lld))
  
  ### Fix for pdgemr2d: if a process is not a part of the given context, its ICTXT is -1
  if (any(base.blacs(ICTXT=ICTXT) == -1))
    desc[2L] <- -1L
  
  desc
}



#' numroc
#'
#' NUMber of Rows Or Columns
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' @param dim
#' Global dim.
#' @param bldim
#' Blocking dim.
#' @param ICTXT
#' BLACS context.
#' @param fixme
#' Should ldims be "rounded" to 0 or not.
#' @return A vector of local dim.
#'
#' @examples
#' spmd.code <- "
#'   suppressMessages(library(pbdMPI))
#'   suppressMessages(library(pbdBASE))
#'   init.grid()
#'
#'   ### Set desc.
#'   dim <- c(6L, 5L)
#'   bldim <- c(3L, 3L)
#'   ldim <- base.numroc(dim = dim, bldim = bldim)
#'   comm.print(ldim)
#'
#'   finalize()
#' "
#' pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)
#'
#' @export
base.numroc <- function(dim, bldim, ICTXT=0, fixme=TRUE)
{
  blacs_ <- base.blacs(ICTXT=ICTXT)
  
  MYP <- c(blacs_$MYROW, blacs_$MYCOL)
  PROCS <- c(blacs_$NPROW, blacs_$NPCOL)
  
  ISRCPROC <- 0
  
  ldim <- numeric(2)
  for (i in 1:2){
    MYDIST <- (PROCS[i] + MYP[i] - ISRCPROC) %% PROCS[i]
    NBLOCKS <- floor(dim[i] / bldim[i])
    ldim[i] <- floor(NBLOCKS / PROCS[i]) * bldim[i]
    EXTRABLKS <- NBLOCKS %% PROCS[i]

    if (is.na(EXTRABLKS))
      EXTRABLKS <- 0

    if (MYDIST < EXTRABLKS)
      ldim[i] <- ldim[i] + bldim[i]
    else if (MYDIST == EXTRABLKS)
      ldim[i] <- ldim[i] + dim[i] %% bldim[i]
  }

  if (fixme){
    if (any(is.na(ldim)))
      ldim[which(is.na(ldim))] <- 0L
    if (any(ldim<1)) ldim <- c(1L, 1L) # FIXME
  }

  ldim
}

numroc <- base.numroc



#' @useDynLib pbdBASE R_NUMROC
NUMROC <- function(N, NB, IPROC, NPROCS)
{
  ret <- .Call(R_NUMROC, as.integer(N), as.integer(NB), as.integer(IPROC), as.integer(NPROCS))
  ret
}



#' Determining Local Ownership of a Distributed Matrix
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' A simple wrapper of numroc. The return is the answer to
#' the question 'do I own any of the global matrix?'.  Passing a distributed
#' matrix is allowed, but often it is convenient to determine that information
#' without even having a distributed matrix on hand. In this case, explicitly
#' passing the appropriate information to the arguments \code{dim=},
#' \code{bldim=} (and \code{CTXT=} as necessary, since it defaults to 0) while
#' leaving \code{x} missing will produce the desired result. See the examples
#' below for more clarity.
#'
#' The return for each function is local.
#'
#' @param dim
#' global dimension
#' @param bldim
#' blocking dimension
#' @param ICTXT
#' BLACS context
#' @return TRUE or FALSE
#'
#' @keywords BLACS Distributing Data
#'
#' @examples
#' spmd.code <- "
#'   suppressMessages(library(pbdMPI))
#'   suppressMessages(library(pbdBASE))
#'   init.grid()
#'
#'   iown <- base.ownany(dim=c(4, 4), bldim=c(4, 4), ICTXT=0)
#'   comm.print(iown, all.rank = TRUE)
#'
#'   finalize()
#' "
#' pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)
#'
#' @export
base.ownany <- function(dim, bldim, ICTXT=0)
{
  if (length(bldim)==1)
    bldim <- rep(bldim, 2)
  
  grid <- base.blacs(ICTXT=ICTXT)
  
  check <- integer(2)
  
  check[1L] <- NUMROC(dim[1L], bldim[1L], grid$MYROW, grid$NPROW)
  check[2L] <- NUMROC(dim[2L], bldim[2L], grid$MYCOL, grid$NPCOL)
  
  if (any(check<1))
    return(FALSE)
  else
    return(TRUE)
}



#' maxdim
#'
#' Compute maximum dimension across all nodes
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' @param dim
#' Global dim.
#' @return Maximum dimension.
#'
#' @export
base.maxdim <- function(dim)
{
  mdim <- numeric(2)
  mdim[1] <- pbdMPI::allreduce(dim[1], op='max')
  mdim[2] <- pbdMPI::allreduce(dim[2], op='max')
  
  mdim
}



#' maxdim
#'
#' Compute dimensions on process MYROW=MYCOL=0
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' @param dim
#' Global dim.
#' @param ICTXT
#' BLACS context.
#' @return Dimension on MYROW=MYCOL=0
#'
#' @export
base.dim0 <- function(dim, ICTXT=0)
{
  blacs_ <- base.blacs(ICTXT=ICTXT)
  MYROW <- blacs_$MYROW
  MYCOL <- blacs_$MYCOL
  
  if (MYROW == 0 && MYCOL == 0){
    mx01 <- dim[1]
    mx02 <- dim[2]
  }
  
  mx01 <- pbdMPI::bcast(mx01)
  mx02 <- pbdMPI::bcast(mx02)
  
#  pbdMPI::barrier()
  
  if (MYROW==0 && MYCOL==0)
    return(dim)
  else
    return(c(mx01, mx02))
}



#' g2l_coord
#'
#' Global to local coords.
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' @param ind
#' Matrix indices.
#' @param bldim
#' Blocking dimension.
#' @param ICTXT
#' BLACS context.
#' @param dim
#' Ignored; will be removed in a future version.
#' @return Local coords.
#'
#' @useDynLib pbdBASE g2l_coords
#' @name g2l_coord
#' @rdname g2l_coord
#' @export
base.g2l_coord <- function(ind, bldim, ICTXT=0, dim=NULL)
{
  blacs_ <- base.blacs(ICTXT=ICTXT)
  procs <- c(blacs_$NPROW, blacs_$NPCOL)
  src <- c(0,0)
  
  out <- .Call(g2l_coords, ind=as.integer(ind), bldim=as.integer(bldim), procs=as.integer(procs), src=as.integer(src))
  
#  out[5:6] <- out[5:6] + 1
  
  if (out[3]!=blacs_$MYROW || out[4]!=blacs_$MYCOL)
    out <- rep(NA, 6)
  
  # out is a 'triple of pairs' stored as a length-6 vector, consisting of:
    # block position
    # process grid block
    # local coordinates
  # out will be a length 6 vector of NA when that global coord is not
  # relevant to the local storage
  
  out
}

#' @rdname g2l_coord
#' @export
g2l_coord <- base.g2l_coord



#' l2g_coord
#'
#' Local to global coords.
#'
#' For advanced users only. See pbdDMAT for high-level functions.
#'
#' @param ind
#' Matrix indices.
#' @param bldim
#' Blocking dimension.
#' @param ICTXT
#' BLACS context.
#' @param dim
#' Ignored; will be removed in a future version.
#' @return Global coords.
#'
#' @useDynLib pbdBASE l2g_coords
#' @name l2g_coord
#' @rdname l2g_coord
#' @export
base.l2g_coord <- function(ind, bldim, ICTXT=0, dim=NULL)
{
  blacs_ <- base.blacs(ICTXT=ICTXT)
  procs <- c(blacs_$NPROW, blacs_$NPCOL)
  myproc <- c(blacs_$MYROW, blacs_$MYCOL)
  
  out <- .Call(l2g_coords, ind=as.integer(ind), bldim=as.integer(bldim), procs=as.integer(procs), src=as.integer(myproc))
  out
}

#' @rdname l2g_coord
#' @export
l2g_coord <- base.l2g_coord
