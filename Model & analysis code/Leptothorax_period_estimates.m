clear all; close all

cd '...\Empirical data' %location of the activity time series

dinfo = dir;
A = {dinfo.name};

A = A(~cellfun('isempty', strfind(A,'activity')));
A = A(cellfun('isempty', strfind(A,'sectors')));

A=sort_nat(A);

name={};
for i=1:length(A) % loop though all colonies
    
activity = readtable(char(A(i))); % load time series

activity=activity.activity;

time=hours(seconds([1:length(activity)]*30));

f12=smoothdata(activity,'gaussian',15); % smooth activity time series

figure(1) % plot activity time series
% set(gcf,'Position',[100 100 300 350])
subplot(5,4,i)
plot(time,f12, 'k', 'LineWidth', 2)
hold on
scatter(time,activity, 10, '.b')
xlabel('Hours')
ylabel('Activity')
colony=char(A(i));
colony = strrep(colony,'activity_MLD_','');
colony = strrep(colony,'.csv','');
title(colony)
xlim([0 9.1])

f12=rescale(f12); % rescale time series to fall between 0 and 1 
        
power=[];
        index1=[];
        [dpoaeCWT,f,coi] = cwt(f12, 1/30); % wavelet analysis
        for j=1:length(f12)
            cfsOAE = dpoaeCWT(:,j);
            q=abs(cfsOAE);
            h=horzcat(q,f);
            ex=coi(j);
            q2 = h(:,2) < ex; % exclude data points in the cone of influence 
            q(q2) = [];
            [power(j), index1(j)] = max(q);
        end
        wcom=horzcat(power',index1');
        [M,Y] = max(power);
        
        period_wave(i)=1/f(index1(Y)); % compute the dominant period of oscillation using wavelet analysis for the m-th time series
name=vertcat(cellstr(name),char(A(i)));

end

v=table(name, minutes(seconds(period_wave))'); % save data
v.Properties.VariableNames ={'Colony' 'Dominant_Period'}

% writetable(v,'Colony_period_estimates.csv')