clear

mode = "selfloop";

file_name = './benchmark_result_selfloop/snr01_r1';
load([file_name '.mat'])

infMethods = ["BCS" "LSCON" "lasso" "svmc" "Zscore" "GENIE3"]; 

categories_list = [];
x_list = [];

for j = 1:size(infMethods, 2)
    for i = 1:20
        x_list = [x_list j];
        categories_list = [categories_list infMethods(j)];
    end
end

if mode == "selfloop"
    auroc_mat = [test_result.auroc_bcs' test_result.auroc_baseline ];
    f1_mat = [test_result.f1_bcs' test_result.f1_baseline ];
    aupr_mat = [test_result.aupr_bcs' test_result.aupr_baseline ];
else
    auroc_mat = [test_result_noselfloop.auroc_bcs' test_result_noselfloop.auroc_baseline ];
    f1_mat = [test_result_noselfloop.f1_bcs' test_result_noselfloop.f1_baseline ];
    aupr_mat = [test_result_noselfloop.aupr_bcs' test_result_noselfloop.aupr_baseline ];
end



subplot(1, 3, 2)
% auroc_mat = auroc_mat(:);
% h1 = boxchart(x_list, auroc_mat, 'GroupByColor', categories_list);

for i = 1:6
    boxchart(i.*ones(1, 20), auroc_mat(:, i));
    hold on
end
% legend(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"],'Location', 'southeast')
xticks([1 2 3 4 5 6]); % Set tick locations
xticklabels(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"]); % Set tick labels
ylim([0, 1]);
ylabel('AUROC')
grid on

subplot(1, 3, 3)
for i = 1:6
    boxchart(i.*ones(1, 20), f1_mat(:, i));
    hold on
end

% legend(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"], 'FontSize',12)

xticks([1 2 3 4 5 6]); % Set tick locations
xticklabels(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"]); % Set tick labels
ylim([0, 1]);
ylabel('Maximum F1 score')
grid on

subplot(1, 3, 1)
for i = 1:6
    boxchart(i.*ones(1, 20), aupr_mat(:, i));
    hold on
end
% legend(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"])
xticks([1 2 3 4 5 6]); % Set tick locations
xticklabels(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"]); % Set tick labels
ylim([0, 1]);
ylabel('AUPR')
grid on

figure_width = 1500;  % Specify the width in pixels
figure_height = 400; % Specify the height in pixels
set(gcf, 'Position', [100, 100, figure_width, figure_height]);


% saveas(gcf, [file_name '.jpg'])
