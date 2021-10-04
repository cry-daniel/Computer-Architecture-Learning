#include <cstdio>
#include <cstdlib>
#define NNZ 4054

double temp;
int cnt=0;
double vals[5000];


int main(){
    FILE *fp;
    fp=freopen("nnz.txt","r",stdin);
    if(fp==NULL){
        printf("错误！");
        exit(1); //中止程序
    }
    for(int i=1;i<=NNZ;i++){
        printf("qqq");
    //while(scanf("%lf",&temp)){
        scanf("%lf",&temp);
        vals[i]=temp;
        printf("%lf\n",temp);
    }
    printf("cnt = %d\n",cnt);
}