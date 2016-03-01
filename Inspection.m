NumberofPositions  = 18;
load TDMeasurements.mat
TimeDomain = TDMeasurements;
figure
mesh(TimeDomain(:,1:30))
colormap summer

figure
hold all
for PositionIndex=1:NumberofPositions 
    plot(TimeDomain(PositionIndex,1:50));
    pause
end

figure
hold all
for PositionIndex=1:NumberofPositions 
    plot(DifferenceSignal(NumberofPositions,1:50)')
    pause
end