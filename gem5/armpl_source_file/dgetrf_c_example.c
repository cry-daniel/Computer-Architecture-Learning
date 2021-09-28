#include <armpl.h>
#include <stdio.h>

int main(void)
{
#define NMAX 700
#define NRHMAX 700
  int lda, ldb, matrix_layout;
  int i, info, j, n, nrhs;
  double a[NMAX*NMAX], b[NMAX*NRHMAX];
  int ipiv[NMAX];

#ifdef USE_ROW_ORDER
  /* These macros allows access to a 1-D array as though
     they are 2-D arrays stored in row-major order */
  #define A(I,J) a[((I)-1)*lda+(J)-1]
  #define B(I,J) b[((I)-1)*ldb+(J)-1]
  matrix_layout = LAPACK_ROW_MAJOR;
  lda = NMAX;
  ldb = NMAX;
#else
  /* These macros allows access to a 1-D array as though
     they are 2-D arrays stored in column-major order */
  #define A(I,J) a[((J)-1)*lda+(I)-1]
  #define B(I,J) b[((J)-1)*ldb+(I)-1]
  matrix_layout = LAPACK_COL_MAJOR;
  lda = NMAX;
  ldb = NMAX;
#endif

  printf("ARMPL example: solution of linear equations using dgetrf/dgetrs\n");
  printf("---------------------------------------------------------------\n");
  printf("\n");

  /* Initialize matrix A */
  n = 680;
  for(int i=1;i<=n;i++){
    for(int j=1;j<=n;j++){
        A(i,j)=i*j/0.45+2.698*i+2.311*j+i/j;
    }
  }


  /* Initialize right-hand-side matrix B */
  nrhs = 680;
  for(int i=1;i<=nrhs;i++){
    for(int j=1;j<=nrhs;j++){
        B(i,j)=i*j/0.45+2.698*i+2.311*j+i/j;
    }
  }


  //printf("Matrix A:\n");

  /* Factorize A */
  info = LAPACKE_dgetrf(matrix_layout,n,n,a,lda,ipiv);
  printf("\n");
  if (info == 0)
    {
      /* Compute solution */
      //for (int temp=1;temp<=2000;temp++)
      info = LAPACKE_dgetrs(matrix_layout,'n',n,nrhs,a,lda,ipiv,b,ldb);
      /* Print solution */
      printf("Solution matrix X of equations A*X = B:\n");
      for (i = 1; i <= n; i+=100)
        {
          for (j = 1; j <= nrhs; j+=100)
            printf("%8.4f ", B(i,j));
          printf("\n");
        }
    }
  else
    printf("The factor U of matrix A is singular\n");

  return 0;
}
