function [xhit, yhit, num_dart] = findDartLocation_v2(dart, masks)
    
    rows = size(dart, 1);
    % 找出整個飛鏢盤的寬度
    sBoard = regionprops(masks.whole_board, 'Area', 'BoundingBox');
    [~, boardIndex] = max([sBoard(:).Area]);
    board_width = sBoard(boardIndex).BoundingBox(3);
    
    % 先對 dart map 做 disk dilation，把區域補起來
    dart_mask = (imdilate(dart.^2 > 0.2 * graythresh(dart.^2), ...
        strel('disk', round(rows/100))));
    % 找出該區域的 orientation
    sDart = regionprops(dart_mask, 'Orientation', 'Area', 'BoundingBox');
    % 找出所有區域的Bounding Box的寬度
    dart_bbox = vertcat(sDart(:).BoundingBox);
    dart_width = dart_bbox(:, 3);
    
    % 若該區域寬度和飛鏢盤寬度比例大於0.1，則其可能為有飛鏢
    isDart_thresh = 0.1;
    ratio = dart_width / board_width;
    dartIndex = find(ratio > isDart_thresh);
    
    % 根據前面的 orientation 結果，沿著該方向去對 dart map 做 line dilation
    dart_mask = zeros(size(dart));
    for i = 1:length(dartIndex)
        idx = dartIndex(i);
        x = sDart(idx).BoundingBox(1);
        y = sDart(idx).BoundingBox(2);
        w = sDart(idx).BoundingBox(3);
        h = sDart(idx).BoundingBox(4);
        tmp_dart_mask = zeros(size(dart));
        local_dart = dart(ceil(y):floor(y+h), ceil(x):floor(x+w));
        tmp_dart_mask(ceil(y):floor(y+h), ceil(x):floor(x+w)) = (imclose(local_dart.^2 > 0.2*graythresh(local_dart.^2), ...
            strel('line', 50, sDart(idx).Orientation)));
        dart_mask = dart_mask | tmp_dart_mask;
    end
    
    sDart = regionprops(dart_mask, 'Orientation', 'Area', 'Extrema', 'PixelList', 'BoundingBox');

    % 根據 Orientation 連接之後，再做一次偵測確定飛鏢數量
    dart_bbox = vertcat(sDart(:).BoundingBox);
    dart_width = dart_bbox(:, 3);
    ratio = dart_width / board_width;
    dartIndex = find(ratio > isDart_thresh);

    num_dart = length(dartIndex);
    if (num_dart > 3)
        num_dart = 0;
    end
    
    % 找到極值的座標當作飛鏢落在飛鏢盤上的位置
    xhit = zeros(num_dart, 1);
    yhit = zeros(num_dart, 1);
    for i = 1:num_dart
        if (sDart(dartIndex(i)).Orientation < 0)
            xhit(i) = sDart(dartIndex(i)).Extrema(7,1);
            yhit(i) = sDart(dartIndex(i)).Extrema(7,2);
        else
            xhit(i) = sDart(dartIndex(i)).Extrema(8,1);
            yhit(i) = sDart(dartIndex(i)).Extrema(8,2);
        end
    end
end