
% ----- Slope accuracy
% All
% data1 = T.slope_accuracy_12m(listSubjR); data2 = T.slope_accuracy_12m(listSubjNR);
% fig = figure;
% fBoxplotWithDotsAndColors({data1,data2},labels={'Rs','NRs'},y_lim=[-.35 .35],plotLines=0);%,position=[1 2]);%,x_lim=[.25 1.65]);%,y_label={'Whole group'});
% % fig = fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Whole group'});
% % hold on; yline(0);hold off;
% title(sprintf('Slope accuracy'))
% %pos=get(gcf,"Position");
% fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
% saveas(fig,fullfile(pathFiguresPng,'all_slopeAccu'),'png');
% print(fig,fullfile(pathFiguresSvg,'all_slopeAccu'),'-dsvg');

%% Now plot the correlations -- new way (R & NR overlayed; reg with shading)
listSubj = listSubjAll;
% ----- ERN & slope accuracy
data2 = T.ERN_Diff_min33to172ms(listSubj); %zscore(T.ERN_Diff_min33to172ms(listSubj));
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y',sprintf('ERN (uV)\n(correct minus incorrect)'),'color','Group');
% g.set_title('Relationship between performance & ERN (by group)');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.6 pos(4)*.6];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_slopeAcc_ERN_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_ERN_RandNR'),'-dsvg');

% ----- FRN & slope accuracy
data2 = T.FRN_Diff_min457to930ms(listSubj); %zscore(T.FRN_Diff_min457to930ms(listSubj));
data1= T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y',sprintf('FRN (uV)\n(correct minus incorrect)'),'color','Group');
% g.set_names('x','z-Performance','y','z-FRN');
% g.set_names('x','Performance (z-score)','y','FRN (z-score)','color','Mirror group');
% g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
% g.set_title('Relationship between performance & FRN (by group)');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_slopeAcc_FRN_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_FRN_RandNR'),'-dsvg');

% ----- nFix & slope accuracy
data2 = T.nFixExpB_PCvsPI(listSubj); %zscore(T.nFixExpB_PCvsPI(listSubj));
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y',sprintf('Fixations (#)\n(post-corr. minus post-incorr.)'),'color','Group');
% g.set_names('x','z-Performance','y','z-Fixations');
% g.set_names('x','Performance (z-score)','y','Exploratory fixations (z-score)','color','Mirror group');
% g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
% g.set_title('Relationship between performance & exploratory fixations (by group)');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_slopeAcc_nFixExpB_PCvsPI_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_nFixExpB_PCvsPI_RandNR'),'-dsvg');

% ----- nSwitches & slope accuracy
data2 = T.nSwitchExpB_PCvsPI(listSubj); %zscore(T.nSwitchExpB_PCvsPI(listSubj));
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y',sprintf('Switches (#)\n(post-corr. minus post-incorr.)'),'color','Group');
% g.set_names('x','z-Performance','y','z-Switches');
% g.set_names('x','Performance (z-score)','y','Exploratory switches (z-score)','color','Mirror group');
% g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
% g.set_title('Relationship between performance & exploratory switches (by group)');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_slopeAcc_nSwitchExpB_PCvsPI_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_nSwitchExpB_PCvsPI_RandNR'),'-dsvg');

% ----- DecLat & slope accuracy
data2 = T.decLat_PCvsPI(listSubj); %zscore(T.decLat_PCvsPI(listSubj));
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm()
g.set_names('x','Performance','y',sprintf('Latency (ms)\n(post-corr. minus post-incorr.)'),'color','Group');
% g.set_names('x','z-Performance','y','z-Latency');
% g.set_names('x','Performance (z-score)','y','Decision latency (z-score)','color','Mirror group');
% g.set_names('column','Origin','x','Year of production','y','Fuel economy (MPG)','color','# Cylinders');
% g.set_title('Relationship between performance & decision latency (by group)');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_slopeAcc_DecLat_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_DecLat_RandNR'),'-dsvg');


% --- R & NRs (native not z-scored variables)
data2 = T.propOptOut_HvsE(listSubj)*100; %data1 = (data1 - mean(data2,'omitmissing'))/std(data1,'omitmissing'); %to avoid the nans
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y',['Opt-outs (%)',sprintf('\n(Harder minus Easy)')],'color','Group');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_propOptOutNative_HvsE_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_propOptOutNative_HvsE_RandNR'),'-dsvg');

% ----- Opt-Outs_Harder & slope accuracy
% --- R & NRs (native not z-scored variables)
data2 = T.propOptOut_Harder(listSubj); %data1 = (data1 - mean(data2,'omitmissing'))/std(data1,'omitmissing'); %to avoid the nans
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y','Opt-outs in Harder (%)','color','Group');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_propOptOutNative_Harder_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_propOptOutNative_Harder_RandNR'),'-dsvg');

% ----- Opt-Outs_Easy & slope accuracy
% --- R & NRs (native not z-scored variables)
data2 = T.propOptOut_Easy(listSubj); %data1 = (data1 - mean(data2,'omitmissing'))/std(data1,'omitmissing'); %to avoid the nans
data1 = T.slope_accuracy_12m(listSubj); %data2 = (data2 - mean(data2,'omitmissing'))/std(data2,'omitmissing');
g=gramm('x',data1,'y',data2,'color',T.mirror(listSubj));
g.geom_point();
g.stat_glm();
g.set_names('x','Performance','y','Opt-outs in Easy (%)','color','Group');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.75 pos(4)*.75];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,'shadedReg_propOptOutNative_Easy_RandNR'),'png');
print(fig,fullfile(pathFiguresSvg,'shadedReg_slopeAcc_propOptOutNative_Easy_RandNR'),'-dsvg');

