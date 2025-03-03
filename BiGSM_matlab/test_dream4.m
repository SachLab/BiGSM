%%%% Benchmarking on DREAM4 data %%%%%

clear
addpath(genpath('../grn/genespider'));

data_type = 'knockdowns';  % replace with your genespider path

infMethods = ["LSCON" "lasso" "svmc" "Zscore" "GENIE3"];


test_result = {};

for network_idx=1:5
    
    file_path = "./DREAM4 training data/insilico_size100_"+num2str(network_idx)+"/insilico_size100_"+num2str(network_idx)+"_"+data_type+".tsv";
    standard_path = "./DREAM4 gold standards/insilico_size100_"+num2str(network_idx)+"_goldstandard.tsv";
    wild_path = "./DREAM4 training data/insilico_size100_"+num2str(network_idx)+"/insilico_size100_"+num2str(network_idx)+"_wildtype.tsv";
    
    mat_wildtype = readtable(wild_path, "FileType","text",'Delimiter', '\t');
    mat_wildtype = table2array(mat_wildtype);
    temp = mat_wildtype;
    for w=1:99
        mat_wildtype = cat(1, mat_wildtype, temp);
    end


    mat1 = readtable(file_path,"FileType","text",'Delimiter', '\t');
    mat2 = table2array(mat1);
    mat3 = readtable(standard_path, "FileType","text",'Delimiter','\t');
    
    A_true = zeros(size(mat2, 1));
    
    for i=1:size(mat3, 1)
        regulator = table2array(mat3(i, 1));
        regulator = str2double(regulator{1}(2:end));
    
        target = table2array(mat3(i, 2));
        target = str2double(target{1}(2:end));
    
        weight = table2array(mat3(i, 3));
     
        A_true(target,regulator) = weight;
    end
    
    
    Y = mat2;
    P = -eye(size(mat2, 1));
    
    
    % fetch size of the data, i.e. number of genes
    N = size(Y,1);
    
    % start with setting up an empty network
    A = zeros(N);
    % create a Network object
    Net = datastruct.Network(A, 'myNetwork');
    
    % define stdE
    stdE = std(Y(:));
    % define zero noise matrix
    E = [zeros(N)];
    % define input noise matrix as zeros
    F = zeros(size(P));
    
    % prepare data structure obejct
    % assign an empty network
    D(1).network = Net.network;
    % define zero noise
    D(1).E = E;
    D(1).F = F;
    D(1).Y = Y; % here is where your data is assigned
    D(1).P = P;
    D(1).lambda = [stdE^2,0];
    D(1).cvY = D.lambda(1)*eye(N);
    D(1).cvP = zeros(N);
    D(1).sdY = stdE*ones(size(D.P));
    D(1).sdP = zeros(size(D.P));
    
    % create a data object with your data and scale-free network
    Data = datastruct.Dataset(D,Net);

    for m=1:length(infMethods)
        method = infMethods(m)
    
        % infer a set of networks
        zeta = logspace(-20,0,500); 

        [Aest, z] = Methods.(method)(Data,zeta);
        
        for j=1:size(Aest, 3)
            infer_net = Aest(:,:,j);
            infer_net(eye(N)~=0)=0;
            Aest(:,:,j) = infer_net;
        end
        
        Net = datastruct.Network(A_true, 'myNetwork');
        M1 = analyse.CompareModels(Net,Aest);
        test_result(1).f1_baseline(network_idx, m) = max(M1.F1);
        test_result(1).auroc_baseline(network_idx, m) = M1.AUROC;
        test_result(1).aupr_baseline(network_idx, m) = M1.AUPR;
    end
    
    max_iter = 25;
    Y = Y - mat_wildtype;
    A_est_bcs = bigsm(P, Y', max_iter, size(A));
    A_est_bcs(eye(N)~=0)=0;
    A_est_bcs_co = manual_test(A_est_bcs, zeta);
    
    M2 = analyse.CompareModels(Net,A_est_bcs_co);
    test_result(1).f1_bcs(network_idx) = max(M2.F1);
    test_result(1).auroc_bcs(network_idx) = M2.AUROC;
    test_result(1).aupr_bcs(network_idx) = M2.AUPR;
end
