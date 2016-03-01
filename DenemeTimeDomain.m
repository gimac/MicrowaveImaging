load TDMeasurements.mat
NumSpaceSamples = 18;

TimeDomain = TDMeasurements;

TruncatedLength = 60;


figure

n=TruncatedLength-1;
r = (0:n)'/n;
theta = linspace(-pi,pi,NumSpaceSamples);
X = r*cos(theta);
Y = r*sin(theta);

NewMap = zeros(NumSpaceSamples,TruncatedLength);

NewMap(:,1:5) = 1;

pcolor(X,Y,(fliplr(TimeDomain(:,1:TruncatedLength)))');
axis square

