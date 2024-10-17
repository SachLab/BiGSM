# BiGSM: Bayesian Inference of Gene Regulatory Network via Sparse Modelling

#### This is the code for BiGSM, including algorithm implementation, experiments, results analysis and visualization, and datasets.
The main experiments are implemented in MATLAB, based on GeneSPDIER: https://bitbucket.org/sonnhammergrni/genespider/src/master/

Some parts of analysis and visualizations are implemented in Python. 

## BiGSM_matlab
#### This folder includes the algorithm implementation, experiments, datasets, and data generation on Matlab, with some visualization of the results.

- `bigsm.m` -- Implementation of the BiGSM algorithm.
- `run_bigsm.m` -- An example of how to run BiGSM using the GeneSPIDER toolbox.
- `benchmark_test.m` -- Execute benchmark tests using the GeneSPIDER toolbox.
- `test_dream3/4/5` -- Run benchmark test with the corresponding DREAM dataset.
- `genBenchmark.m` -- Run benchmark test on datasets from GRNbenchmark.org.
- `test_ecoli.m` -- Run benchmark tests with biological *E. coli* data.

After each benchmark test, save the result in `.mat` files. The results in `.mat` format will be analyzed using Python code.

## analysis_python
This folder includes results analysis and visualization.

- `rank_grnbenchmark` -- Visualize and analyze the results from GRNbenchmark.org.
- `plot_posterior` -- Visualize the inferred posterior distributions from BiGSM and compare the point-estimates to the true GRN.
- `plot_ecoli.py` -- Visualize the results on *E. coli* biological data.
- `ridgeline.py` -- Analyze the density of inferred full GRN using ridgeline plots.
