function [Z_est,W_est,p_o_est] = fn_tumor_clones( var_count, total_count, rep, alpha, beta)




Data = repmat(var_count,rep,1);
N_st_Matrix = repmat(total_count,rep,1);


S = size(Data,1);
T = size(Data,2);
%%%%% initialization

        % alpha of IBP
          %alpha = 0.045;  %1
          betas = [beta beta];

        % number of particles
          N = 500; %500
        
        % Initialize p_o
          a_00 = 1; % 1
          b_00 = 100; % 100
          p_o_particles = betarnd(a_00,b_00,[1,N]);
          
          
        % Initialize theta_ot, t = 1,...,T
          a_0 = 0.1; %0.
          b_general = 1;
          theta_o_particles = gamrnd(a_0,b_general,[T,N]);
          
        % parameters of theta_ct
          a = 0.2; %6
          
        % Initialize matrix Z, t = 1,...,T
          Z_init = zeros(1,5,N);
        
        para_frac = 0.00001; %0.01
          
for s = 1:S
    s
    Data_s = Data(s,:);
    N_st_s = N_st_Matrix(s,:);
    
   
    
    if s == 1
    
    
         %PROB = zeros(1,N);
         
            for n = 1:N

                Z_lana_n = Z_init(:,:,n);

                Z_loni_n = fn_trinary_cIBP_Tran(Z_lana_n,alpha,betas,s);
                
                Z_loni{n} = Z_loni_n;
     
                %%% Get the number of columns of Z, then get the number of rows of theta matrix and sample them 
                
                 C_here_n = size(Z_loni_n,2);

                 no_theta_n = C_here_n*T;
                 theta_ct_n = gamrnd(a,b_general,[no_theta_n,1]);
                 
                 %%% let the sampled parameters pass through state equation
                 
                 theta_ct_n = normrnd(theta_ct_n,para_frac*theta_ct_n);
                 
                 theta_ct_ALL{n} = theta_ct_n;  %%% all theta_ct
                 
                 
                 p_o_particles(n) = normrnd(p_o_particles(n),para_frac*p_o_particles(n));
                   po_n = p_o_particles(n);
                   
                   theta_o_particles(:,n) = normrnd(theta_o_particles(:,n),para_frac*theta_o_particles(:,n));
                   theta_o_n_all_T = theta_o_particles(:,n);
                     
                   
                   %%% Calculate the weight for particle n
                   
                    prob_n = zeros(1,T);
                    
                       for t = 1:T
                           n_st = Data_s(t); N_st = N_st_s(t);
                           
                           theta_o_t = theta_o_n_all_T(t);
                           
                         %%% take out the theta_ct
                           bee = (t-1)*C_here_n + 1;  
                           eed = t*C_here_n; 
                           theta_ct = theta_ct_n(bee:eed);
                           
                           all_theta = [theta_o_t; theta_ct]; %column vector
                           w_ct = all_theta/sum(all_theta);    %column vector
                           
                           po_and_z = [po_n Z_loni_n(s,:)]; % row vector
                           
                           p_st = po_and_z*w_ct;
                           
                           prob_n(t) = binopdf(n_st,N_st,p_st);
                            
                       end
                       
                       prob_n;
                       
%                           inter1 = sum(log(prob_n));
%                           PROB(n) = exp(vpa(inter1));

                         
                          inter1 = vpa(sum(log(prob_n)));
                          inter2 = vpa(exp(inter1));
                          PROB(n) = inter2;

                          
                  
            end
            
            %%% normalize weights
            
                 wt = PROB/sum(PROB); clear PROB;
                 wt = double(wt);
            
            %%% resample  %%% rr = randsample([1:N],N,true,wt), new = old{rr}
            
                 rr = randsample([1:N],N,true,wt);
                 
                 p_o_particles = p_o_particles(rr);
                 theta_o_particles = theta_o_particles(:,rr);
                 
                 Z_loni = Z_loni(rr);
                 theta_ct_ALL = theta_ct_ALL(rr);
                 
