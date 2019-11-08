% Find files

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

% Create AVG image
avg_load = NaN(h,w,frame_no);
for frame = 1:frame_no
    avg_load(:,:,frame) = 255-double(imread(filenames(frame).name));
end
AVG_stack = mean(avg_load,3);

clear avg_load
%% 

choice = 1;

temp = (255-double(imread(filenames(choice).name))) - AVG_stack;
figure;
colormap(gray)
subplot(1,3,1)
imagesc(255-double(imread(filenames(frame).name)));
title(['Frame: ',num2str(choice)]);
axis image
subplot(1,3,2)
imagesc(AVG_stack);
title(['Frame: ',num2str(choice)]);
axis image
subplot(1,3,3)
imagesc(temp)
title(['Frame: ',num2str(choice)]);
axis image
%% 

% Threshold

med_test = median(temp(:));
std_test = std(temp(:));
thresh = med_test + std_test;
Binary = imbinarize(temp,thresh);
figure;
title(['Frame: ',num2str(choice)]);
imshowpair(temp,Binary,'montage')

%%

% Erosion Dilation

se = strel('disk',2);

image1_erode = Binary;
for k=1:2
image1_erode = imerode(image1_erode,se);
end
figure; imshowpair(temp,image1_erode,'montage');title(['Frame: ',num2str(choice)]);

image1_dilation = image1_erode;
for k=1:2
image1_dilation = imdilate(image1_dilation,se);
end
figure; imshowpair(temp,image1_dilation,'montage');title(['Frame: ',num2str(choice)]);


particle_data = regionprops(image1_dilation, 'Centroid','Area','Eccentricity');

%% 
% Movie section

figure;
colormap(gray);
for choice =1:600
    temp = (255-double(imread(filenames(choice).name))) - AVG_stack;
    thresh = median(temp(:)) + std(temp(:));
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


%% 

% Create AVG of inverted images
% File too large to do one large average, so need to chunk.

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
    
