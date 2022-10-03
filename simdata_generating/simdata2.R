m.src <- function(X){
  p = ncol(X)
  X.trans = rep(0, nrow(X))
  id = rep(0, nrow(X))
  threshold = sum(X)/nrow(X)
  for(i in 1:nrow(X)){
    X.trans[i] = sum(X[i,] * c(rep(1,p/2), rep(-0.5,p/2))*(1-0.5*as.numeric(sum(X[i,])>threshold)))
  }
  return(X.trans)
}

delta <- function(X, del, s){
  if(s==5){
    thres = c(-.5, 0, 0, .3, .7)
  }else if(s==10){
    thres = c(-.5, -.5, 0, 0, 0, 0, .3, .3, .7, .7)
  }else if(s==15){
    thres = c(rep(-.5,4), rep(0,4), rep(.3,4), rep(.7,3))
  }
  
  d = rep(0, nrow(X))
  X.sub = X[,1:s]
  for(i in 1:nrow(X.sub)){
    for(j in 1:ncol(X.sub)){
      if(X[i,j] >= thres[j]){
        d[i] = d[i] + del
      }
    }
  }
  return(d)
}

simdata2 <- function(p,s,n.tar,n.src,n.test,del){
  
  X.src <- matrix(runif(n.src*p, -1, 1), n.src, p)  #continuous X
  X.tar <- matrix(runif(n.tar*p, -1, 1), n.tar, p)  #continuous X
  X.test <- matrix(runif(n.test*p, -1, 1), n.test, p)  #continuous X

  X.src[,1:s] = matrix(rbinom(n.src*s, 1, 0.5), n.src, s) #binary X
  X.tar[,1:s] = matrix(rbinom(n.tar*s, 1, 0.5), n.tar, s) #binary X
  X.test[,1:s] = matrix(rbinom(n.test*s, 1, 0.5), n.test, s) #binary X

  ##generate outcome Y
  y.src = m.src(X.src) + rnorm(n.src, 0, 1)
  y.tar = m.src(X.tar) + delta(X.tar, del, s) + rnorm(n.tar, 0,1)
  y.test = m.src(X.test) + delta(X.test, del, s) + rnorm(n.test, 0,1)
 
  y.src = y.src - mean(y.src)
  y.tar = y.tar - mean(y.tar)
  y.test = y.test - mean(y.test)

  dat.tar = data.frame(y.tar, X.tar)
  dat.src = data.frame(y.src, X.src)
  dat.test = data.frame(y.test, X.test)

  dat=list(dat.src,dat.tar,dat.test)
  
  return(dat)
}

# dat=simdata2(p,s,n.tar,n.src,n.test,del)
