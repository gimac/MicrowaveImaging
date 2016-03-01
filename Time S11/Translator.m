TDLength = 3202;
SpaceSamples = 18;
TDMeasurements = zeros(SpaceSamples,TDLength);


SpaceIndex = 1;
for DegreeIndex=20:20:360
    FileName = [num2str(DegreeIndex) 'degtimes11.txt'];
    FidInput = fopen(FileName, 'r');
    InputArray = fread(FidInput);
    fclose(FidInput);
    TabIndexes = find(InputArray == 9); %getting the indices of HORTAB
    InputArray(TabIndexes) = 13; %replace with Enter
    %write a NewFile
    NewFileName = [num2str(DegreeIndex) 'degTimes112Import.txt'];
    FidNewFile = fopen(NewFileName, 'w');
    fwrite(FidNewFile, InputArray);
    fclose(FidNewFile);
    TDMeasurements(SpaceIndex,:) = importTimeDomain(NewFileName);
    SpaceIndex = SpaceIndex + 1;
end

save TDMeasurements TDMeasurements