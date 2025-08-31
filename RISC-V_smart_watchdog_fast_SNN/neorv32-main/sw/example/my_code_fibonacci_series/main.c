
#include <neorv32.h>
#include <stdio.h>

#define NUMS 45 

// working array to hold the first 45 fibonacci series values calculated
int work_array[NUMS] = {0};

/**********************************************************************//**
 * @name Fibonacci series function declaration
 **************************************************************************/

// perform the fibonacci series
void fibonacci(int array[], int n) {
    array[0] = 0;
    array[1] = 1;

    for (int i=2; i<=n; i++) {
        array[i] = array[i-1] + array[i-2];
    }
}

int main() {

    // call fibonacci series function to calculate first 45 values
    fibonacci(work_array, NUMS-1);

    return 0;
}



