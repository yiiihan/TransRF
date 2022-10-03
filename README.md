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
dat.tar=read.table('/yourpath/TransRF/test_data/sim_tar.txt',header=F)
dat.test=read.table('/yourpath/TransRF/test_data/sim_test.txt',header=F)
dat.src=read.table('/yourpath/TransRF/test_data/sim_src.txt',header=F)

X=dat.tar[,-1]
y=dat.tar[,1]

colnames(dat.src)[1]='y.src'

X.test=dat.test[,-1]
y.test=dat.test[,1]

rf.src = viRandomForests(y.src ~ ., data=dat.src, ntree=500, fprob=NULL, keep.forest=TRUE, importance=TRUE)
S = importancenew(rf.src, type=2) 

library(viRandomForests)
library(randomForest)
library(pROC)

get.auc = function(y, y.prob){
  pROC::auc(pROC::roc(y, as.numeric(y.prob)))
}

get.mse<- function(y, y.pred){
  mean((y-y.pred)^2)
}


transRF = function(X, y, X.test=NULL, rf.src, S, p.val=0.1){

 ####### If no testing data is availble, split 20% target data for testing
 if(is.null(X.test)){
   sample0 <- sample(c(TRUE, FALSE), nrow(X), replace=TRUE, prob=c(0.8, 0.2))
   X.tar0 <- X[sample0, ]
   X.test <- X[!sample0, ]
   y.tar0 <- y[sample0]
   y.test <- y[!sample0]
 }else{
   X.tar0 = X
   y.tar0 = y
   y.test <- rep(NA, dim(X.test)[1])
 }
 dat.test <- data.frame(y.test=y.test, X.test)

 var_list = attr(rf.src$terms,"term.labels")
 num = length(var_list)

 ###### Spliting p.val% (default 10%) training data fot validation
 sample1 <- sample(c(TRUE, FALSE), nrow(X.tar0), replace=TRUE, prob=c(1-p.val, p.val))
 X.tar <- X.tar0[sample1, ]
 X.val <- X.tar0[!sample1, ]
 y.tar <- y.tar0[sample1]
 y.val <- y.tar0[!sample1]

 dat.tar = data.frame(y.tar=y.tar, X.tar)
 dat.val = data.frame(y.val=y.val, X.val)


 ###### Target-only: fit RandomForest
 colnames(dat.tar)[1]='y.tar'
 rf.m0 <- randomForest::randomForest(y.tar ~ ., data=dat.tar, ntree=500)
 colnames(dat.test)=colnames(dat.tar)
 y.m0.pred = predict(rf.m0, dat.test)

 ###### Source model prediction
 colnames(dat.test)[1:num+1]=var_list
 y.src.pred = predict(rf.src , dat.test)

 ###### Model 1: fit viRandomForest y.tar ~ X.tar with source.score
 rf.m1 <- viRandomForests::viRandomForests(y.tar ~ ., data=dat.tar, ntree=500, fprob=S, keep.forest=TRUE, importance=TRUE)
 colnames(dat.test)=colnames(dat.tar)
 y.m1.pred = predict(rf.m1, dat.test)

 ###### Model 2: fit viRandomForest y.delta ~ X.tar
 colnames(dat.tar)[1:num+1]=var_list
 y.src.hat = predict(rf.src , dat.tar)
 y.delta = y.tar - y.src.hat

 dat.train2 = cbind(y.delta, dat.tar[,-1])
 colnames(dat.train2)[1]='y.delta'
 rf.delta <- viRandomForests::viRandomForests(y.delta ~ ., data=dat.train2, ntree=500, fprob=NULL, keep.forest=TRUE, importance=TRUE)
 colnames(dat.train2)[1:num+1]=var_list
 colnames(dat.test)[1:num+1]=var_list
 y.delta.pred = predict(rf.delta, dat.test)
 y.m2.pred = y.src.pred + y.delta.pred

 ###### Model 3: fit y.tar ~ X.tar + source.pred
 dat.y.src.train = cbind(dat.tar, y.src.hat)
 dat.y.src.test = data.frame(dat.test, y.src.pred)
 colnames(dat.y.src.test) = colnames(dat.y.src.train)
 rf.m3 <- viRandomForests::viRandomForests(y.tar ~ ., data=dat.y.src.train, ntree=500,  fprob=c(rep(1,length(S)),2), keep.forest=TRUE, importance=TRUE)
 y.m3.pred = predict(rf.m3, dat.y.src.test)

 ###### TransRF: emsemble of target-only and Models 1-3
 colnames(dat.val)=colnames(dat.tar)
 y0 = predict(rf.m0, dat.val)
 y1 = predict(rf.m1, dat.val)

 colnames(dat.val)[1:num+1]=var_list
 y2 = predict(rf.delta, dat.val) + predict(rf.src, dat.val)
 y3 = predict(rf.m3, data.frame(dat.val, y.src.hat=predict(rf.src , dat.val)))
 y4 = predict(rf.src , dat.val)

 weight.ensemble = coef(lm(y.val~y0+y1+y2+y3))
 y.transrf = cbind(1,y.m0.pred,y.m1.pred, y.m2.pred, y.m3.pred) %*% weight.ensemble

 output = list(y.transrf = y.transrf, y.test=y.test) #if user provides X.test, then y.test=NULL
 return(output)
}

ypred = transRF(X, y, X.test, rf.src,S)
get.mse(y.test,ypred$y.transrf)
```


