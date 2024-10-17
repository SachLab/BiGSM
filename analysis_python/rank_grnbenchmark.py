import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
# results on grnbenchmark, GeneNetWeaver dataset

class InferResults():
    def __init__(self):
        self.high = {'aupr': [], 'auroc': [], 'f1': []}
        self.low = {'aupr': [], 'auroc': [], 'f1': []}
        self.medium = {'aupr': [], 'auroc': [], 'f1': []}
        self.rank_high = {'aupr': [], 'auroc': [], 'f1': []}
        self.rank_medium = {'aupr': [], 'auroc': [], 'f1': []}
        self.rank_low = {'aupr': [], 'auroc': [], 'f1': []}


name_list = ['LSCON', 'LASSO', 'SVMC', 'Zscore', 'GENIE3', 'BiGSM']
lscon = InferResults()
lasso = InferResults()
svm = InferResults()
zscore = InferResults()
genie3 = InferResults()
bigsm = InferResults()
result_dic = {'LSCON':lscon, 'LASSO':lasso, 'SVMC':svm, 'Zscore':zscore, 'GENIE3':genie3, 'BiGSM':bigsm}

with open('grn_benchmark_results/gnw_results.txt') as file:
    results = file.readlines()

for l in range(len(results)):
    results[l] = results[l].split('\t')
    method = results[l][3]
    if method in name_list:
        network = int(results[l][1])
        noise_level = results[l][2]
        method = results[l][3]
        aupr = float(results[l][4])
        auroc = float(results[l][5])
        f1 = float(results[l][6])
        if noise_level == 'High':
            result_dic[method].high['aupr'].append(aupr)
            result_dic[method].high['auroc'].append(auroc)
            result_dic[method].high['f1'].append(f1)
        if noise_level == 'Medium':
            result_dic[method].medium['aupr'].append(aupr)
            result_dic[method].medium['auroc'].append(auroc)
            result_dic[method].medium['f1'].append(f1)
        if noise_level == 'Low':
            result_dic[method].low['aupr'].append(aupr)
            result_dic[method].low['auroc'].append(auroc)
            result_dic[method].low['f1'].append(f1)
#
# for method in name_list:
#     print(method)
#     print(result_dic[method].low)
#     print(result_dic[method].medium)
#     print(result_dic[method].high)

def get_rank(original_list):
    # print(original_list, 'original list')
    sorted_list = sorted(range(len(original_list)), key=lambda i: original_list[i], reverse=True)
    # print(sorted_list)
    rank_list = [0] * len(original_list)
    rank = 1
    buffer = 1
    rank_list[sorted_list[0]] = rank
    for i in range(len(original_list)-1):
        current_loc = sorted_list[i+1]
        previous_loc = sorted_list[i]
        if original_list[current_loc] == original_list[previous_loc]:
            rank_list[current_loc] = rank
            buffer += 1
        else:
            rank += buffer
            buffer = 1
            rank_list[current_loc] = rank

    return rank_list

for n in range(5):  # five network
    aupr_list, auroc_list, f1_list = [], [], []
    for m in range(len(name_list)):
        aupr_list.append(result_dic[name_list[m]].low['aupr'][n])
        auroc_list.append(result_dic[name_list[m]].low['auroc'][n])
        f1_list.append(result_dic[name_list[m]].low['f1'][n])
    print(aupr_list)
    rank_aupr = get_rank(aupr_list)
    print(rank_aupr)
    rank_auroc = get_rank(auroc_list)
    rank_f1 = get_rank(f1_list)
    for m in range(len(name_list)):
        result_dic[name_list[m]].rank_low['aupr'].append(rank_aupr[m])
        result_dic[name_list[m]].rank_low['auroc'].append(rank_auroc[m])
        result_dic[name_list[m]].rank_low['f1'].append(rank_f1[m])

