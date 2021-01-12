function [score, hitMask] = getScore(x, y, center, region, masks)

    [rows, columns] = size(masks.board);
    x = round(x); y = round(y);

    % 以飛鏢盤的中心點作為圓心，根據飛鏢落的位置計算角度
    hitAngle = atan2(y - center.Centroid(2), (x - center.Centroid(1)));
    hitAngle = mod((hitAngle * 180 / pi) + 360, 360);

    % 查看該角度落在哪一個分數的區間裡面
    for i = 1:numel(region)
        if (hitAngle > region(i).minAngle) && (hitAngle <= region(i).maxAngle)
            hitRegion = i;
            break;
        end
    end
    if (hitAngle > region(20).minAngle) || (hitAngle <= region(20).maxAngle)
        hitRegion = 20;
    end    

    % 將極座標(Polar)表示法轉換成直角座標(Cartesian)表示法
    [x1, y1] = pol2cart(deg2rad(region(hitRegion).minAngle), max(rows, columns));
    [x2, y2] = pol2cart(deg2rad(region(hitRegion).maxAngle), max(rows, columns));
    % 從飛鏢盤中心沿著兩側夾角展出的扇形
    hitMask = poly2mask([0 x1 x2] + center.Centroid(1), ...
                        [0 y1 y2] + center.Centroid(2), ...
                        rows, columns);

    % 查看飛鏢落在哪個得分區域(ex:單倍、雙倍、三倍、沒得分)
    score = region(hitRegion).value;
    if masks.single(y, x)
        hitMask = masks.single .* hitMask;
    elseif masks.double(y, x)
        score = score * 2;
        hitMask = masks.double .* hitMask;
    elseif masks.triple(y, x)
        score = score * 3;
        hitMask = masks.triple .* hitMask;
    elseif masks.miss(y, x)
        score = score * 0;
        hitMask = masks.miss;
    elseif masks.innerBull(y, x)
        score = 50;
        hitMask = masks.innerBull;
    elseif masks.outerBull(y, x)
        score = 25;
        hitMask = masks.outerBull;
    end

    hitMask = hitMask > 0.5;
end

