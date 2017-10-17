//+
lc = DefineNumber[ 10, Name "Parameters/lc" ];
//+
Point(1) = {0, 25*12, 0, lc};
//+
Point(2) = {0, 0, 0, lc};
//+
Line(1) = {2, 1};
//+
Physical Line("mat1") = {1};
//+
Physical Line("dir1") = {1};
