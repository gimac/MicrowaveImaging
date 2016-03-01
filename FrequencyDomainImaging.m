DegStep = 20;
NumSpaceSamples = 18;
load Measurements;
%we will gonna have an ifft, however we need to pad zeros to the lower
%frequency ranges to obtain a complete time domain data.

%for now i will assume a 1 GHz - 8 GHz BW,
FrequencyStart = 1;%GHz
FrequencyStop = 8;%GHz
SweepBW = FrequencyStop - FrequencyStart;

NumberofZeros = (length(Measurements)/SweepBW) * FrequencyStart;
MaximumFrequency = 8e9;
MinimumTimeStep = 1/(2*MaximumFrequency);
TimeScale = 0:MinimumTimeStep:1e-6;
%1. Obtain time domain
for PositionIndex = 1:NumSpaceSamples
    PaddedData = [zeros(1,floor(NumberofZeros)) (Measurements(PositionIndex,:))];
    TimeDomain(PositionIndex,:) = abs(ifft([fliplr(conj(PaddedData)) PaddedData]));
end

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
TruncatedLength = 30;

ImageSubPos = zeros(NumSpaceSamples,TruncatedLength);
ImageSubNeg = zeros(NumSpaceSamples,TruncatedLength);

for PositionIndex = 1:NumSpaceSamples
    ImageSubPos(PositionIndex,:) = SubPos(PositionIndex,1:TruncatedLength);
    ImageSubNeg(PositionIndex,:) = SubNeg(PositionIndex,1:TruncatedLength);
end

%7. Step
%my map is a x = 18, y = 50 sampled map
AngleRange = 20:20:360;

figure

n=TruncatedLength-1;
r = (0:n)'/n;
theta = linspace(-pi,pi,18);
X = r*cos(theta);
Y = r*sin(theta);

NewMap = zeros(NumSpaceSamples,TruncatedLength);

[IndexList1,IndexList2] = find(Y>=0);
for Index=1:length(IndexList1)
NewMap(IndexList2(Index),IndexList1(Index)) = ImageSubPos(IndexList2(Index), IndexList1(Index));
end
[IndexList1,IndexList2] = find(Y<0);
for Index=1:length(IndexList1)
NewMap(IndexList2(Index),IndexList1(Index)) = ImageSubNeg(IndexList2(Index), IndexList1(Index));
end

pcolor(X,Y,NewMap');