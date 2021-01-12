function [backgroundImage, grayBackgroundImage, dartImage, grayDartImage] = cropDartBoard(backgroundImage, dartImage)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Note: 背景必須單純且為淺色   %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % 先將圖片做 Gray Level Thresholding
    grayBackgroundImage = rgb2gray(backgroundImage);
    BWBackgroundImage = grayBackgroundImage > graythresh(grayBackgroundImage);
    % 利用 FloodFill 方式將孔洞補上
    background = imfill(~BWBackgroundImage,'holes');
    
    % 找出最大的 Connected Components 當作 DartBoard 的範圍
    s = regionprops(background,'BoundingBox','Area');
    [~, idx] = max([s(:).Area]);

    % 依照 Proposed DartBoard Region 去對圖片做切割
    backgroundImage = backgroundImage(ceil(s(idx).BoundingBox(2)):floor(s(idx).BoundingBox(2)+s(idx).BoundingBox(4)),...
           ceil(s(idx).BoundingBox(1)):floor(s(idx).BoundingBox(1)+s(idx).BoundingBox(3)),:);
    grayBackgroundImage = rgb2gray(backgroundImage);

    dartImage = dartImage(ceil(s(idx).BoundingBox(2)):floor(s(idx).BoundingBox(2)+s(idx).BoundingBox(4)),...
           ceil(s(idx).BoundingBox(1)):floor(s(idx).BoundingBox(1)+s(idx).BoundingBox(3)),:);
    grayDartImage = rgb2gray(dartImage);
end