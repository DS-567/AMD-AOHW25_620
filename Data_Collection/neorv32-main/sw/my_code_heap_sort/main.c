
#include <neorv32.h>
#include <stdio.h>
#include <stdlib.h>


// starting array of numbers to be moved to work array and sorted from smallest to largest (small > large)
const int start_array[20] = {42349, 12711, 5636, 633, 34094, 52049, 46503, 59552, 12303, 50235, 10773, 42652, 59184, 23440, 26751, 1562, 52694, 44897, 55398, 24869};

// working array of numbers
int work_array[20] = {0};

// Function to swap the position of two elements

void swap(int* a, int* b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}

// To heapify a subtree rooted with node i
// which is an index in arr[].
// n is size of heap
void heapify(int arr[], int N, int i)
{
    // Find largest among root, left child and right child

    // Initialize largest as root
    int largest = i;

    // left = 2*i + 1
    int left = 2 * i + 1;

    // right = 2*i + 2
    int right = 2 * i + 2;

    // If left child is larger than root
    if (left < N && arr[left] > arr[largest])

        largest = left;

    // If right child is larger than largest
    // so far
    if (right < N && arr[right] > arr[largest])

        largest = right;

    // Swap and continue heapifying if root is not largest
    // If largest is not root
    if (largest != i) {

        swap(&arr[i], &arr[largest]);

        // Recursively heapify the affected
        // sub-tree
        heapify(arr, N, largest);
    }
}

// Main function to do heap sort
void heapSort(int arr[], int N)
{

    // Build max heap
    for (int i = N / 2 - 1; i >= 0; i--)

        heapify(arr, N, i);

    // Heap sort
    for (int i = N - 1; i >= 0; i--) {

        swap(&arr[0], &arr[i]);

        // Heapify root element to get highest element at
        // root again
        heapify(arr, i, 0);
    }
}

// Driver's code
int main()
{

  // loop to copy start array from ROM to work array in RAM to be manipulated
  for(int j=0; j<20; j++){
    work_array[j] = start_array[j];
  }

  // find the array's length
  int size = sizeof(work_array) / sizeof(work_array[0]);

  // Function call
  heapSort(work_array, size);

  return 0;
  
}