for n in range(5):  # five network
    aupr_list, auroc_list, f1_list = [], [], []
    for m in range(len(name_list)):
        aupr_list.append(result_dic[name_list[m]].medium['aupr'][n])
        auroc_list.append(result_dic[name_list[m]].medium['auroc'][n])
        f1_list.append(result_dic[name_list[m]].medium['f1'][n])
    rank_aupr = get_rank(aupr_list)
    rank_auroc = get_rank(auroc_list)
    rank_f1 = get_rank(f1_list)
    for m in range(len(name_list)):
        result_dic[name_list[m]].rank_medium['aupr'].append(rank_aupr[m])
        result_dic[name_list[m]].rank_medium['auroc'].append(rank_auroc[m])
        result_dic[name_list[m]].rank_medium['f1'].append(rank_f1[m])

for n in range(5):  # five network
    aupr_list, auroc_list, f1_list = [], [], []
    for m in range(len(name_list)):
        aupr_list.append(result_dic[name_list[m]].high['aupr'][n])
        auroc_list.append(result_dic[name_list[m]].high['auroc'][n])
        f1_list.append(result_dic[name_list[m]].high['f1'][n])
    rank_aupr = get_rank(aupr_list)
    rank_auroc = get_rank(auroc_list)
    rank_f1 = get_rank(f1_list)
    for m in range(len(name_list)):
        result_dic[name_list[m]].rank_high['aupr'].append(rank_aupr[m])
        result_dic[name_list[m]].rank_high['auroc'].append(rank_auroc[m])
        result_dic[name_list[m]].rank_high['f1'].append(rank_f1[m])


rank_dic_high = {}
rank_dic_med = {}
rank_dic_low = {}
for noise in ['High', 'Medium', 'Low']:
    for method in name_list:
        # print(method)
        if noise == 'High':
            ranks = result_dic[method].rank_high
            rank_dic_high[method] = [np.mean(ranks['aupr']), np.mean(ranks['auroc']), np.mean(ranks['f1'])]
        elif noise == 'Medium':
            ranks = result_dic[method].rank_medium
            rank_dic_med[method] = [np.mean(ranks['aupr']), np.mean(ranks['auroc']), np.mean(ranks['f1'])]
        else:
            ranks = result_dic[method].rank_low
            rank_dic_low[method] = [np.mean(ranks['aupr']), np.mean(ranks['auroc']), np.mean(ranks['f1'])]
        # print(ranks)
        # print(np.mean(ranks['aupr']), np.mean(ranks['auroc']), np.mean(ranks['f1']))


# Example DataFrame similar to the heatmap in the image
def plot_avg_rank():
    # Create the DataFrame
    df_l = pd.DataFrame(rank_dic_low, index=['AUPR', 'AUROC', 'Maximum-F1'])
    df_m = pd.DataFrame(rank_dic_med, index=['AUPR', 'AUROC', 'Maximum-F1'])
    df_h = pd.DataFrame(rank_dic_high, index=['AUPR', 'AUROC', 'Maximum-F1'])
    # Sorted
    df_l = df_l.loc[:, df_l.mean().sort_values().index]
    df_m = df_m.loc[:, df_m.mean().sort_values().index]
    df_h = df_h.loc[:, df_h.mean().sort_values().index]

    # Create the heatmap using seaborn
    fig, axes = plt.subplots(3, 1, figsize=(8, 8))
    sns.heatmap(df_l, ax=axes[0], cmap='YlOrRd', cbar=False, annot=True, annot_kws={"size": 14})
    sns.heatmap(df_m, ax=axes[1], cmap='YlOrRd', cbar=False, annot=True, annot_kws={"size": 14})
    sns.heatmap(df_h, ax=axes[2], cmap='YlOrRd', cbar=False, annot=True, annot_kws={"size": 14})
    for ax in axes:
        ax.tick_params(axis='x', labelsize=14)  # X-axis tick label font size
        ax.tick_params(axis='y', labelsize=14)

    axes[0].set_title('Low Noise', fontsize=14)
    axes[1].set_title('Medium Noise', fontsize=14)
    axes[2].set_title('High Noise', fontsize=14)


    norm = plt.Normalize(vmin=np.min([df_l.values, df_m.values, df_h.values]), vmax=np.max([df_l.values, df_m.values, df_h.values]))
    sm = plt.cm.ScalarMappable(cmap="YlOrRd", norm=norm)
    sm.set_array([])
    cbar = fig.colorbar(sm, ax=axes, orientation='vertical', fraction=0.05, pad=0.05)
    cbar.ax.tick_params(labelsize=14)
    cbar.set_label('Average rank of methods over 5 networks', rotation=270, labelpad=20, fontsize=15)
    plt.suptitle("GeneNetWeaver", fontsize=16)
    plt.tight_layout()
    plt.subplots_adjust(right=0.8, hspace=0.4)
    plt.savefig('gnw_grnbenchmark.svg')
    plt.show()


