clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('TEST_features_stimuliAndQueries_Nexcerpt-by-Nfeat.mat')
load('featureVectors_normalized_allSpecies_Nexcerpt-by-Nfeature.mat')
Nspec=10;


Nexcerpt=length(fv_e_n);
Nquery=100;
Ntop=5;
inTop=zeros(Nquery,1);
clear d sum_rr 
for nq=1:Nquery
    q=fv_q(nq,:); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% fv_q, not s
    %q=fv_e_n(nq,:);
    nspec=specLabels(nq);
    
    for nexcerpt=1:Nexcerpt
        s=fv_e_n(nexcerpt,:);
        d(nexcerpt)=nansum(abs(q-s));
    end
    
    [~,i_sort]=sort(d);
    top=spec_allspec(i_sort(1:Ntop));

    ranks = find(top==nspec);
    if ~isempty(ranks),
        inTop(nq)=1;
        ranks_recip=ones(size(ranks))/ranks;
        sum_rr(nq)=sum(ranks_recip);
    end
    
end
freqInTop=mean(inTop)
meanRR=mean(sum_rr)


% c=0;
% for nspec=1:Nspec
%     for nrec=1:Nrec
%         c=c+1;
%         specLabels(c)=nspec;
%         
%         % CALCULATE FEATURE VECTORS
%         fv_q(c,:) = ft_normalizeFeatures( ft_allFeatures(pc_q{nspec,nrec}));
%         fv_s(c,:) = ft_normalizeFeatures( ft_allFeatures(pc_s{nspec,nrec}));
%         
%         
%     end
% end
% 
% save('TEST_features_stimuliAndQueries_Nexcerpt-by-Nfeat.mat','fv_q','fv_s','specLabels')
% clear nspec nrec
%%
% load('featureVectors_normalized_allSpecies_Nexcerpt-by-Nfeature.mat')
% %%
% Nq=100;
% Ne=length(fv_e_n);
% d=zeros(100,1);
% sum_rr = zeros(100,1);
%%

    


% clc,clear dist
% Nrec=10;
% for nspec_q=10%:Nspec
%     for nrec_q=5%:Nrec
%         q=fv_s{nspec_q,nrec_q};
%         
% 
%         for nspec_s=1:Nspec
%             for nrec_s=1:Nrec
%                 s=fv_s{nspec_s,nrec_s};
%                 dist(nspec_s,nrec_s)=nansum(abs(q-s));
%                 imagesc(dist),title(nspec_q)
%                 ylabel('species'),xlabel('recording')
%                 %pause
%             end
%         end
%         
%     end
% end
