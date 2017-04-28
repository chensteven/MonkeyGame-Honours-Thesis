function runEM
    files = 'Subject1__05_03_2017__15_58_50__SubjectDataStruct_small.mat';
    load(files);
    folderName = './ProcessedStructsForPython/';
    addpath('./IndividualAnalysisEM');
    acc = subjectDataSmall.Runtime.TrialData.Acc;
    maxvalue = max(subjectDataSmall.Runtime.TrialData.Block);
    substring = files(1:30);
    for c =1:2:maxvalue
        block = (subjectDataSmall.Runtime.TrialData.Block == c);
        new_acc = acc(block);
        if(length(new_acc) > 1)
            Responses = transpose(new_acc);
            MaxResponse = 1;
            BackgroundProb = 0.5;
            SigE = 0.005; %default variance of learning state process is sqrt(0.005)
            UpdaterFlag = 2;  %default allows bias

            runanalysis(Responses, MaxResponse, BackgroundProb, SigE, UpdaterFlag);
            load('resultsindividual.mat');

            eTable = table(p05, p95, pmid, pmode1, cback);
            e = struct(eTable);

            fname = sprintf('_EM-Block-%d.mat', c);
            fname = strcat(folderName, substring, fname);

            save(fname, 'e'); 
        end
     
    end
end