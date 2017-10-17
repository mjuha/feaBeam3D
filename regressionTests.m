function regressionTests(normDisp,normRot,tol)
% this function evaluate a regression test based on
% the norm of the solution vectors. Displacement and rotation
global u nn

sumDisp = zeros(3,1);
sumRot = zeros(3,1);

for i=1:nn
    sumDisp = sumDisp + u(1:3,i);
    sumRot = sumRot + u(4:6,i);
end
% solution average
sumDisp = sumDisp / nn;
sumRot = sumRot / nn;

fprintf(' Regresion test:\n')
fprintf(' Average displacement = %g\n',norm(sumDisp))
fprintf(' Average rotation = %g\n\n',norm(sumRot))

assert(abs(norm(sumDisp) - normDisp) <= tol, 'Error in displacement average')
assert(abs(norm(sumRot) - normRot) <= tol, 'Error in rotation average')

end