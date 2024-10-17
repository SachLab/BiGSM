import numpy as np
import matplotlib.pyplot as plt
import scipy.io as scio


def load_mat(filename, mat_name):
    return scio.loadmat(filename)[mat_name]
#
# test_results = load_mat('./real_ecoli.mat', 'test_result')[0][0].tolist()
signed_benchmark = False

if signed_benchmark:
    test_results = load_mat('./real_ecoli_dir.mat', 'test_result_dir')[0][0].tolist()
    inf_methods = ["BiGSM", "LSCON", "LASSO", "SVM", "Zscore"]
    metrics = ['Signed Maximum-F1', 'Signed AUROC', 'Signed AUPR']
else:
    test_results = load_mat('./real_ecoli.mat', 'test_result')[0][0].tolist()
    inf_methods = ["BiGSM", "LSCON", "LASSO", "SVM", "Zscore", "GENIE3"]
    metrics = ['Maximum-F1', 'AUROC', 'AUPR']

f1_list = test_results[0][0].tolist()
auroc_list = test_results[1][0].tolist()
aupr_list = test_results[2][0].tolist()
f1_bigsm = test_results[3][0].tolist()
auroc_bigsm = test_results[4][0].tolist()
aupr_bigsm = test_results[5][0].tolist()

f1_all = f1_bigsm+f1_list
auroc_all = auroc_bigsm+auroc_list
aupr_all = aupr_bigsm+aupr_list



# Grouping the data by metrics

data = [f1_all, auroc_all, aupr_all]

# Number of methods and metrics
n_methods = len(inf_methods)
n_metrics = len(metrics)

# Bar width and positions
bar_width = 0.12
index = np.arange(n_metrics)  # One group for each metric

# Set up figure
fig, ax = plt.subplots(figsize=(10, 6))

# Plot bars for each method within each metric group
for i in range(n_methods):
    ax.bar(index + i * bar_width, [f1_all[i], auroc_all[i], aupr_all[i]], bar_width, label=inf_methods[i])

# Add labels and title
# ax.set_xlabel('Metrics')
# ax.set_ylabel('Scores')
ax.set_xticks(index + bar_width * (n_methods - 1) / 2)
ax.set_xticklabels(metrics, fontsize=18)
ax.grid(True)
ax.tick_params(axis='y', labelsize=18)
# ax.set_ylim([0, 1])
# Show plot

ax.legend(loc='lower left', bbox_to_anchor=(1, 0.5), fontsize=18)
plt.tight_layout()
if signed_benchmark:
    plt.savefig('./signed.png')
else:
    plt.savefig('./real_ecoli.pdf')
plt.show()