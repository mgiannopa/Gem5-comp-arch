#include <stdio.h>

int main(){
	int n=10, i;
	int t1=0, t2=1, nextTerm;

	//Ask user for the number of terms
	//printf("Number of terms");
	//scanf("%d", &n);

	//Print the sequence
	printf("Fibonacci series: ");
	for (i=1; i<=n; i++) {
		if (i==1) {
			printf("%d, ",t1);
			continue;
		}
		if (i==2) {
			printf("%d, ",t2);
			continue;
		}
		//Update the terms
		nextTerm= t1 + t2;
		t1 = t2;
		t2 = nextTerm;

		printf("%d", nextTerm);//Print the next term

		if (i != n) {
			printf(", ");//For more readable prints
		}
	}
return 0;
}


