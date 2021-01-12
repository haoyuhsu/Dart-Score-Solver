clear all;
m = mobiledev;
cam = camera(m, 'back');
cam.Resolution = '1280x720';

for i = 1:3
    dart = snapshot(cam, 'manual');
    write_dir = strcat('./', 'mobile_', string(4-i), '_dart', '.jpg');
    imwrite(dart, write_dir);
end

no_dart = snapshot(cam, 'manual');
imwrite(no_dart, 'mobile_no_dart.jpg');



