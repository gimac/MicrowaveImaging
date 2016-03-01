%This is the trial for confocal image construction
clear NewMap
load TDMeasurements.mat
TimeDomain = TDMeasurements;
SpaceSamples = 18;
SpaceExpantion = 360;
RangeSamples = 50;%samples that are taken from the time domain data
SampleStepsDegree = 1;
RoundFactor = 10;%this factor is used for remapping of the pixels, since 
XDomainLenght = 10;

TruncateTimeDomain = TimeDomain(:,1:RangeSamples);%Truncate
MaximumTimeDomain = max(max(TruncateTimeDomain));%Take the maximum
TruncateTimeDomain = TruncateTimeDomain./MaximumTimeDomain;%Normalize
InitialMap = (fliplr(TruncateTimeDomain));
%LetsMultiplyThisGuy
InterpolatedInitialMap = zeros(size(InitialMap,1)*20,size(InitialMap,2));

for InitialIndex=1:SpaceSamples
    for Interpolation=1:20
    InterpolatedInitialMap((InitialIndex - 1)*20 + Interpolation,:) = InitialMap(InitialIndex,:);
    end
end


%Lets take their indexes as coordinates
    Xg = linspace(0,XDomainLenght,RangeSamples);
    Yg = zeros(1, RangeSamples);
for ThetaIndex=1:SpaceExpantion
    Theta = deg2rad(SampleStepsDegree * ThetaIndex);
    GlobalCoordinates = [Xg;Yg];
    
    TFMatri = [cos(Theta) -sin(Theta); sin(Theta) cos(Theta)];
    
    for CoordinateIndex = 1:length(Xg)
        LocalCoordinates(ThetaIndex,:,CoordinateIndex) = TFMatri * GlobalCoordinates(:,CoordinateIndex);
    end
end

RoundedLocalCoordinates = round(RoundFactor*LocalCoordinates);

MinimumY = min(min(RoundedLocalCoordinates(:,2,:)));
MinimumX = min(min(RoundedLocalCoordinates(:,1,:)));

for Index1=1:SpaceExpantion
    for Index2=1:RangeSamples
        NewCoordinate = RoundedLocalCoordinates(Index1,:, Index2);
        Value = InterpolatedInitialMap(Index1,Index2);
        
        NewMap(NewCoordinate(1) + abs(MinimumX) + 1, NewCoordinate(2) + abs(MinimumY) + 1) = Value;
    end    
end


figure

image(NewMap*255);
axis square