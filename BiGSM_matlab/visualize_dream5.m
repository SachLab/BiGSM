clear


load('./dream5_results.mat')


infMethods = ["BCS" "LSCON" "lasso" "svmc" "Zscore" "GENIE3"]; 

auroc_mat = [test_result.auroc_bcs' test_result.auroc_baseline ];
f1_mat = [test_result.f1_bcs' test_result.f1_baseline ];
aupr_mat = [test_result.aupr_bcs' test_result.aupr_baseline ];


x = 1:8:15;
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

network = ["In silico" "E.coli"];
for j=1:2
    text(8.1*j-5.5, -0.03, network(j), FontSize=20)
end


% xtick_num = sort(xtick_num);
% methods_list = [infMethods infMethods infMethods infMethods infMethods];
% xticks(xtick_num);
% xticklabels(methods_list)

figure_width = 1500;  % Specify the width in pixels
figure_height = 800; % Specify the height in pixels
set(gcf, 'Position', [100, 100, figure_width, figure_height]);
ax = gca; % Get current axis
set(ax.YAxis, 'FontSize', 18);
ylabel(" AUROC ", FontSize=18)
% title("DREAM3 insilico size 50 knockouts, AUPR", FontSize=16)

saveas(gcf, './dream4_result/knockdowns1.png')
