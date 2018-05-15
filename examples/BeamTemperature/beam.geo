//+
lc = DefineNumber[ 1000, Name "Parameters/lc" ];
//+
Point(1) = {0, 0, 0, lc};
//+
Point(2) = {200, 0, 0, lc};
//+
Point(3) = {500, 0, 0, lc};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Physical Line("mat1") = {1};
//+
Physical Line("mat2") = {2};
//+
Physical Line("dir1") = {1, 2};
