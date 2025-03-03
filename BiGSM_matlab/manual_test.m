function [A_est_cutoff] = manual_test(A_est,zeta)
% This is the function for generating estimated GRN with different
% sparsities according the given range of sparsity thresholds. 
% 
% The thresholds are in (0, 1]. The full inferred GRN A_est are first being
% scaled to (0, 1) and the thresholds are applied as hard thresholding to
% force values smaller than the thresold become zero. Then the trhesholded 
% A_est is rescaled to the original range.
%
% function [A_est_cutoff] = manual_test(A_est,zeta)
%
%   Input Arguments: bigsm(A_est, zeta)
%   ================
%   A_est: the estimated full GRN with inferred weights as a matrix. If
%   there are N genes in the network, A_est has size N x N
%   zeta: range of sparsity thresholds with size 1xn_zeta, it can be
%   defined as logspace(zeta_min,0,n_zeta), where zeta_min can be from -6
%   to -20 and n_zeta can be from 30 to 500. 
%
%   Output Arguments: A_est_cutoff
%   =================
%   A_est_cutoff: the 3d array with estimated GRNs with different sparsities
%   according to the input zeta range



A_opt = A_est;
% check results
zetaRange = [];
zetaRange(1) = min(abs(A_est(A_est~=0)))-10.*eps;
zetaRange(2) = max(abs(A_est(A_est~=0)))+10.*eps;

% Convert to interval.
delta = zetaRange(2)-zetaRange(1);
zetavec = zeta*delta + zetaRange(1);

for i=1:length(zetavec)
    temp = find(abs(A_opt) <= zetavec(i));
    Atmp = A_opt;
    Atmp(temp) = 0;
    A_est_cutoff(:,:,i) = Atmp;
end
end

