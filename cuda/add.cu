#include <stdio.h>
#include <stdlib.h>

// Matrices are stored in row-major order:
// M(row, col) = *(M.elements + row * M.width + col)
typedef struct
{
    int width;
    int height;
    float *elements;
} Matrix;

// Thread block size
#define BLOCK_SIZE 16

// Forward declaration of the matrix multiplication kernel
__global__ void MatAddKernel(const Matrix, const Matrix, Matrix);

// Matrix multiplication - Host code
// Matrix dimensions are assumed to be multiples of BLOCK_SIZE
void MatAdd(const Matrix A, const Matrix B, Matrix C)
{
    cudaSetDevice(0);
    cudaDeviceSynchronize();
    size_t available, total;
    cudaMemGetInfo(&available, &total);
    printf("Mem total: %ld Bytes\nMem available: %ld Bytes\n", available, total);
    // Load A and B to device memory
    Matrix d_A;
    d_A.width = A.width;
    d_A.height = A.height;
    size_t size = A.width * A.height * sizeof(float);
    printf("size of A: %ld\n", size);
    cudaMalloc(&d_A.elements, size);
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: allocation A %s\n", cudaGetErrorString(error));
        exit(-1);
    }
    cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice);
    Matrix d_B;
    cudaMalloc(&d_B.elements, size);
    error = cudaGetLastError();
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: allocation B %s\n", cudaGetErrorString(error));
        exit(-1);
    }
    cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);

    // Allocate C in device memory
    Matrix d_C;
    error = cudaGetLastError();
    cudaMalloc(&d_C.elements, size);
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: allocation C %s\n", cudaGetErrorString(error));
        exit(-1);
    }

    // Invoke kernel
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 dimGrid(B.width / dimBlock.x, A.height / dimBlock.y);
    MatAddKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);
    cudaDeviceSynchronize();
    error = cudaGetLastError();
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: calculation error %s\n", cudaGetErrorString(error));
        exit(-1);
    }

    // Read C from device memory
    cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost);
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: copying C %s\n", cudaGetErrorString(error));
        exit(-1);
    }

    // Free device memory
    cudaFree(d_A.elements);
    cudaFree(d_B.elements);
    cudaFree(d_C.elements);
}

// Matrix multiplication kernel called by MatMul()
__global__ void MatAddKernel(Matrix A, Matrix B, Matrix C)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int id = row * A.width + col;
    C.elements[id] = A.elements[id] + B.elements[id];
}

int myrand()
{
    return rand() / (RAND_MAX / 10);
}

int main()
{ // A x B
    srand(0);
    Matrix A, B, C;
    A.height = B.height = C.height = 2 * BLOCK_SIZE;
    A.width = B.width = C.width = 1 * BLOCK_SIZE;
    A.elements = (float *)malloc(A.height * A.width * sizeof(float));
    B.elements = (float *)malloc(B.height * B.width * sizeof(float));
    C.elements = (float *)malloc(C.height * C.width * sizeof(float));
    printf("Content of A: \n");
    for (int i = 0; i < A.height; i++)
    {
        for (int j = 0; j < A.width; j++)
        {
            A.elements[i * A.height + j] = myrand();
            printf("%2d", (int)A.elements[i * A.height + j]);
        }
        printf("\n");
    }

    printf("\n\nContent of B: \n");
    for (int i = 0; i < B.height; i++)
    {
        for (int j = 0; j < B.width; j++)
        {
            B.elements[i * B.height + j] = myrand();
            printf("%2d", (int)B.elements[i * B.height + j]);
        }
        printf("\n");
    }

    MatAdd(A, B, C);

    printf("\n\nContent of C: \n");
    for (int i = 0; i < C.height; i++)
    {
        for (int j = 0; j < C.width; j++)
        {
            printf("%3d", (int)C.elements[i * C.height + j]);
        }
        printf("\n");
    }

    return 0;
}
