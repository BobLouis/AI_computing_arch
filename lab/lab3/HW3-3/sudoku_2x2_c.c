#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

bool check(int index, char *data, int n)
{
    // 0 1 2 3
    // 4 5 6 7
    // 8 9 10 11
    // 12 13 14 15

    // check row
    for (int i = 0; i < 4; i++)
    {
        if (data[((index >> 2) << 2) + i] == n && index != (((index >>2)<<2) + i))
            return 0;
    }

    // check col
    for (int i = 0; i < 4; i++)
    {
        if (data[(index & 0b11) + (i<<2)] == n && index != ((index & 0b11) + (i << 2)))
            return 0;
    }

    // check block
    //Calculate start
    int start = (index & 0b11) - ((index & 0b11) & 1) + (((index >>2) - ((index >>2 ) &1)) << 2);
    for (int i = 0; i < 2; i++)
    {
        if (data[start + i] == n && index != start + i)
            return 0;
    }
    for (int i = 4; i < 6; i++)
    {
        if (data[start + i] == n && index != start + i)
            return 0;
    }
    return 1;
}

bool solve(int index, char *test_c_data)
{
    if (index >= 16)
        return true; // 如果檢查完所有的格子，回傳 True

    if (test_c_data[index] > 0)               // set是一個儲存所有資料的array
        return solve(index + 1, test_c_data); // 如果格子中已經有值了則會往下一格判斷
    else
    {
        for (int n = 1; n < 5; ++n)
        {                           // 判斷目前這格在 1~4是否有符合條件
            test_c_data[index] = n; // 如果有的話就往下一格作判斷（遞迴）
                                    // 直到每一格都符合條件為止
            if (check(index, test_c_data, n) && solve(index + 1, test_c_data))
            {                // check function用來檢查當前這格放入這個數值是否正確
                return true; // solve(index+1) function則是繼續判斷下一格的值
            }
        }
        test_c_data[index] = 0; // returns the value to 0 to mark it as empty
        return false;           // no solution
    }
}

void sudoku_2x2_c(char *test_c_data)
{
    // TODO
    // Finish your sudoku algorithm in c language
    solve(0, test_c_data);
}
