%%
% Part 1

% read from excel
targetRed = xlsread('Manual Count.xlsx','B2:B50');
targetNuclei = xlsread('Manual Count.xlsx','C4:C15');

% Particle Detection

info = imfinfo('Image 2 disc ROI.tif');
w = info(1).Width;
h = info(1).Height;

Total_stack = length(info);
Total_frames = Total_stack/3;

frame = 1;
for m=1:3:Total_stack
    Data(frame).RedImage = imread('Image 2 disc ROI.tif',m+1);
    Data(frame).NucleiImage = imread('Image 2 disc ROI.tif',m);
    frame = frame+1;
end

countRed = NaN(Total_frames,1);
for i = 1:Total_frames
    n = 1;
    dif = NaN(1,1000);
    for j = 1:1000
        test = double(Data(i).RedImage);

        median_test = median(test(:));
        thresh = median_test +n*median_test;
        Binary = imbinarize(test,thresh);

        se = strel('disk',2);
        image1_erode = imerode(Binary,se);
        image1_dilation = imdilate(image1_erode,se);

        data = regionprops(image1_dilation,'Area');
        areas = extractfield(data,'Area');

        countRed(i)=length(areas);
        dif(j) = countRed(i)- targetRed(i);

        if dif(j) > 0 % increase threshold
            n = n*(1+dif(j)/max(targetRed));
        elseif dif(j) < 0 % threshold overshot, go back
            n = n/(1+(dif(j-1)+1)/max(targetRed));
        elseif dif(j) == 0 % threshold good enough, display image
%             figure('Name',num2str(i));
%             imshowpair(test,image1_dilation,'montage')
            break
        end
    end
end
disp('Done with Red')


countNuclei = NaN(length(targetNuclei),1);
for i = 1:length(targetNuclei)
    n = 0.1;
    dif = NaN(1,1000);
    for j = 1:1000
        test = double(Data(i+2).NucleiImage);

        median_test = median(test(:));
        thresh = median_test +n*median_test;
        Binary = imbinarize(test,thresh);

        se = strel('disk',2);
        image1_erode = imerode(Binary,se);
        image1_dilation = imdilate(image1_erode,se);

        data = regionprops(image1_dilation,'Area');
        
        if min(size(data)) == 1
            areas = extractfield(data,'Area');
        else
            areas = zeros(1,10);
        end
        
        countNuclei(i)=length(areas);
        dif(j) = countNuclei(i)- targetNuclei(i);

        if dif(j) > 0 % increase threshold
            n = n*(1+dif(j)/max(targetNuclei));
        elseif dif(j) < 0 % threshold overshot, go back
            n = n/(1+(dif(j-1)+1)/max(targetNuclei));
        elseif dif(j) == 0 % threshold good enough, display image
%             figure('Name',num2str(i));
%             imshowpair(test,image1_dilation,'montage')
            break
        end
    end
end
disp('Done with Nuclei')

clearvars -except countRed countNuclei
countRed
countNuclei
%%
%%%%%%%%%%%%%%%%%%%%%
% Part 2

% load images separatly
PathName = uigetdir;
cd(PathName);

filenames = dir;
keep = [];
for m=1:length(filenames)
    test = filenames(m,1).name;
    if (length(test) > 3) && (strcmp(test(length(test)-2:end), 'pgm') == 1)
        keep = [keep m]; 
    end
end

filenames = filenames(keep);
frame_no = length(filenames);
ImageInfo = imfinfo(filenames(1,1).name);
w = ImageInfo(1).Width;
h = ImageInfo(1).Height;

avg_load = NaN(h,w,frame_no/50);

k = 1;
for frames = 1:50:frame_no
    temp_stack = NaN(h,w,50);
    j=1;
    for sub_frames = frames:frames+49
        temp_stack(:,:,j) = 255-double(imread(filenames(sub_frames).name));
        j=j+1;
        disp(num2str(sub_frames)); % monitor progress
    end
    avg_load(:,:,k) = mean(temp_stack,3);
    k=k+1;
end

clear temp_stack
Total_AVG = mean(avg_load,3);

clear avg_load
%%

% make a binary mask with for the wells
mask = sum(double(imread('mask.png')),3); 
mask(mask == 0) = 1;
mask(mask ~= 1) = 0;

figure;
colormap(gray);
se = strel('disk',2);
for choice =1:600
    temp = (255-double(imread(filenames(choice).name))) - Total_AVG;
    temp = temp.*mask; % will remove all of the image outside of the wells
    % which is where a lot of the noise comes from
    thresh = median(temp(:)) + 0.9*std(temp(:)); % focus on the wells
    Binary = imbinarize(temp,thresh);
    
    image1_erode = Binary;
    for k=1:2
        image1_erode = imerode(image1_erode,se);
    end    
    image1_dilation = image1_erode;
    for k=1:2
        image1_dilation = imdilate(image1_dilation,se);
    end
    imagesc(image1_dilation);
    axis image
    title(['Frame: ',num2str(choice)]);
    drawnow
end

