/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// Copyright 2013, Schmidt

#include <RNACI.h>

#include "pbdBASE.h"
#include "blacs.h"


/* Reductions */
SEXP R_igsum2d1(SEXP ICTXT, SEXP SCOPE, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  R_INIT;
  const int m = INT(M, 0), n = INT(N, 0);
  char top = ' ';
  
  SEXP OUT;
  newRmat(OUT, m, n, "int");
  
  memcpy(INTP(OUT), INTP(A), m*n*sizeof(int));
  
  Cigsum2d(INT(ICTXT, 0), STR(SCOPE, 0), &top, m, n, INTP(OUT), 
      INTP(LDA)[0], INTP(RDEST)[0], INTP(CDEST)[0]);
  
  R_END;
  return(OUT);
}



SEXP R_dgsum2d1(SEXP ICTXT, SEXP SCOPE, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INT(M, 0), n = INT(N, 0);
  char top = ' ';
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(REALSXP, m, n));
  
  memcpy(REAL(OUT), REAL(A), m*n*sizeof(double));
  
  Cdgsum2d(INTEGER(ICTXT)[0], CHARPT(SCOPE, 0), &top, m, n, REAL(OUT), 
      INTEGER(LDA)[0], INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}



SEXP R_igamx2d1(SEXP ICTXT, SEXP SCOPE, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INTEGER(M)[0], n = INTEGER(N)[0];
  char top = ' ';
  int rcflag = -1;
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(INTSXP, m, n));
  
  memcpy(INTEGER(OUT), INTEGER(A), m*n*sizeof(int));
  
  Cigamx2d(INTEGER(ICTXT)[0], CHARPT(SCOPE, 0), &top, m, n, INTEGER(OUT), 
      INTEGER(LDA)[0], &rcflag, &rcflag, rcflag, INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}



SEXP R_dgamx2d1(SEXP ICTXT, SEXP SCOPE, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INTEGER(M)[0], n = INTEGER(N)[0];
  char top = ' ';
  int rcflag = -1;
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(REALSXP, m, n));
  
  memcpy(REAL(OUT), REAL(A), m*n*sizeof(double));
  
  Cdgamx2d(INTEGER(ICTXT)[0], CHARPT(SCOPE, 0), &top, m, n, REAL(OUT), 
      INTEGER(LDA)[0], &rcflag, &rcflag, rcflag, INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}



SEXP R_igamn2d1(SEXP ICTXT, SEXP SCOPE, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INTEGER(M)[0], n = INTEGER(N)[0];
  char top = ' ';
  int rcflag = -1;
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(INTSXP, m, n));
  
  memcpy(INTEGER(OUT), INTEGER(A), m*n*sizeof(int));
  
  Cigamn2d(INTEGER(ICTXT)[0], CHARPT(SCOPE, 0), &top, m, n, INTEGER(OUT), 
      INTEGER(LDA)[0], &rcflag, &rcflag, rcflag, INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}



SEXP R_dgamn2d1(SEXP ICTXT, SEXP SCOPE, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INTEGER(M)[0], n = INTEGER(N)[0];
  char top = ' ';
  int rcflag = -1;
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(REALSXP, m, n));
  
  memcpy(REAL(OUT), REAL(A), m*n*sizeof(double));
  
  Cdgamn2d(INTEGER(ICTXT)[0], CHARPT(SCOPE, 0), &top, m, n, REAL(OUT), 
      INTEGER(LDA)[0], &rcflag, &rcflag, rcflag, INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}



// Point to point send/receive
SEXP R_dgesd2d1(SEXP ICTXT, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INTEGER(M)[0], n = INTEGER(N)[0];
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(REALSXP, m, n));
  
  memcpy(REAL(OUT), REAL(A), m*n*sizeof(double));
  
  Cdgesd2d(INTEGER(ICTXT)[0], m, n, REAL(OUT), INTEGER(LDA)[0], 
      INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}



SEXP R_dgerv2d1(SEXP ICTXT, SEXP M, SEXP N, SEXP A, SEXP LDA, SEXP RDEST, SEXP CDEST)
{
  const int m = INTEGER(M)[0], n = INTEGER(N)[0];
  
  SEXP OUT;
  PROTECT(OUT = allocMatrix(REALSXP, m, n));
  
  memcpy(REAL(OUT), REAL(A), m*n*sizeof(double));
  
  Cdgerv2d(INTEGER(ICTXT)[0], m, n, REAL(OUT), INTEGER(LDA)[0], 
      INTEGER(RDEST)[0], INTEGER(CDEST)[0]);
  
  UNPROTECT(1);
  return(OUT);
}
