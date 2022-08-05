# TransRF

TransRF is a transfer learning framework based on random forest models <br>
It is based on an ensemble of multiple transfer learning approaches, each covering a particular type of similarity between the source and the target populations.TransRF improve the prediction performance in a target underrepresented population with limited sample size.

## Dependency

`TransRF` requires the following R packages: `randomForest`, `viRandomForests`. Install `randomForest` by: 

```r
install.packages(c("randomForest"), dependencies=TRUE)
```

R package `viRandomForests` based on the original R package “randomForest” and it can be freely downloaded from http://zhaocenter.org/ software.

```r
install.packages("/path/viRandomForests_1.0.tar.gz", repos=NULL, type="source")
```

## Using TransRF

```r
source('/yourpath/TransRF/TransRF.R') 
ypred = (X, y, X.test=NULL, rf.src, S, p.val=0.1)
```
 - X (required): Variables from the target. The variables need to be completely the same set and in the same order as variables used in the source model.

 - y (required): Response from the target.

 - X.test (optional): If no testing data is availble, automatically split 20\% target data for testing.
 
 - rf.src (required): Random forest model from the source. 

 - S (required): Feature importance score from the source model. 
 
 - p.val (optional): The percent of spliting training data for validatio.  The default value is 10\%. 


## Output

TransRF outputs predicted y for each samples and y.test. If user provides X.test, then y.test=NULL.


### Example data
Example data are in the `test_data` folder and simulated from simulation scenario 3. <br>
- Source data (`sim_src.txt`) <br>
- Target data (`sim_tar.txt`) <br>
- Test data (`sim_test.txt`) <br>
Note: The phenotype data are in the first column.

An example to use the test data:

```r
dat.tar=read.table('/yourpath/TransRF/test/data/sim_tar.txt',header=F)
dat.test=read.table('/yourpath/TransRF/test/data/sim_test.txt',header=F)
dat.src=read.table('/yourpath/TransRF/test/data/sim_src.txt',header=F)

X=dat.tar[,-1]
y=dat.tar[,1]

colnames(dat.src)[1]='y.src'

X.test=dat.test[,-1]
y.test=dat.test[,1]

rf.src = viRandomForests(y.src ~ ., data=dat.src, ntree=500, fprob=NULL, keep.forest=TRUE, importance=TRUE)
S = importancenew(rf.src, type=2) 

source('/yourpath/TransRF/TransRF.R')
ypred = transRF(X, y, X.test, rf.src,S)
get.mse(y.test,ypred$y.transrf)
```


