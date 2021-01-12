function [masks] = findRegionMasks(image)

    grayImage = rgb2gray(image);

    redRegions = image(:,:,1) - grayImage;
    masks.red = redRegions > graythresh(redRegions);

    greenRegions = image(:,:,2) - grayImage;
    masks.green = greenRegions > graythresh(greenRegions);

    % 分數加倍的圓環區為紅綠相間，故將兩個做相加得到加倍區
    masks.multipliers = masks.red + masks.green;

    % 利用 disk structural element 去做 dilation，把紅綠之間的縫隙補齊
    se = strel('disk', round(numel(image(:,1,1))/100));
    masks.multRings = imclose(masks.multipliers, se);
    
    % 把加倍區以內的部分填滿即為整個圓盤的有效得分區域
    masks.board = imfill(masks.multRings, 'holes');
    % 以外則為無效得分區域
    masks.miss = ~masks.board;

    % 加倍區以外的地方為single area
    masks.single = masks.board - masks.multRings;
    % 標靶的最外圍為double area
    masks.double = masks.board - imfill(masks.single, 'holes');

    innerRing = imfill((masks.board - masks.double - masks.single), 'holes') - ...
        (masks.board - masks.double - masks.single);

    % 圓盤中間部分為triple area
    masks.triple = masks.board - masks.double - masks.single - imfill(innerRing, 'holes');
    masks.triple(masks.triple < 0) = 0;

    % 圓盤中心為bulleye
    masks.outerBull = (masks.multRings - masks.double - masks.triple) .* masks.green;
    masks.innerBull = (masks.multRings - masks.double - masks.triple) .* masks.red;
    
    % 整個圓盤(包含無得分的區域)
    edgeImage = edge(grayImage, 'canny', 0.25);
    im_dilate = imfill(imdilate(edgeImage, ...
                    strel('disk', round(size(edgeImage, 1)/150))), 'holes');
    % Erode程度比Dilate大以避免圓盤邊界誤差被考慮進去
    whole_board = imerode(im_dilate, ...
                    strel('disk', round(size(edgeImage, 1)/80)));
    masks.whole_board = whole_board;
end

