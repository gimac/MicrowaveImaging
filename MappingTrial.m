%This is the trial for confocal image construction
clear NewMap

SpaceSamples = 18;
RangeSamples = 60;


InitialMap = ones(SpaceSamples, RangeSamples);

InitialMap(:,45:52) = 1;
InitialMap(5:6, 10:28) = 1;
InitialMap(18, 45:60) = 1;
% lets create a coordinate systemfor or pixels

%Lets take their indexes as coordinates
    Xg = linspace(0,6,RangeSamples);
    Yg = zeros(1, RangeSamples);
for ThetaIndex=1:SpaceSamples
    Theta = deg2rad(20 * ThetaIndex);
    GlobalCoordinates = [Xg;Yg];
    
    TFMatri = [cos(Theta) -sin(Theta); sin(Theta) cos(Theta)];
    
    for CoordinateIndex = 1:length(Xg)
        LocalCoordinates(ThetaIndex,:,CoordinateIndex) = TFMatri * GlobalCoordinates(:,CoordinateIndex);
    end
end

RoundedLocalCoordinates = round(10*LocalCoordinates);

MinimumY = min(min(RoundedLocalCoordinates(:,2,:)));
MinimumX = min(min(RoundedLocalCoordinates(:,1,:)));

for Index1=1:SpaceSamples
    for Index2=1:RangeSamples
        NewCoordinate = RoundedLocalCoordinates(Index1,:, Index2);
        Value = InitialMap(Index1,Index2);
        
        NewMap(NewCoordinate(1) + abs(MinimumX) + 1, NewCoordinate(2) + abs(MinimumY) + 1) = Value;
        
    end    
end


figure

image(NewMap*255);