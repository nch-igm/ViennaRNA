/* Last changed Time-stamp: <2001-09-14 18:13:16 ivo> */
/*                

		  c Ivo Hofacker

		  Vienna RNA package
*/
#include <config.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "energy_par.h"
#include "fold_vars.h"
#include "params.h"
/*@unused@*/
static char rcsid[] UNUSED = "$Id: params.c,v 1.1 2001/09/17 10:30:43 ivo Exp $";

#define PUBLIC
#define PRIVATE static

#define MIN2(A, B)      ((A) < (B) ? (A) : (B))

PRIVATE paramT p;
PRIVATE int done=0;

PUBLIC paramT *scale_parameters(void)
{
  unsigned int i,j,k,l;
  double tempf;
  if ((fabs(p.temperature == temperature)<1e-6)&&(done)) return &p;

  tempf = ((temperature+K0)/Tmeasure);
  for (i=0; i<31; i++) 
    p.hairpin[i] = (int) hairpin37[i]*(tempf);
  for (i=0; i<=MIN2(30,MAXLOOP); i++) {
    p.bulge[i] = (int) bulge37[i]*tempf;
    p.internal_loop[i]= (int) internal_loop37[i]*tempf;
  }
  p.lxc = lxc37*tempf;
  for (; i<=MAXLOOP; i++) {
    p.bulge[i] = p.bulge[30]+(int)(p.lxc*log((double)(i)/30.));
    p.internal_loop[i] = p.internal_loop[30]+(int)(p.lxc*log((double)(i)/30.));
  }
  for (i=0; i<5; i++)
    p.F_ninio[i] = (int) F_ninio37[i]*tempf;
   
  for (i=0; (i*7)<strlen(Tetraloops); i++) 
    p.TETRA_ENERGY[i] = TETRA_ENTH37 - (TETRA_ENTH37-TETRA_ENERGY37[i])*tempf;
  for (i=0; (i*5)<strlen(Triloops); i++) 
    p.Triloop_E[i] =  Triloop_E37[i];
   
  p.MLbase = ML_BASE37*tempf;
  for (i=0; i<=NBPAIRS; i++) { /* includes AU penalty */
    p.MLintern[i] = ML_intern37*tempf;
    p.MLintern[i] +=  (i>2)?TerminalAU:0;
  }
  p.MLclosing = ML_closing37*tempf;

  /* stacks    G(T) = H - [H - G(T0)]*T/T0 */
  for (i=0; i<=NBPAIRS; i++)
    for (j=0; j<=NBPAIRS; j++)
      p.stack[i][j] = enthalpies[i][j] -
	(enthalpies[i][j] - stack37[i][j])*tempf;

  /* mismatches */
  for (i=0; i<=NBPAIRS; i++)
    for (j=0; j<5; j++)
      for (k=0; k<5; k++) {
	p.mismatchI[i][j][k] = mism_H[i][j][k] -
	  (mism_H[i][j][k] - mismatchI37[i][j][k])*tempf;
	p.mismatchH[i][j][k] = mism_H[i][j][k] -
	  (mism_H[i][j][k] - mismatchH37[i][j][k])*tempf;
	p.mismatchM[i][j][k] = mism_H[i][j][k] -
	  (mism_H[i][j][k] - mismatchM37[i][j][k])*tempf;
      }
   
  /* dangles */
  for (i=0; i<=NBPAIRS; i++)
    for (j=0; j<5; j++) {
      int dd;
      dd = dangle5_H[i][j] - (dangle5_H[i][j] - dangle5_37[i][j])*tempf; 
      p.dangle5[i][j] = (dd>0) ? 0 : dd;  /* must be <= 0 */
      dd = dangle3_H[i][j] - (dangle3_H[i][j] - dangle3_37[i][j])*tempf;
      p.dangle3[i][j] = (dd>0) ? 0 : dd;  /* must be <= 0 */
    }
  /* interior 1x1 loops */
  for (i=0; i<=NBPAIRS; i++)
    for (j=0; j<=NBPAIRS; j++)
      for (k=0; k<5; k++)
	for (l=0; l<5; l++) 
	  p.int11[i][j][k][l] = int11_H[i][j][k][l] -
	    (int11_H[i][j][k][l] - int11_37[i][j][k][l])*tempf;

  /* interior 2x1 loops */
  for (i=0; i<=NBPAIRS; i++)
    for (j=0; j<=NBPAIRS; j++)
      for (k=0; k<5; k++)
	for (l=0; l<5; l++) {
	  int m;
	  for (m=0; m<5; m++)
	    p.int21[i][j][k][l][m] = int21_H[i][j][k][l][m] -
	      (int21_H[i][j][k][l][m] - int21_37[i][j][k][l][m])*tempf;
	}
  /* interior 2x2 loops */
  for (i=0; i<=NBPAIRS; i++)
    for (j=0; j<=NBPAIRS; j++)
      for (k=0; k<5; k++)
	for (l=0; l<5; l++) {
	  int m,n;
	  for (m=0; m<5; m++)
	    for (n=0; n<5; n++)	     
	      p.int22[i][j][k][l][m][n] = int22_H[i][j][k][l][m][n] -
		(int22_H[i][j][k][l][m][n]-int22_37[i][j][k][l][m][n])*tempf;
	}

  /* p.Tetraloops = Tetraloops;
  p.Triloops = Triloops;
  */
  p.temperature = temperature;
  done = 1;
  return &p;
}
