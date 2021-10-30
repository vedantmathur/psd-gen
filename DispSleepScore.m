function DispSleepScore(file)
%DISPSLEEPSCORE Returns a sleep score using naive scoring methods.

    thresh = 2;
    
    % Extract Data
    T = readtable('test.xlsx','Sheet','PowerSpectra');
    R = T(:,53:104);
    R.AvgVec = mean(R{:,:},2);
    vec = R.AvgVec(2:end);
    % disp(vec)
    
    % Some math to help normalise the data and increase the differences.
    vec = vec .^ 2;
    z = vec(vec < thresh);
    ct = length(z);
    tot = length(vec);
    
    score = 100 * ct / tot;
    
    msgbox(sprintf('sleep score: %f', score));
end

