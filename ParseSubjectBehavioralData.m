function [behavStruct, trialData] = ParseSubjectBehavioralData(varargin)


%get current folder, set script to automatically return to this folder in
%event of early closing.
scriptPath = pwd;
finishup = onCleanup(@() CleanupFun(scriptPath));

if isempty(varargin)
    dataFolder = uigetdir('Data', 'Choose the subject folder');
    [subjectPath,subjectID,~] = fileparts(dataFolder);
    trialData = readtable([subjectPath filesep subjectID filesep 'RuntimeData' filesep 'TrialData' filesep subjectID '__TrialData.txt'], 'delimiter', '\t');
else
    trialData = varargin{1};
end


nTestTrials = 12;
windowSize = 5;
nBlocks = max(trialData.Block);
nMainTrials = [];

fprintf('\tProcessing accuracy and RT data.\n');
trialData.SmoothAcc = nan(size(trialData,1),1);
trialData.SmoothAccContext1 = nan(size(trialData,1),1);
trialData.SmoothAccContext2 = nan(size(trialData,1),1);


for i = 1:nBlocks
    blockData.Raw = trialData(trialData.Block==i,:);
    
    nTrials = length(blockData.Raw.Acc);
    
    if mod(i,2) == 1
        nMainTrials = [nMainTrials; nTrials];
    end;
    
    blockData.Acc = nan(nTrials, 5);
    blockData.SmoothAcc = nan(nTrials,1);
    blockData.SmoothAccContext1 = nan(nTrials,1);
    blockData.SmoothAccContext2 = nan(nTrials,1);
    blockData.PickupRT = nan(nTrials, 5);
%     blockData.EM_pmode = nan(nTrials, 5);
%     blockData.EM_p05 = nan(nTrials,5);
%     blockData.EM_p95 = nan(nTrials,5);
%     blockData.EM_LP = nan(1,5);
%     blockData.PreLP_Acc = nan(1,5);
%     blockData.PostLP_Acc = nan(1,5);
%     blockData.PreLP_PickupRT = nan(1,5);
%     blockData.PostLP_PickupRT = nan(1,5);
%     blockData.PreLP_RewardRT = nan(1,5);
%     blockData.PostLP_RewardRT = nan(1,5);
    
    blockData.Acc(:,1) = blockData.Raw.Acc;
    blockData.SmoothAcc = SlidingWindowBackward(blockData.Acc(:,1), windowSize);
    contexts = unique(blockData.Raw.ContextNum);
    for j = 1:length(contexts)
        blockData.(['SmoothAccContext' num2str(j)])(blockData.Raw.ContextNum==contexts(j)) = SlidingWindowBackward(blockData.Acc(blockData.Raw.ContextNum==contexts(j),1), windowSize);
    end
    
    trialData.SmoothAcc(trialData.Block == i) = blockData.SmoothAcc;
    trialData.SmoothAccContext1(trialData.Block == i) = blockData.SmoothAccContext1;
    trialData.SmoothAccContext2(trialData.Block == i) = blockData.SmoothAccContext2;
    
    blockData.PickupRT(:,1) = blockData.Raw.FixDoorToPickupTime;
    
    for j = 1:nTrials
        if ~isnan(blockData.Acc(j,1))
            if blockData.Acc(j,1)
                blockData.PickupRT(j,1) = blockData.PickupRT(j,1) / blockData.Raw.FixDoorToTargetDistance(j);
            else
                blockData.PickupRT(j,1) = blockData.PickupRT(j,1) / blockData.Raw.FixDoorToDistractorDistance(j);
            end
        end
    end
            
    
    blockData.PickupRT(blockData.Raw.NumPickups>1,:) = NaN;
    
%     blockData.EmData.All.Responses = blockData.Raw.Acc;
%     blockData.EmData.All = get_learningCurveStat_01(blockData.EmData.All);
%     
%     blockData.EM_pmode(:,1) = blockData.EmData.All.pmode(2:end);
%     blockData.EM_p05(:,1) = blockData.EmData.All.p05(2:end);
%     blockData.EM_p95(:,1) = blockData.EmData.All.p95(2:end);
%     lp = find(blockData.EM_p05(:,1) > 0.5,1);
%     if ~isempty(lp) && lp > 1
%         blockData.EM_LP(1) = lp;
%         blockData.PreLP_Acc(1) = nanmean(blockData.Acc(1:lp-1));
%         blockData.PostLP_Acc(1) = nanmean(blockData.Acc(lp:end));
%         blockData.PreLP_PickupRT(1) = nanmean(blockData.PickupRT(1:lp-1));
%         blockData.PostLP_PickupRT(1) = nanmean(blockData.PickupRT(1:lp-1));
%         blockData.PreLP_RewardRT(1) = nanmean(blockData.RewardRT(1:lp-1));
%         blockData.PostLP_RewardRT(1) = nanmean(blockData.RewardRT(1:lp-1));
%     else
%         blockData.EM_LP(1) = NaN;
%         blockData.PreLP_Acc(1) = NaN;
%         blockData.PostLP_Acc(1) = NaN;
%         blockData.PreLP_PickupRT(1) = NaN;
%         blockData.PostLP_PickupRT(1) = NaN;
%         blockData.PreLP_RewardRT(1) = NaN;
%         blockData.PostLP_RewardRT(1) = NaN;
%     end
    
    for j = 1:4
        theseTrials = find(blockData.Raw.TrialType == j);
        acc = blockData.Acc(theseTrials,1);
        blockData.Acc(theseTrials,j + 1) = acc;
        blockData.PickupRT(theseTrials,j + 1) = blockData.PickupRT(theseTrials,1);
        
