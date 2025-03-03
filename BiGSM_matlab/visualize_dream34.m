%%% Plotting results for benchmarking on DREAM3 / DREAM4 %%%

clear

% chooose between DREAM3 or DREAM4 result
load('./DREAM4_result/knockdowns.mat')
% load('./DREAM3_results/dream3_ko.mat')

infMethods = ["BCS" "LSCON" "lasso" "svmc" "Zscore" "GENIE3"]; 

auroc_mat = [test_result.auroc_bcs' test_result.auroc_baseline ];
f1_mat = [test_result.f1_bcs' test_result.f1_baseline ];
aupr_mat = [test_result.aupr_bcs' test_result.aupr_baseline ];

x = 1:8:35;
xtick_num = x;

for i=0:5
    if i ~= 0
        xtick_num = [xtick_num x+i];
    end
    bar(x+i, auroc_mat(:, i+1), 'BarWidth', 0.125)% 'FaceColor', colors(i+1))
    hold on
end

set(gca, 'XTick', []);
set(gca, 'XTickLabel', []);

legend(["BiGSM" "LSCON" "LASSO" "SVM" "Zscore" "GENIE3"], FontSize=15)

network = ["Ecoli1" "Ecoli2" "Yeast1" "Yeast2" "Yeast3"];
% network = ["Net1" "Net2" "Net3" "Net4" "Net5"];
for j=1:5
    text(8*j-6, -0.03, network(j), FontSize=18)
end


figure_width = 1500;  % Specify the width in pixels
figure_height = 800; % Specify the height in pixels
set(gcf, 'Position', [100, 100, figure_width, figure_height]);
ax = gca; % Get current axis
set(ax.YAxis, 'FontSize', 18);
ylabel(" AUROC ", FontSize=18)

% specify saving path
% saveas(gcf, './DREAM3_results/knockout.png')
