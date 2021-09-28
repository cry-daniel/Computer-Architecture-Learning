#include <stdio.h>
#include <stdlib.h>
#include "armpl.h"

#define NNZ_A 12
#define NNZ_B 9
#define M 5
#define N 5
#define K 5

int main()
{
	/* 1. Set-up local CSR structure */
	armpl_spmat_t armpl_mat_a, armpl_mat_b, armpl_mat_c;
	const double alpha = 1.0, beta = 1.0;
	int creation_flags = 0;

	double vals_a[NNZ_A] = {1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12.};
	int row_ptr_a[M+1] = {0, 2, 4, 7, 9, 12};
	int col_indx_a[NNZ_A] = {0, 2, 1, 3, 1, 2, 3, 2, 3, 2, 3, 4};

	double vals_b[NNZ_B] = {1., 2., 3., 4., 5., 6., 7., 8., 9.};
	int row_ptr_b[K+1] = {0, 2, 4, 6, 7, 9};
	int col_indx_b[NNZ_B] = {0, 2, 1, 3, 0, 1, 4, 2, 4};

	/* 2a. Set-up Arm Performance Libraries sparse matrix object for A */
	armpl_status_t info = armpl_spmat_create_csr_d(&armpl_mat_a, M, K, row_ptr_a, col_indx_a, vals_a, creation_flags);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_create_csr_d returned %d\n", info);

	/* 2b. Set-up Arm Performance Libraries sparse matrix object for B */
	info = armpl_spmat_create_csr_d(&armpl_mat_b, K, N, row_ptr_b, col_indx_b, vals_b, creation_flags);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_create_csr_d returned %d\n", info);

	/* 2c. Set-up Arm Performance Libraries sparse matrix object for C */
	armpl_mat_c = armpl_spmat_create_null(M, N);

	/* 3a. Supply any pertinent information that is known about the matrix A */
	info = armpl_spmat_hint(armpl_mat_a, ARMPL_SPARSE_HINT_STRUCTURE, ARMPL_SPARSE_STRUCTURE_UNSTRUCTURED);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	/* 3b. Supply any pertinent information that is known about the matrix B */
	info = armpl_spmat_hint(armpl_mat_b, ARMPL_SPARSE_HINT_STRUCTURE, ARMPL_SPARSE_STRUCTURE_UNSTRUCTURED);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	/* 3c. Supply any hints that are about the SpAdd calculations to be performed with matrix A */
	info = armpl_spmat_hint(armpl_mat_a, ARMPL_SPARSE_HINT_SPADD_OPERATION, ARMPL_SPARSE_OPERATION_NOTRANS);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	info = armpl_spmat_hint(armpl_mat_a, ARMPL_SPARSE_HINT_SPADD_INVOCATIONS, ARMPL_SPARSE_INVOCATIONS_SINGLE);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	/* 3c. Supply any hints that are about the SpAdd calculations to be performed with matrix B */
	info = armpl_spmat_hint(armpl_mat_b, ARMPL_SPARSE_HINT_SPADD_OPERATION, ARMPL_SPARSE_OPERATION_NOTRANS);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	info = armpl_spmat_hint(armpl_mat_b, ARMPL_SPARSE_HINT_SPADD_INVOCATIONS, ARMPL_SPARSE_INVOCATIONS_SINGLE);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_hint returned %d\n", info);

	/* 4. Optimize the matrices based on the hints previously supplied */
	info = armpl_spadd_optimize(ARMPL_SPARSE_OPERATION_NOTRANS, ARMPL_SPARSE_OPERATION_NOTRANS,
                                    ARMPL_SPARSE_SCALAR_ONE, armpl_mat_a, ARMPL_SPARSE_SCALAR_ONE, armpl_mat_b, armpl_mat_c);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spadd_optimize returned %d\n", info);

	/* 5a. Do SpAdd */
for(int temp=1;temp<=5000000;temp++)
	info = armpl_spadd_exec_d(ARMPL_SPARSE_OPERATION_NOTRANS, ARMPL_SPARSE_OPERATION_NOTRANS, alpha,
			          armpl_mat_a, beta, armpl_mat_b, armpl_mat_c);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spadd_exec_d returned %d\n", info);

	/* 5b. Create and populate a CSR representation of C */
	int *out_row_ptr_c, *out_col_indx_c;
	double *out_vals_c;
	int nrows_c, ncols_c, out_nnz_c;
	info = armpl_spmat_export_csr_d(armpl_mat_c, 0, &nrows_c, &ncols_c, &out_row_ptr_c, &out_col_indx_c, &out_vals_c);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_export_csr_d returned %d\n", info);

	/* 5c. Compute the number of nonzeros now present in C and print the matrix */
	out_nnz_c = out_row_ptr_c[nrows_c] - out_row_ptr_c[0];

	printf("Computed matrix C:\n");

	printf("\tValues: \t\t");
	for (int i=0; i<out_nnz_c; i++) {
		printf("%2.1f ", out_vals_c[i]);
	}
	printf("\n");

	printf("\tColumn Indices: \t");
	for (int i=0; i<out_nnz_c; i++) {
		printf("%d ", (int)out_col_indx_c[i]);
	}
	printf("\n");

	printf("\tRow Pointer: \t\t");
	for (int i=0; i<nrows_c+1; i++) {
		printf("%d ", (int)out_row_ptr_c[i]);
	}
	printf("\n");

	/* 6. Destroy created matrices to free any memory created during the 'optimize' phase */
	info = armpl_spmat_destroy(armpl_mat_a);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_destroy returned %d\n", info);

	info = armpl_spmat_destroy(armpl_mat_b);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_destroy returned %d\n", info);

	info = armpl_spmat_destroy(armpl_mat_c);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_destroy returned %d\n", info);

	free(out_row_ptr_c);
	free(out_col_indx_c);
	free(out_vals_c);

	return (int)info;
}
