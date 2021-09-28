#include <armpl.h>
#include <stdio.h>

int main(void)
{
#define MMAX 800
#define NMAX 800
  int lda;
  int i, info, j, m, n, minmn;
  double a[MMAX*NMAX], s[MMAX+NMAX], u[1], vt[1];
  int matrix_layout;

#ifdef USE_ROW_ORDER
  /* This macro allows access to a 1-d array as though
     it is a 2-d array stored in row-major order */
  #define A(I,J) a[((I)-1)*lda+(J)-1]
  matrix_layout = LAPACK_ROW_MAJOR;
  lda = MMAX;
#else
  /* This macro allows access to a 1-d array as though
     it is a 2-d array stored in column-major order */
  #define A(I,J) a[((J)-1)*lda+(I)-1]
  matrix_layout = LAPACK_COL_MAJOR;
  lda = NMAX;
#endif

  printf("ARMPL example: SVD of a matrix A using dgesdd\n");
  printf("---------------------------------------------\n");
  printf("\n");
  //for (int temp=1;temp<=24000;temp++){
  /* Initialize matrix A */
  m = 600;
  n = 580;
  for(int i=1;i<=m;i++){
    for(int j=1;j<=n;j++){
        A(i,j)=i*j/0.56+i/j+2.6*i-3.4*j;
    }
  }

  /* Compute singular values of A */
  //for (int temp=1;temp<=24000;temp++)
  info = LAPACKE_dgesdd(matrix_layout,'n',m,n,a,lda,s,u,1,vt,1);
  /* Print solution */
  if (m < n)
    minmn = m;
  else
    minmn = n;
  printf("\n");
  printf("Singular values of matrix A:\n");
  for (i = 0; i < minmn; i+=100)
    printf("%8.4f ", s[i]);
  printf("\n");

  return 0;
}
