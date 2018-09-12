%% plot the behavioral event data
function plot_behavData(fileName,batName,sessionType)
load(fileName); %this is the file saved from extract_behavParam

%make vectors of data wanted for plotting
for vv = 1:length(behavData)
    %get bat specific data
   logBat(vv) = strcmp(batName,behavData(vv).batId);
   indBat = find(logBat);
   %get task specific data
   logTask(vv) = strcmp(sessionType,behavData(vv).taskType);
   indTask = find(logTask);
   indBatTask = intersect(indBat,indTask);
end

figure
%plot call num for each day
subplot(2,2,1)
plot(1:length(indBatTask),[behavData(indBatTask).numCalls],'or-')
title(['Number of calls: Bat ' batName])%,'FontSize',35)
xlabel('Training Day')%,'FontSize',40)
ylabel('#Calls')%,'FontSize',40)
set(gca,'xtick',0:length(indBatTask),'xticklabel',[behavData(indBatTask).sessionDate])
%xlim([0 length(behavData.idList)+1])

%plot call rate for each day
subplot(2,2,2)
plot(1:length(indBatTask),[behavData(indBatTask).callRate],'or-')
title(['Call rate: Bat ' batName])%,'FontSize',35)
xlabel('Training Day')%,'FontSize',40)
ylabel('#Calls/hr')%,'FontSize',40)
set(gca,'xtick',0:length(indBatTask),'xticklabel',[behavData(indBatTask).sessionDate])

%plot reward percent for each day
subplot(2,2,3)
plot(1:length(indBatTask),[behavData(indBatTask).callRewardPercentage],'or-')
title(['Reward %: Bat ' batName])%,'FontSize',35)
xlabel('Training Day')%,'FontSize',40)
ylabel('Reward %')%,'FontSize',40)
set(gca,'xtick',0:length(indBatTask),'xticklabel',[behavData(indBatTask).sessionDate])

%plot delay to reward for each day
subplot(2,2,4)
plot(1:length(indBatTask),[behavData(indBatTask).avgDelay2Reward],'or-')
title(['Delay to reward: Bat ' batName])%,'FontSize',35)
xlabel('Training Day')%,'FontSize',40)
ylabel('Avg delay to reward (s)')%,'FontSize',40)
set(gca,'xtick',0:length(indBatTask),'xticklabel',[behavData(indBatTask).sessionDate])
end