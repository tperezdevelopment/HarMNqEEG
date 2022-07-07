function funcsym = complexfun_method_separate_calc_musigma_z_by_tperezdevelopment(y,mu,musigma,z)
%% This function replaces the call to complexfun matlab function for the
%% compile simbolic toolbox problems. This is a automatic function generate by the following function. The other code is in complexfun:
%%  func=@(y,mu,musigma,z) y-mu-sqrt(musigma).*z;

funcsym = imag(mu).*-1i-real(mu)+imag(y).*1i+real(y)-sqrt(imag(musigma)).*imag(z).*1i-sqrt(real(musigma)).*real(z);

