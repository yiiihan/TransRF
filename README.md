# TransRF

TransRF is a transfer learning framework based on random forest models <br>
It is based on an ensemble of multiple transfer learning approaches, each covering a particular type of similarity between the source and the target populations.TransRF improve the prediction performance in a target underrepresented population with limited sample size.

## Getting started

`TransRF` requires the following R packages: `randomForest`, `viRandomForests`, `truncnorm`, `dplyr`. Install them by: 

```r
install.packages(c("randomForest`", "truncnorm", "dplyr"), dependencies=TRUE)
```

```r
install.packages("/n/home11/yhan/software/viRandomForests_1.0.tar.gz", repos=NULL, type="source") ```

