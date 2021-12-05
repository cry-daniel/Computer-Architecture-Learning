#include <stdio.h>
#include <stdlib.h>

int x;


int main(){
    double* a;
    scanf("%d",&x);
    a=(double *) malloc(x*sizeof(double));
    printf("%d\n",x);
    for (int i=0;i<=x;i++){
        a[i*100]=0.6;
        printf("%d %lf\n",i,a[i]);
    }
}