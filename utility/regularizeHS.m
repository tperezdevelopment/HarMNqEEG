function CrossR = regularizeHS(Cross, dF)
%Input:     Cross (Cross spectral matrix to be regularized)
%           dF (Degees of freedom)
%Output:    CrossR (Regularized Cross spectral matrix)
% refer to: Schneider-Luftman, D., Walden, A.T., 2016. 
% Partial Coherence Estimation via Spectral Matrix Shrinkage 
% under Quadratic Loss. IEEE Trans. Signal Process. 64, 5767–5777. 
% https://doi.org/10.1109/TSP.2016.2582464

%%
%     Author: Pedro Antonio Valdés-Sosa, Carlos Lopez, Min Li
%     Create Time: 2021

 

e = real(eig(Cross));
e(e<0)=0;
t = sum(e);
t1 = sum(e.^2)-(1/dF)*t^2;  %% page 6 down (Ⅶ part)
p = size(Cross,1);
I = eye(p);
[n,ro] = HS(dF,p,t,t1);
CrossR = (1-ro).*Cross + (ro*n).*I;
CrossR(logical(eye(size(CrossR))))=real(diag(CrossR));
    function [n,ro] = HS(K,p,t,t1)
        t3 = 1.0./p;
        n = t.*t3;
        if nargout > 1
            ro = 1.0./(-K.*t3+K.*1.0./t.^2.*t1+1.0);
        end
    end

end