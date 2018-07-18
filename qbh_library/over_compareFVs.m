function [rank] = over_compareFVs(list_excerpts,list_queries,par,saveOn)
    
if nargin<4, saveOn=0; end
    [fv_e info_e] = over_excerptsFV(list_excerpts,par,saveOn);
    
    [fv_q info_q] = over_queriesFV(list_queries,par,saveOn);
    
    Nptp = length(list_queries);
    Nquery = length(info_q);
    rank = zeros(Nquery,1);
    
    for nquery = 1:Nquery
        q = fv_q(:,nquery);
        [~, i_sort] = sort(sum(abs(bsxfun(@minus,fv_e,fv_q))));
        ranking_e = info_e(i_sort);
        
        matchXC = find([ranking_e.xcID] == info_q(nquery).xcID);
        matchEN = find([ranking_e.excerptNum] == info_q(nquery).excerpt);
        
        rank(nquery) = intersect(matchXC, matchEN);

    end

end