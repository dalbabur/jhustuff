% Particle Detection

info = imfinfo('Image 2 disc ROI.tif');
w = info(1).Width;
h = info(1).Height;

Total_stack = length(info);
Total_frames = Total_stack/3;

% Cells, Red, Green
% We care about Cells and Red.

% Make an empty stack
% NOTE: Normally the order of dimensions for an image is w,h,z.
% BUT, order for matrix is row, column, z. (row = h, column = w)


frame = 1;
for m=1:3:Total_stack
    Data(frame).RedImage = imread('Image 2 disc ROI.tif',m+1);
    Data(frame).NucleiImage = imread('Image 2 disc ROI.tif',m);
    frame = frame+1;
end

% Binarize Red Image

test = double(Data(5).RedImage);
median_test = median(test(:));
thresh = median_test +3*median_test;
Binary = imbinarize(test,thresh);
figure;
imshowpair(test,Binary,'montage')

particle_data = regionprops(Binary, 'Centroid','Area');
areas = sort(extractfield(particle_data,'Area'),'descend');

% EROSION AND DILATION

se = strel('disk',2);

image1_erode = imerode(Binary,se);
figure; imshowpair(test,image1_erode,'montage')

image1_dilation = imdilate(image1_erode,se);
figure; imshowpair(test,image1_dilation,'montage')

particle_data = regionprops(image1_dilation, 'Centroid','Area');

% Use Binary Image as a Mask

figure; imshowpair(test,image1_dilation.*test,'montage');

particle_data = regionprops(image1_dilation,image1_dilation.*test, 'Centroid','Area','MeanIntensity');


areas = extractfield(particle_data,'Area');
positions = extractfield(particle_data,'Centroid');
Data(5).Area = areas;
Data(5).Positions = positions;


% Nuclei Manipulation

test = ((2^16)-1) - double(Data(9).NucleiImage);
med_test = median(test(:));
test(test>((2^16)-10)) = med_test;
thresh = med_test + 0.2*med_test;
Binary = imbinarize(test,thresh);
figure;
imshowpair(test,Binary,'montage')

se = strel('disk',5);

image1_erode = imerode(Binary,se);
figure; imshowpair(test,image1_erode,'montage')

image1_dilation = imdilate(image1_erode,se);
figure; imshowpair(test,image1_dilation,'montage')

