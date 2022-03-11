#include <stdio.h>

int main()
{
    int index;
    // scanf("%d", &index);
    for (index = 0; index < 16; index++)
    {
        int row = index / 4;
        int col = index % 4;
        printf("%d %d\n", index, 8 * (row / 2) + 2 * (col / 2));
    }
}