#include <stdio.h>
#include <stdlib.h>
#include "armpl.h"

#define NNZ 12
#define M 5
#define N 5

int main()
{
	/* 1. Set-up local CSR structure */
	armpl_spmat_t armpl_mat;
	const int ntests = 1000;
	const double alpha = 1.0, beta = 0.0;
	int creation_flags = 0;
	double vals[NNZ] = {1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12.};
	int row_ptr[M+1] = {0, 2, 4, 7, 9, 12};
	int col_indx[NNZ] = {0, 2, 1, 3, 1, 2, 3, 2, 3, 2, 3, 4};

	/* 2. Set-up Arm Performance Libraries sparse matrix object */
	armpl_status_t info = armpl_spmat_create_csr_d(&armpl_mat, M, N, row_ptr, col_indx, vals, creation_flags);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_create_csr_d returned %d\n", info);

	/* 3a. Supply any pertinent information that is known about the matrix */
	info = armpl_spmat_hint(armpl_mat, ARMPL_SPARSE_HINT_STRUCTURE, ARMPL_SPARSE_STRUCTURE_UNSTRUCTURED);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	/* 3b. Supply any hints that are about the SpMV calculations to be performed */
	info = armpl_spmat_hint(armpl_mat, ARMPL_SPARSE_HINT_SPMV_OPERATION, ARMPL_SPARSE_OPERATION_NOTRANS);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	info = armpl_spmat_hint(armpl_mat, ARMPL_SPARSE_HINT_SPMV_INVOCATIONS, ARMPL_SPARSE_INVOCATIONS_MANY);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	/* 4. Call an optimization process that will learn from the hints you have previously supplied */
	info = armpl_spmv_optimize(armpl_mat);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmv_optimize returned %d\n", info);

	/* 5. Setup input and output vectors and then do SpMV and print result.*/
	double *x = (double *)malloc(N*sizeof(double));
	for (int i=0; i<N; i++) {
		x[i] = 1.0;
	}
	double *y = (double *)malloc(M*sizeof(double));

	for (int i=0; i<ntests; i++) {
		for (int temp=1;temp<=500;temp++)
		info = armpl_spmv_exec_d(ARMPL_SPARSE_OPERATION_NOTRANS, alpha, armpl_mat, x, beta, y);
		if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmv_exec_d returned %d\n", info);
	}

	printf("Computed vector y:\n");
	for (int i=0; i<M; i++) {
		printf("\t%2.1f\n", y[i]);
	}

	/* 6. Destroy created matrix to free any memory created during the 'optimize' phase */
	info = armpl_spmat_destroy(armpl_mat);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_destroy returned %d\n", info);

	/* 7. Free user allocated storage */
	free(x); free(y);

	return (int)info;
}