def gen_scatter_plot(metric):
    # print(result_dic['LSCON'].low)
    # print(bigsm.high[metric])
    data = {
        'Noise Level': ['High'] * 30 + ['Medium'] * 30 + ['Low'] * 30,
        'Y-axis': bigsm.high[metric]+lscon.high[metric]+lasso.high[metric]+svm.high[metric]+zscore.high[metric]+genie3.high[metric]+
        bigsm.medium[metric]+lscon.medium[metric]+lasso.medium[metric]+svm.medium[metric]+zscore.medium[metric]+genie3.medium[metric]+
        bigsm.low[metric]+lscon.low[metric]+lasso.low[metric]+svm.low[metric]+zscore.low[metric]+genie3.low[metric],
        # 'Y-axis': [0.9, 0.95, 1, 0.85, 1, 0.75] * 15,
        'Method': (['BiGSM']*5+['LSCON']*5+['LASSO']*5+['SVM']*5+['Zscore']*5+['GENIE3']*5)*3
    }
    # print(len(data['Y-axis']))
    # print(len(data['Method']))

    # Convert to DataFrame
    df = pd.DataFrame(data)

    # Define color palette and marker styles manually to match the plot
    colors = {
        'BiGSM': 'red', 'LSCON': 'green', 'SVM': 'blue', 'GENIE3': 'brown',
        'LASSO': 'purple', 'PLSNET': 'grey', 'RidgeRegression': 'pink', 'Zscore': 'orange'
    }

    markers = {
        'BiGSM': 'D', 'LSCON': 'o', 'SVM': '^', 'GENIE3': '+',
        'LASSO': 'x', 'LeastSquares': '>', 'PLSNET': '<', 'RidgeRegression': 'p',
        'TIGRESS': 's', 'Zscore': 'v'
    }

    noise_map = {'High': 1, 'Medium': 2, 'Low': 3}

    # Add jitter for x-axis points
    jitter_strength = 0.1  # Adjust this to control how spread out the points are
    df['Noise Level Num'] = df['Noise Level'].map(noise_map) + np.random.uniform(-jitter_strength, jitter_strength,
                                                                                 size=len(df))

    # Plot each method with its corresponding marker and color
    for method in df['Method'].unique():
        print(method)

        subset = df[df['Method'] == method]
        if markers[method] != 'x' and markers[method] != '+':
            plt.scatter(subset['Noise Level Num'], subset['Y-axis'],
                        label=method, color=colors[method], marker=markers[method],
                        facecolor='none', s=90, linewidths=2)
        else:
            plt.scatter(subset['Noise Level Num'], subset['Y-axis'],
                        label=method, color=colors[method], marker=markers[method], s=90, linewidths=2)

    # Customize the plot
    plt.ylim(-0.01, 1.05)
    plt.yticks(fontsize=14)
    plt.xticks([1, 2, 3], ['High', 'Medium', 'Low'], fontsize=16)  # Ensure the ticks match the noise levels
    plt.xlabel('Noise Level', fontsize=16)
    if metric != 'f1':
        plt.ylabel(metric.upper(), fontsize=16)
    else:
        plt.ylabel('Maximum F1-score', fontsize=16)


    plt.grid(True)

    # Show the plot
    # plt.tight_layout()
    # plt.show()


plt.figure(figsize=(20, 8))
metrics = ['aupr', 'auroc', 'f1']
for m in range(len(metrics)):
    plt.subplot(1, 3, m+1)
    gen_scatter_plot(metrics[m])
    if m == 2:
        plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=14)
        # 'best', 'upper right', 'upper left', 'lower left', 'lower right', 'right', 'center left',
        # 'center right', 'lower center', 'upper center', 'center'
plt.tight_layout()
plt.savefig('gnw_scatters.pdf')
plt.show()