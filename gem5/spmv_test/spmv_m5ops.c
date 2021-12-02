#include <stdio.h>
#include <stdlib.h>

#include "armpl.h"
#include "gem5/m5ops.h"
#define nnz 100000
#define m 100000
#define n 100000

int main()
{
	/* 1. Set-up local CSR structure */
	armpl_spmat_t armpl_mat;
	const int ntests = 1000;
	int M,N,NNZ;
	const double alpha = 1.0, beta = 0.0;
	int creation_flags = 0;
	double vals[nnz];
	int row_ptr[m+1];
	int col_indx[nnz];
	int temp1=0;
	double temp=0;
	FILE *fp;

	fp=freopen("info.txt","r",stdin);
	scanf("%d %d %d",&NNZ,&M,&N);
	fclose(fp);

	fp=freopen("nnz.txt","r",stdin);
	/*while(scanf("%lf",&temp)){
		vals[cnt++]=temp;
	}*/
	for(int i=1;i<=NNZ;i++){
		scanf("%lf",&temp);
		vals[i]=temp;
	}
	fclose(fp);

	fp=freopen("row.txt","r",stdin);
	/*while(scanf("%d",&temp1)){
		row_ptr[cnt++]=temp1;
	}*/
	for(int i=1;i<=M+1;i++){
		scanf("%d",&temp1);
		row_ptr[i]=temp1;
	}
	fclose(fp);

	fp=freopen("col.txt","r",stdin);
	/*while(scanf("%d",&temp1)){
		col_indx[cnt++]=temp1;
	}*/
	for(int i=1;i<=NNZ;i++){
		scanf("%d",&temp1);
		col_indx[i]=temp1;
	}
	fclose(fp);

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
	m5_checkpoint(0,0);
	m5_reset_stats(0,0);
	for (int i=0; i<ntests; i++) {
		info = armpl_spmv_exec_d(ARMPL_SPARSE_OPERATION_NOTRANS, alpha, armpl_mat, x, beta, y);
		if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmv_exec_d returned %d\n", info);
	}
	m5_dump_stats(0,0);
	//m5_exit(0);
	printf("finish!\n");
	printf("Computed vector y:\n");
	for (int i=0; i<10; i++) {
		printf("\t%2.1f\n", y[i]);
	}

	/* 6. Destroy created matrix to free any memory created during the 'optimize' phase */
	info = armpl_spmat_destroy(armpl_mat);
	if (info!=ARMPL_STATUS_SUCCESS) printf("ERROR: armpl_spmat_destroy returned %d\n", info);

	/* 7. Free user allocated storage */
	free(x); free(y);

	return (int)info;
}
