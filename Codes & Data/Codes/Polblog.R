rm(list=ls())
setwd('C:/Users/Namjoon Suh/Desktop/Stat+PDE/Citation-Network/Codes & Data/Codes')
source('ADMM_Optim.R') # Need to set r = 4 
source('functions.R')
library("igraph"); library("CINNA");

CV <- function(X,gamma,delta,K){
  rate <- 0;
  for(j in 1:K){
    X_fit = X; count = 0;
    n = nrow(X); I_1 = sample(1:n, floor(n/2)); I_2 = setdiff(1:n,I_1);
    M = expand.grid(I_2,I_2);
    for(i in 1:length(I_2)^2){ X_fit[M[i,1],M[i,2]]=0 }
    res = ADMM(X_fit,gamma,delta)
    alpha = res[[1]]; L = res[[3]]; S = res[[4]];
    X_new = CrtData(alpha,L,S,n)[[1]];
    
    for(l in 1:length(I_2)^2){ 
      if(X[M[l,1],M[l,2]]!=X_new[M[l,1],M[l,2]])
        count <- count + 1;
    }
    rate <- rate + (count/length(I_2)^2)/K;
  }
  return(rate)
}
CrtData <- function(alpha,L,S,N){
  # Create empty matrix for storing adjacency matrix X and Probability for 
  X <- matrix(0,N,N); 
  P <- matrix(0,N,N);
  P <- exp(alpha+L+S)/(1+exp(alpha+L+S));
  
  # Create random graph according to (a, L, S)
  for(i in 1:(N-1)){
    for(j in (i+1):N){
      if(P[i,j]>runif(1,0,1))
        X[i,j]<-1
    }
  }
  X <- X + t(X)
  result <- list(X,P)
  return(result)
}

pol = as.matrix(read.table("polblogsgiant.txt"));
y = read.table("polblogsgianty.txt")
gamma = seq(from=0.00061,to=0.0007,by=0.00001);
delta = seq(from=0.00651,to=0.0075,by=0.0001);
Res_pol <- Model_Sel(pol,gamma,delta);
save(Res_pol, file = "PolBlog_result.RData")
load("PolBlog_result.RData")

# Run CV
count <- 1;
MisCl_rate_pol <- matrix(rep(0,length(gamma)^2),nrow=length(gamma),ncol=length(delta));
for(i in 3:10){
  for(j in 2:8){
    MisCl_rate_pol[i,j] <- CV(pol,gamma[i],delta[j],10)    
    print(count)
    count <- count + 1;
  }
}
save(MisCl_rate_pol, file = "MisCl_rate_pol_result.RData")

 