return;


%% ----- Opt-outs Easy vs Harder
yL = [0 70];
% All
listSubj=listSubjAll;
data1 = T.propOptOut_Easy(listSubj)*100; data2 = T.propOptOut_Harder(listSubj)*100;
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Easy','Harder'},y_lim=yL,colours=[colors(4,:);colors(2,:)]);
title('Opt-outs (%) - all')
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'all_prctOptOut_HvsE'),'png');
print(fig,fullfile(pathFiguresSvg,'all_prctOptOut_HvsE'),'-dsvg');
% R
listSubj=listSubjR;
data1 = T.propOptOut_Easy(listSubj)*100; data2 = T.propOptOut_Harder(listSubj)*100;
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Easy','Harder'},y_lim=yL,colours=[colors(4,:);colors(2,:)]);
title('Opt-outs (%) - Rs')
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'R_prctOptOut_HvsE'),'png');
print(fig,fullfile(pathFiguresSvg,'R_prctOptOut_HvsE'),'-dsvg');
% NR
listSubj=listSubjNR;
data1 = T.propOptOut_Easy(listSubj)*100; data2 = T.propOptOut_Harder(listSubj)*100;
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Easy','Harder'},y_lim=yL,colours=[colors(4,:);colors(2,:)]);
title('Opt-outs (%) - NRs')
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'NR_prctOptOut_HvsE'),'png');
print(fig,fullfile(pathFiguresSvg,'NR_prctOptOut_HvsE'),'-dsvg');


%% ----- EEG: ERN 1
% All
listSubj=listSubjAll;
data1 = T.ERN_Corr_min33to172ms(listSubj); data2 = T.ERN_Incorr_min33to172ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Whole group'},colours=[colors(3,:);colors(1,:)]);
title(sprintf('ERN amplitude (uV)\n(min. in early window: 37-172ms) - all'))
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'allminERNEarlyPeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'allminERNEarlyPeakPCandPI'),'-dsvg');
% R
listSubj=listSubjR;
data1 = T.ERN_Corr_min33to172ms(listSubj); data2 = T.ERN_Incorr_min33to172ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Group of mirror R'},colours=[colors(3,:);colors(1,:)]);
title(sprintf('ERN amplitude (uV)\n(min. in early window: 37-172ms) - Rs'))
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'RminERNEarlyPeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'RminERNEarlyPeakPCandPI'),'-dsvg');
% NR
listSubj=listSubjNR;
data1 = T.ERN_Corr_min33to172ms(listSubj); data2 = T.ERN_Incorr_min33to172ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Group of mirror NR'},colours=[colors(3,:);colors(1,:)]);
title(sprintf('ERN amplitude (uV)\n(min. in early window: 37-172ms) - NRs'))
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'NRminERNEarlyPeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'NRminERNEarlyPeakPCandPI'),'-dsvg');

% ----- EEG: ERN 2
% All
listSubj=listSubjAll;
data1 = T.ERN_Corr_min332to547ms(listSubj); data2 = T.ERN_Incorr_min332to547ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Whole group'},colours=[colors(3,:);colors(1,:)]);
title(sprintf('ERN amplitude (uV)\n(min. in late window: 323-516ms) - all'))
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'allminERNLatePeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'allminERNLatePeakPCandPI'),'-dsvg');
% R
listSubj=listSubjR;
data1 = T.ERN_Corr_min332to547ms(listSubj); data2 = T.ERN_Incorr_min332to547ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Group of mirror R'},colours=[colors(3,:);colors(1,:)]);
title(sprintf('ERN amplitude (uV)\n(min. in late window: 323-516ms) - Rs'))
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'RminERNLatePeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'RminERNLatePeakPCandPI'),'-dsvg');
% NR
listSubj=listSubjNR;
data1 = T.ERN_Corr_min332to547ms(listSubj); data2 = T.ERN_Incorr_min332to547ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={'Group of mirror NR'},colours=[colors(3,:);colors(1,:)]);
title(sprintf('ERN amplitude (uV)\n(min. in late window: 323-516ms) - NRs'))
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'NRminERNLatePeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'NRminERNLatePeakPCandPI'),'-dsvg');

% ----- EEG: FRN
% All
listSubj=listSubjAll;
data1 = T.FRN_Corr_min457to930ms(listSubj); data2 = T.FRN_Incorr_min457to930ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={sprintf('FRN amplitude (uV)\n(min. in window: 452-800ms)')});
title('Whole group')
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'allminFRNPeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'allminFRNPeakPCandPI'),'-dsvg');
% R
listSubj=listSubjR;
data1 = T.FRN_Corr_min457to930ms(listSubj); data2 = T.FRN_Incorr_min457to930ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={sprintf('FRN amplitude (uV)\n(min. in window: 452-800ms)')},colours=[colors(3,:);colors(1,:)]);
title('Group of mirror R')
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'RminFRNPeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'RminFRNPeakPCandPI'),'-dsvg');
% NR
listSubj=listSubjNR;
data1 = T.FRN_Corr_min457to930ms(listSubj); data2 = T.FRN_Incorr_min457to930ms(listSubj);
fig = figure; fBoxplotWithDotsAndColors([data1,data2],labels={'Post-Corr.','Post-Incorr.'},y_label={sprintf('FRN amplitude (uV)\n(min. in window: 452-800ms)')},colours=[colors(3,:);colors(1,:)]);
title('Group of mirror NR')
%pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
saveas(fig,fullfile(pathFiguresPng,'NRminFRNPeakPCandPI'),'png');
print(fig,fullfile(pathFiguresSvg,'NRminFRNPeakPCandPI'),'-dsvg');

