#include <stdio.h>
#include <stdlib.h>
#include <float.h>

void matrixAlloc(void ***a, int m, int n, int size) {
	int i, j;
	void *memory;

	memory = (void *) malloc (m*n*size);
	*a = (void **) malloc (m * sizeof(void *));
	for (i = 0; i < m; i++) {
		(*a)[i] = memory + (i * n * size);		
	}
}

void printIntMatrix(int **root, char *name, int n, int m) {
	int i, j;
	
	printf("%s ", name);
	for (j = 0; j < n; j++) {
		printf("%5d  ", j + 1);
	}
	printf("\n");
	for (i = 0; i < n; i++) {
		printf("%d:   ", i + 1);
		for (j = 0; j < n; j++) {
			printf("%5d, ", root[i][j]);
		}
		printf("\n");
	}
}

void printFloatMatrix(float **cost, char *name, int n, int m) {
	int i, j;
	
	printf("%s ", name);
	for (j = 0; j < n; j++) {
		printf("%5d  ", j + 1);
	}
	printf("\n");
	for (i = 0; i < n; i++) {
		printf("%d:   ", i + 1);
		for (j = 0; j < n; j++) {
			printf("%5.f, ", cost[i][j]);
		}
		printf("\n");
	}
}

void treeOutput(int **root, int low, int high) {
	printf("tree: %d - %d; root: %d\n", low, high, root[low][high + 1]);
	if (low < root[low][high + 1] - 1)
		treeOutput(root, low, root[low][high + 1] - 1);
	if (root[low][high + 1] < high - 1)
		treeOutput(root, root[low][high + 1] + 1, high);
}

int main(int argc, char *argv[])
{
	float bestcost, rcost, tempCost;
	int n, r, i, j, high, low, bestroot;
	int **root;
	float **cost;
	float *p;
	FILE *input;
	
	input = fopen(argv[1], "r");
	fscanf(input, "%d\n", &n);
	p = (float *) malloc (n * sizeof(float));
	for (i = 0; i < n; i++) {
		fscanf(input, "%f\n", &p[i]);
	}
	fclose(input);
	
	matrixAlloc((void ***) &cost, n + 1, n + 1, sizeof(float));
	matrixAlloc((void ***) &root, n + 1, n + 1, sizeof(int));

	for (low = n; low >= 0; low--) {
		cost[low][low] = 0;
		root[low][low] = low;
		
		for (high = low + 1; high <= n; high++) {
			bestcost = FLT_MAX;
			tempCost = 0;
			
			for (j = low; j < high; j++) {
				tempCost += p[j];
			}
			
			for (r = low; r < high; r++) {
				rcost = tempCost + cost[low][r] + cost[r + 1][high];
				
				if (rcost < bestcost) {
					bestcost = rcost;
					bestroot = r;
				}
			}
			
			cost[low][high] = bestcost;
			root[low][high] = bestroot;
		}
	}

	//printFloatMatrix(cost, "cost", n + 1, n + 1);
	//printf("\n");
	//printIntMatrix(root, "root", n + 1, n + 1);
	treeOutput(root, 0, n - 1);
}

