function [A_est_bcs] = bigsm(Y, P, max_iter, target_size)
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
            i
            A_est_bcs(:, j) = Mu;
            break
        end
        beta = beta_new;
        alpha_vec(alpha_vec > 1e10) = 1e10; % prevent values go to infinity
        A_est_bcs(j, :) = Mu;
    end
    alpha_all(j, :) = alpha_vec;
%     (1/beta)^(0.5)
end

end

