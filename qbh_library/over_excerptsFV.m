function [fv_e,info_e] = over_excerptsFV(list_excerpts,par,saveOn)

if nargin<3, saveOn=0; end

centsPerOctave = 1200;
Nspec = length(list_excerpts);
Nfeat = 43;
fv_e = [];

for nspec = 1:Nspec
    disp('--------------------------------------------')
    load(list_excerpts(nspec).name)
    toDelete = [];
    Nexcerpt = length(excerpts);
    %Nexcerpt = 2;
    FV_spec = zeros(Nfeat, Nexcerpt);
    for nexcerpt = 1:Nexcerpt
        fprintf('spec %d, excerpt %d / %d \n',nspec,nexcerpt,Nexcerpt)
        a = excerpts(nexcerpt).audio;
        pc = yb_yinbird(a,par) * centsPerOctave;
        if sum(~isnan(pc)) > 0
            FV_ind = ft_allFeatures(pc,par);
        else toDelete = [toDelete nexcerpt];
        end
        FV_spec(:,nexcerpt) = FV_ind;
        excerpts(nexcerpt).pitchCurve = pc;
        excerpts(nexcerpt).featureVector = FV_ind;       
    end
    excerpts(toDelete) = [];
    FV_spec(:,toDelete)=[];
    
    if saveOn==1
        spcFile = sprintf('over_excerpts_fv_pc_a_species%02d_%s',nspec);
        save(spcFile,'excerpts','par','-v7.3')
    end
        
    fv_e = [fv_e FV_spec];
    temp = excerpts;%(1:Nexcerpt);
    temp = rmfield(temp,{'audio','pitchCurve','featureVector'});
    if nspec ==1, info_e = temp;
    else info_e = [info_e temp];
    end
end
if saveOn==1
    fileName = 'overAll_excerpts_featureVectors_allSpc';
    save(fileName,'fv_e','info_e','-v7.3')
end

end

