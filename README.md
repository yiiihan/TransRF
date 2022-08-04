# TransRF
Transfer learning framework based on random forest models <br>
TransRF is based on an ensemble of multiple transfer learning approaches, each covering a particular type of similarity between the source and the target populations.TransRF improve the prediction performance in a target underrepresented population with limited sample size.

## Getting started

`TransRF` requires the following R packages: `randomForest`, `viRandomForests`, `truncnorm`, `dplyr`. Install them by: 

```r
install.packages(c("randomForest`", "truncnorm", "dplyr"), dependencies=TRUE)
```

R package `viRandomForests` based on the original R package “randomForest” and it can be freely downloaded from http://zhaocenter.org/ software.

```r
install.packages("/path/viRandomForests_1.0.tar.gz", repos=NULL, type="source")
```

