function funcsym = complexfun_method_separate_nocalcmusigma_z_by_tperezdevelopment(y,mu,eps)
%% This function replaces the call to complexfun matlab function for the
%% compile simbolic toolbox problems. This is a automatic function generate by the following function. The other code is in complexfun:
%%  func=@(y,mu,eps) y-mu-eps;
funcsym = imag(eps).*-1i-imag(mu).*1i-real(eps)-real(mu)+imag(y).*1i+real(y);
end