%         typeField = ['TrialType' num2str(j)];
%         blockData.EmData.(typeField).Responses = acc;
%         blockData.EmData.(typeField) = get_learningCurveStat_01(blockData.EmData.(typeField));
%         
%         blockData.EM_pmode(theseTrials,j+1) = blockData.EmData.(typeField).pmode(2:end);
%         blockData.EM_p05(theseTrials,j+1) = blockData.EmData.(typeField).p05(2:end);
%         blockData.EM_p95(theseTrials,j+1) = blockData.EmData.(typeField).p95(2:end);
%         lp = find(blockData.EmData.(typeField).p05(2:end) > 0.5,1);
%         if ~isempty(lp) && lp > theseTrials(1)
%             blockData.EM_LP(j+1) = theseTrials(lp);
%             blockData.PreLP_Acc(j+1) = nanmean(blockData.Acc(theseTrials(1:lp-1)));
%             blockData.PostLP_Acc(j+1) = nanmean(blockData.Acc(theseTrials(lp:end)));
%             blockData.PreLP_PickupRT(j+1) = nanmean(blockData.PickupRT(theseTrials(1:lp-1)));
%             blockData.PostLP_PickupRT(j+1) = nanmean(blockData.PickupRT(theseTrials(1:lp-1)));
%             blockData.PreLP_RewardRT(j+1) = nanmean(blockData.RewardRT(theseTrials(1:lp-1)));
%             blockData.PostLP_RewardRT(j+1) = nanmean(blockData.RewardRT(theseTrials(1:lp-1)));
%         else
%             blockData.EM_LP(j+1) = NaN;
%             blockData.PreLP_Acc(j+1) = NaN;
%             blockData.PostLP_Acc(j+1) = NaN;
%             blockData.PreLP_PickupRT(j+1) = NaN;
%             blockData.PostLP_PickupRT(j+1) = NaN;
%             blockData.PreLP_RewardRT(j+1) = NaN;
%             blockData.PostLP_RewardRT(j+1) = NaN;
%         end
    end
    
    behavStruct.(['Block' num2str(i) 'Data']) = blockData;
end

nMaxTrials = max(nMainTrials);
% longer = nMainTrials >= nMaxTrials;
% 
% while sum(longer) < 3
%     nMaxTrials = max(nMainTrials(~longer));
%     longer = nMainTrials >=nMaxTrials;
% end


nansForAvg = nan(nMaxTrials, 5, ceil(nBlocks/2));
nansForAvgTest = nan(12, 5, floor(nBlocks/2));
accForAvg = nansForAvg;
pickupRTForAvg = nansForAvg;
accForAvgTest = nansForAvgTest;
pickupRTForAvgTest = nansForAvgTest;


blockFields = fields(behavStruct);

for i = 1:nBlocks/2
    mainRow = i*2-2+1;
    
    blockField = blockFields{mainRow};
    if i < nBlocks
        testField = blockFields{mainRow+1};
    end
    nTrials = min(size(behavStruct.(blockField).Acc,1), nMaxTrials);
    nTestTrials = size(behavStruct.(testField).Acc,1);
    accForAvg(1:nTrials,:,i) = behavStruct.(blockField).Acc(1:nTrials,:);
    pickupRTForAvg(1:nTrials,:,i) = behavStruct.(blockField).PickupRT(1:nTrials,:);
    accForAvgTest(1:nTestTrials,:,i) = behavStruct.(testField).Acc;
    pickupRTForAvgTest(1:nTestTrials,:,i) = behavStruct.(testField).PickupRT;
end
accMean = nanmean(accForAvg,3);
rtMean = nanmean(pickupRTForAvg,3);

accMeanTest = nanmean(accForAvgTest,3);
rtMeanTest = nanmean(pickupRTForAvgTest,3);
for i = 1:5
    accMean(:,i) = smooth(accMean(:,i),9);
    rtMean(:,i) = smooth(rtMean(:,i),9);
    accMeanTest(:,i) = smooth(accMeanTest(:,i),9);
    rtMeanTest(:,i) = smooth(rtMeanTest(:,i),9);
end
    

behavStruct.AccMean = accMean;
behavStruct.PickupRtMean = rtMean;
behavStruct.AccSEM = nanstd(accForAvg,1,3) / sqrt(nBlocks);
behavStruct.PickupRtSEM = nanstd(pickupRTForAvg,1,3) / sqrt(nBlocks);


behavStruct.AccMeanTest = accMeanTest;
behavStruct.PickupRtMeanTest = rtMeanTest;
behavStruct.AccSEMTest = nanstd(accForAvgTest,1,3) / sqrt(nBlocks);
behavStruct.PickupRtSEMTest = nanstd(pickupRTForAvgTest,1,3) / sqrt(nBlocks);


fred = 2;


function CleanupFun(path)
cd(path);