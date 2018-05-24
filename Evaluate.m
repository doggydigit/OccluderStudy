
%% Old Stuff
% oldlabels = {{'BRAIN'}
%     {'plane', 'warplane', 'airliner'}
%     {'BONSAI'}
%     {'BUDDHA'}
%     {'monarch', 'ringlet', 'lycaenid'}
%     {'CHANDELIER'}
%     {'rock crab', 'Dungeness crab', 'king crab', 'fiddler crab'}
%     {'American lobster', 'crayfish', 'spiny lobster'}
%     {'dalmatian'}
%     {'vase', 'whiskey jug', 'pitcher', 'water jug', 'teapot'} % 10
%     {'FACE'}
%     {'grand piano'}
%     {'loggerhead', 'leatherback turtle', 'terrapin'}
%     {'HELICOPTER'}
%     {'black stork', 'spoonbill', 'hornbill', 'goose', 'white stork', 'vulture', 'dowitcher', 'redshank', 'crane', 'little blue heron', 'magpie', 'coucal', 'limpkin', 'sulphur-crested cockatoo', 'flamingo', 'American egret', 'house finch', 'macaw'}
%     {'wallaby'}
%     {'catamaran', 'yawl', 'schooner', 'trimaran'} % 17
%     {'notebook', 'laptop', 'screen', 'space bar', 'hand-held computer', 'desktop computer', 'iPod'}
%     {'cheetah', 'leopard', 'jaguar'}
%     {'llama'} % 20
%     {'MENORAH'}
%     {'tricycle', 'moped', 'bicycle-built-for-two', 'mountain bike', 'motor scooter'}
%     {'revolver', 'rifle', 'assault rifle'}
%     {'starfish'} % 24
%     {'SUNFLOWER'}
%     {'trilobite', 'chiton'}
%     {'umbrella'} % 27
%     {'analog clock', 'stopwatch', 'digital watch', 'wall clock', 'digital clock'}
%     };
% goodclasses = [0,1,0,0,1,0,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,1,1];

%% Predefine some stuff
clear all
close all
net = alexnet;
labels = {{'plane', 'warplane', 'airliner'}
    {'monarch', 'ringlet', 'lycaenid'}
    {'rock crab', 'Dungeness crab', 'king crab', 'fiddler crab'}
    {'American lobster', 'crayfish', 'spiny lobster'}
    {'dalmatian'}
    {'vase', 'whiskey jug', 'pitcher', 'water jug', 'teapot'} % 6
    {'grand piano'}
    {'loggerhead', 'leatherback turtle', 'terrapin'}
    {'black stork', 'spoonbill', 'hornbill', 'goose', 'white stork', 'vulture', 'dowitcher', 'redshank', 'crane', 'little blue heron', 'magpie', 'coucal', 'limpkin', 'sulphur-crested cockatoo', 'flamingo', 'American egret', 'house finch', 'macaw'}
    {'wallaby'} % 10
    {'catamaran', 'yawl', 'schooner', 'trimaran'} % 11
    {'notebook', 'laptop', 'screen', 'space bar', 'hand-held computer', 'desktop computer', 'iPod'}
    {'cheetah', 'leopard', 'jaguar'}
    {'llama'} % 14
    {'tricycle', 'moped', 'bicycle-built-for-two', 'mountain bike', 'motor scooter'}
    {'revolver', 'rifle', 'assault rifle'}
    {'starfish'} % 17
    {'trilobite', 'chiton'}
    {'umbrella'} % 19
    {'analog clock', 'stopwatch', 'digital watch', 'wall clock', 'digital clock'}
    };

%% Evaluate occluded images
disp('Evaluating occluded images')
load Occluded_C101_p227.mat
nrclasses = length(classes);
nr_radi = length(occluded_images);
accuracy = zeros(nrclasses, nr_radi);
totalaccu = zeros(nr_radi, 1);
disp('Evaluating radius:')
for r=1:nr_radi
    disp(r)
    for c=1:nrclasses
        for i=1:length(occluded_images{r}{c})
           l = classify(net,occluded_images{r}{c}{i});
           if any(strcmp(labels{c},char(l(1))))
               accuracy(c,r) = accuracy(c,r) + 1;
           end
        end
        accuracy(c,r) = accuracy(c,r)/length(occluded_images{r}{c});
        totalaccu(r) = totalaccu(r) + accuracy(c,r);
    end
end
totalaccu = totalaccu/20;
clear occluded_images
clear occluder_masks
save('alexnet_accuracy', 'accuracy', 'totalaccu')

%% Evaluate generated occluded images
disp('Evaluating regenerated occluded images')
% load alexnet_accuracy
% nrclasses = length(classes);
% nr_radi = length(totalaccu);
a1 = accuracy(:,1);
ta1 = totalaccu(1);
load SimpleOccluded320/info.mat
nr_levels = 10;
gen_accuracy = zeros(nrclasses, nr_levels);
gen_totalaccu = zeros(nr_levels, 1);
disp('Evaluating radius:')
for r=2:nr_levels
    disp(r)
    for c=1:nrclasses
        for i=1:classsizes(c)
            img = imresize(imread(strcat('SimpleOccluded320/gen_deepoutshape_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg')), [227, 227]);
            l = classify(net,img);
            if any(strcmp(labels{c},char(l(1))))
               gen_accuracy(c,r) = gen_accuracy(c,r) + 1;
           end
        end
        gen_accuracy(c,r) = gen_accuracy(c,r)/classsizes(c);
        gen_totalaccu(r) = gen_totalaccu(r) + gen_accuracy(c,r);
    end
end
gen_totalaccu = gen_totalaccu/nrclasses;
gen_accuracy(:,1) = a1;
gen_totalaccu(1) = ta1;
save('gen_deepoutshape_alexnet_accuracy', 'gen_accuracy', 'gen_totalaccu')