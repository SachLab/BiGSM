import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.io as scio
from joypy import joyplot

def load_mat(filename, mat_name):
    mat = scio.loadmat(filename)[mat_name].astype(np.float64)
    return np.ravel(mat)

file_path = 'full_grns_s5'

A = load_mat('full_grns_s5/A.mat', 'A')
# plt.hist(A, bins=100)
# plt.show()
genie3 = load_mat(file_path+'/GENIE3.mat', 'Aest_baseline')
LSCON = load_mat(file_path+'/LSCON.mat', 'Aest_baseline')
lsco = load_mat(file_path+'/lsco.mat', 'Aest_baseline')
# plt.hist(LSCON, bins=100)
# plt.show()
lasso = load_mat(file_path+'/lasso.mat', 'Aest_baseline')
svmc = load_mat(file_path+'/svmc.mat', 'Aest_baseline')
zscore = load_mat(file_path+'/Zscore.mat', 'Aest_baseline')
bcs = load_mat(file_path+'/bcs.mat', 'A_est_bcs')
# plt.hist(bcs, bins=100)
# plt.show()

est_mat = np.reshape(bcs, (50, 50))
a_mat = np.reshape(A, (50, 50))
# vmin = min(a_mat.min(), est_mat.min())
# vmax = max(a_mat.max(), est_mat.max())
vmin = min(a_mat.min(), LSCON.min(), lsco.min(), bcs.max())
vmax = max(a_mat.max(), LSCON.max(), lsco.max(), bcs.max())

# fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))
# im1 = ax1.imshow(est_mat, vmin=vmin, vmax=vmax, cmap='RdYlGn')
# ax1.set_title('BiGSM')
# im2 = ax2.imshow(a_mat, vmin=vmin, vmax=vmax, cmap='RdYlGn')
# ax2.set_title('True GRN')
# plt.tight_layout()
# cbar = fig.colorbar(im1, ax=[ax1, ax2], orientation='vertical')

# plt.show()

data_list = [A, bcs, LSCON, lasso, svmc, zscore, genie3]
name_list = ['True GRN', 'BiGSM', 'LSCO', 'LSCON', 'LASSO', 'SVM', 'Zscore', 'GENIE3']

def normalize_matrix(matrix, new_min, new_max):
    # Get the minimum and maximum values from the matrix
    X_min = np.min(matrix)
    X_max = np.max(matrix)
    normalized_matrix = new_min + (matrix - X_min) * (new_max - new_min) / (X_max - X_min)

    return normalized_matrix

# plt.figure(figsize=(22, 10))
for d in range(len(data_list)-1):
    # plt.subplot(2, 4, d+1)
    m_data = np.average(data_list[d+1])
    # print(m_data)
    data_list[d+1] = normalize_matrix(data_list[d+1], A.min(), A.max())
    data_list[d+1] = data_list[d+1] -np.average(data_list[d+1]) + m_data
    print(np.average(data_list[d+1]), m_data)
#     plt.hist(data_list[d].ravel(), bins=30)
#     plt.grid(True)
#     plt.xlim(-10, 10)
#     plt.title(name_list[d], fontsize='large')
# plt.tight_layout()
# plt.show()



data_frame = np.stack(data_list, axis=1)

df = pd.DataFrame(data_frame)
df.columns = ['True GRN', 'BiGSM', 'LSCON', 'LASSO', 'SVM', 'Zscore', 'GENIE3']
print(df.shape)
# Create the ridgeline plot
fig, ax = plt.subplots(figsize=(10, 8))
joyplot(
    data=df,
    ax=ax,
    colormap=plt.cm.twilight,
    linewidth=1,
    x_range=(-1.2, 1.2),
    # bw_method=0.4,
    xlabelsize=18,  # X-axis label font size
    ylabelsize=18,  # Y-axis label font size
    overlap=2,
)
plt.savefig('ridgeline.pdf')
plt.show()