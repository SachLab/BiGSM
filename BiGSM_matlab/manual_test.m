function [A_est] = manual_test(A_est,zeta)
%MANUAL_TEST Summary of this function goes here
%   Detailed explanation goes here
A_opt = A_est;
% check results
zetaRange = [];
zetaRange(1) = min(abs(A_est(A_est~=0)))-eps;
zetaRange(2) = max(abs(A_est(A_est~=0)))+10*eps;

% Convert to interval.
delta = zetaRange(2)-zetaRange(1);
zetavec = zeta*delta + zetaRange(1);

for i=1:length(zetavec)
    temp = find(abs(A_opt) <= zetavec(i));
    Atmp = A_opt;
    Atmp(temp) = 0;
    A_est(:,:,i) = Atmp;
end
end

