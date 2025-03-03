# BiGSM: Bayesian Inference of Gene Regulatory Network via Sparse Modelling

This is the code for BiGSM: Bayesian Inference of Gene Regulatory Network via Sparse Modelling. This repo includes algorithm implementation, experiments, results analysis and visualization, and datasets.

## Authors
Hang Qin (hangq@kth.se), Mateusz Garbulowski, Erik L.L. Sonnhammer, Saikat Chatterjee.

## Dependencies
- The main experiments are implemented in MATLAB based on GeneSPDIER: https://bitbucket.org/sonnhammergrni/genespider/src/master/

- A small part of visualizations is implemented in Python (>= 3.7.0) with the following packages:
    - numpy (1.21.6)
    - pandas (1.3.5 )
    - seaborn (0.12.2)
    - matplotlib (3.5.1)
    - joypy (0.2.6)

## Datasets
The experiments were carried out using the following datasets. 
- GeneSPIDER simualtion dataset. ([GeneSPIDER](https://bitbucket.org/sonnhammergrni/genespider/src/master/))
- DREAM collection (DREAM3, DREAM4, DERAM5) ([DREAM challenges](https://gnw.sourceforge.net/dreamchallenge.html))
- GRNbenchmark dataset ([grnbenchmark](https://grnbenchmark.org/))

## Code organization
### BiGSM_matlab
The MatLab project includes the following parts.
- Algorithm implementation of BiGSM
- Benchmark experiments
- Runtime analysis of BiGSM
- Visualization of the results on GeneSPIDER, DREAM collection.

Details of the code structure:
````
- bigsm.m (Function of the implementation of the BiGSM algorithm)
- run_bigsm.m  (An example of how to run BiGSM using the GeneSPIDER toolbox)

- benchmark_test.m (Execute benchmark tests using the GeneSPIDER toolbox)
- genBenchamrk.m (Run benchmark test on datasets from GRNbenchmark.org)
- test_dream3.m (Run benchmark test with DREAM3 dataset)
- test_dream4.m (Run benchmark test with DREAM4 dataset)
- test_dream5.m (Run benchmark test with DREAM5 dataset)
- test_ecoli.m (Run benchmark tests with biological E. coli data)

- test_runtime.m (Evaluate the runtime of BiGSM algorithm)

- find_index.m (Util function used in loading DREAM3 dataset)
- manual_test.m (Util function for generating estimated GRN in a range of sparsities)

- visualize_dream34.m (Visualize the benchark results on DREAM3 or DREAM4 dataset)
- visualize_dream5.m (Visualize the benchark results on DREAM5 dataset)
- visualize_gs.m (Visualize the benchamrk results on GeneSPIDER dataset)

- benchmark_result_no_selfloop/ (Contains benchamrk results on GeneSPIDER dataset without self-loops)
- benchmark_result_selfloop/ (Contains benchamrk results on GeneSPIDER dataset with self-loops)

- DREAM3/ (Contains DREAM3 dataset)
- DREAM3_results/ (Contains benchamrk results on DREAM3 dataset)

- DREAM4 gold standards (Contains DREAM4 gold standards)
- DREAM4 training data (Contains DREAM4 data for running inference)
- DREAM4_result/ (Contains benchamrk results on DREAM4 dataset)

- DREAM5/ (Contains DREAM5 dataset)
- DREAM5_result/ (Contains benchamrk results on DREAM5 dataset)

- grnbenchmark_data/ (Contain dataset from grnbenchmark.org)
- grnbenchmark_results/ (Contain benchamrk results on grnbenchmark dataset)
````

After each benchmark test, save the result in `.mat` files. The results in `.mat` format will be analyzed using Python code.

### analysis_python
The following analyses and visualizations are implemented based on Python due to its flexibility and broader library support
- Visualization of the results on GRNbenchmark and E.coli dataset.
- Visualization of the inferred posterior distributions from BiGSM and compare the point-estimates to the true GRN.
- Density visualization and analysis of inferred full GRN.

Details of the code structure:
````
- ridgeline.py (Density visualization and analysis of inferred full GRN using ridgeline plots)
- rank_grnbenchmark.py (Visualization of the benchmark results on GRNbenchmark)

- plot_posterior/ (Contrain files and code for visualization of the inferred posterior distributions)
| - A.mat (True GRN genereated from GeneSPIDER)
| - A_est_bigsm.mat (Full inferred GRN matrix from BiGSM, also the mean matrix of inferred posterior distributions)
| - alpha.mat (Inferred precision matrix of the posterior distributions)
| - plot_posterior.py (Visualization of the inferred posterior distributions)

- plot_ecoli/ (Contain code for visualization of the benchmark result with E.coli data)
| - real_ecoli.mat (Benchmark result with E.coli data)
| - plot_ecoli.py (Visualization of the result with E.coli data)

- grn_benchmark_results/ (Contain benchamrk result with GRNbenchmark data)
- full_grn_s5/ (Contain a true GRN with sparsity as 5 links per node on average and the estimated GRN from different methods)
````

## Run experiments 
### 1. Install GeneSPIDER
- After downloading the `BiGSM_matlab` folder, install [GeneSPIDER](https://bitbucket.org/sonnhammergrni/genespider/src/master/) and put the GeneSPIDER under the project root fold or anywhere you prefer.
- Modify the line "addpath(genpath('../grn/genespider'));" to the path where you put the GeneSPIDER downloaded, or simply add GeneSPIDER to Path (selected folder and subfolders).

### 2. Run inference or benchmark test
- Example of running BiGSM with GeneSPIDER,
    - Run `run_bigsm.m` that calls function `bigsm.m`, it will run GRN inference with the true GRN and gene expression simulated by GeneSPIDER
    - Note that BiGSM itself does not depend on GeneSPIDER, but the example `run_bigsm.m` uses GeneSPIDER to simualte data for the inference task
- To run benchamrk test with different dataset,
    - GeneSPIDER data: run `benchmark_test.m`, save the structure files `test_result` and `test_result_noselfloop` under the `benchmark_result_selfloop/`
     and `benchmark_result_no_selfloop/` folders respectively. Then run `visualize_gs.m` to show the results in box charts. 
    - DREAM collection data: run `test_dream3.m`, `test_dream4.m`, and `test_dream5.m` respectively, and save the structure files `test_result` under the 
    folder `DREAM3_results/`, `DREAM4_result/`, and `DREAM5_result/` respectively. Then run `visualize_dream34.m` and `visualize_dream5.m` to show
     the results. 
    - GRNbenchmark data: go to https://grnbenchmark.org, download the benchmark data and place the data under `grnbenchmark_data/`. Run `genBenchamrk.m`, it
     will save the result to `grnbenchmark_results/`. To use GRNbenchmark online benchamrk tool, upload the result in a zip file to https://grnbenchmark.org. 
    - E.coli biological data: run `test_ecoli.m`, save the structure file `test_result` as `.mat` file and copy it to the `plot_ecoli/` folder in
     the `analysis_python` project
- To have more analysis with Python
    - Download `analysis_python` folder and install required dependencies
    - Run `ridgeline.py` to perform density analysis
    - Run `rank_grnbenchmark.py` to generate the rank plot of benchamrk result on grnbenchmark
    - Run `plot_ecoli.py` to show the result on e.coli data
    - Gather the GRN matrix (A), inferred GRN matrix by BiGSM (A_est_bigsm) and inferred precision matrix (alpha_all) by running `run_bigsm.m` and `bigsm.m`, 
    save them as `A.mat`, `A_est_bigsm.mat` and `alpha.mat` under `plot_posterior/` folder. Then run `plot_posterior.py` to visualize the inferred posterior 
    distributions and the inferred GRN matrix. 