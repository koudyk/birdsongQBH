function [fv_q , info_q] = over_queriesFV(list_ptp,par,saveOn)

if nargin<3, saveOn=0; end
centsPerOctave = 1200;
Nptp = length(list_ptp);
Nfeat = 43;
fv_q = [];

for nptp = 1:Nptp
    disp('--------------------------------------------')
    load(list_ptp(nptp).name)
    Nquery = length(queries);
    %Nquery = 2;
    fv_ptp = zeros(Nfeat, Nquery);
    for nquery = 1:Nquery
        fprintf('ptp %d, query %d / %d \n',nptp,nquery,Nquery)
        a = queries(nquery).query;
        pc = yin_queries(a,par) * centsPerOctave;
        fv_ind = ft_allFeatures(pc,par);
        fv_ptp(:,nquery) = fv_ind;
        queries(nquery).pitchCurve = pc;
        queries(nquery).featureVector = fv_ind;
        queries(nquery).ptp = ptp;
    end
    if saveOn==1,
        ptpFile = sprintf('over_queries_fv-pc-a_%03dqueries_ptp%03d',Nquery,ptp);
        save(ptpFile,'queries','par','-v7.3')
    end
    fv_q = [fv_q fv_ptp];
    temp = queries(1:Nquery);
    temp = rmfield(temp,{'stimulus','query','pitchCurve','featureVector'});
    if nptp ==1, info_q = temp;
    else info_q = [info_q temp];
    end
end

if saveOn ==1
    fileName = 'overAll_queries_featureVectors_allPtp';
    save(fileName,'fv_q','info_q','-v7.3')
end
   
end
