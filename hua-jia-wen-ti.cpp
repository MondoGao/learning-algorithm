//
// Created by Mondo on 2017/2/20.
//
// http://bailian.openjudge.cn/practice/2813/

#include <stdio.h>
#include <cstring>


char start() {
    char wall[16][17];
    std::memset(wall, 'w', sizeof(wall));
    int n; // n 代表墙的长宽, 占用数组范围为 0-n+1 x 0-n
    scanf("%d", &n);
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            scanf(" %c", &wall[i + 1][j + 1]);
        }
    }

    return wall[0][0];

}

int main() {
    start();
}