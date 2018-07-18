clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

list_spec = dir('pitchCurves_excerpts_cents_spc*_NXC-Nexcerpt.mat');
Nspec=10;

Nfeat=43;

                        features_allspec=[];
                        xcID_allspec=[];
                        spec_allspec = [];


for nspec=1:Nspec
    load(list_spec(nspec).name)
    c=0;
    % GET FEATURE LABELS
    if nspec==1, [~,featureLabels] = ft_allFeatures(pitchCurves{1}{1}); end
    
    NXC=length(pitchCurves); % number of xeno-canto recordings
                         totalNExcerpts = sum(cellfun(@(x) numel(x),pitchCurves));
                        featureVectors = zeros(totalNExcerpts,Nfeat);
    for nXC=1:NXC % Xeno-Canto file
        
        Nexcerpt=length(pitchCurves{nXC});
        for nexcerpt=1:Nexcerpt % pitch curve of clean excerpt in the XC file
            c=c+1;
            fprintf('spec %d, XC ID %d / %d, excerpt %d / %d \n',nspec,nXC,NXC,nexcerpt,Nexcerpt)
            pc = pitchCurves{nXC}{nexcerpt};
            %plot(pc),pause
            if nansum(pc)>0 && ~isempty(pc) && ~isempty(pc_segConcat(pc))
                excerpts_spec(c).nspec = nspec;
                excerpts_spec(c).xcID = nxID(nID);
                excerpts_spec(c).pitchCurve = pc;
                excerpts_spec(c).features = ft_allFeatures(pc);
            end
        end
    end
    if nspec ==1, excerpts=excerpts_spec; 
    else excerpts  = [excerpts excerpts_spec];
        
    speciesFile=sprintf('featureVectors_spc%02d_Nexcerpt-by-Nfeature',nspec);
    save(speciesFile,'featureVectors','featureLabels','nspec','xcID','wsize_sec','ssize_sec',...
       'hop_pwin','fs','fmin_hz','fmax_hz','-v7.3')   
end

allSpecFile = 'featureVectors_allSpecies_Nexcerpt-by-Nfeature';
    save(allSpecFile,'features_allspec','xcID_allspec','spec_allspec','featureLabels','wsize_sec','ssize_sec',...
       'hop_pwin','fs','fmin_hz','fmax_hz','-v7.3')
