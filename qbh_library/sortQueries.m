function [ sortedQueries ] = sortQueries( queries )

[~,i_sort] = sort([queries.no]);
sortedQueries=queries(i_sort);


end

