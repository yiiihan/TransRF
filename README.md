# TransRF

TransRF is a transfer learning framework based on random forest models <br>
It is based on an ensemble of multiple transfer learning approaches, each covering a particular type of similarity between the source and the target populations.TransRF improve the prediction performance in a target underrepresented population with limited sample size.

## Dependency

`TransRF` requires the following R packages: `randomForest`, `viRandomForests`, `truncnorm`, `dplyr`. Install them by: 

```r
install.packages(c("randomForest`", "truncnorm", "dplyr"), dependencies=TRUE)
```

R package `viRandomForests` based on the original R package “randomForest” and it can be freely downloaded from http://zhaocenter.org/ software.

```r
install.packages("/path/viRandomForests_1.0.tar.gz", repos=NULL, type="source")
```

## Tutorial

### Example data
- Source data (`sim_src.txt`) <br>
- Target data (`sim_tar.txt`) <br>
- Validation data (`sim_val.txt`) <br>
Note: The phenotype data are in the first column.
- Test data (`sim_test.txt`) <br>
Note: The test data do not contain phenotype data.

### Example code

````{r, engine = 'bash', eval = FALSE}
### Parameters initialization
TransRF=/your/path/TransRF/TransRF.R
mkdir /your/path/TransRF/out
tar=/your/path/TransRF/test_data/sim_tar
src=/your/path/TransRF/test_data/sim_src
val=/your/path/TransRF/test_data/sim_val
test=/your/path/TransRF/test_data/sim_test
outPath=/your/path/TransRF/out

### Run TransRF
Rsricpt ${TransRF}  --tar ${tar}.txt --src ${src}.txt --val ${val}.txt --test ${test}.txt --outPath ${outPath}

````
