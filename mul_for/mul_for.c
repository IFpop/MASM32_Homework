#include "stdio.h"

int main()
{
    int a[10];
    int i,j,k,l; 
    for(i = 0 ; i < 10 ; i++){
    	a[i] = 0;
        for(j = 0 ; j < 10 ; j++){
            for(k = 0 ; k < 10; k++){
                for(l = 0 ; l < 10; l++){
                    a[i] += i+j+k+l;
                }
            }
        }
    }
    for(i = 0 ; i < 2 ; i++){
        printf("%d\n",a[i]);
    }
}