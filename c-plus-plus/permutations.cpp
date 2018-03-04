//
// Created by Mondo on 04/03/2018.
//
#include <iostream>
using namespace std;

/**
 * 递归函数生成排列
 * p28
 * @tparam T
 * @param list - 带排列数组
 * @param cut - 切分前缀后缀点
 * @param end - 数组末尾位置
 */
template<typename T>
void permutations(T list[], int cut, int end)
{
    if (cut == end)
    {
        // 直接输出
        copy(list, list + end + 1, ostream_iterator<T>(cout, " "));
        cout << endl;
    }
    else
    {
        // 依次去除每一个元素，使用剩下的数组进行进一步递归
        for (int i = cut; i <= end; i++)
        {
            swap(list[cut], list[i]);
            permutations(list, cut + 1, end);
            swap(list[i], list[cut]);
        }
    }
}
