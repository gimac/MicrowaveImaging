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

for PositionIndex = 1:NumSpaceSamples
    PaddedData = [zeros(1,floor(NumberofZeros)) (Measurements(PositionIndex,:))];
    TimeDomain(PositionIndex,:) = ifft([fliplr(conj(PaddedData)) PaddedData]);
end

load('Deg20TimeDomain.mat');

figure
title('Time Domain Comparison')
xlabel('Time');
ylabel('Amplitude');
hold all
plot(Deg20TimeDomain.Time*1e-9, Deg20TimeDomain.TDR)
plot(TimeScale(1:length(TimeDomain(1,:))), abs(TimeDomain(1,:)));




