% COMPRESSION

RGB = imread('autumn.tif');
I = rgb2gray(RGB);

I = imread('cameraman.tif');

J = dct2(I);

figure
imshow(log(abs(J)),[])
colormap(gca,jet(64))
colorbar

J(abs(J) < 10) = 0;

J = sparse(J);

K = idct2(full(J));

figure
imshowpair(I,K,'montage')
title('Original Grayscale Image (Left) and Processed Image (Right)');

% Make an experimental image

% Create a logical image of a circle with specified
% diameter, center, and image size.
% First create the image.
imageSizeX = 1000;
imageSizeY = 1000;
[columnsInImage,rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = 500;
centerY = 500;
radius = 100;

stripes = zeros(1000,1000);
stripe_locs = 100:50:950;

for m=1:length(stripe_locs)
    stripes(:,stripe_locs(m):stripe_locs(m)+25) = 1;
end

stripes_rot = imrotate(stripes,45,'nearest','crop');

circlePixels1 = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;

circlePixels1 = circlePixels1.*stripes;


circlePixels2 = (rowsInImage - 300).^2 ...
    + (columnsInImage - 300).^2 <= radius.^2;
circlePixels2 = circlePixels2.*stripes_rot;

% circlePixels is a 2D "logical" array.
% Now, display it.
figure;
subplot(2,2,1)
imagesc(circlePixels1) ;
axis square
subplot(2,2,2)
imagesc(circlePixels2) ;
axis square
subplot(2,2,3)
imagesc(stripes) ;
axis square
colormap(gray);

% Rotation
spacing = 0.5;
N = 180/spacing;
thetas = linspace(0, 180-spacing, N);
image1 = circlePixels1;
image2 = circlePixels2;


%Find fft of the Radon transform
F1 = abs(fft(radon(image1, thetas)));
F2 = abs(fft(radon(image2, thetas)));

figure;
subplot(3,2,1);imagesc(image1);
subplot(3,2,2);imagesc(image2);
subplot(3,2,3);imagesc(radon(image1, thetas));
subplot(3,2,4);imagesc(radon(image2,thetas));
subplot(3,2,5);imagesc(F1);
subplot(3,2,6);imagesc(F2);

%Find the index of the correlation peak
correlation = sum(fft2(F1) .* fft2(F2));
peaks = real(ifft(correlation));
[~,peakIndex] = max(peaks);


rotatedImage = imrotate(image2,-thetas(peakIndex),'crop');

figure;
subplot(2,2,1)
imagesc(image1) ;
axis square
subplot(2,2,2)
imagesc(image2) ;
axis square
subplot(2,2,3)
imagesc(rotatedImage) ;
axis square
colormap(gray);

% Translation

[optimizer,metric] = imregconfig('multimodal');
alignedImage = imregister(rotatedImage,image1,'translation',optimizer,...
    metric);

subplot(2,2,4)
imagesc(alignedImage) ;
axis square
colormap(gray);

% Invert image intensities

InvertedImage = 255 - I; %255 if used because it's an 8-bit image (2^8-1 = 255)

% Binarize image;

threshold = 180;
Binary = I;
Binary(Binary < threshold) = 0;
Binary = logical(Binary);

figure;hist(double(I(:)),100);

Binary2 = imbinarize(I);

figure;
colormap(gray);
subplot(1,3,1);
imagesc(I);
subplot(1,3,2);
imagesc(Binary);
subplot(1,3,3);
imagesc(Binary2);

% Particle Detection

particle_data = regionprops(Binary2, 'Centroid','Area','PixelList');



% AVERAGE

% STD

