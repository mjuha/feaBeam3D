function ComputeSparsity
% ======================================================================

% =====================================================================
global LM nel irow icol nzmax

nzmax = 0;
for elem=1:nel
    for k=1:12
        i_index = LM(k,elem);
        if (i_index > 0)
            for m=1:12
                j_index = LM(m,elem);
                if (j_index > 0)
                    nzmax = nzmax + 1;
                end
            end
        end
    end
end

irow = zeros(1,nzmax);
icol = zeros(1,nzmax);

count = 0;
for elem=1:nel
    for k=1:12
        i_index = LM(k,elem);
        if (i_index > 0)
            for m=1:12
                j_index = LM(m,elem);
                if (j_index > 0)
                    count = count + 1;
                    irow(count) = i_index;
                    icol(count) = j_index;
                end
            end
        end
    end
end

end

