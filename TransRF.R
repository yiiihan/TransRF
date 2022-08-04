library(dplyr)
library(viRandomForests)
library(randomForest)
library(truncnorm)

args_list <- list(
  make_option("--tar", type = "character", default = NULL,
              help = "INPUT: the path of target data", metavar = "character"),
  make_option("--src", type = "character", default = NULL,
              help = "INPUT: the path of source data", metavar = "character"),
  make_option("--val", type = "character", default = NULL,
              help = "INPUT: the path of validation data", metavar = "character"),
  make_option("--test", type = "character", default = NULL,
              help = "INPUT: the path of test data", metavar = "character"),
  make_option("--outPath", type="character", default=NULL,
              help="INPUT: the output path", metavar="character"),
)

opt_parser <- OptionParser(option_list=args_list)
opt <- parse_args(opt_parser)

#############################################
###### Check the options
#############################################
if (!file.exists(opt$tar)){
  cat(paste0("ERROR: ", opt$target, " does not exist! Please check!\n"))
  q()
}
if (!file.exists(opt$src)){
  cat(paste0("ERROR: ", opt$target, " does not exist! Please check!\n"))
  q()
}
if (!file.exists(opt$val)){
  cat(paste0("ERROR: ", opt$target, " does not exist! Please check!\n"))
  q()
}
if (!file.exists(opt$test)){
  cat(paste0("ERROR: ", opt$test, " does not exist! Please check!\n"))
  q()
}
if (!file.exists(opt$outPath)){
  cat(paste0("ERROR: ", opt$outPath, " does not exist! Please check!\n"))
  q()
}
start <- proc.time()


#############################################
###### Get the options
#############################################
path.out <- opt$outPath

dat.src <- read.table(opt$src,header=F)
dat.tar <- read.table(opt$tar,header=F)
dat.val <- read.table(opt$val,header=F)
X.test <- read.table(opt$test,header=F)

X.src <- dat.src[,-1]
X.tar <- dat.tar[,-1]
X.val <- dat.val[,-1]

y.src <- dat.src[,1]
y.tar <- dat.tar[,1]
y.val <- dat.val[,1]

y.test <- rep(0, dim(X.test)[1])
dat.test <- data.frame(y.test, X.test)
colnames(dat.test)=colnames(dat.src)
#############################################
###### Target only: fit RandomForest
#############################################
rf.tar1 <- randomForest(y.tar ~ ., data=dat.tar, ntree=500)
y.tar1.pred = predict(rf.tar1, dat.test)
# MSE.tar1 = mean((predict(rf.tar1, dat.test) - y.test)^2)

#######################
###### Fit source model
#######################
# dat.src = data.frame(y.src, X.src)
rf.src = viRandomForests(y.src ~ ., data=dat.src, ntree=500, fprob=NULL, keep.forest=TRUE, importance=TRUE)
i.src = importancenew(rf.src, type=2) #importance feature of source tree
y.src.pred = predict(rf.src, dat.test, type = "response")
# MSE.src = mean((predict(rf.src, dat.test, type = "response") - y.test)^2)

####################################################################
###### Method 1: fit viRandomForest y.tar ~ X.tar with source.score
####################################################################
rf.tl1 <- viRandomForests(y.tar ~ ., data=dat.tar, ntree=500, fprob=i.src, keep.forest=TRUE, importance=TRUE)
y.tl1.pred = predict(rf.tl1, dat.test)
# MSE.tl1 = mean((y.tl1.pred - y.test)^2)

#################################################################
###### Method 2: fit viRandomForest y.delta ~ X.tar with source.score
#################################################################
y.src.hat = predict(rf.src, dat.tar, type = "response")
y.delta = y.tar - y.src.hat
y.src.hat.test = predict(rf.src, dat.test, type = "response")
# y.delta.test = y.test - y.src.hat.test

dat.train2 = cbind(y.delta, dat.tar[,-1])
# dat.test2 = cbind(y.delta.test, dat.test[,-1])

rf.delta <- viRandomForests(y.delta ~ ., data=dat.train2, ntree=500, fprob=NULL, keep.forest=TRUE, importance=TRUE)
# y.delta.rf = predict(rf.delta, dat.test2, type = "response")
y.delta.rf = predict(rf.delta, dat.test, type = "response")
y.tl2.pred = y.src.hat.test + y.delta.rf
# MSE.tl2 = mean((y.tl2.pred - y.test)^2)

##############################################################
###### Method 3: target-only + source-only column: fit y.tar ~ X.tar + source
##############################################################
dat.y.src.train = cbind(dat.tar, y.src.hat)
dat.y.src.test = data.frame(dat.test, y.src.hat.test)
colnames(dat.y.src.test) = colnames(dat.y.src.train)

rf.tar.src <- viRandomForests(y.tar ~ ., data=dat.y.src.train, ntree=500,  fprob=c(rep(1,length(i.src)),2), keep.forest=TRUE, importance=TRUE)
y.tl3.pred = predict(rf.tar.src, dat.y.src.test, type = "response")
# MSE.tl3 = mean((y.tl3.pred - y.test)^2)

##################################
###### TransRF
##################################
y0 = predict(rf.tar1, dat.val) #target-only
y1 = predict(rf.tl1, dat.val)
y2 = predict(rf.delta, dat.val) + predict(rf.src, dat.val)
y3 = predict(rf.tar.src, data.frame(dat.val, y.src.hat=predict(rf.src, dat.val)))
y4 = predict(rf.src, dat.val) #source-only
MSE.tar.val = mean((y0 - y.val)^2)
MSE.src.val = mean((y4 - y.val)^2)

weight.ensemble = coef(lm(y.val~y0+y1+y2+y3))
y.ensemble = cbind(1,y.tar1.pred,y.tl1.pred, y.tl2.pred, y.tl3.pred) %*% weight.ensemble
# MSE.ensemble = mean((y.ensemble - y.test)^2)

#######################################
## weighted target-only & source-only
#######################################
weight = matrix(c(MSE.src.val/(MSE.tar.val+MSE.src.val), MSE.tar.val/(MSE.tar.val+MSE.src.val)), 2, 1)
y.tar.src.w = cbind(y.tar1.pred, y.src.hat.test) %*% weight
# MSE.tar.src.w = mean((y.tar.src.w - y.test)^2)

#######################################
## Output
#######################################
out = data.frame (targetOnly = y.tar1.pred,
              sourceOnly = y.src.pred,
              weight = y.tar.src.w,
              model1 = y.tl1.pred,
              model2 = y.tl2.pred,
              model3 = y.tl3.pred,
              transRF = y.ensemble)

write.table(out, file=paste0(path.out,'outResult_TransRF.txt'),row.names = F,col.names = T,quote=F)
