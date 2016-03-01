load TDMeasurements.mat
DegStep = 20;
NumSpaceSamples = 18;

TimeDomain = TDMeasurements;

DifferenceSignal = zeros(NumSpaceSamples, size(TimeDomain,2));
%2. Take difference and form 180 deg out-of-phase two element array
for PositionIndex = 1:NumSpaceSamples
    if(PositionIndex==NumSpaceSamples)
        DifferenceSignal(PositionIndex,:) = TimeDomain(PositionIndex,:) - TimeDomain(1,:);
    else
        DifferenceSignal(PositionIndex,:) = TimeDomain(PositionIndex,:) - TimeDomain(PositionIndex + 1,:);
    end
end

SubPos = zeros(NumSpaceSamples, size(TimeDomain,2));
SubNeg = zeros(NumSpaceSamples, size(TimeDomain,2));
%3. Generate SubSignals
for PositionIndex = 1:NumSpaceSamples
    IndexList = find(DifferenceSignal(PositionIndex,:) > 0);
    for ReplacementIndex=1:length(IndexList)
        SubPos(PositionIndex,IndexList(ReplacementIndex)) = DifferenceSignal(PositionIndex,IndexList(ReplacementIndex));
    end
    IndexList = find(DifferenceSignal(PositionIndex,:) < 0);
    for ReplacementIndex=1:length(IndexList)
        SubNeg(PositionIndex,ReplacementIndex) = -1 * DifferenceSignal(PositionIndex,IndexList(ReplacementIndex));
    end
end

%4. Normalize
for PositionIndex = 1:NumSpaceSamples
    SubPos(PositionIndex,:) = SubPos(PositionIndex,:)/max(SubPos(PositionIndex,:));
    SubNeg(PositionIndex,:) = SubNeg(PositionIndex,:)/max(SubNeg(PositionIndex,:));
end

%5. Step
%According to 5 minute research sun flower seed oil has a dielectric
%constant around 3
Epsilon = 3;

%6. Step
D = 0.025;
R = 0.12;
x = 0.04;

c = 3e8;

DelayTime = 2*(D + sqrt(Epsilon)*(R+x))/c;

%I will take 3nSec of reception which is like 50th sample, lets truncate
TruncatedLength = 60;

ImageSubPos = zeros(NumSpaceSamples,TruncatedLength);
ImageSubNeg = zeros(NumSpaceSamples,TruncatedLength);

for PositionIndex = 1:NumSpaceSamples
    ImageSubPos(PositionIndex,:) = SubPos(PositionIndex,1:TruncatedLength);
    ImageSubNeg(PositionIndex,:) = SubNeg(PositionIndex,1:TruncatedLength);
end

%7. Step
%my map is a x = 18, y = 50 sampled map
ImageSubPos = fliplr(ImageSubPos);
ImageSubNeg = fliplr(ImageSubNeg);

RoundFactor = 20;

%Lets take their indexes as coordinates
Xg = linspace(0,5,TruncatedLength);
Yg = zeros(1, TruncatedLength);
for ThetaIndex=1:NumSpaceSamples
    Theta = deg2rad(DegStep * ThetaIndex);
    GlobalCoordinates = [Xg;Yg];
    
    TFMatri = [cos(Theta) -sin(Theta); sin(Theta) cos(Theta)];
    
    for CoordinateIndex = 1:length(Xg)
        LocalCoordinates(ThetaIndex,:,CoordinateIndex) = TFMatri * GlobalCoordinates(:,CoordinateIndex);
    end
end

RoundedLocalCoordinates = round(RoundFactor*LocalCoordinates);

MinimumY = min(min(RoundedLocalCoordinates(:,2,:)));
MinimumX = min(min(RoundedLocalCoordinates(:,1,:)));

for Index1=1:NumSpaceSamples
    for Index2=1:TruncatedLength
        NewCoordinate = RoundedLocalCoordinates(Index1,:, Index2);
        if(NewCoordinate(2) < 0)
            Value = ImageSubPos(Index1,Index2);
        else
            Value = ImageSubNeg(Index1,Index2);
        end
        
        
        NewMap(NewCoordinate(1) + abs(MinimumX) + 1, NewCoordinate(2) + abs(MinimumY) + 1) = Value;
        
    end
end

figure

image(NewMap*255);
axis square