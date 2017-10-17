//+
lc = DefineNumber[ 1000, Name "Parameters/lc" ];
//+
Point(1) = {0, 0, 0, lc};
//+
Point(2) = {120, 0, 0, lc};
//+
Point(3) = {240, 0, 0, lc};
//+
Point(4) = {360, 0, 0, lc};
//+
Point(5) = {480, 0, 0, lc};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 5};
//+
Physical Line("mat1") = {1, 2, 3, 4};
//+
Physical Line("dir1") = {1, 2, 3, 4};
//+
Physical Line("load1") = {1, 4};
