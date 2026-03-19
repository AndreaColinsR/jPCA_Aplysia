function Comparing_jPCAs

filename='Feb0416_1.mat';

[jPCA_scores1,Loads_jPC1,Var_exp_jpc1]=jPCA_for_Aplysia(filename,90,250);

[jPCA_scores2,Loads_jPC2,Var_exp_jpc2]=jPCA_for_Aplysia(filename,250);

%% compute participation of each neuron 
ndim = 2;
Participation1 = sum(abs(Loads_jPC1(:,1:ndim)).*Var_exp_jpc1(1:ndim),2);
Participation2 = sum(abs(Loads_jPC2(:,1:ndim)).*Var_exp_jpc2(1:ndim),2);

figure
subplot(2,2,1)

bar(1:2,[sum(Var_exp_jpc1(1:ndim)) sum(Var_exp_jpc2(1:ndim))])

subplot(2,2,2)
plot(Participation1)
hold on 
plot(Participation2)

subplot(2,2,3)
maxP=max([Participation1;Participation2]);
scatter(Participation1,Participation2)
xlim([0,maxP])
ylim([0,maxP])
axis square
end