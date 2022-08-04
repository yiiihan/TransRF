library(truncnorm)

m.src <- function(X, beta){
  p = ncol(X)
  X.trans = rep(0, nrow(X))
  for(i in 1:nrow(X)){
    trans = (sqrt(abs(X[i,])) * c(rep(1,p/4), rep(-0.5,p/4), rep(-0.8,p/4), rep(0.5,p/4)))
    X.trans[i] = sum(trans*beta)
  }
  return(X.trans)
}

m.tar <- function(X, beta){
  p = ncol(X)
  X.trans = rep(0, nrow(X))
  for(i in 1:nrow(X)){
    trans = (abs(X[i,])^2 * c(rep(1,p/2), rep(-2,p/2)))
    X.trans[i] = sum(trans*beta)
  }
  return(X.trans)
}


simdata1 <- function(p,j,n.tar,n.src,n.test){
  set.seed(1)
  X.src <- matrix(rtruncnorm(n.src*p, a=-2, b=2, mean = -1, sd = .5),n.src,p)  #continuous X
  X.tar <- matrix(rtruncnorm(n.src*p, a=-2, b=2, mean = 1, sd = .5), n.tar, p)  #continuous X
  X.test <- matrix(rtruncnorm(n.src*p, a=-2, b=2, mean = 1, sd = .5), n.test, p)  #continuous X
 
  ######### generate target beta and target Y
  beta.tar = seq(1,p,1)* (rbinom(p, 1, 0.5) - 0.5)*2
  y.tar = m.tar(X.tar, beta.tar) + rnorm(n.tar, 0, .5)
  y.test = m.tar(X.test, beta.tar) + rnorm(n.test, 0, .5)

  ## center target Y
  y.tar = y.tar - mean(y.tar)
  y.test = y.test - mean(y.test)

  dat.tar = data.frame(y.tar, X.tar)
  dat.test = data.frame(y.test, X.test)
 
  #####generate source beta
  ### swap the 1st & the j-th term 
  beta.src = beta.tar
  beta1 = beta.tar[1]
  beta.p = beta.tar[j]
  beta.src[1] = beta.p
  beta.src[j] = beta1
  beta.src = -beta.src
  
  ##generate outcome Y for source
  y.src = m.src(X.src, beta.src) + rnorm(n.src, 0, .5)
  y.src = y.src - mean(y.src)
  dat.src = data.frame(y.src, X.src)
  
  dat=list(dat.src,dat.tar,dat.test)
  
  return(dat)
}

# dat=simdata1(p,j,n.tar,n.src,n.test)