%                  for m = 1:N
%                      theta_ct_ALL{m} = theta_ct_ALL{rr(m)};
%                      Z_loni{m} = Z_loni{rr(m)};   
%                  end
                 
                 
                 
                 
      
    else  %%%%% other time steps
        
        Z_lana = Z_loni;
           
         %PROB = zeros(1,N);
         
            for n = 1:N

                Z_lana_n = Z_lana{n};

                Z_loni_n = fn_trinary_cIBP_Tran(Z_lana_n,alpha,betas,s);
                
                Z_loni{n} = Z_loni_n;
     
                
                %%% see if a new column is created for the new and then sample W matrix to compliment this 
                
                 C_lana = size(Z_lana_n,2);
                 C_loni = size(Z_loni_n,2);
                 diff = C_loni - C_lana;
                 
                 
                 
                %%% Calculate the weight for particle n
                  
                   p_o_particles(n) = normrnd(p_o_particles(n),para_frac*p_o_particles(n));
                   po_n = p_o_particles(n);
                   
                   theta_o_particles(:,n) = normrnd(theta_o_particles(:,n),para_frac*theta_o_particles(:,n));
                   theta_o_n_all_T = theta_o_particles(:,n);
                     
                  
                   theta_ct_ALL{n} = normrnd(theta_ct_ALL{n},para_frac*theta_ct_ALL{n});
                   theta_ct_n = theta_ct_ALL{n};  %%% all theta_ct
                   
                   
                   
                  if diff == 0  %%% new column(s) of Z is/are not created.
                   
                            prob_n = zeros(1,T);
                               for t = 1:T
                                   
                                   n_st = Data_s(t);
                                   N_st = N_st_s(t);

                                   theta_o_t = theta_o_n_all_T(t);

                                 %%% take out the theta_ct

                                   

                                       bee = (t-1)*C_lana + 1;  
                                       eed = t*C_lana; 
                                       theta_ct = theta_ct_n(bee:eed);
                                       all_theta = [theta_o_t; theta_ct]; %column vector

                                       w_ct = all_theta/sum(all_theta);    %column vector

                                       po_and_z = [po_n Z_loni_n(s,:)]; % row vector

                                       p_st = po_and_z*w_ct;

                                       prob_n(t) = binopdf(n_st,N_st,p_st);

                               end
                       
                  else
                      
                      
                                 prob_n = zeros(1,T);
                                 
                                 theta_ct_new_matrix = zeros(C_loni,T);
                                 
                               for t = 1:T
                                   n_st = Data_s(t); N_st = N_st_s(t);

                                   theta_o_t = theta_o_n_all_T(t);

                                 %%% take out the theta_ct

                                       bee = (t-1)*C_lana + 1;  
                                       eed = t*C_lana; 
                                       theta_ct = theta_ct_n(bee:eed);
                                  
                                       theta_ct_loni = [theta_ct_n(bee:eed); gamrnd(a,b_general,[diff,1])];
                                       theta_ct_new_matrix(:,t) = theta_ct_loni;
                                       
                                       all_theta = [theta_o_t; theta_ct_loni]; %column vector
                                   

                                       w_ct = all_theta/sum(all_theta);    %column vector

                                       po_and_z = [po_n Z_loni_n(s,:)]; % row vector

                                       p_st = po_and_z*w_ct;

                                       prob_n(t) = binopdf(n_st,N_st,p_st);

                               end
                       
                                       theta_ct_ALL{n} = theta_ct_new_matrix(:);
                           
                  end
                  
%                                         inter2 = sum(log(prob_n));
%                                         PROB(n) = exp(vpa(inter2));
                                        
                                        inter3 = vpa(sum(log(prob_n)));
                                        inter4 = vpa(exp(inter3));
                                        PROB(n) = inter4;
                                        
                  
            end
            
            
            
            
            %%% normalize weights
            
                 wt = PROB/sum(PROB); clear PROB;
                 wt = double(wt);
                 
            
            %%% resample  %%% rr = randsample([1:N],N,true,wt), new = old{rr}
            
                 rr = randsample([1:N],N,true,wt);
                 
                 p_o_particles = p_o_particles(rr);
                 theta_o_particles = theta_o_particles(:,rr);
                 
                 theta_ct_ALL = theta_ct_ALL(rr);
                 Z_loni = Z_loni(rr);   
                 
                 
%                  for m = 1:N
%                      theta_ct_ALL{m} = theta_ct_ALL{rr(m)};
%                      Z_loni{m} = Z_loni{rr(m)};   
%                  end
                 
        
    end
       
       
       
end
          
   

wt = (1/N)*ones(1,N);

S_orig = S/rep;
for n = 1:N
Z_loni_now{n} = Z_loni{1}(S - S_orig + 1:S,:);
end




%%%%%%%  POINT ESTIMATES %%%%%%%%%%
   
    
 %%%%% determine point estimate of C...i.e C_est
 
        ALL_C = zeros(1,N);
        for n = 1:N
            ALL_C(n) = size(Z_loni_now{n},2); 
        end
        
      % ALL_C
        
       unique_C = unique(ALL_C);
       
       prob_C = zeros(1,length(unique_C));
       len_Cs = zeros(1,length(unique_C));
       for c = 1:length(unique_C);
           
           prr = unique_C(c);
           ind_c = find(ALL_C == prr);
           prob_C(c) = length(ind_c)/N;
           len_Cs(c) = length(ind_c);
       end
 
       [vaa, indd] = max(len_Cs);
       C_est = unique_C(indd);
       
       
       %%%% Plot of C
             
             uppe = max(unique_C) + 1;
             lowe = min(unique_C) - 1;
             
             x_min = 0;
             x_max = uppe + 5;
             
             pre_x = 0:lowe;
             post_x = uppe:x_max;
             xx = [pre_x unique_C post_x]; 
             yy = [zeros(1,lowe+1) prob_C zeros(1,x_max-max(unique_C))]; 
             
%        figure;
%             plot(xx,yy)
%             xlabel('C')
%             ylabel('P(C|Y)')
%             xlim([x_min x_max])
%             ylim([0 1])
%             %vline(C_est);
%             h = vline(C_est,'g','The Answer');
     
 %%%%% pick out all particles (Z,W,p) that belong to this C-star
     ind_C_est = find(ALL_C == C_est);
     
    picked_Z_loni = Z_loni_now(ind_C_est);
    picked_p_o_particles = p_o_particles(ind_C_est); 
    picked_theta_o_particles = theta_o_particles(:,ind_C_est);
    picked_theta_ct_ALL = theta_ct_ALL(ind_C_est);
    picked_wt = wt(ind_C_est);  
    indx = 2;
    
     %%%% point estimate of Z
     Z_est = picked_Z_loni{indx};
     
     
     
     
     %%%% point estimate of p_0
     p_o_est = picked_p_o_particles(indx);
     
     
     %%%% point estimate of W
     
     theta_o_est = picked_theta_o_particles(:,indx);
     theta_ct_ALL_est = picked_theta_ct_ALL{indx};
     
     olu = vec2mat(theta_ct_ALL_est,C_est)';
     ade = [theta_o_est'; olu]; 
     sum_ade = sum(ade);
     W_est = ade./repmat(sum_ade,C_est+1,1);
     


end

