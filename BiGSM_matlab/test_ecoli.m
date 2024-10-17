clear
addpath(genpath('../grn/genespider'));

% define the size of your data and network
N = 9;

infMethods = ["LSCON" "lasso" "svmc" "Zscore" "GENIE3"];


P = -[eye(N)];
Y = [0.906 -0.132 -0.139 0.187 0.291 -0.061 -0.077 -0.017 -0.025;
     0.212 0.383 -0.117 0.064 0.169 -0.087 0.039 0.125 0.084;
     0.018 -0.107 10.524 0.061 0.080 0.013 0.064 0.089 -0.070;
     0.104 -0.050 -0.273 0.139 0.180 0.146 0.069 -0.004 0.275;
     0.119 -0.097 0.056 0.315 2.147 0.142 -0.068 0.135 0.113;
     0.076 -0.189 -0.124 0.250 0.347 2.017 -0.067 -0.172 -0.022;
     -0.122 -0.047 -0.102 -0.107 -0.011 0.104 3.068 0.365 0.217;
     0.178 -0.183 0.036 -0.070 -0.034 -0.155 0.008 26.633 0.087;
     0.072 -0.128 0.073 0.081 0.305 0.051 -0.061 0.274 0.672];

D(1).network = [];
Net = datastruct.Network(zeros(N), 'myNetwork');
D(1).E = zeros(N);
D(1).F = zeros(N);
D(1).Y = Y; % response matrix + noise
D(1).P = P;
D(1).lambda = [std(Y(:))^2,0];
D(1).cvY = D.lambda(1)*eye(N);
D(1).cvP = zeros(N);
D(1).sdY = std(Y(:))*ones(size(D.P));
D(1).sdP = zeros(size(D.P));

% create a Data object with data "D" and scale-free network "Net"
Data = datastruct.Dataset(D, Net);

A = [1 -1 -1 1 1 -1 1 0 0;
    1 -1 -1 1 1 -1 1 0 0;
    1 -1 -1 1 1 -1 1 0 0;
    0 0 0 0 0 0 1 0 1;
    1 -1 -1 1 1 -1 1 0 0;
    1 -1 -1 1 1 -1 1 0 0;
    1 -1 -1 1 1 -1 1 1 0;
    0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 1 0 1];
Net = datastruct.Network(A, 'myNetwork');
% Remove self loop
% A(eye(N)~=0)=0;

% Choose a baseline to compare
% infMethod = 'Zscore'; % lsco LSCON lasso svmc GENIE3 Zscore

zeta = logspace(-20,0,500);

% [Aest_ls, z1] = Methods.(infMethod)(Data,zeta);
for m=1:length(infMethods)
    method = infMethods(m)
    [Aest, z] = Methods.(method)(Data,zeta);
    
%     for j=1:size(Aest, 3)
%         infer_net = Aest(:,:,j);
%         infer_net(eye(N)~=0)=0;
%         Aest(:,:,j) = infer_net;
%     end

    M1 = analyse.CompareModels(Net,Aest);
    test_result(1).f1_baseline(1, m) = max(M1.F1);
    test_result(1).auroc_baseline(1, m) = M1.AUROC;
    test_result(1).aupr_baseline(1, m) = M1.AUPR;

    % for signed benchamrk
    PRE = M1.dirprec;
    REC = M1.dirsen;
    [junk,ord] = sort(M1.nlinks);
    PRE = PRE(ord);
    REC = REC(ord);
    aupr_dir = trapz(REC,PRE);

    TPR = M1.dirsen;
    FPR = 1 - M1.dirspe;
    [junk,ord] = sort(M1.nlinks);
    TPR = TPR(ord);
    FPR = FPR(ord);
    auroc_dir = trapz(FPR,TPR);

    max_F1_dir = max(M1.TR ./ (M1.TR + 0.5.*(M1.FI+M1.FR+M1.FZ)));

    test_result_dir(1).f1_baseline(1, m) = max_F1_dir;
    test_result_dir(1).auroc_baseline(1, m) = auroc_dir;
    test_result_dir(1).aupr_baseline(1, m) = aupr_dir;
end
    

bigsm_f1 = [];
bigsm_auroc = [];
bigsm_aupr = [];

max_iter = 20;
A_est_bcs = bigsm(D.Y, P, max_iter, size(A));

A_est_bcs_co = manual_test(A_est_bcs, zeta);

M2 = analyse.CompareModels(Net,A_est_bcs_co);
test_result(1).f1_bcs(1) = max(M2.F1);
test_result(1).auroc_bcs(1) = M2.AUROC;
test_result(1).aupr_bcs(1) = M2.AUPR;

% for signed benchamrk

PRE = M2.dirprec;
REC = M2.dirsen;
[junk,ord] = sort(M2.nlinks);
PRE = PRE(ord);
REC = REC(ord);
aupr_dir = trapz(REC,PRE);

TPR = M2.dirsen;
FPR = 1 - M2.dirspe;
[junk,ord] = sort(M2.nlinks);
TPR = TPR(ord);
FPR = FPR(ord);
auroc_dir = trapz(FPR,TPR);
max_F1_dir = max(M2.TR ./ (M2.TR + 0.5.*(M2.FI+M2.FR+M2.FZ)));

test_result_dir(1).f1_bcs(1) = max_F1_dir;
test_result_dir(1).auroc_bcs(1) = auroc_dir;
test_result_dir(1).aupr_bcs(1) = aupr_dir;



