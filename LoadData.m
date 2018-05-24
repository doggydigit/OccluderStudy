close all
clear all

% oldclasses = {'brain', 'airplanes', 'bonsai', 'buddha', 'butterfly', ...
%     'chandelier', 'crab', 'crayfish', 'dalmatian', 'ewer', 'Faces', ...
%     'grand_piano', 'hawksbill', 'helicopter', 'ibis', 'kangaroo', 'ketch', ...
%     'laptop', 'Leopards', 'llama', 'menorah', 'Motorbikes', 'revolver', ...
%     'starfish', 'sunflower', 'trilobite', 'umbrella', 'watch'};

classes = {'airplanes', 'butterfly', 'crab', 'crayfish', 'dalmatian', ...
    'ewer', 'grand_piano', 'hawksbill', 'ibis', 'kangaroo', 'ketch', ...
    'laptop', 'Leopards', 'llama', 'Motorbikes', 'revolver', 'starfish', ...
    'trilobite', 'umbrella', 'watch'};

% potentiallbadclasses = {'brain', 'airplanes', 'bonsai', 'buddha', ...
%     'chandelier', 'crab', 'crayfish', 'dalmatian', 'Faces', ...
%     'hawksbill', 'ibis', 'ketch', ...
%     'menorah', 'Motorbikes', ...
%     'sunflower'};
% 
% classesthatwillneedmerging = {'brain', 'airplanes', 'bonsai', 'buddha', ...
%     'chandelier', 'crab', 'crayfish', 'dalmatian', 'Faces', ...
%     'hawksbill', 'helicopter', 'ibis', 'kangaroo', 'ketch', ...
%     'menorah', 'Motorbikes', 'revolver', ...
%     'sunflower', 'umbrella', 'watch'};


%% Load Images and Masks
nrclasses = length(classes);
images = cell(nrclasses, 1);
masks = cell(nrclasses, 1);
for c=1:nrclasses
    imgfiles = dir(strcat('101_ObjectCategories/', classes{c}, '/*.jpg'));
    anofiles = dir(strcat('Annotations/', classes{c}, '/*.mat'));
    nrimgs = length(imgfiles);
    nranos = length(anofiles);
    if nrimgs ~= nranos
        disp(classes{c});
    end
    images{c} = cell(nrimgs, 1);
    masks{c} = cell(nrimgs, 1);
    for f=1:nrimgs
        images{c}{f} = imread(strcat('101_ObjectCategories/', classes{c}, '/', imgfiles(f).name));
        load(strcat('Annotations/', classes{c}, '/', anofiles(f).name));
        szes = size(images{c}{f});
        masks{c}{f} = poly2mask(obj_contour(1,:)+box_coord(3),obj_contour(2,:)+box_coord(1), szes(1), szes(2));
    end
end

%% Count number of images
nr_imgs = 0;
for c=1:nrclasses
    nr_imgs = nr_imgs + length(images{c});
end

%% Keep only images with desired sizes
szes = zeros(nr_imgs, 2);
ratios = zeros(nr_imgs,1);
j=1;
for c=1:nrclasses
    for i=length(images{c}):-1:1
        sz = size(images{c}{i});
        szes(j,:) = sz(1:2);
        if sz(1) > sz(2)
            ratios(j) = sz(1)/sz(2);
        else
            ratios(j) = sz(2)/sz(1);
        end
        if ratios(j) > 2
            images{c}(i)=[];
            masks{c}(i)=[];
        end
        j=j+1;
    end
end

%% Save images and masks
save('Images101.mat', 'images', 'masks', 'classes');
