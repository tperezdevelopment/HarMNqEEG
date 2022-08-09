function [z,mu,sigma] = HarMNqEEG_stats_zscore(x,flag,dim)
%% This code was taked from Stats toolbox for compiler problem
%ZSCORE Standardized z score.
%   Z = ZSCORE(X) returns a centered, scaled version of X, the same size as X.
%   For vector input X, Z is the vector of z-scores (X-MEAN(X)) ./ STD(X). For
%   matrix X, z-scores are computed using the mean and standard deviation
%   along each column of X.  For higher-dimensional arrays, z-scores are
%   computed using the mean and standard deviation along the first
%   non-singleton dimension.
%
%   The columns of Z have sample mean zero and sample standard deviation one
%   (unless a column of X is constant, in which case that column of Z is
%   constant at 0).
%
%   [Z,MU,SIGMA] = ZSCORE(X) also returns MEAN(X) in MU and STD(X) in SIGMA.
%
%   [...] = ZSCORE(X,1) normalizes X using STD(X,1), i.e., by computing the
%   standard deviation(s) using N rather than N-1, where N is the length of
%   the dimension along which ZSCORE works.  ZSCORE(X,0) is the same as
%   ZSCORE(X).
%
%   [...] = ZSCORE(X,FLAG,'all') standardizes X by working on all the
%   elements of X. Pass in FLAG==0 to use the default normalization by N-1,
%   or 1 to use N.
%
%   [...] = ZSCORE(X,FLAG,DIM) standardizes X by working along the dimension
%   DIM of X.
%
%   [...] = ZSCORE(X,FLAG,VECDIM) standardizes X by working along the all the
%   dimensions of X specified in VECDIM.
%
%   See also MEAN, STD.

%   Copyright 1993-2019 The MathWorks, Inc. 


% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = x; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Validate flag
if ~(isequal(flag,0) || isequal(flag,1) || isempty(flag))
    error(message('stats:trimmean:BadFlagReduction'));
end

% Compute X's mean and sd, and standardize it
mu = mean(x,dim);
sigma = std(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = (x-mu) ./ sigma0;

