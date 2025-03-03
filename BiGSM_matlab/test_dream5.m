%%%% Benchmarking on DREAM5 data %%%%%

clear
addpath(genpath('../grn/genespider'));  % replace with your genespider path

expression1_path = "./dream5/net1_expression_data.tsv";

expression3_path = "./dream5/net3_expression_data.tsv";

chip1_path = "./dream5/net1_chip_features.tsv";

chip3_path = "./dream5/net3_chip_features.tsv";

standard1_path = "./dream5/DREAM5_NetworkInference_GoldStandard_Network1 - in silico.tsv";

standard3_path = "./dream5/DREAM5_NetworkInference_GoldStandard_Network3 - E. coli.tsv";


expression1 = readtable(expression1_path, "FileType","text",'Delimiter', '\t');
chip1 = readtable(chip1_path, "FileType","text",'Delimiter', '\t');
standard1 = readtable(standard1_path, "FileType","text",'Delimiter', '\t');


expression3 = readtable(expression3_path, "FileType","text",'Delimiter', '\t');
chip3 = readtable(chip3_path, "FileType","text",'Delimiter', '\t');
standard3 = readtable(standard3_path, "FileType","text",'Delimiter', '\t');


infMethods = ["LSCON" "lasso" "svmc" "Zscore" "GENIE3"];
test_result = {};

%% select delete gene and overexpression
for dataset = 1:2
    if dataset == 1
        chip = chip1;
        expression = expression1;
        standard = standard1;
    elseif dataset == 2
        chip = chip3;
        expression = expression3;
        standard = standard3;
    end
    
    j = 0;
    exp_subset = {};
    target_genes = {};
    pertub_type = {};
    row_num = {};
    
    for i = 1:size(chip, 1)
        if ~strcmp(chip{i, "DeletedGenes"}{1}, 'NA') || ~strcmp(chip{i, "OverexpressedGenes"}{1}, 'NA')
            j = j + 1;
            exp_subset{j} = chip{i, "x_Experiment"};
            row_num{j} = i;
        end
        if ~strcmp(chip{i, "DeletedGenes"}{1}, 'NA') && ~strcmp(chip{i, "OverexpressedGenes"}{1}, 'NA')
            target_genes{j} = [chip{i, "DeletedGenes"}{1} ',' chip{i, "OverexpressedGenes"}{1}];
            pertub_type{j} = 1;
        end
        if ~strcmp(chip{i, "OverexpressedGenes"}{1}, 'NA') && strcmp(chip{i, "DeletedGenes"}{1}, 'NA')
            target_genes{j} = chip{i, "OverexpressedGenes"}{1};
            pertub_type{j} = 1;
        end
        if strcmp(chip{i, "OverexpressedGenes"}{1}, 'NA') && ~strcmp(chip{i, "DeletedGenes"}{1}, 'NA')
            target_genes{j} = chip{i, "DeletedGenes"}{1};
            pertub_type{j} = 1;
        end
    end
    
    % next step: select target gene expression data, select a true subnetwork.
    
    % first, find the set of target genes
    gene_set = unique(target_genes, 'stable');
    gene_set_extra = {};
    for i=1:size(gene_set, 2)
        if contains(gene_set(1, i), ',')
            sub_genes = split(gene_set(1, i), ",")';
            gene_set_extra = [gene_set_extra, sub_genes];
        else
            gene_set_extra = [gene_set_extra, gene_set(1, i)];
        end
    end
    
    gene_set_extra = unique(gene_set_extra, 'stable');  % the unique target gene set
    
    % select target columns (genes) and rows (experiments) in expression data
    new_expression1 = [];
    for i = 1:size(gene_set_extra, 2)
        gene_name = gene_set_extra(1, i);
        new_expression1 = [new_expression1 expression(:, gene_name{1})];
    end
    
    
    row_to_select = cell2mat(row_num);
    new_expression2 = new_expression1(row_to_select, :);  % 199 * 38, 199 experiments, on 38 genes
    Y = table2array(new_expression2); 
    
    % select and form a subnet matrix A
    N = size(Y, 2);  % gene number
    A = zeros(N, N);
    for i = 1:N
        gene1 = string(gene_set_extra{1, i});  
        for j = 1:N
            gene2 = string(gene_set_extra{1, j});
            rowIndex = find(standard.Var1 == gene1 & standard.Var2 == gene2);
            if isempty(rowIndex)
                A(i, j) = 0;
            else
                A(i, j) = standard.Var3(rowIndex);
            end
        end
    end
    

    % form the pertubation matrix
    p_matrix = zeros(size(Y));
    for i = 1:size(p_matrix, 1)
        perturb_gene = target_genes{1, i};
        split_gene = strsplit(perturb_gene, ',');
        if size(split_gene, 2) == 1
            target_one_gene = find(strcmp(gene_set_extra, perturb_gene));
            p_matrix(i, target_one_gene) = pertub_type{1, i};
        else
            for n = 1:size(split_gene, 2)
                target_one_gene = find(strcmp(gene_set_extra, split_gene{1, n}));
                p_matrix(i, target_one_gene) = pertub_type{1, i};
                
            end
        end
    end
    P = p_matrix;
    
    % Inference and benchmark test
    Y = Y';
    P = P';
    A_temp = zeros(N);
    Net = datastruct.Network(A_temp, 'myNetwork');
    
    % define stdE
    stdE = std(Y(:));
    E = [zeros(size(Y))];
    % define input noise matrix as zeros
    F = zeros(size(P));
    
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
    
    Data = datastruct.Dataset(D,Net);

    zeta = logspace(-10,0,500);

    Net = datastruct.Network(A, 'myNetwork');


     for m=1:length(infMethods)
        method = infMethods(m)

        [Aest, z] = Methods.(method)(Data,zeta);
         
        M1 = analyse.CompareModels(Net,Aest);
        test_result(1).f1_baseline(dataset, m) = max(M1.F1);
        test_result(1).auroc_baseline(dataset, m) = M1.AUROC;
        test_result(1).aupr_baseline(dataset, m) = M1.AUPR;
     end

    max_iter = 35;
    A_est_bcs = bigsm(Y, P, max_iter, size(A));
    A_est_bcs_co = manual_test(A_est_bcs, zeta);
    M2 = analyse.CompareModels(Net,A_est_bcs_co);

    test_result(1).f1_bcs(dataset) = max(M2.F1);
    test_result(1).auroc_bcs(dataset) = M2.AUROC;
    test_result(1).aupr_bcs(dataset) = M2.AUPR;

end
