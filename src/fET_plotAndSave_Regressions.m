% Make regression plots between variables for 2 groups overlayed

function fET_plotAndSave_Regressions(T, pathFiguresPng, pathFiguresSvg, groups, variables, labels)

data1 = T.(variables{1});
data2 = T.(variables{2});
% data1 = T.slope_accuracy_12m(listSubj);
g=gramm(x=data1,y=data2,color=groups);
g.geom_point();
g.stat_glm();
g.set_names('x',labels{1},'y',labels{2},'color','Group');
fig = figure;
g.draw();
fontsize(fig,20,'points');
pos=get(fig,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.6 pos(4)*.6];
% hold on; yline(0,'--',color=[.5 .5 .5 .3]); xline(0,'--',color=[.5 .5 .5 .3]); hold off; % NOT PLOTTING?
saveas(fig,fullfile(pathFiguresPng,sprintf('shadedReg_%s_%s_byGroups',variables{1},variables{2})),'png');
print(fig,fullfile(pathFiguresSvg,sprintf('shadedReg_%s_%s_byGroups',variables{1},variables{2})),'-dsvg');

end