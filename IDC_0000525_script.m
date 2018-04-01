clear all; clc; close all;
rng('default');rng(3000); %300

%%%% Load the input data
load('IDC_0000525_alt_count')
load('IDC_0000525_total_count')
  
var_count = IDC_0000525_alt_count;
total_count = IDC_0000525_total_count;

rep = 5; % Number of replicates
alpha = 0.045;
beta = 2;





%%%%% The main function
[Z_est,W_est,p_o_est] = fn_tumor_clones(var_count,total_count,rep, alpha,beta);

 %%%% Estimate of the mutational profiles (matrix Z)
     disp('Estimate of the genotype matrix is:')
     disp(Z_est)
     
 %%%% Estimate of the proportions in the samples (matrix W)
     disp('Estimate of the proportion matrix is:')
     disp(W_est)
     
 %%%% Estimate of p_0
     disp('Estimate of p_o is:')
     disp(p_o_est)
     
   