function [A_est_bcs] = bigsm(Y, P, max_iter, target_size)
% This is the function for GRN inference using BiGSM algorithm
%
% function [A_est_bcs] = bigsm(Y, P, max_iter, target_size)
%
%   Input Arguments: bigsm(Y, P, max_iter, target_size)
%   ================
%   Y: gene expression matrix, with shape N x rN, N is number of genes and 
%   r is the number of replicates. (for example, 50 x 100 with r=2)
%   P: perturbation matrix, need to have the same shape as Y (N x rN)
%
%   max_iter: maximum iterations for Bayes learning, 10-50 should be good.
%   target_size: size of the inferred GRN matrix, if the real GRN matrix A
%   has N genes, then the size is 50x50. The user can simply pass size(A)
%
%   Output Arguments: A_est_bcs
%   =================
%   estA: the estimated full GRN with inferred weights as a matrix aligned 
%   with the input target_size.


A_est_bcs = zeros(target_size);

H = (-Y');

alpha_all = zeros(target_size);

for j = 1:target_size(1)
    p_vec = -P(j, :)';
    beta = 10;
    alpha_vec = 0.01.*ones(target_size(1), 1);

    for i=1:max_iter
        % Up date the mean and covariance of the Gaussian posterior
        Sigma_inv = beta.*H'*H+diag(alpha_vec);
        Sigma = inv(Sigma_inv);
        Mu = beta.*(Sigma_inv\H'*p_vec);

        % Update the prior
        gamma = 1 - alpha_vec.*diag(Sigma);
        alpha_vec_new = gamma./(Mu.^2);

        beta_new = (size(H, 1)-sum(gamma))/(norm(p_vec-H*Mu, 2)^2);
        alpha_vec = alpha_vec_new;
        
        if abs(beta-beta_new) < 0.0001   % converge condition
            A_est_bcs(:, j) = Mu;
            break
        end
        beta = beta_new;
        alpha_vec(alpha_vec > 1e10) = 1e10; % prevent values go to infinity
        A_est_bcs(j, :) = Mu;
    end
    alpha_all(j, :) = alpha_vec;
end

end

