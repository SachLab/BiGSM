clear
addpath(genpath('../grn/genespider'));

n_test = 20;
SNR = 0.01; % usually 1 is low, 0.1 is medium, 0.01 is high noise
zeta = logspace(-20,0,500);
max_iter = 35;  % maximum iteration of bcs

% Choose a baseline to compare
infMethods = ["LSCON" "lasso" "svmc" "Zscore" "GENIE3"]; % lsco LSCON lasso svmc GENIE3 Zscore

% define the size of your data and network
N = 50;
% define desired sparsity degree, e.g. 3 edges per node on average
S = 3; % /(N);
P = -[eye(N) eye(N) eye(N)]; % sample perturbation matrix

for n = 1:n_test
    clear A Net X E D Data
    disp('testing '+string(n))
    
    % create scale-free network that gives probability to edges
    A = datastruct.scalefree2(N, S); % A is the network matrix
    % set pin and pout parameters in order to remove selfloops
    A = datastruct.stabilize(A,'iaa','low');
    % as random weights cannot guarantee that the network is stable
    % hence we stabilize, i.e. tune IAA degree
    % create Network object
    Net = datastruct.Network(A, 'myNetwork');
    
    % define perturbation matrix for the experiment
    % for two replicates
    
    % create data
    X = Net.G*P; % G - static gain model, A - network
    % add noise to data
    % define signal-to-noise ratio
    
    s = svd(X);
    stdE = s(N)/(SNR*sqrt(chi2inv(1-analyse.Data.alpha,numel(P))));
    % estimate noise matrix
    E = stdE*randn(size(P));
    % input noise matrix
    F = zeros(size(P));
    
    % assign scale-free network
    D(1).network = Net.network;
    % define zero noise
    D(1).E = E;
    D(1).F = F;
    D(1).Y = X+E; % response matrix + noise
    D(1).P = P;
    D(1).lambda = [stdE^2,0];
    D(1).cvY = D.lambda(1)*eye(N);
    D(1).cvP = zeros(N);
    D(1).sdY = stdE*ones(size(D.P));
    D(1).sdP = zeros(size(D.P));
    
    % create a Data object with data "D" and scale-free network "Net"
    Data = datastruct.Dataset(D, Net);

    % Remove self loop
    A_noselfloop = A.*(eye(height(A))-1);
    Net_noselfloop = datastruct.Network(A_noselfloop, 'myNetwork');
    
    %%%%% Testing benchmark method %%%%%
    for m=1:length(infMethods)
        method = infMethods(m)
        [Aest_baseline, z1] = Methods.(method)(Data,zeta);
        Aest_baseline_noselfloop = Aest_baseline;
        for j=1:size(Aest_baseline, 3)
            infer_net = Aest_baseline(:,:,j);
            infer_net_noselfloop = infer_net;
            infer_net_noselfloop(eye(N)~=0)=0;
            Aest_baseline_noselfloop(:,:,j) = infer_net_noselfloop;
        end
        M1 = analyse.CompareModels(Net,Aest_baseline);
        test_result(1).f1_baseline(n, m) = max(M1.F1);
        test_result(1).auroc_baseline(n, m) = M1.AUROC;
        test_result(1).aupr_baseline(n, m) = M1.AUPR;

        M1_noselfloop = analyse.CompareModels(Net_noselfloop ,Aest_baseline_noselfloop);
        test_result_noselfloop(1).f1_baseline(n, m) = max(M1_noselfloop.F1);
        test_result_noselfloop(1).auroc_baseline(n, m) = M1_noselfloop.AUROC;
        test_result_noselfloop(1).aupr_baseline(n, m) = M1_noselfloop.AUPR;
    end
    

    %%%%% BiGSM %%%%%
    A_est_bcs = bigsm(D.Y, P, max_iter, size(A));
    
    A_est_bcs_noselfloop = A_est_bcs.*(eye(height(A))-1);
    A_est_bcs_co = manual_test(A_est_bcs, zeta);
    A_est_bcs_co_noselfloop = manual_test(A_est_bcs_noselfloop, zeta);

    M2 = analyse.CompareModels(Net,A_est_bcs_co);
    test_result(1).f1_bcs(n) = max(M2.F1);
    test_result(1).auroc_bcs(n) = M2.AUROC;
    test_result(1).aupr_bcs(n) = M2.AUPR;

    M2_noselfloop = analyse.CompareModels(Net_noselfloop,A_est_bcs_co_noselfloop);
    test_result_noselfloop(1).f1_bcs(n) = max(M2_noselfloop.F1);
    test_result_noselfloop(1).auroc_bcs(n) = M2_noselfloop.AUROC;
    test_result_noselfloop(1).aupr_bcs(n) = M2_noselfloop.AUPR;
end



