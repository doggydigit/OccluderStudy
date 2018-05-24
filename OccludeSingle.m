close all
clear all
disp('Loading Images')
load Images101

%% Occlude Images
disp('Occluding Images')
nr_visi = 10;
radi = linspace(0, 0.45, nr_visi);
occluded_images = cell(nr_visi,1);
occluder_masks = cell(nr_visi,1);
occluded_images{1} = images;
nrclasses = length(images);
for c = 1:nrclasses
    for i = 1:length(images{c})
        imsize = size(images{c}{i});
        for r=1:nr_visi
            occluder_masks{r}{c}{i} = true(imsize(1), imsize(2));
        end
    end
end
for r = 2:nr_visi
    %% Initialize/Predefine some stuff
    occluded_images{r} = images;
    occluder_masks{r} = cell(length(images),1);
    
    %% Occlude all images
    for c = 1:nrclasses
        for i = 1:length(images{c})
            imsize = size(images{c}{i});
            color = length(imsize) == 3;
            rad = floor(min(imsize(1:2))*radi(r))-1;
            cx = randi([rad+1, imsize(2)-rad]);
            cy = randi([rad+1, imsize(1)-rad]);
            occshape = randi(4);
            switch occshape
                case 1
                    %% Occluding with Circle
                    occluder_masks{r}{c}{i} = true(imsize(1), imsize(2));
                    r2 = rad^2;
                    for y = 1:imsize(1)
                        for x = 1:imsize(2)
                            if (y-cy)^2 + (x-cx)^2 <= r2
                                occluder_masks{r}{c}{i}(y,x) = false;
                                if color
                                    occluded_images{r}{c}{i}(y,x,:) = 0;
                                else
                                    occluded_images{r}{c}{i}(y,x) = 0;
                                end
                            end
                        end
                    end
                case 2
                    %% Occluding with square
                    occluder_masks{r}{c}{i} = true(imsize(1), imsize(2));
                    for y = cy-rad:cy+rad
                        for x = cx-rad:cx+rad
                            occluder_masks{r}{c}{i}(y,x) = false;
                            if color
                                occluded_images{r}{c}{i}(y,x,:) = 0;
                            else
                                occluded_images{r}{c}{i}(y,x) = 0;
                            end
                        end
                    end
                case 3
                    %% Occluding with upward triangle
                    h = round(sqrt(3)*rad/2);
                    occluder_masks{r}{c}{i} = poly2mask([cx-rad, cx+rad, cx],[cy-h, cy-h, cy+h],imsize(1),imsize(2));
                    if color
                        occluded_images{r}{c}{i}(repmat(occluder_masks{r}{c}{i},1,1,3)) = 0;
                    else 
                        occluded_images{r}{c}{i}(occluder_masks{r}{c}{i}) = 0;
                    end
                    occluder_masks{r}{c}{i} = ~occluder_masks{r}{c}{i};
                case 4
                    %% Occluding with downward triangle
                    h = round(sqrt(3)*rad/2);
                    occluder_masks{r}{c}{i} = poly2mask([cx-rad, cx+rad, cx],[cy+h, cy+h, cy-h],imsize(1),imsize(2));
                    if color
                        occluded_images{r}{c}{i}(repmat(occluder_masks{r}{c}{i},1,1,3)) = 0;
                    else 
                        occluded_images{r}{c}{i}(occluder_masks{r}{c}{i}) = 0;
                    end
                    occluder_masks{r}{c}{i} = ~occluder_masks{r}{c}{i};
                otherwise
                    print('BUGGGG');
            end
        end
    end
end
save(strcat('Occluded_C101_poriginal.mat'), 'occluded_images', 'masks', 'classes', 'occluder_masks', 'radi','-v7.3');


%% Resize images to size dasz x dasz
% clear all
% close all
% load Occluded_C101_poriginal.mat
% nrclasses = length(masks);
% nr_radi = length(occluder_masks);
disp('Resizing Images')
dasz = 227;
for r=1:nr_radi
    for c=1:nrclasses
        for i=length(occluded_images{r}{c}):-1:1
            sz = size(occluded_images{r}{c}{i});
            if max(sz) > dasz
                f = dasz/max(sz);
                occluder_masks{r}{c}{i} =  imresize(occluder_masks{r}{c}{i}, [round(f*sz(1)), round(f*sz(2))]);
                occluded_images{r}{c}{i} =  imresize(occluded_images{r}{c}{i}, [round(f*sz(1)), round(f*sz(2))]);
                sz = size(occluded_images{r}{c}{i});
            end
            ys = ceil((dasz+1 - sz(1))/2);
            xs = ceil((dasz+1 - sz(2))/2);
            m1 = repmat(uint8(255), dasz, dasz, 3);
            m2 = true(dasz, dasz);
            m2(ys:ys+sz(1)-1, xs:xs+sz(2)-1) = occluder_masks{r}{c}{i};
            if length(sz) == 3
                m1(ys:ys+sz(1)-1, xs:xs+sz(2)-1,:) = occluded_images{r}{c}{i};
            else
                m1(ys:ys+sz(1)-1, xs:xs+sz(2)-1,:) = repmat(occluded_images{r}{c}{i}, 1, 1, 3);
            end
            occluded_images{r}{c}{i} = m1;
            occluder_masks{r}{c}{i} = m2;
        end
    end
end

%% Resize Masks the same way
for c=1:nrclasses
    for i=length(masks{c}):-1:1
        sz = size(masks{c}{i});
        if max(sz) > dasz
            f = dasz/max(sz);
            masks{c}{i} =  imresize(masks{c}{i}, [round(f*sz(1)), round(f*sz(2))]);
            sz = size(masks{c}{i});
        end
        ys = ceil((dasz+1 - sz(1))/2);
        xs = ceil((dasz+1 - sz(2))/2);
        m = false(dasz, dasz);
        m(ys:ys+sz(1)-1, xs:xs+sz(2)-1) = masks{c}{i};
        masks{c}{i} = m;
    end
end


%% Save occluded Images to mat 
disp('Saving Images to .mat files')
save(strcat('Occluded_C101_p', int2str(dasz), '.mat'), 'occluded_images', 'masks', 'classes', 'occluder_masks', 'radi','-v7.3');
% clear all


%% Save images and masks to jpg files
% load Occluded_C101_p227.mat
disp('Saving Images to .jpg files')
for c=1:length(occluded_images{1})
    for i=1:length(occluded_images{1}{c})
        imwrite(masks{c}{i}, strcat('SimpleOccluded', int2str(dasz), '/imagemask_', int2str(c), '_', int2str(i), '.jpg'))
        for r=1:length(occluded_images)
            imwrite(occluded_images{r}{c}{i},strcat('SimpleOccluded', int2str(dasz), '/occluded_image_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg'))
            imwrite(occluder_masks{r}{c}{i},strcat('SimpleOccluded', int2str(dasz), '/occluded_imagemask_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg'))
        end     
    end
end
% Save some information to make loading easier from python
nr_classes = length(occluded_images{1});
classsizes = zeros(nr_classes,1);
for c=1:nr_classes
    classsizes(c) = length(occluded_images{1}{c});
end
nrimgs = sum(classsizes);
save(strcat('SimpleOccluded', int2str(dasz), '/info.mat'), 'nr_radi', 'nrclasses', 'classsizes', 'nrimgs')