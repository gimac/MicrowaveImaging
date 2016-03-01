% time = 0:1e-9:1e-6;
% 
% waveForm = zeros(1, size(time,2));
% 
% waveForm(length(waveForm)/2 - 50: length(waveForm)/2 + 50) = 1;
% 
% FrequencyDomain = fft(waveForm);
% 
% FrequencyDomain(1:length(FrequencyDomain)/10) = 0;
% 
% BackedGuy = ifft(FrequencyDomain);
% 
% figure
% plot(time, BackedGuy);
% hold on
% plot(time, waveForm);
% 
% NewFrequencyResp = FrequencyDomain(length(FrequencyDomain)/10:end);
% 
% TrucatedGuy = ifft(NewFrequencyResp, size(BackedGuy, 2));
% 
% figure
% plot(time, TrucatedGuy);
% hold on
% plot(time, waveForm);

time = 0:1e-9:1e-6;
FrequencyScale = linspace(0,2*pi,length(time));
figure
hold all
grid on
for FrequencyIndex=1:1
WaveForm = sin(FrequencyIndex*45e7*2*pi*time);

FrequencyDomainWaveForm = fft(WaveForm);

plot(FrequencyScale, abs(FrequencyDomainWaveForm));
end

