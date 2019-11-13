prompt = 'Enter Patient Name';
patNum = input(prompt,'s')
filename = sprintf('DataFolder/CGMSeriesLunchPat%s.csv',patNum);
CGM = readmatrix(filename)

CGM = CGM(:,1:31);
%Fill in missing values using interpolation
x = 1: (length(CGM(:,1))*length(CGM(1,:)))
CGM(isnan(CGM)) = interp1(x(~isnan(CGM)),CGM(~isnan(CGM)),x(isnan(CGM)))
CGM = fillmissing(CGM, 'movmean', 15)

X = linspace(0,length(CGM(:,1)), length(CGM(:,1)));

FeatureMatrix = [];
ZC = [];
plotFeatureMatrix = [];
for row=length(CGM(:,1)):-1:1
    CGMrow = flip(CGM(row,:));

    %Calculate windowed distance travelled & RMS
    windowSize = 10;
    startSample = 1;
    endSample = startSample+windowSize-1;
    k=1;
    while(endSample < length(CGMrow) && k<5)
        distancePCA(k) = 0;
        for j = startSample:endSample
            distancePCA(k) = distancePCA(k) + abs(CGMrow(j+1)-CGMrow(j));
        end
        RMSPCA(k) = rms(CGMrow(startSample:endSample))
        startSample = startSample + windowSize/2;
        endSample = startSample +windowSize;
        k = k+1;
    end

    %Distance travelled
    distance = 0;
    for j = 1:length(CGMrow)-1
        distance = distance + abs(CGMrow(j+1)-CGMrow(j));
    end

    %RMS
    RMS = rms(CGMrow);

    %Calculate area under curve
    AUC = trapz(CGMrow) - trapz(min(CGMrow));

    %Calculate Roundness ratio
    rr = distance^2 /(AUC);

    %feature vector
    FeatureVector = [distancePCA RMSPCA AUC rr];
    FeatureMatrix = [FeatureMatrix; FeatureVector];
    normFeatureMatrix = normalize(FeatureMatrix)
    plotFeatureVector = [distance RMS AUC rr];
    plotFeatureMatrix = [plotFeatureMatrix; plotFeatureVector];
end

[coeff, score, latent, explained] = pca(normFeatureMatrix);
top5eigens = coeff(:,1:5);
%plotting bar graph to explain variance
figure(6)
bar(coeff)
title("Variance Explained");
ylabel("Variances");
xlabel("Features");

updatedfeatures = normFeatureMatrix*abs(top5eigens)
titleForGraph = ["Patient1","Patient2","Patient3","Patient4","Patient5"];
color = ['r','g','b','c','m']
 for i = 1:5
     figure(1);
     scatter(X, updatedfeatures(:,i),color(i));
     hold on;
     plot(X, updatedfeatures(:,i),color(i));
     hold on
 end
 title("Graph for " +titleForGraph(1));
 ylabel('New feature values (Principal Components)');
 xlabel('Meals');
 
 
 sum(latent(1:5))/sum(latent(1:10))
 









