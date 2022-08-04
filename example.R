#################################
##### example 1: simulate data 
#################################

source('/yourpath/TransRF/simdata_generating/simdata3.R')

s=15
n.src=1000
p = 20
n.tar = 200
n.test = 100
del=1.5
c=2

dat=simdata3(p,s,n.tar,n.src,n.test,del,c)

dat.tar=dat[[2]]
X=dat.tar[,-1]
y=dat.tar[,1]

dat.src=dat[[1]]
colnames(dat.src)[1]='y.src'
# X.src=dat.src[,-1]
# y.src=dat.src[,1]

dat.test=dat[[3]]
X.test=dat.test[,-1]
y.test=dat.test[,1]

#################################
##### example 2: read data 
#################################

dat.tar=read.table('/yourpath/TransRF/test/data/sim_tar.txt',header=F)
dat.test=read.table('/yourpath/TransRF/test/data/sim_test.txt',header=F)
dat.src=read.table('/yourpath/TransRF/test/data/sim_src.txt',header=F)

X=dat.tar[,-1]
y=dat.tar[,1]

colnames(dat.src)[1]='y.src'

X.test=dat.test[,-1]
y.test=dat.test[,1]

#################################

rf.src = viRandomForests(y.src ~ ., data=dat.src, ntree=500, fprob=NULL, keep.forest=TRUE, importance=TRUE)
S = importancenew(rf.src, type=2) 

source('/yourpath/TransRF/TransRF_tg.R')
ypred = transRF(X, y, X.test, rf.src,S)
get.mse(y.test,ypred$y.transrf)

