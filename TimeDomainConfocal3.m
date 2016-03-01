%This is the trial for confocal image construction
clear NewMap
load TDMeasurements.mat
TimeDomain = TDMeasurements;
SpaceSamples = 18;
RangeSamplesStop = 50;%samples that are taken from the time domain data
RangeStart = 1;
TotalRangeSamples = RangeSamplesStop - RangeStart + 1;
SampleStepsDegree = 20;
RoundFactor = 5;%this factor is used for remapping of the pixels, since 

TruncateTimeDomain = TimeDomain(:,RangeStart:RangeSamplesStop);%Truncate
MaximumTimeDomain = max(max(TruncateTimeDomain));%Take the maximum
TruncateTimeDomain = TruncateTimeDomain./MaximumTimeDomain;%Normalize
InitialMap = (fliplr(TruncateTimeDomain));

%Lets create a mapping for pixels
    Xg = linspace(0,10,TotalRangeSamples);
    Yg = zeros(1, TotalRangeSamples);
    % and rotate them
for ThetaIndex=1:SpaceSamples
    Theta = deg2rad(SampleStepsDegree * ThetaIndex);
    GlobalCoordinates = [Xg;Yg];
    
    TFMatri = [cos(Theta) -sin(Theta); sin(Theta) cos(Theta)];
    
    for CoordinateIndex = 1:length(Xg)
        LocalCoordinates(ThetaIndex,CoordinateIndex,:) = TFMatri * GlobalCoordinates(:,CoordinateIndex);
    end
end

XCoord = LocalCoordinates(:,:,1);
YCoord = LocalCoordinates(:,:,2);

InitialMap(InitialMap < 0) = 0;

NewInitial = (InitialMap) * 10;

F = scatteredInterpolant((reshape(XCoord,1,18*TotalRangeSamples)') ...
    ,(reshape(YCoord,1,18*TotalRangeSamples)'), ...
    (reshape(NewInitial,1,18*TotalRangeSamples)'), 'linear', 'none');
ti = -10:.1:10;
[xq,yq] = meshgrid(ti,ti);
vq = F(xq,yq);

figure
mesh(xq,yq,vq);
hold on;
% plot3(reshape(XCoord,1,18*50)',reshape(YCoord,1,18*50)',reshape(InitialMap,1,18*50)','o');
axis square

figure
contourf(vq)
axis square
colorbar
map = colormap;
map(1,:) = [0 0 0];
colormap(map)
[cmin,cmax] = caxis;
caxis([1,cmax])