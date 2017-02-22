// WA
// 自测数据通过
//
// Created by Mondo on 2017/2/20.
//
// http://bailian.openjudge.cn/practice/2813/
#include <iostream>

#include <stdio.h>
#include <cstring>
#include <cmath>
using namespace std;


class App {

public:
    App() {
        memset(wall, 0, sizeof(wall));
        memset(paint, 0, sizeof(paint));
        min_steps = 500;
        cin >> n;
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                char temp;
                cin >> temp;
                if (temp == 'y') {
                    wall[i + 1][j + 1] = 1; // 空出一圈
                }
            }
        }
        enum_first();
    }

    void print() {
        if (n < 1 || min_steps == 500) {
            printf("inf");
        } else {
            printf("%d", min_steps);
        }
        printf("\n");
    }

private:

    int n; // n 代表墙的长宽, 占用数组范围为 0-n+1 x 0-n
    int min_steps;
    int wall[16][17];
    int paint[16][17];

    bool guess() {
        // 从第一行开始, 一直到倒数第二行, 计算其后一行的画动作
        for (int i = 1; i < n; ++i) {
            for (int j = 1; j < n + 1; ++j) { // 1~n
                // 加一做偏移, 不加的情况下 2 的倍数时上一行为白色, paint 应该为 1, 但取余 2 为 0
                paint[i + 1][j] = (1 + wall[i][j] + paint[i][j] + paint[i][j - 1] + paint[i][j + 1] + paint[i - 1][j]) % 2;
            }
        }

        // 判断第 n 行是否全黄
        for (int k = 1; k < n + 1; ++k) {
            if ((paint[n][k] + paint[n][k-1] + paint[n][k+1] + paint[n-1][k]) % 2 == wall[n][k]) {
                return false;
            }
        }

        return true;
    }

    // 枚举第一行的操作
    void enum_first() {
        for (int i = 1; i < pow(2, n); ++i) {
            if (guess()) {
                int paints = paint_steps();
                if (paints < min_steps) {
                    min_steps = paints;
                }
            }

            paint[1][1]++;
            int c = 1;
            while (paint[1][c] > 1) {
                paint[1][c] = 0;
                c++;
                paint[1][c]++;
            }
            if (paint[1][n + 1] > 0) {
                break;
            }
        }
    }

    int paint_steps() {
        int paints = 0;
        for (int i = 1; i < n + 1; ++i) {
            for (int j = 1; j < n + 1; ++j) {
                paints += paint[i][j];
            }
        }

        return paints;
    }
};



int main() {
    App app;
    app.print();

}
