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
__global__ void PaintKernel(Matrix);


void Paint(Matrix C)
{
    cudaSetDevice(0);
    cudaDeviceSynchronize();
    size_t available, total;
    cudaMemGetInfo(&available, &total);
    // Allocate C in device memory
    Matrix d_C;
    d_C.width = C.width;
    d_C.height = C.height;
    size_t size = C.width * C.height * sizeof(float);
    cudaError_t error = cudaGetLastError();
    cudaMalloc(&d_C.elements, size);
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: allocation C %s\n", cudaGetErrorString(error));
        exit(-1);
    }

    // Invoke kernel
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    dim3 dimGrid(C.width / dimBlock.x, C.height / dimBlock.y);
    PaintKernel<<<dimGrid, dimBlock>>>(d_C);
    cudaDeviceSynchronize();
    error = cudaGetLastError();
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: calculation error %s\n", cudaGetErrorString(error));
        exit(-1);
    }

    // write C to device memory
    cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost);
    if (error != cudaSuccess)
    {
        fprintf(stderr, "ERROR: copying C %s\n", cudaGetErrorString(error));
        exit(-1);
    }

    // Free device memory
    cudaFree(d_C.elements);
}


__global__ void PaintKernel(Matrix C)
{
    // Each thread computes one element of C
    float Cvalue = 0;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (col + row > BLOCK_SIZE/2)
        if (col + row < BLOCK_SIZE/2*3) 
            if (row - col < BLOCK_SIZE/2)
                if (row - col > -BLOCK_SIZE/2)
                        Cvalue = 1;
    C.elements[row * C.width + col] = Cvalue;
}


int main()
{
    Matrix C;
    C.height = 1 * BLOCK_SIZE; // hC = hA
    C.width = 1 * BLOCK_SIZE;   // wC = wB
    size_t nBytes = C.height * C.width * sizeof(float);
    C.elements = (float *)malloc(nBytes);
    memset(C.elements, 0, nBytes);

    Paint(C);
    printf("Num: \n");
    for (int i = 0; i < C.height; i++)
    {
        for (int j = 0; j < C.width; j++)
        {
            printf("%2d", (int)C.elements[i * C.height + j]);
        }
        printf("\n");
    }

    printf("\n\nPainting: \n");
    for (int i = 0; i < C.height; i++)
    {
        for (int j = 0; j < C.width; j++)
        {
            if(C.elements[i * C.height + j]) 
                printf(" -");
            else
                printf(" 0");
        }
        printf("\n");
    }

    return 0;
}
