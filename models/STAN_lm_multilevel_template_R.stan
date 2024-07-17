//
// This Stan program defines a linear model of the
// change in CQ slope to percent of the watershed burned relationship.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data are vectors 'region', 'delta', 'delta_sd', and 'B' of length 'N'.

data {
  
  int<lower=0> N; // number of observations
  int<lower=1> R; // total number of regions
  int<lower=1, upper=R> region [N]; // integers denoting regions
  // note, indexing needs to start with 1
  //int Nobs [regions]; // number of observations within each region
  
  // data necessary to fit regression
  vector[N] delta; // observations - mean estimates of change in CQ slopes from posterior probability distributions
  vector[N] delta_sd; // variability of observations - sd estimates of change in CQ slopes from posterior probability distributions
  vector[N] B; // predictor - percent of the watershed burned (%)
  //matrix[N, regions] delta; // observations - mean estimates of change in CQ slopes from posterior probability distributions
  //matrix[N, regions] delta_sd; // variability of observations - sd estimates of change in CQ slopes from posterior probability distributions
  ///matrix[N, regions] B; // predictor - percent of the watershed burned (%)
  
}

// The parameters accepted by the model. Our model
// accepts two parameters 'aregion', the intercept,
// and 'b_Bregion', the slope of the covariate.

// This formulation estimates all parameters at all regions
// as part of one hierarachical model using hyperparameters
// so as to better pool information across sites.

parameters {
  
  // HUC level parameters
  vector[R] b_Bregion; // slope for each region
  vector[R] aregion; // intercept for each region
  
  // regression hyperparameters
  real a; // intercept hyperparameter
  real asigma; // intercept hyperparameter s.d.
  real b_B; // slope hyperparameter for % watershed burned
  real b_Bsigma; // slope s.d. hyperparameter
  
}

// Nothing in the transformed parameters block for now.

transformed parameters{
  
}

// The model to be estimated. We model the output
// 'delta' to be normally distributed with the mean value
// using the linear formula and standard deviation as 'delta_sd'.

model {
  
  // Establish loop framework
  // For each observation j...
  for(j in 1:N){
  
  // Likelihood
  delta[j] ~ normal(aregion[region[j]] + b_Bregion[region[j]]*B[j], delta_sd[j]);
  // delta, B, and delta_sd are at site-level
  
  // regional model priors 
  // involving hyperparameters
  aregion[region[j]] ~ normal(a, asigma); // intercept parameter prior - a is hyperparameter
  b_Bregion[region[j]] ~ normal(b_B, b_Bsigma); // slope parameter prior - b_B is hyperparameter
  
  // hyperparameter priors
  a ~ normal(0,10);
  b_B ~ normal(0,10);
  
  } // closes regions for loop
  
  // remember, script MUST end in a blank line
  
}


