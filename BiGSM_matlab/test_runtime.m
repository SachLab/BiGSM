%%%% Testing and compare the runtime of BiGSM algorithm %%%%%

%% Define network sizes and inference methods to test
Ns = [50, 100, 300, 500];
infMethods = {'LSCON', 'lasso'};  % three inference methods
max_iter = 35;
zeta = logspace(-10, 0, 100);
num_trials = 10;  % number of repetitions per network size

numSizes = length(Ns);
numMethods = length(infMethods);
time_bigsm = zeros(numSizes, 1);            % average runtime for BiGSM per network size
time_inference = zeros(numSizes, numMethods); % average runtime for each inference method per network size

%% Loop over each network size
for i = 1:numSizes
    N = Ns(i);
    fprintf('Evaluating for N = %d\n', N);
    
    % Temporary arrays to store runtime for each trial
    runtime_bigsm_trials = zeros(num_trials, 1);
    runtime_inference_trials = zeros(num_trials, numMethods);
    
    % Loop over each trial
    for trial = 1:num_trials
        S = 3;  % desired sparsity degree (3 edges per node on average)
        A = datastruct.scalefree2(N, S);         % generate scale-free network matrix
        A = datastruct.stabilize(A, 'iaa', 'low'); % stabilize network matrix
        Net = datastruct.Network(A, 'myNetwork');  % create a Network object
        
        % Define perturbation matrix (negative identity matrix)
        P = -eye(N);
        
        % Generate data using the network's gain matrix G
        X = Net.G * P;

        % Add noise to the data
        SNR = 0.1;
        s = svd(X);
        stdE = s(N) / (SNR * sqrt(chi2inv(1 - analyse.Data.alpha, numel(P))));
        E = stdE * randn(size(P));  % noise matrix
        F = zeros(size(P));        
        
        D(1).network = Net.network;
        D(1).E = E;
        D(1).F = F;
        D(1).Y = X + E;  % noisy response matrix
        D(1).P = P;
        D(1).lambda = [stdE^2, 0];
        D(1).cvY = D(1).lambda(1) * eye(N);
        D(1).cvP = zeros(N);
        D(1).sdY = stdE * ones(size(P));
        D(1).sdP = zeros(size(P));
        
        % Create a Dataset object for this trial
        Data = datastruct.Dataset(D, Net);
        
        % Measure runtime for the BiGSM algorithm
        tic;
        A_est_bcs = bigsm(D(1).Y, P, max_iter, size(A));
        runtime_bigsm_trials(trial) = toc;
        

        % Measure runtime for each inference method
        for j = 1:numMethods
            infMethod = infMethods{j};
            tic;
            [Aest_ls, z1] = Methods.(infMethod)(Data, zeta);
            runtime_inference_trials(trial, j) = toc;
        end
    end
    
    % Compute average runtimes for this network size over all trials
    time_bigsm(i) = mean(runtime_bigsm_trials);
    for j = 1:numMethods
        time_inference(i, j) = mean(runtime_inference_trials(:, j));
    end
    
    fprintf('Average BiGSM runtime for N = %d: %f seconds\n', N, time_bigsm(i));
    for j = 1:numMethods
        fprintf('Average %s runtime for N = %d: %f seconds\n', infMethods{j}, N, time_inference(i, j));
    end
    fprintf('---------------------------------------------\n');
end

%% Plotting the average runtime curves on a semilogarithmic scale
figure;
% Plot average runtime
semilogy(Ns, time_bigsm, 'b-o', 'LineWidth', 2); hold on;
plotStyles = {'r-s', 'g-d'};  % styles for LSCON, lasso

for j = 1:numMethods
    semilogy(Ns, time_inference(:, j), plotStyles{j}, 'LineWidth', 2);
end

xlabel('Network Size (N)');
ylabel('Average Runtime (seconds)');
legend({'BiGSM', 'LSCON', 'LASSO'}, 'Location', 'northwest');
grid on;
% Set the y-axis ticks to powers of 10 (adjust range as needed)
yticks([1e-2 1e-1 1e0 1e1 1e2]);
hold off;
