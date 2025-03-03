%%%% Example of running GRN inference with BiGSM and GeneSPIDER %%%%%

clear
addpath(genpath('../grn/genespider'));  % replace with your genespider path

% define the size of your data and network
N = 50;
% define desired sparsity degree, e.g. 3 edges per node on average
S = 3;

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
P = -[eye(N) eye(N)]; %sample perturbation matrix
% create data
X = Net.G*P; % G - static gain model, A - network
% add noise to data
% define signal-to-noise ratio
SNR = 0.1; % usually 1 is low, 0.1 is medium, 0.01 is high noise
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


%%%%% Inferring using BiGSM algorithm %%%%%
max_iter = 15;

A_est_bigsm = bigsm(D.Y, P, max_iter, size(A));

% Choose a baseline to compare
infMethod = 'LSCON'; % lsco LSCON lasso svmc GENIE3 Zscore

zeta = logspace(-10,0,100);

% [Aest_ls, z0] = Methods.(infMethod)(Data,zeta);
% 
[Aest_ls, z1] = Methods.(infMethod)(Data,zeta);

for j=1:size(Aest_ls, 3)
    infer_net = Aest_ls(:,:,j);
    infer_net(eye(N)~=0)=0;
    Aest_ls(:,:,j) = infer_net;
end

% Remove self loop
A = A.*(eye(height(A))-1);
Net = datastruct.Network(A, 'myNetwork');

A_est_bigsm = A_est_bigsm.*(eye(height(A))-1);
A_est_bigsm_co = manual_test(A_est_bigsm, zeta);


% compare models
M1 = analyse.CompareModels(Net,Aest_ls);
M2 = analyse.CompareModels(Net,A_est_bigsm_co);

disp(" ")
disp("MAX_F1_"+infMethod+" = "+string(max(M1.F1)))
disp("MAX_F1_BiGSM = "+string(max(M2.F1)))
disp(" ")
disp("AUROC_"+infMethod+" = "+string(M1.AUROC))
disp("AUROC_BiGSM = "+string(M2.AUROC))
disp(" ")
disp("AUPR_"+infMethod+" = "+string(M1.AUPR))
disp("AUPR_BiGSM = "+string(M2.AUPR))
