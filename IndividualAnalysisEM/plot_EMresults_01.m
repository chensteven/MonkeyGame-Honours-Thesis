function plot_EMresults_01(M,learnTrial1,infostring)

%iM = 24
% learnTrial1= iLearn(iM);
%M = M0{iM};

if 0
M.p
M.pmode
M.p05
M.p95
M.Responses
M.MaxResponse
M.BackgroundProb  
M.pmatrix
end


%-------------------------------------------------------------------------------------
%plot the figures
%load('resultsindividual');
t=1:size(M.p,2)-1; 

figure('Color','w'), hold on,%(1);  %clf;
set(gcf,'Position',[1042         528         348         278])
% subplot(2,1,1), hold on,

plot(t,M.pmode(2:end),'ro-','Linewidth',2, 'MarkerFaceColor',[0.7 0.7 0.7], 'MarkerSize',4)
hold on;
 plot(t, M.p05(2:end),'r--', t, M.p95(2:end), 'r--');
 
 hold on; [y, x] = find(M.Responses > 0);
      h = plot(x,y+0.08,'s'); set(h, 'MarkerFaceColor','k', 'MarkerSize',4);
      set(h, 'MarkerEdgeColor', 'k');
      hold on; [y, x] = find(M.Responses == 0);
      h = plot(x,y+0.08,'s'); set(h, 'MarkerFaceColor', [0.75 0.75 0.75], 'MarkerSize',4);
      set(h, 'MarkerEdgeColor', 'k');
 plot([learnTrial1 learnTrial1],[0 1],'k--')
      axis([0 t(end)  0 1.08]);
 %else
 %     hold on; plot(t, M.Responses./M.MaxResponse,'ko');
 %     axis([1 t(end)  0 1]);
 %end
 set(gca,'Tickdir','out')
 plot([1 t(end)], [M.BackgroundProb  M.BackgroundProb ],'-','Color',[0.5 0.5 0.5]);
 title(['IO(0.95) Learning trial = ' num2str(learnTrial1)  ]);
% title(['IO(0.95) Learning trial = ' num2str(cback) '   Learning state process variance = ' num2str(SigE^2) ]);
%'   Learning state process variance = ' num2str(SigE^2)
set(gca,'Xlim',[0 35])
 xlabel(infostring)
 ylabel('Probability of a Correct Response')

 if 0
 %plot IO certainty
 subplot(2,1,2), hold on
 %plot(t,1 - pmatrix(2:end),'k')
 plot(t,M.pmatrix(2:end),'k')
 line([ 1 t(end)],[0.90 0.90]);
 line([ 1 t(end)],[0.99 0.99]);
 line([ 1 t(end)],[0.95 0.95]);
 axis([1 t(end)  0 1]);
 grid on;
 xlabel('Trial Number')
 ylabel('Certainty')
 
 end
 
 