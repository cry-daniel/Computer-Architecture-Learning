#include <armpl.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {

	// Dimensions of the matrix multiplication problems
	int m = 50;
	int n = 48;
	int k = 46;

	// Scalar parameters of the matrix multiplication.
	// If beta = 0 then C need not be initialized
	// on entry to cblas_dgemm, and C_p need not be
	// initialized on entry to armpl_dgemm_interleave_batch.
	double alpha = 1.0;
	double beta = 0.5;

	// Set up an batch of problems to solve
	int ninter = 4;
	int nbatch = 15;

	int jstrd_A = ninter; // The interleave-batch layout is "row-major"
	int istrd_A = jstrd_A*k;
	int bstrd_A = istrd_A*m;

	int jstrd_B = ninter;
	int istrd_B = jstrd_B*n;
	int bstrd_B = istrd_B*k;

	int jstrd_C = ninter;
	int istrd_C = jstrd_C*n;
	int bstrd_C = istrd_C*m;

	double *A_p = (double *)malloc(sizeof(double)*bstrd_A*nbatch);
	double *B_p = (double *)malloc(sizeof(double)*bstrd_B*nbatch);
	double *C_p = (double *)malloc(sizeof(double)*bstrd_C*nbatch);

	// Set up BLAS DGEMM input
	int lda = m;
	int ldb = k;
	int ldc = m;

	double *A = (double *)malloc(sizeof(double)*lda*k);
	double *B = (double *)malloc(sizeof(double)*ldb*n);
	double *C = (double *)malloc(sizeof(double)*ldc*n);

	// Loop over the nbatch*ninter problems, calling cblas_dgemm and
	// accumulating a scalar checksum, blas_sum.
	armpl_status_t info;
	double blas_sum = 0.0;
	for (int ib = 0; ib < nbatch; ib++) {
		for (int ii = 0; ii < ninter; ii++) {

			// Initialize this A matrix
			for (int j = 0; j < k; j++) {
				for (int i = 0; i < m; i++) {
					A[j*lda + i] = (double)(ib*ninter + ninter)*m*k + j*m + i;
				}
			}

			// Pack A into A_p for later interleave-batch call
			info = armpl_dge_interleave(ninter, ii, m, k, A, 1, lda,
			                            &A_p[bstrd_A*ib], istrd_A, jstrd_A);
			if (info != ARMPL_STATUS_SUCCESS) {
				fprintf(stderr, "Error: armpl_dge_interleave (A)\n");
				return (int)info;
			}

			// Initialize this B matrix
			for (int j = 0; j < n; j++) {
				for (int i = 0; i < k; i++) {
					B[j*ldb + i] = (double)(ib*ninter + ninter)*k*n + j*k + i;
				}
			}

			// Pack B into B_p for later interleave-batch call
			info = armpl_dge_interleave(ninter, ii, k, n, B, 1, ldb,
			                            &B_p[bstrd_B*ib], istrd_B, jstrd_B);
			if (info != ARMPL_STATUS_SUCCESS) {
				fprintf(stderr, "Error: armpl_dge_interleave (B)\n");
				return (int)info;
			}

			// Perform BLAS GEMM on the current problem
			cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, m, n, k,
			            alpha, A, lda, B, ldb, beta, C, ldc);

			for (int j = 0; j < n; j++) {
				for (int i = 0; i < m; i++) {
					blas_sum += C[j*ldc + i];
				}
			}
		}
	}

	// Free the BLAS arrays
	free(A);
	free(B);
	free(C);

	// Perform a single interleave-batch call to compute all
	// ninter*nbatch probelms
	info = armpl_dgemm_interleave_batch(ninter, nbatch, 'N', 'N', m, n, k,
	                                    alpha, A_p, bstrd_A, istrd_A, jstrd_A,
                                        B_p, bstrd_B, istrd_B, jstrd_B, beta,
                                        C_p, bstrd_C, istrd_C, jstrd_C);
	if (info != ARMPL_STATUS_SUCCESS) {
		fprintf(stderr, "Error: armpl_dgemm_interleave_batch\n");
		return (int)info;
	}

	// Free the interleave-batch input arrays
	free(A_p);
	free(B_p);

	// Extract each C matrix and form a new checksum, ib_sum
	double *CC = (double *)malloc(sizeof(double)*ldc*n);
	double ib_sum = 0.0;
	for (int ib = 0; ib < nbatch; ib++) {
		for (int ii = 0; ii < ninter; ii++) {

			// Unpack the next output matrix in the batch into CC
			info = armpl_dge_deinterleave(ninter, ii, m, n, CC, 1, ldc,
			                              &C_p[bstrd_C*ib], istrd_C, jstrd_C);
			if (info != ARMPL_STATUS_SUCCESS) {
				fprintf(stderr, "Error: armpl_dg_deinterleave\n");
				return (int)info;
			}

			// Add contributions to checksum
			for (int j = 0; j < n; j++) {
				for (int i = 0; i < m; i++) {
					ib_sum += CC[j*ldc + i];
				}
			}
		}
	}

	// Free the interleave-batch out array and the BLAS array we unpacked into
	free(CC);
	free(C_p);

	printf("ARMPL example: interleave-batch matrix multiplication\n");
	printf("-----------------------------------------------------\n\n");

	printf("blas_sum = %e\n", blas_sum);
	printf("  ib_sum = %e\n\n", ib_sum);

	return 0;
}
