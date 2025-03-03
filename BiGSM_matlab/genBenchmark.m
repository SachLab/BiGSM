%%%% Benchmarking using GRNbenchmark %%%%%

clear
addpath(genpath('../grn/genespider'));  % replace with your genespider path

tool = "GeneNetWeaver"; % select between GeneSPIDER and GeneNetWeaver
nlev = "LowNoise"; % select between LowNoise, HighNoise, MediumNoise

pathin = './grnbenchmark_data/';
pathout = './grnbenchmark_results/';

reps = 5; % repetitions, in GRNbenchmark it is 5

for j = 1:reps

    Y = readtable(pathin+tool+"_"+nlev+"_Network"+j+"_GeneExpression.csv", "ReadRowNames", true);

    gnsnms = string(cell2mat(Y.Row));

    P = readtable(pathin+tool+"_"+nlev+"_Network"+j+"_Perturbations.csv", "ReadRowNames", true);
    Y = table2array(Y);
    P = table2array(P);

    N = size(Y,1);
    A = zeros(N);
    Net = datastruct.Network(A, 'myNetwork');
    D(1).network = [];
    % define zero noise
    D(1).E = [zeros(N) zeros(N) zeros(N)];
    D(1).F = zeros(N);
    D(1).Y = Y; % here is where your data is assigned
    D(1).P = P;
    D(1).lambda = [std(Y(:))^2,0];
    D(1).cvY = D.lambda(1)*eye(N);
    D(1).cvP = zeros(N);
    D(1).sdY = std(Y(:))*ones(size(D.P));
    D(1).sdP = zeros(size(D.P));

    % create data object with data "D" and scale-free network "Net"
    Data = datastruct.Dataset(D, Net);

    % now we can run inference
    zeta = 0; % return full network as GRN benchmark do cutoff internally
    infMethod = 'lsco';
    [A0, z] = Methods.(infMethod)(Data,zeta);

    
    %%% Inference using BiGSM %%%
    max_iter = 35;
    A_est_bcs = bigsm(Y, P, max_iter, size(A));
    
    inet = A_est_bcs; % network to save
    wedges = compose("%9.5f",round(inet(:),5)); % keep weights

    inet(inet<0) = -1; % convert to signed edges without weights
    inet(inet>0) = 1;

    edges = inet(:); % from left to right, columns are merged to one vec
    nams_edges = combvec(1:size(inet,1),1:size(inet,1))';
    edges_from = gnsnms(nams_edges(:,2));
    edges_to = gnsnms(nams_edges(:,1));
    nrid = string((1:length(edges_from))');
    edge_list = table(nrid, edges_from, edges_to, wedges, string(edges));

    allVars = 1:width(edge_list);
    newNames = ["ID","Regulator","Target","Weight","Sign"]; % define names in the file
    edge_list = renamevars(edge_list,allVars,newNames);
    Var1 = "";
    Var2 = "Regulator";
    Var3 = "Target";
    Var4 = "Weight";
    Var5 = "Sign";
    newNamesTab = table(Var1,Var2,Var3,Var4,Var5);
    newNamesTab = renamevars(newNamesTab,allVars,newNames);

    edge_list(edges==0,:) = [];
    edge_list2 = [newNamesTab; edge_list];
    writetable(edge_list2,pathout+tool+"_"+nlev+"_Network"+j+"_grn.csv",'QuoteStrings',true,"WriteVariableNames",false) % save as csv

end
