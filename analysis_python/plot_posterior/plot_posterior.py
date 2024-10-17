import numpy as np
import matplotlib.pyplot as plt
import scipy.io as scio


def load_mat(filename, mat_name):
    return scio.loadmat(filename)[mat_name].astype(np.float64)

A = load_mat('A.mat', 'A')
A_hat = load_mat('A_est_bcs.mat', 'A_est_bcs')
alpha = load_mat('alpha.mat', 'alpha')
# print(A)
# print(A[1:4, 1:4])

def subscript_number(n):
    # Unicode characters for subscript digits are U+2080 to U+2089
    subscript_digits = str.maketrans("0123456789", "₀₁₂₃₄₅₆₇₈₉")
    return str(n).translate(subscript_digits)

# plot_gaussian(A_hat[0, 0], alpha[0, 0])
def plot_gaussian(ax, mean, variance, i, j):
    # Generate data points along the x-axis
    x = np.linspace(-4, 4, 1000)

    # Calculate the corresponding y-values for the Gaussian distribution
    y = 1 / (np.sqrt(2 * np.pi * variance)) * np.exp(-(x - mean) ** 2 / (2 * variance))

    # Plot the Gaussian distribution
    ax.set_xlim(-4, 4)
    ax.set_ylim(-0.05, 4)

    ax.plot(x, y, linewidth=2)
    ax.axis('on')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(True)
    ax.spines['left'].set_visible(True)
    a = 'a'
    sub = subscript_number(str(i+1))+subscript_number(str(j+1))
    ax.set_title("f("+f'{a}{sub}'+"|p,H,\u03B1, \u03B2)", fontsize=18)

    ax.grid(True)


#
A = A[1:4, 1:4]
A_hat = A_hat[1:4, 1:4]
alpha = alpha[1:4, 1:4]

# Create a 6x6 grid of subplots
fig, axs = plt.subplots(3, 3, figsize=(15, 12))


# Plot Gaussian distributions in each subplot
for i in range(3):
    for j in range(3):
        plot_gaussian(axs[i, j], A_hat[i, j], 1/alpha[i, j], i, j)


# plt.suptitle('Estimated Posterior Distribution of a toy GRN', fontsize=32)
plt.tight_layout()
# plt.savefig('posterior.svg')
plt.show()

from matplotlib import colors
from matplotlib.colors import LinearSegmentedColormap
# Sample 3x3 matrix

color = [(0.8, 0.2, 0.2), (1, 1, 1), (0, 0.5, 0)]  # Red, White, Green
positions = [0, 0.5, 1]  # Red at 0, White at 0.5, Green at 1
custom_cmap = LinearSegmentedColormap.from_list('custom_cmap', list(zip(positions, color)))




matrix = A

vmin = min(A.min(), A_hat.min())
vmax = max(A.max(), A_hat.max())

plt.figure(figsize=(5, 4))
# Plot the matrix as an image
plt.imshow(matrix, cmap='RdBu', vmin=vmin, vmax=vmax)

# Add text annotations for each cell
for i in range(3):
    for j in range(3):
        if i==0 and j==1:
            color = 'black'
        elif i==2 and j==0:
            color = 'black'
        elif i==2 and j==1:
            color = 'black'
        else:
            color = 'white'
        plt.text(j, i, f'{matrix[i, j]:.3f}', color=color, ha='center', va='center', fontsize=16)

# plt.axis('off')
plt.grid(color='white', linewidth=4, which='major')
plt.xticks(np.arange(-0.5, 3, 1), [])
plt.yticks(np.arange(-0.5, 3, 1), [])
plt.colorbar()  # Add color bar for reference
# plt.grid(False)  # Turn off grid lines
# plt.title('true GRN') #, fontsize=36)
plt.tight_layout()
# plt.savefig('a_true.svg')
plt.show()
